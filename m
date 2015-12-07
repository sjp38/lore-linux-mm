Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 884396B027A
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 10:11:20 -0500 (EST)
Received: by qgea14 with SMTP id a14so145112273qge.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 07:11:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j20si25591343qhc.31.2015.12.07.07.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 07:11:19 -0800 (PST)
Date: Mon, 7 Dec 2015 16:11:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp: introduce thp_mmu_gather to pin tail pages
 during MMU gather
Message-ID: <20151207151117.GH29105@redhat.com>
References: <1447938052-22165-1-git-send-email-aarcange@redhat.com>
 <1447938052-22165-2-git-send-email-aarcange@redhat.com>
 <87wpsq7ghe.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87wpsq7ghe.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Dec 07, 2015 at 03:00:53PM +0530, Aneesh Kumar K.V wrote:
> Andrea Arcangeli <aarcange@redhat.com> writes:
> 
> > This theoretical SMP race condition was found with source review. No
> > real life app could be affected as the result of freeing memory while
> > accessing it is either undefined or it's a workload the produces no
> > information.
> >
> > For something to go wrong because the SMP race condition triggered,
> > it'd require a further tiny window within the SMP race condition
> > window. So nothing bad is happening in practice even if the SMP race
> > condition triggers. It's still better to apply the fix to have the
> > math guarantee.
> >
> > The fix just adds a thp_mmu_gather atomic_t counter to the THP pages,
> > so split_huge_page can elevate the tail page count accordingly and
> > leave the tail page freeing task to whoever elevated thp_mmu_gather.
> >
> 
> Will this be a problem after
> http://article.gmane.org/gmane.linux.kernel.mm/139631  
> "[PATCHv12 00/37] THP refcounting redesign" ?

The THP zero page SMP TLB flushing race (patch 2/2) is definitely
still needed even with the THP refcounting redesign applied (perhaps
it'll reject but the problem remains exactly the same).

The MMU gather part (patch 1/2) as far as I can tell it's still needed
too because split_huge_page bails out on gup pins only (which is the
primary difference, as previously split_huge_page was forbidden to
fail to guarantee a graceful fallback into the legacy code after a
split_huge_page_pmd, but that introduced the need of more complex
put_page for tail pages to deal with the gup tail pins). There are no
gup pins involved in this race and put_page may still free the tails
in __split_huge_page despite the MMU gather THP TLB flush may not have
run yet (there's even still the comment about it in __split_huge_page
confirming this, so unless that comment is also wrong the theoretical
SMP race fix is needed). The locking in the __split_huge_page with the
refcounting redesign applied still retains the lru_lock so it would
also still allow to fix the race for good, with the refcounting
redesign, in the same way. Kirill please correct me if I overlooked
something in your patchset.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
