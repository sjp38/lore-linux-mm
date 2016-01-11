Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id BF446828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 01:09:14 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id e65so39861307pfe.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 22:09:14 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id l66si26075894pfi.124.2016.01.10.22.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 22:09:14 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id e65so39861179pfe.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 22:09:14 -0800 (PST)
Date: Sun, 10 Jan 2016 22:09:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH next] powerpc/mm: fix _PAGE_PTE breaking swapoff
In-Reply-To: <87k2ngu0b4.fsf@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1601102208040.1701@eggly.anvils>
References: <alpine.LSU.2.11.1601091643060.9808@eggly.anvils> <87si24u32t.fsf@linux.vnet.ibm.com> <87k2ngu0b4.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, 11 Jan 2016, Aneesh Kumar K.V wrote:
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
> > Hugh Dickins <hughd@google.com> writes:
> >
> >> Swapoff after swapping hangs on the G5.  That's because the _PAGE_PTE
> >> bit, added by set_pte_at(), is not expected by swapoff: so swap ptes
> >> cannot be recognized.
> >>
> >> I'm not sure whether a swap pte should or should not have _PAGE_PTE set:
> >> this patch assumes not, and fixes set_pte_at() to set _PAGE_PTE only on
> >> present entries.
> >
> > One of the reason we added _PAGE_PTE is to enable HUGETLB migration. So
> > we want migratio ptes to have _PAGE_PTE set.
> >
> >>
> >> But if that's wrong, a reasonable alternative would be to
> >> #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) & ~_PAGE_PTE })
> >> #define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
> >>
> 
> You other email w.r.t soft dirty bits explained this. What I missed was
> the fact that core kernel expect swp_entry_t to be of an arch neutral
> format.  The confusing part was "arch_entry"
> 
> static inline pte_t swp_entry_to_pte(swp_entry_t entry)
> {
> 	swp_entry_t arch_entry;
> .....
> }
> 	
> IMHO we should use the alternative you suggested above. I can write a
> patch with additional comments around that if you want me to do that.

Sure, please go ahead - thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
