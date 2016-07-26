Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED26D6B0253
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 12:36:09 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b35so28965559qta.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 09:36:09 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id y202si958017qkb.170.2016.07.26.09.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 09:36:09 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id q8so783867qke.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 09:36:09 -0700 (PDT)
Subject: Re: [RFC PATCH] mm/hugetlb: Avoid soft lockup in set_max_huge_pages()
References: <1469547868-9814-1-git-send-email-hejianet@gmail.com>
 <579788BA.1040706@linux.intel.com>
From: hejianet <hejianet@gmail.com>
Message-ID: <5797916B.2020008@gmail.com>
Date: Wed, 27 Jul 2016 00:35:55 +0800
MIME-Version: 1.0
In-Reply-To: <579788BA.1040706@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Paul Gortmaker <paul.gortmaker@windriver.com>



On 7/26/16 11:58 PM, Dave Hansen wrote:
> On 07/26/2016 08:44 AM, Jia He wrote:
>> This patch is to fix such soft lockup. I thouhgt it is safe to call
>> cond_resched() because alloc_fresh_gigantic_page and alloc_fresh_huge_page
>> are out of spin_lock/unlock section.
> Yikes.  So the call site for both the things you patch is this:
>
>>          while (count > persistent_huge_pages(h)) {
> ...
>>                  spin_unlock(&hugetlb_lock);
>>                  if (hstate_is_gigantic(h))
>>                          ret = alloc_fresh_gigantic_page(h, nodes_allowed);
>>                  else
>>                          ret = alloc_fresh_huge_page(h, nodes_allowed);
>>                  spin_lock(&hugetlb_lock);
> and you choose to patch both of the alloc_*() functions.  Why not just
> fix it at the common call site?  Seems like that
> spin_lock(&hugetlb_lock) could be a cond_resched_lock() which would fix
> both cases.
>
> Also, putting that cond_resched() inside the for_each_node*() loop is an
> odd choice.  It seems to indicate that the loops can take a long time,
> which really isn't the case.  The _loop_ isn't long, right?
Yes,thanks for the suggestions
Will send out V2 later

B.R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
