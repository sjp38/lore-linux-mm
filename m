Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id E98046B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 04:10:41 -0400 (EDT)
Received: by iofz202 with SMTP id z202so212328451iof.2
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 01:10:41 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id y138si28251517iod.172.2015.10.27.01.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 01:10:41 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so215539938pad.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 01:10:41 -0700 (PDT)
Date: Tue, 27 Oct 2015 17:10:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] mm: simplify reclaim path for MADV_FREE
Message-ID: <20151027081059.GE26803@bbox>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
 <1445236307-895-5-git-send-email-minchan@kernel.org>
 <alpine.LSU.2.11.1510261828350.10825@eggly.anvils>
 <EDCE64A3-D874-4FE3-91B5-DE5E26A452F5@gmail.com>
 <20151027070903.GD26803@bbox>
 <32537EDE-3EE6-4C44-B820-5BCAF7A5D535@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <32537EDE-3EE6-4C44-B820-5BCAF7A5D535@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Oct 27, 2015 at 03:39:16PM +0800, yalin wang wrote:
> 
> > On Oct 27, 2015, at 15:09, Minchan Kim <minchan@kernel.org> wrote:
> > 
> > Hello Yalin,
> > 
> > Sorry for missing you in Cc list.
> > IIRC, mails to send your previous mail address(Yalin.Wang@sonymobile.com)
> > were returned.
> > 
> > You added comment bottom line so I'm not sure what PageDirty you meant.
> > 
> >> it is wrong here if you only check PageDirty() to decide if the page is freezable or not .
> >> The Anon page are shared by multiple process, _mapcount > 1 ,
> >> so you must check all pt_dirty bit during page_referenced() function,
> >> see this mail thread:
> >> http://ns1.ske-art.com/lists/kernel/msg1934021.html
> > 
> > If one of pte among process sharing the page was dirty, the dirtiness should
> > be propagated from pte to PG_dirty by try_to_unmap_one.
> > IOW, if the page doesn't have PG_dirty flag, it means all of process did
> > MADV_FREE.
> > 
> > Am I missing something from you question?
> > If so, could you show exact scenario I am missing?
> > 
> > Thanks for the interest.
> oh, yeah , that is right , i miss that , pte_dirty will propagate to PG_dirty ,
> so that is correct .
> Generic to say this patch move set_page_dirty() from add_to_swap() to 
> try_to_unmap(), i think can change a little about this patch:
> 
> @@ -1476,6 +1446,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> 				ret = SWAP_FAIL;
> 				goto out_unmap;
> 			}
> +			if (!PageDirty(page))
> +				SetPageDirty(page);
> 			if (list_empty(&mm->mmlist)) {
> 				spin_lock(&mmlist_lock);
> 				if (list_empty(&mm->mmlist))
> 
> i think this 2 lines can be removed ,
> since  pte_dirty have propagated to set_page_dirty() , we dona??t need this line here ,
> otherwise you will always dirty a AnonPage, even it is clean,
> then we will page out this clean page to swap partition one more , this is not needed.
> am i understanding correctly ?

Your understanding is correct.
I will fix it in next spin.

> 
> By the way, please change my mail address to yalin.wang2010@gmail.com in CC list .
> Thanks a lot. :) 

Thanks for the review!

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
