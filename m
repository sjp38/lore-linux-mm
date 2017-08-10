Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2122A6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:43:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k68so2988516wmd.14
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:43:29 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id s15si5783925edd.47.2017.08.10.06.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 06:43:27 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id y206so3094898wmd.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:43:27 -0700 (PDT)
Date: Thu, 10 Aug 2017 16:43:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 05/16] mm: Protect VMA modifications using VMA sequence
 count
Message-ID: <20170810134325.j4ijsxzc56e443of@node.shutemov.name>
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1502202949-8138-6-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170809101241.ek4fqinqaq5qfkq4@node.shutemov.name>
 <f935091a-d8f9-1951-8397-f5c464a2b922@linux.vnet.ibm.com>
 <20170810005828.qmw3p7d676hjwkss@node.shutemov.name>
 <4e552377-af38-3580-73b6-1edf685cb90d@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4e552377-af38-3580-73b6-1edf685cb90d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Thu, Aug 10, 2017 at 10:27:50AM +0200, Laurent Dufour wrote:
> On 10/08/2017 02:58, Kirill A. Shutemov wrote:
> > On Wed, Aug 09, 2017 at 12:43:33PM +0200, Laurent Dufour wrote:
> >> On 09/08/2017 12:12, Kirill A. Shutemov wrote:
> >>> On Tue, Aug 08, 2017 at 04:35:38PM +0200, Laurent Dufour wrote:
> >>>> The VMA sequence count has been introduced to allow fast detection of
> >>>> VMA modification when running a page fault handler without holding
> >>>> the mmap_sem.
> >>>>
> >>>> This patch provides protection agains the VMA modification done in :
> >>>> 	- madvise()
> >>>> 	- mremap()
> >>>> 	- mpol_rebind_policy()
> >>>> 	- vma_replace_policy()
> >>>> 	- change_prot_numa()
> >>>> 	- mlock(), munlock()
> >>>> 	- mprotect()
> >>>> 	- mmap_region()
> >>>> 	- collapse_huge_page()
> >>>
> >>> I don't thinks it's anywhere near complete list of places where we touch
> >>> vm_flags. What is your plan for the rest?
> >>
> >> The goal is only to protect places where change to the VMA is impacting the
> >> page fault handling. If you think I missed one, please advise.
> > 
> > That's very fragile approach. We rely here too much on specific compiler behaviour.
> > 
> > Any write access to vm_flags can, in theory, be translated to several
> > write accesses. For instance with setting vm_flags to 0 in the middle,
> > which would result in sigfault on page fault to the vma.
> 
> Indeed, just setting vm_flags to 0 will not result in sigfault, the real
> job is done when the pte are updated and the bits allowing access are
> cleared. Access to the pte is controlled by the pte lock.
> Page fault handler is triggered based on the pte bits, not the content of
> vm_flags and the speculative page fault is checking for the vma again once
> the pte lock is held. So there is no concurrency when dealing with the pte
> bits.

Suppose we are getting page fault to readable VMA, pte is clear at the
time of page fault. In this case we need to consult vm_flags to check if
the vma is read-accessible.

If by the time of check vm_flags happend to be '0' we would get SIGSEGV as
the vma appears to be non-readable.

Where is my logic faulty?

> Regarding the compiler behaviour, there are memory barriers and locking
> which should prevent that.

Which locks barriers are you talking about?

We need at least READ_ONCE/WRITE_ONCE to access vm_flags everywhere.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
