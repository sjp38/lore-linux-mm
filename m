Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 391736B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:10:20 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so203728251pab.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:10:20 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id yi10si12405976pab.15.2015.11.30.14.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 14:10:19 -0800 (PST)
Received: by pacej9 with SMTP id ej9so197800694pac.2
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:10:19 -0800 (PST)
Date: Mon, 30 Nov 2015 14:10:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v1] mm: hugetlb: call huge_pte_alloc() only if ptep is
 null
In-Reply-To: <1448524936-10501-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.10.1511301409380.10460@chino.kir.corp.google.com>
References: <1448524936-10501-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, 26 Nov 2015, Naoya Horiguchi wrote:

> Currently at the beginning of hugetlb_fault(), we call huge_pte_offset()
> and check whether the obtained *ptep is a migration/hwpoison entry or not.
> And if not, then we get to call huge_pte_alloc(). This is racy because the
> *ptep could turn into migration/hwpoison entry after the huge_pte_offset()
> check. This race results in BUG_ON in huge_pte_alloc().
> 
> We don't have to call huge_pte_alloc() when the huge_pte_offset() returns
> non-NULL, so let's fix this bug with moving the code into else block.
> 
> Note that the *ptep could turn into a migration/hwpoison entry after
> this block, but that's not a problem because we have another !pte_present
> check later (we never go into hugetlb_no_page() in that case.)
> 
> Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org> [2.6.36+]

Acked-by: David Rientjes <rientjes@google.com>

It would be nice to provide a sample of the BUG_ON() output in the commit 
message, however, so people can quickly find this if greping for what they 
just saw kill their machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
