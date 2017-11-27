Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D79E76B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 05:06:39 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v69so14667049wrb.3
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:06:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7sor3526246wmc.56.2017.11.27.02.06.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 02:06:38 -0800 (PST)
Date: Mon, 27 Nov 2017 11:06:35 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH] vfs: Add PERM_* symbolic helpers for common file
 mode/permissions
Message-ID: <20171127100635.kfw2nspspqbrf2qm@gmail.com>
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.563046145@linutronix.de>
 <20171127094156.rbq7i7it7ojsblfj@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127094156.rbq7i7it7ojsblfj@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Mon, Nov 27, 2017 at 12:14:07AM +0100, Thomas Gleixner wrote:
> >  static int __init pt_dump_debug_init(void)
> >  {
> > +	pe_knl = debugfs_create_file("kernel_page_tables", S_IRUSR, NULL, NULL,
> > +				     &ptdump_fops);
> > +	if (!pe_knl)
> >  		return -ENOMEM;
> >  
> > +	pe_curknl = debugfs_create_file("current_page_tables_knl", S_IRUSR,
> > +					NULL, NULL, &ptdump_curknl_fops);
> > +	if (!pe_curknl)
> > +		goto err;
> > +
> > +#ifdef CONFIG_KAISER
> > +	pe_curusr = debugfs_create_file("current_page_tables_usr", S_IRUSR,
> > +					NULL, NULL, &ptdump_curusr_fops);
> > +	if (!pe_curusr)
> > +		goto err;
> > +#endif
> >  	return 0;
> > +err:
> > +	pt_dump_debug_remove_files();
> > +	return -ENOMEM;
> >  }
> 
> 
> Could we pretty please use the octal permission thing? I can't read
> thise S_crap nonsense.

They are completely unreadable to me too. So if we added these helpers I sent a 
year ago:

	https://lwn.net/Articles/696231/

Then the above could be written as:

	pe_curknl = debugfs_create_file("current_page_tables_knl", PERM_r________,
					NULL, NULL, &ptdump_curknl_fops);

... etc., which is much more readable IMHO. Not only that, it would be trivial to 
_write_ permission masks as well. I just wrote this:

	PERM_rw_r__r__

Which is so much more readable than "S_IRUGO|S_IWUSR" or even "0644". The former 
pattern is used 527 times in the kernel ...

The patch below adds it to the current kernel.

Thanks,

	Ingo
---
Signed-off-by: Ingo Molnar <mingo@kernel.org>

 include/linux/stat.h | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/include/linux/stat.h b/include/linux/stat.h
index 22484e44544d..fc389c3a8692 100644
--- a/include/linux/stat.h
+++ b/include/linux/stat.h
@@ -6,6 +6,38 @@
 #include <asm/stat.h>
 #include <uapi/linux/stat.h>
 
+/*
+ * Human readable symbolic definitions for common
+ * file permissions:
+ */
+#define PERM_r________	0400
+#define PERM_r__r_____	0440
+#define PERM_r__r__r__	0444
+
+#define PERM_rw_______	0600
+#define PERM_rw_r_____	0640
+#define PERM_rw_r__r__	0644
+#define PERM_rw_rw_r__	0664
+#define PERM_rw_rw_rw_	0666
+
+#define PERM__w_______	0200
+#define PERM__w__w____	0220
+#define PERM__w__w__w_	0222
+
+#define PERM_r_x______	0500
+#define PERM_r_xr_x___	0550
+#define PERM_r_xr_xr_x	0555
+
+#define PERM_rwx______	0700
+#define PERM_rwxr_x___	0750
+#define PERM_rwxr_xr_x	0755
+#define PERM_rwxrwxr_x	0775
+#define PERM_rwxrwxrwx	0777
+
+#define PERM__wx______	0300
+#define PERM__wx_wx___	0330
+#define PERM__wx_wx_wx	0333
+
 #define S_IRWXUGO	(S_IRWXU|S_IRWXG|S_IRWXO)
 #define S_IALLUGO	(S_ISUID|S_ISGID|S_ISVTX|S_IRWXUGO)
 #define S_IRUGO		(S_IRUSR|S_IRGRP|S_IROTH)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
