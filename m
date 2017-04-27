Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 796C86B02E1
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 07:07:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id m89so23498520pfi.14
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 04:07:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b200si2349533pfb.342.2017.04.27.04.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 04:07:26 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RB4mjE043357
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 07:07:26 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a3f4p0wtw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 07:07:25 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 21:07:23 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3RB7C0j2294104
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 21:07:20 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3RB6lfQ030130
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 21:06:48 +1000
Subject: Re: Freeing HugeTLB page into buddy allocator
References: <4f609205-fb69-4af5-3235-3abf05aa822a@linux.vnet.ibm.com>
 <20170427055457.GA19344@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 27 Apr 2017 16:36:20 +0530
MIME-Version: 1.0
In-Reply-To: <20170427055457.GA19344@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Message-Id: <d40857d7-3162-cf83-dd0e-313555414f5b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "wujianguo@huawei.com" <wujianguo@huawei.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 04/27/2017 11:24 AM, Naoya Horiguchi wrote:
> On Tue, Apr 25, 2017 at 02:27:27PM +0530, Anshuman Khandual wrote:
>> Hello Jianguo,
>>
>> In the commit a49ecbcd7b0d5a1cda, it talks about HugeTLB page being
>> freed into buddy allocator instead of hugepage_freelists. But if
>> I look the code closely for the function unmap_and_move_huge_page()
>> it only calls putback_active_hugepage() which puts the page into the
>> huge page active list to free up the source HugeTLB page after any
>> successful migration. I might be missing something here, so can you
>> please point me where we release the HugeTLB page into buddy allocator
>> directly during migration ?
> 
> Hi Anshuman,
> 
> As stated in the patch description, source hugetlb page is freed after
> successful migration if overcommit is configured.
> 
> The call chain is like below:
> 
>   soft_offline_huge_page
>     migrate_pages
>       unmap_and_move_huge_page
>         putback_active_hugepage(hpage)
>           put_page // refcount is down to 0
>             __put_page
>               __put_compound_page
>                 free_huge_page
>                   if (h->surplus_huge_pages_node[nid])
>                     update_and_free_page
>                       __free_pages
> 
> So the inline comment
> 
> +		/* overcommit hugetlb page will be freed to buddy */
> 
> might be confusing because at this point the overcommit hugetlb page was
> already freed to buddy.
> 
> I hope this will help you.

Surely does. Thanks Naoya.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
