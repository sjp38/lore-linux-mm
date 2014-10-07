Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id ECDFB6B0069
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 13:21:45 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id x3so6093974qcv.24
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 10:21:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 10si30965573qaj.81.2014.10.07.10.21.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Oct 2014 10:21:44 -0700 (PDT)
Date: Tue, 7 Oct 2014 12:56:57 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 3/5] mm/hugetlb: fix getting refcount 0 page in
 hugetlb_fault()
Message-ID: <20141007165657.GB24093@nhori.bos.redhat.com>
References: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1410820799-27278-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.LSU.2.11.1409292132370.4640@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409292132370.4640@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, stable@vger.kernel.org

On Mon, Sep 29, 2014 at 09:52:24PM -0700, Hugh Dickins wrote:
> On Mon, 15 Sep 2014, Naoya Horiguchi wrote:
> > When running the test which causes the race as shown in the previous patch,
> > we can hit the BUG "get_page() on refcount 0 page" in hugetlb_fault().
> 
> Two minor comments...
> 
> > @@ -3192,22 +3208,19 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > 	 * Note that locking order is always pagecache_page -> page,
> >  	 * so no worry about deadlock.
> 
> That sentence of comment is stale and should be deleted,
> now that you're only doing a trylock_page(page) here.

OK, I'll delete it.

> >  out_mutex:
> >  	mutex_unlock(&htlb_fault_mutex_table[hash]);
> > +	if (need_wait_lock)
> > +		wait_on_page_locked(page);
> >  	return ret;
> >  }
> 
> It will be hard to trigger any problem from this (I guess it would
> need memory hotremove), but you ought really to hold a reference to
> page while doing a wait_on_page_locked(page).

I'll do that.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
