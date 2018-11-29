Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 536D36B5485
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 15:53:05 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id c73so4236286itd.1
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 12:53:05 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o5si2017726jaj.9.2018.11.29.12.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 12:53:04 -0800 (PST)
Subject: Re: [PATCH] hugetlbfs: Call VM_BUG_ON_PAGE earlier in free_huge_page
References: <1543491843-23438-1-git-send-email-nic_w@163.com>
 <0B408D50-D101-4457-B779-5951DEE0435A@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <211f80a2-9347-129c-0001-5f4abfd0b7dc@oracle.com>
Date: Thu, 29 Nov 2018 12:52:54 -0800
MIME-Version: 1.0
In-Reply-To: <0B408D50-D101-4457-B779-5951DEE0435A@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>, Yongkai Wu <nic.wuyk@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nic_w@163.com, Michal Hocko <mhocko@kernel.org>

On 11/29/18 5:51 AM, William Kucharski wrote:
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> 
>> On Nov 29, 2018, at 4:44 AM, Yongkai Wu <nic.wuyk@gmail.com> wrote:
>>
>> A stack trace was triggered by VM_BUG_ON_PAGE(page_mapcount(page),
>> page) in free_huge_page().  Unfortunately, the page->mapping field
>> was set to NULL before this test.  This made it more difficult to
>> determine the root cause of the problem.
>>
>> Move the VM_BUG_ON_PAGE tests earlier in the function so that if
>> they do trigger more information is present in the page struct.
>>
>> Signed-off-by: Yongkai Wu <nic_w@163.com>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> Acked-by: Mike Kravetz <mike.kravetz@oracle.com>

Thank you for fixing the formatting and commit message.

Adding Andrew on so he can add to his tree as appropriatre. Also Cc'ing Michal.

>> ---
>> mm/hugetlb.c | 5 +++--
>> 1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 7f2a28a..14ef274 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1248,10 +1248,11 @@ void free_huge_page(struct page *page)
>> 		(struct hugepage_subpool *)page_private(page);
>> 	bool restore_reserve;
>>
>> -	set_page_private(page, 0);
>> -	page->mapping = NULL;
>> 	VM_BUG_ON_PAGE(page_count(page), page);
>> 	VM_BUG_ON_PAGE(page_mapcount(page), page);
>> +
>> +	set_page_private(page, 0);
>> +	page->mapping = NULL;
>> 	restore_reserve = PagePrivate(page);
>> 	ClearPagePrivate(page);
>>
>> -- 
>> 1.8.3.1
>>
> 


-- 
Mike Kravetz
