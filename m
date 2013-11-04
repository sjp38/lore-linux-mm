Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id ECB476B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 06:32:31 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id y10so6507136pdj.24
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 03:32:31 -0800 (PST)
Received: from psmtp.com ([74.125.245.136])
        by mx.google.com with SMTP id ai2si10556069pad.233.2013.11.04.03.32.29
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 03:32:30 -0800 (PST)
From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [Bug 64121] New: [BISECTED] "mm" performance regression updating from 3.2 to 3.3
Date: Mon, 04 Nov 2013 12:32:23 +0100
Message-ID: <1798714.enT4nlElFa@storm>
In-Reply-To: <20131101184332.GF707@cmpxchg.org>
References: <bug-64121-27@https.bugzilla.kernel.org/> <20131031134610.30d4c0e98e58fb0484e988c1@linux-foundation.org> <20131101184332.GF707@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Friday, 1. November 2013 14:43:32 Johannes Weiner wrote:
> Maybe we should just ignore everything above 16G on 32 bit, but that
> would mean actively breaking setups that _individually_ worked before
> and never actually hit problems due to their specific circumstances.
> 
> On the other hand, I don't think it's reasonable to support this
> anymore and it should be more clear that people doing these things are
> on their own.
> 
> What makes it worse is that all of these reports have been modern 64
> bit machines, with modern amounts of memory, running 32 bit kernels.
> I'd be more inclined to seriously look into this if it were hardware
> that couldn't just run a 64 bit kernel...

thanks for your detailed analysis! 

It's good to know the exact cause of this. Other people with
the same symptoms can now stumble upon this problem report.

We run the same distribution on 32 bit and 64 bit CPUs, that's why we've
avoided to upgrade to 64 bit yet. For our purposes, 16 GB of RAM is more than
enough. So I've implemented a small hack to limit the memory to 16 GB.
That gives way better performance than f.e. a memory limit of 20 GB.


Limit to 20 GB (for comparison):
# dd_rescue /dev/zero disk.img
dd_rescue: (info): ipos:    293888.0k, opos:    293888.0k, xferd:    293888.0k
                   errs:      0, errxfer:         0.0k, succxfer:    293888.0k
             +curr.rate:    99935kB/s, avg.rate:    51625kB/s, avg.load:  3.3%


With the new 16GB limit:
dd_rescue: (info): ipos:   1638400.0k, opos:   1638400.0k, xferd:   1638400.0k
                   errs:      0, errxfer:         0.0k, succxfer:   1638400.0k
             +curr.rate:    83685kB/s, avg.rate:    81205kB/s, avg.load:  6.1%


-> Limiting to 16GB with an "override" boot parameter for people
that really need more RAM might be a good idea even for mainline.


---hackish patch----------------------------------------------------------
Limit memory to 16 GB. See kernel bugzilla #64121.

diff -u -r -p linux.orig/arch/x86/mm/init_32.c linux.i2n/arch/x86/mm/init_32.c
--- linux.orig/arch/x86/mm/init_32.c	2013-11-04 11:52:55.881152576 +0100
+++ linux.i2n/arch/x86/mm/init_32.c	2013-11-04 11:52:01.309151985 +0100
@@ -621,6 +621,13 @@ void __init highmem_pfn_init(void)
 	}
 #endif /* !CONFIG_HIGHMEM64G */
 #endif /* !CONFIG_HIGHMEM */
+#ifdef CONFIG_HIGHMEM64G
+	/* Intra2net: Limit memory to 16GB */
+	if (max_pfn > MAX_NONPAE_PFN * 4) {
+		max_pfn = MAX_NONPAE_PFN * 4;
+		printk(KERN_WARNING "Limited memory to 16GB. See kernel bugzilla #64121\n");
+	}
+#endif
 }
 
 /*
--------------------------------------------------------------------------

Thanks again for your help,
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
