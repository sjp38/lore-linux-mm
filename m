Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60F9F8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 07:49:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x24-v6so8547688edm.13
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 04:49:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d30-v6si3370530edn.311.2018.09.11.04.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 04:49:30 -0700 (PDT)
Date: Tue, 11 Sep 2018 13:49:27 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: 32-bit PTI with THP = userspace corruption
Message-ID: <20180911114927.gikd3uf3otxn2ekq@suse.de>
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee>
 <20180830205527.dmemjwxfbwvkdzk2@suse.de>
 <alpine.LRH.2.21.1808310711380.17865@math.ut.ee>
 <20180831070722.wnulbbmillxkw7ke@suse.de>
 <alpine.DEB.2.21.1809081223450.1402@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1809081223450.1402@nanos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Meelis Roos <mroos@linux.ee>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

Hi,

[
  Andrea, maybe you can have a quick look here too, please? Maybe I am
  overlooking a simple way to fix the issue. Problem description is
  below.
]

On Sat, Sep 08, 2018 at 12:24:10PM +0200, Thomas Gleixner wrote:
> > I'll try to reproduce and work on a fix.
> 
> Any progress on this?

Yes, but slower than I hoped because an infection sent me to bed for a
couple of days :/

So I can reproduce the issue, and the core problem is that with 32-bit
legacy paging the PGD level is also the huge-page level. This means that
we have two huge PTEs for every mapping and also two places where we
have to look for A/D bits. The problem now is that the kernel only looks
at the huge PTE in the kernel page-table when it evaluates A/D bits.
This causes data corruption when it misses an A/D bit.

I had a look into the THP and the HugeTLBfs code, and that is not
really easy to fix there. As I can see it now, there are a few options
to fix that, but most of them are ugly:

	1) Use Software A/D bits for 2-level legacy paging (ugly because
	   we need separate PAGE_* macros for that paging mode then)

	2) Update all the places in THP and HugeTLBfs code that
	   evaluate A/D bits to take both PTEs into account (ugly too
	   for obvious reasons)

	3) Disable THP and HugeTLBfs on 2-level paging kernels when PTI
	   is enabled (ugly because it breaks userspace expectations)

	4) Disable PTI support on 2-level paging by making it dependent
	   on CONFIG_X86_PAE. This is, imho, the least ugly option
	   because the machines that do not support PAE are most likely
	   too old to be affected my Meltdown anyway. We might also
	   consider switching i386_defconfig to PAE?

I am not a THP or HugeTLBfs expert and maybe I am overlooking a simpler
way to fix this issue. But as it stands now I am in favour for option
number 4.

Any other thoughts?

Thanks,

	Joerg
