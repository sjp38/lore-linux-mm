Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAC856B02F9
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 06:12:18 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o14so20494936wrf.6
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:12:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p9sor2396123wmb.4.2017.11.28.03.12.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 03:12:17 -0800 (PST)
Date: Tue, 28 Nov 2017 12:12:14 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] vfs: Add PERM_* symbolic helpers for common file
 mode/permissions
Message-ID: <20171128111214.42esi4igzgnldsx5@gmail.com>
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.563046145@linutronix.de>
 <20171127094156.rbq7i7it7ojsblfj@hirez.programming.kicks-ass.net>
 <20171127100635.kfw2nspspqbrf2qm@gmail.com>
 <CA+55aFyLC9+S=MZueRXMmwwnx47bhovXr1YhRg+FAPFfQZXoYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyLC9+S=MZueRXMmwwnx47bhovXr1YhRg+FAPFfQZXoYA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, linux-mm <linux-mm@kvack.org>, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Nov 27, 2017 at 2:06 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> >
> > +/*
> > + * Human readable symbolic definitions for common
> > + * file permissions:
> > + */
> > +#define PERM_r________ 0400
> > +#define PERM_r__r_____ 0440
> > +#define PERM_r__r__r__ 0444
> 
> I'm not a fan. Particularly as you have a very random set of
> permissions (rx and wx? Not very common),

So I originally created those defines based on a grep of patterns used in the 
kernel, and added the 'wx' variants for completeness.

We would only need a small subset. Here's a git grep based histogram of octal file 
permission masks used in the kernel source:

      # mode
     21 0200
      8 0220
     14 0222
     33 0400
     11 0440
    219 0444
     91 0555
     39 0600
    906 0644
     12 0660
     12 0664
     18 0666
     14 0755
     31 0777

So there's literally only 14 variants used, and 0644 and 0444 make up 95% of the 
cases. We get the patch below if we extend these existing patterns using their 
natural (looking) generators to a complete group - 19 patterns that should cover 
all the sensible combinations.

> but also because it's just not that legible.

Fair enough.

Thanks,

	Ingo

---
 include/linux/stat.h |   28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

Index: tip/include/linux/stat.h
===================================================================
--- tip.orig/include/linux/stat.h
+++ tip/include/linux/stat.h
@@ -6,6 +6,34 @@
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
 #define S_IRWXUGO	(S_IRWXU|S_IRWXG|S_IRWXO)
 #define S_IALLUGO	(S_ISUID|S_ISGID|S_ISVTX|S_IRWXUGO)
 #define S_IRUGO		(S_IRUSR|S_IRGRP|S_IROTH)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
