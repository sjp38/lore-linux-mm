Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0999280276
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 09:01:34 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id 34so238356600uac.6
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 06:01:34 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id j10si34243211plg.64.2016.12.23.06.01.32
        for <linux-mm@kvack.org>;
        Fri, 23 Dec 2016 06:01:33 -0800 (PST)
Date: Fri, 23 Dec 2016 23:01:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: pmd dirty emulation in page fault handler
Message-ID: <20161223140131.GA5724@bbox>
References: <1482364101-16204-1-git-send-email-minchan@kernel.org>
 <20161222081713.GA32480@node.shutemov.name>
 <20161222145203.GA18970@bbox>
 <20161223091725.GA23117@dhcp22.suse.cz>
 <20161223095336.GA5305@bbox>
 <20161223115421.GD23109@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20161223115421.GD23109@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Jason Evans <je@fb.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, "[4.5+]" <stable@vger.kernel.org>, Andreas Schwab <schwab@suse.de>

On Fri, Dec 23, 2016 at 12:54:21PM +0100, Michal Hocko wrote:
> On Fri 23-12-16 18:53:36, Minchan Kim wrote:
> > Hi,
> > 
> > On Fri, Dec 23, 2016 at 10:17:25AM +0100, Michal Hocko wrote:
> > > On Thu 22-12-16 23:52:03, Minchan Kim wrote:
> > > [...]
> > > > >From b3ec95c0df91ad113525968a4a6b53030fd0b48d Mon Sep 17 00:00:00 2001
> > > > From: Minchan Kim <minchan@kernel.org>
> > > > Date: Thu, 22 Dec 2016 23:43:49 +0900
> > > > Subject: [PATCH v2] mm: pmd dirty emulation in page fault handler
> > > > 
> > > > Andreas reported [1] made a test in jemalloc hang in THP mode in arm64.
> > > > http://lkml.kernel.org/r/mvmmvfy37g1.fsf@hawking.suse.de
> > > > 
> > > > The problem is page fault handler supports only accessed flag emulation
> > > > for THP page of SW-dirty/accessed architecture.
> > > > 
> > > > This patch enables dirty-bit emulation for those architectures.
> > > > Without it, MADV_FREE makes application hang by repeated fault forever.
> > > 
> > > The changelog is rather terse and considering the issue is rather subtle
> > > and it aims the stable tree I think it could see more information. How
> > > do we end up looping in the page fault and why the dirty pmd stops it.
> > > Could you update the changelog to be more verbose, please? I am still
> > > digesting this patch but I believe it is correct fwiw...
> > > 
> > 
> > How about this? Feel free to suggest better wording.
> > 
> > Andreas reported [1] made a test in jemalloc hang in THP mode in arm64.
> > http://lkml.kernel.org/r/mvmmvfy37g1.fsf@hawking.suse.de
> > 
> > The problem is currently page fault handler doesn't supports dirty bit
> > emulation of pte for non-HW dirty-bit architecture so that application
> 
> s@pte@pmd@ ?

It would be more clear. Will update with it.

> 
> > stucks until VM marked the pmd dirty.
> > 
> > How the emulation work depends on the architecture. In case of arm64,
> > when it set up pte firstly, it sets pte PTE_RDONLY to get a chance to
> > mark the pte dirty via triggering page fault when store access happens.
> > Once the page fault occurs, VM marks the pte dirty and arch code for
> > setting pte will clear PTE_RDONLY for application to proceed.
> > 
> > IOW, if VM doesn't mark the pte dirty, application hangs forever by
> > repeated fault(i.e., store op but the pte is PTE_RDONLY).
> > 
> > This patch enables dirty-bit emulation for those architectures.
> 
> Yes this is helpful and much more clear, thank you. One thing that is
> still not clear to me is why cannot we handle that in the arch specific
> code. I mean what is the side effect of doing pmd_mkdirty for
> architectures which do not need it?

For architecture which supports H/W access/dirty bit, it couldn't be
reached there code path so there is no side effect, I think. A thing
I can think of is just increasing code size little bit. Maybe, we
could optimize away some ifdef magic but not sure worth it. We have
been same way pte(not pmd) emulation handling for several decacdes.
Anyway, it should be off-topic, I think.

Thanks.

> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
