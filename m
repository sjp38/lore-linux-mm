Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7286B006C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 21:44:52 -0400 (EDT)
Received: by qgev13 with SMTP id v13so31095326qge.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:44:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g32si31366091qgg.124.2015.06.25.18.44.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 18:44:51 -0700 (PDT)
Message-ID: <558CAE7C.9000105@redhat.com>
Date: Thu, 25 Jun 2015 21:44:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 3/3] mm: make swapin readahead to improve thp collapse
 rate
References: <1434799686-7929-1-git-send-email-ebru.akagunduz@gmail.com> <1434799686-7929-4-git-send-email-ebru.akagunduz@gmail.com> <20150621181131.GA6710@node.dhcp.inet.fi> <558766E4.5020801@redhat.com> <558AA37E.20106@suse.cz>
In-Reply-To: <558AA37E.20106@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 06/24/2015 08:33 AM, Vlastimil Babka wrote:
> On 06/22/2015 03:37 AM, Rik van Riel wrote:
>> On 06/21/2015 02:11 PM, Kirill A. Shutemov wrote:
>>> On Sat, Jun 20, 2015 at 02:28:06PM +0300, Ebru Akagunduz wrote:
>>>> +	__collapse_huge_page_swapin(mm, vma, address, pmd, pte);
>>>> +
>>>
>>> And now the pages we swapped in are not isolated, right?
>>> What prevents them from being swapped out again or whatever?
>>
>> Nothing, but __collapse_huge_page_isolate is run with the
>> appropriate locks to ensure that once we actually collapse
>> the THP, things are present.
>>
>> The way do_swap_page is called, khugepaged does not even
>> wait for pages to be brought in from swap. It just maps
>> in pages that are in the swap cache, and which can be
>> immediately locked (without waiting).
>>
>> It will also start IO on pages that are not in memory
>> yet, and will hopefully get those next round.
> 
> Hm so what if the process is slightly larger than available memory and really
> doesn't touch the swapped out pages that much? Won't that just be thrashing and
> next round you find them swapped out again?

Yes, it might.

However, all the policy smarts are in patch 2/3, not in
patch 3/3 (which has the mechanism).

I suspect the code could use some more smarts, but I am
not quite sure what they should be...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
