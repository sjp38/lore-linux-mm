Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 89CB66B005D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 05:09:49 -0400 (EDT)
Date: Wed, 3 Oct 2012 10:09:14 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2] mm: thp: Set the accessed flag for old pages on
 access fault.
Message-ID: <20121003090914.GA22445@mudshark.cambridge.arm.com>
References: <1349197151-19645-1-git-send-email-will.deacon@arm.com>
 <20121002150104.da57fa94.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121002150104.da57fa94.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "kirill@shutemov.name" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, Chris Metcalf <cmetcalf@tilera.com>, Steve Capper <Steve.Capper@arm.com>

On Tue, Oct 02, 2012 at 11:01:04PM +0100, Andrew Morton wrote:
> On Tue,  2 Oct 2012 17:59:11 +0100
> Will Deacon <will.deacon@arm.com> wrote:
> 
> > On x86 memory accesses to pages without the ACCESSED flag set result in the
> > ACCESSED flag being set automatically. With the ARM architecture a page access
> > fault is raised instead (and it will continue to be raised until the ACCESSED
> > flag is set for the appropriate PTE/PMD).
> > 
> > For normal memory pages, handle_pte_fault will call pte_mkyoung (effectively
> > setting the ACCESSED flag). For transparent huge pages, pmd_mkyoung will only
> > be called for a write fault.
> > 
> > This patch ensures that faults on transparent hugepages which do not result
> > in a CoW update the access flags for the faulting pmd.
> 
> Alas, the code you're altering has changed so much in linux-next that I
> am reluctant to force this fix in there myself.  Can you please
> redo/retest/resend?  You can do that on 3.7-rc1 if you like, then we
> can feed this into -rc2.

No problem. I'll rebase the entire ARM series at -rc1 prior to posting
anyway, so this can be included in that lot.

> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3524,7 +3524,8 @@ retry:
> >  
> >  		barrier();
> >  		if (pmd_trans_huge(orig_pmd)) {
> > -			if (flags & FAULT_FLAG_WRITE &&
> > +			int dirty = flags & FAULT_FLAG_WRITE;
> 
> `flags' is `unsigned int', so making `dirty' match that is nicer.

I'll fold that in with the above.

Cheers,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
