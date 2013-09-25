Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B56BD6B0034
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 13:12:50 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so6305586pdj.25
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:12:50 -0700 (PDT)
From: "Timothy Pepper" <timothy.c.pepper@linux.intel.com>
Date: Wed, 25 Sep 2013 10:12:43 -0700
Subject: Re: mm: insure topdown mmap chooses addresses above security minimum
Message-ID: <20130925171243.GA7428@tcpepper-desk.jf.intel.com>
References: <1380057811-5352-1-git-send-email-timothy.c.pepper@linux.intel.com>
 <20130925073048.GB27960@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130925073048.GB27960@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, James Morris <james.l.morris@oracle.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

On Wed 25 Sep at 09:30:49 +0200 mingo@kernel.org said:
> >  	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
> >  	info.length = len;
> > -	info.low_limit = PAGE_SIZE;
> > +	info.low_limit = max(PAGE_SIZE, PAGE_ALIGN(mmap_min_addr));
> >  	info.high_limit = mm->mmap_base;
> >  	info.align_mask = filp ? get_align_mask() : 0;
> >  	info.align_offset = pgoff << PAGE_SHIFT;
> 
> There appears to be a lot of repetition in these methods - instead of 
> changing 6 places it would be more future-proof to first factor out the 
> common bits and then to apply the fix to the shared implementation.

Besides that existing redundancy in the multiple somewhat similar
arch_get_unmapped_area_topdown() functions, I was expecting people might
question the added redundancy of the six instances of:

	max(PAGE_SIZE, PAGE_ALIGN(mmap_min_addr));

There's also a seventh similar instance if you consider
mm/mmap.c:round_hint_to_min() and its call stack.  I'm inclined to
think mmap_min_addr should be validated/aligned in one place, namely on
initialization and input in security/min_addr.c:update_mmap_min_addr(),
with mmap_min_addr always stored as an aligned value.

In the past commit 40401530 Al Viro arguably moved that checking out
of the security code and toward the mmap code.  Granted at that point
though there was only the round_hint_to_min() insuring the value in
mmap_min_addr was page aligned before use in that call path.  I'm thinking
something like:

diff --git a/security/min_addr.c b/security/min_addr.c
--- a/security/min_addr.c
+++ b/security/min_addr.c
@@ -14,14 +14,16 @@ unsigned long dac_mmap_min_addr = CONFIG_DEFAULT_MMAP_MIN_ADDR;
  */
 static void update_mmap_min_addr(void)
 {
+	unsigned long addr;
 #ifdef CONFIG_LSM_MMAP_MIN_ADDR
 	if (dac_mmap_min_addr > CONFIG_LSM_MMAP_MIN_ADDR)
-		mmap_min_addr = dac_mmap_min_addr;
+		addr = dac_mmap_min_addr;
 	else
-		mmap_min_addr = CONFIG_LSM_MMAP_MIN_ADDR;
+		addr = CONFIG_LSM_MMAP_MIN_ADDR;
 #else
-	mmap_min_addr = dac_mmap_min_addr;
+	addr = dac_mmap_min_addr;
 #endif
+	mmap_min_addr = max(PAGE_SIZE, PAGE_ALIGN(addr));
 }
 
 /*

But this possibly has implications beyond the mmap code.

Al Viro, James Morris: any thoughts on the above?

Michel, Rik: what do you think of common helpers called by
ARM, MIPS, SH, Sparc, x86_64 arch_get_unmapped_area_topdown()
and arch_get_unmapped_area() to handle initialization of struct
vm_unmapped_area_info info fields which are currently mostly common?
Given the nuances of "mostly common" I'm not sure the result would
actually be positive for overall readability / self-documenting-ness of
the per arch files.

-- 
Tim Pepper <timothy.c.pepper@linux.intel.com>
Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
