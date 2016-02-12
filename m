Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0B00E6B0005
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 05:12:48 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p63so12737160wmp.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 02:12:47 -0800 (PST)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id r123si2889787wmb.8.2016.02.12.02.12.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 12 Feb 2016 02:12:47 -0800 (PST)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sebott@linux.vnet.ibm.com>;
	Fri, 12 Feb 2016 10:12:46 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7C9E42190063
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:12:29 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1CACh5723396596
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:12:43 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1CACdj2010058
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 03:12:42 -0700
Date: Fri, 12 Feb 2016 11:12:34 +0100 (CET)
From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
In-Reply-To: <20160212100137.GE25087@arm.com>
Message-ID: <alpine.LFD.2.20.1602121106140.1773@schleppi>
References: <20160211192223.4b517057@thinkpad> <20160211190942.GA10244@node.shutemov.name> <20160211205702.24f0d17a@thinkpad> <20160212100137.GE25087@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

On Fri, 12 Feb 2016, Will Deacon wrote:
> On Thu, Feb 11, 2016 at 08:57:02PM +0100, Gerald Schaefer wrote:
> > On Thu, 11 Feb 2016 21:09:42 +0200
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > > On Thu, Feb 11, 2016 at 07:22:23PM +0100, Gerald Schaefer wrote:
> > > > Sebastian Ott reported random kernel crashes beginning with v4.5-rc1 and
> > > > he also bisected this to commit 61f5d698 "mm: re-enable THP". Further
> > > > review of the THP rework patches, which cannot be bisected, revealed
> > > > commit fecffad "s390, thp: remove infrastructure for handling splitting PMDs"
> > > > (and also similar commits for other archs).
> > > > 
> > > > This commit removes the THP splitting bit and also the architecture
> > > > implementation of pmdp_splitting_flush(), which took care of the IPI for
> > > > fast_gup serialization. The commit message says
> > > > 
> > > >     pmdp_splitting_flush() is not needed too: on splitting PMD we will do
> > > >     pmdp_clear_flush() + set_pte_at().  pmdp_clear_flush() will do IPI as
> > > >     needed for fast_gup
> > > > 
> > > > The assumption that a TLB flush will also produce an IPI is wrong on s390,
> > > > and maybe also on other architectures, and I thought that this was actually
> > > > the main reason for having an arch-specific pmdp_splitting_flush().
> > > > 
> > > > At least PowerPC and ARM also had an individual implementation of
> > > > pmdp_splitting_flush() that used kick_all_cpus_sync() instead of a TLB
> > > > flush to send the IPI, and those were also removed. Putting the arch
> > > > maintainers and mailing lists on cc to verify.
> > > > 
> > > > On s390 this will break the IPI serialization against fast_gup, which
> > > > would certainly explain the random kernel crashes, please revert or fix
> > > > the pmdp_splitting_flush() removal.
> > > 
> > > Sorry for that.
> > > 
> > > I believe, the problem was already addressed for PowerPC:
> > > 
> > > http://lkml.kernel.org/g/454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
> > > 
> > > I think kick_all_cpus_sync() in arch-specific pmdp_invalidate() would do
> > > the trick, right?
> > 
> > Hmm, not sure about that. After pmdp_invalidate(), a pmd_none() check in
> > fast_gup will still return false, because the pmd is not empty (at least
> > on s390). So I don't see spontaneously how it will help fast_gup to break
> > out to the slow path in case of THP splitting.
> > 
> > > 
> > > If yes, I'll prepare patch tomorrow (some sleep required).
> > > 
> > 
> > We'll check if adding kick_all_cpus_sync() to pmdp_invalidate() helps.
> > It would also be good if Martin has a look at this, he'll return on
> > Monday.
> 
> Do you have a reliable way to trigger the "random kernel crashes"? We've not
> seen anything reported on arm64, but I don't see why we wouldn't be affected
> by the same bug and it would be good to confirm and validate a fix.

My testcase was compiling the kernel. Most of the time my test system
didn't survive a single compile run. During bisect I did at least 20
compile runs to flag a commit as good.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
