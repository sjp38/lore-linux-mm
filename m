Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0FC6B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 00:54:06 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id ft15so2898652pdb.29
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:54:05 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id it5si20830508pbc.230.2014.09.29.21.54.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 21:54:05 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so2139621pdj.17
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:54:04 -0700 (PDT)
Date: Mon, 29 Sep 2014 21:52:24 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 3/5] mm/hugetlb: fix getting refcount 0 page in
 hugetlb_fault()
In-Reply-To: <1410820799-27278-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1409292132370.4640@eggly.anvils>
References: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1410820799-27278-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, stable@vger.kernel.org

On Mon, 15 Sep 2014, Naoya Horiguchi wrote:
> When running the test which causes the race as shown in the previous patch,
> we can hit the BUG "get_page() on refcount 0 page" in hugetlb_fault().

Two minor comments...

> @@ -3192,22 +3208,19 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> 	 * Note that locking order is always pagecache_page -> page,
>  	 * so no worry about deadlock.

That sentence of comment is stale and should be deleted,
now that you're only doing a trylock_page(page) here.

>  out_mutex:
>  	mutex_unlock(&htlb_fault_mutex_table[hash]);
> +	if (need_wait_lock)
> +		wait_on_page_locked(page);
>  	return ret;
>  }

It will be hard to trigger any problem from this (I guess it would
need memory hotremove), but you ought really to hold a reference to
page while doing a wait_on_page_locked(page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
