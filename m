Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36C046B0253
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:12:59 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id yy13so33203611pab.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 11:12:59 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id fv12si14194405pac.121.2016.02.11.11.12.58
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 11:12:58 -0800 (PST)
Date: Thu, 11 Feb 2016 22:12:53 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160211191253.GA8589@black.fi.intel.com>
References: <20160211192223.4b517057@thinkpad>
 <20160211190942.GA10244@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160211190942.GA10244@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Thu, Feb 11, 2016 at 09:09:42PM +0200, Kirill A. Shutemov wrote:
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

Correct link is

http://lkml.kernel.org/g/1454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
