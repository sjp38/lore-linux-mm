Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7F56B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:57:09 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id 128so35993789wmz.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 11:57:09 -0800 (PST)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id b71si40008466wmd.46.2016.02.11.11.57.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Feb 2016 11:57:08 -0800 (PST)
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 11 Feb 2016 19:57:07 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 405AF219005E
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 19:56:50 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1BJv4e827590692
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 19:57:04 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1BJv3IL019045
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:57:04 -0500
Date: Thu, 11 Feb 2016 20:57:02 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe
 also on PowerPC and ARM)
Message-ID: <20160211205702.24f0d17a@thinkpad>
In-Reply-To: <20160211190942.GA10244@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
	<20160211190942.GA10244@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Thu, 11 Feb 2016 21:09:42 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Thu, Feb 11, 2016 at 07:22:23PM +0100, Gerald Schaefer wrote:
> > Hi,
> > 
> > Sebastian Ott reported random kernel crashes beginning with v4.5-rc1 and
> > he also bisected this to commit 61f5d698 "mm: re-enable THP". Further
> > review of the THP rework patches, which cannot be bisected, revealed
> > commit fecffad "s390, thp: remove infrastructure for handling splitting PMDs"
> > (and also similar commits for other archs).
> > 
> > This commit removes the THP splitting bit and also the architecture
> > implementation of pmdp_splitting_flush(), which took care of the IPI for
> > fast_gup serialization. The commit message says
> > 
> >     pmdp_splitting_flush() is not needed too: on splitting PMD we will do
> >     pmdp_clear_flush() + set_pte_at().  pmdp_clear_flush() will do IPI as
> >     needed for fast_gup
> > 
> > The assumption that a TLB flush will also produce an IPI is wrong on s390,
> > and maybe also on other architectures, and I thought that this was actually
> > the main reason for having an arch-specific pmdp_splitting_flush().
> > 
> > At least PowerPC and ARM also had an individual implementation of
> > pmdp_splitting_flush() that used kick_all_cpus_sync() instead of a TLB
> > flush to send the IPI, and those were also removed. Putting the arch
> > maintainers and mailing lists on cc to verify.
> > 
> > On s390 this will break the IPI serialization against fast_gup, which
> > would certainly explain the random kernel crashes, please revert or fix
> > the pmdp_splitting_flush() removal.
> 
> Sorry for that.
> 
> I believe, the problem was already addressed for PowerPC:
> 
> http://lkml.kernel.org/g/454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
> 
> I think kick_all_cpus_sync() in arch-specific pmdp_invalidate() would do
> the trick, right?

Hmm, not sure about that. After pmdp_invalidate(), a pmd_none() check in
fast_gup will still return false, because the pmd is not empty (at least
on s390). So I don't see spontaneously how it will help fast_gup to break
out to the slow path in case of THP splitting.

> 
> If yes, I'll prepare patch tomorrow (some sleep required).
> 

We'll check if adding kick_all_cpus_sync() to pmdp_invalidate() helps.
It would also be good if Martin has a look at this, he'll return on
Monday.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
