Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9216B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 07:59:08 -0400 (EDT)
Received: by wgra20 with SMTP id a20so171195034wgr.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 04:59:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ew17si22959021wid.0.2015.03.30.04.59.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 04:59:06 -0700 (PDT)
Date: Mon, 30 Mar 2015 12:59:01 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH] mm: hugetlb: add stub-like do_hugetlb_numa()
Message-ID: <20150330115901.GR4701@suse.de>
References: <1427708426-31610-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150330102802.GQ4701@suse.de>
 <55192885.5010608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55192885.5010608@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <nao.horiguchi@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Mar 30, 2015 at 07:42:13PM +0900, Naoya Horiguchi wrote:
> On 03/30/2015 07:28 PM, Mel Gorman wrote:
> >On Mon, Mar 30, 2015 at 09:40:54AM +0000, Naoya Horiguchi wrote:
> >>hugetlb doesn't support NUMA balancing now, but that doesn't mean that we
> >>don't have to make hugetlb code prepared for PROTNONE entry properly.
> >>In the current kernel, when a process accesses to hugetlb range protected
> >>with PROTNONE, it causes unexpected COWs, which finally put hugetlb subsystem
> >>into broken/uncontrollable state, where for example h->resv_huge_pages is
> >>subtracted too much and wrapped around to a very large number, and free
> >>hugepage pool is no longer maintainable.
> >>
> >
> >Ouch!
> >
> >>This patch simply clears PROTNONE when it's caught out. Real NUMA balancing
> >>code for hugetlb is not implemented yet (not sure how much it's worth doing.)
> >>
> >
> >It's not worth doing at all. Furthermore, an application that took the
> >effort to allocate and use hugetlb pages is not going to appreciate the
> >minor faults incurred by automatic balancing for no gain.
> 
> OK,
> 
> >Why not something
> >like the following untested patch?
> 
> I'll test this tomorrow.
> Thank you very much for the comment.
> 

I note now that the patch was too hasty. By rights, that check
should be covered by vma_migratable() but it's only checked if
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION which means it's x86-only. If you
are seeing this problem on any other arch then a more correct fix might be
to remove the CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION check in vma_migratable.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
