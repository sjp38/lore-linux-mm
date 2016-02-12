Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B081C6B0005
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 07:21:54 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p63so18103799wmp.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 04:21:54 -0800 (PST)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id 65si3513089wmg.21.2016.02.12.04.21.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 12 Feb 2016 04:21:53 -0800 (PST)
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sebott@linux.vnet.ibm.com>;
	Fri, 12 Feb 2016 12:21:52 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1695A2190066
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 12:21:36 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1CCLoDC12189874
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 12:21:50 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1CCLmIV019053
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 05:21:49 -0700
Date: Fri, 12 Feb 2016 13:21:46 +0100 (CET)
From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
In-Reply-To: <20160211191253.GA8589@black.fi.intel.com>
Message-ID: <alpine.LFD.2.20.1602121318080.1773@schleppi>
References: <20160211192223.4b517057@thinkpad> <20160211190942.GA10244@node.shutemov.name> <20160211191253.GA8589@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

On Thu, 11 Feb 2016, Kirill A. Shutemov wrote:
> On Thu, Feb 11, 2016 at 09:09:42PM +0200, Kirill A. Shutemov wrote:
> > On Thu, Feb 11, 2016 at 07:22:23PM +0100, Gerald Schaefer wrote:
> > > Hi,
> > > 
> > > Sebastian Ott reported random kernel crashes beginning with v4.5-rc1 and
> > > he also bisected this to commit 61f5d698 "mm: re-enable THP". Further
> > > review of the THP rework patches, which cannot be bisected, revealed
> > > commit fecffad "s390, thp: remove infrastructure for handling splitting PMDs"
> > > (and also similar commits for other archs).
> > > 
> > > This commit removes the THP splitting bit and also the architecture
> > > implementation of pmdp_splitting_flush(), which took care of the IPI for
> > > fast_gup serialization. The commit message says
> > > 
> > >     pmdp_splitting_flush() is not needed too: on splitting PMD we will do
> > >     pmdp_clear_flush() + set_pte_at().  pmdp_clear_flush() will do IPI as
> > >     needed for fast_gup
> > > 
> > > The assumption that a TLB flush will also produce an IPI is wrong on s390,
> > > and maybe also on other architectures, and I thought that this was actually
> > > the main reason for having an arch-specific pmdp_splitting_flush().
> > > 
> > > At least PowerPC and ARM also had an individual implementation of
> > > pmdp_splitting_flush() that used kick_all_cpus_sync() instead of a TLB
> > > flush to send the IPI, and those were also removed. Putting the arch
> > > maintainers and mailing lists on cc to verify.
> > > 
> > > On s390 this will break the IPI serialization against fast_gup, which
> > > would certainly explain the random kernel crashes, please revert or fix
> > > the pmdp_splitting_flush() removal.
> > 
> > Sorry for that.
> > 
> > I believe, the problem was already addressed for PowerPC:
> > 
> > http://lkml.kernel.org/g/454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
> 
> Correct link is
> 
> http://lkml.kernel.org/g/1454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
> 

Based on your suggestion Gerald provided the following patch but sadly it
didn't fix the problem.

Sebastian


---
 arch/s390/include/asm/pgtable.h |    2 ++
 1 file changed, 2 insertions(+)

--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1587,6 +1587,8 @@ static inline void pmdp_invalidate(struc
 				   unsigned long address, pmd_t *pmdp)
 {
 	pmdp_flush_direct(vma->vm_mm, address, pmdp);
+	/* Serialize against fast_gup with IPI */
+	kick_all_cpus_sync();
 }

 #define __HAVE_ARCH_PMDP_SET_WRPROTECT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
