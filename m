Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 394E36B0032
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 08:33:08 -0400 (EDT)
Received: by wicgi11 with SMTP id gi11so45061041wic.0
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 05:33:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa9si2616365wid.33.2015.06.24.05.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Jun 2015 05:33:06 -0700 (PDT)
Subject: Re: [RFC v2 3/3] mm: make swapin readahead to improve thp collapse
 rate
References: <1434799686-7929-1-git-send-email-ebru.akagunduz@gmail.com>
 <1434799686-7929-4-git-send-email-ebru.akagunduz@gmail.com>
 <20150621181131.GA6710@node.dhcp.inet.fi> <558766E4.5020801@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <558AA37E.20106@suse.cz>
Date: Wed, 24 Jun 2015 14:33:02 +0200
MIME-Version: 1.0
In-Reply-To: <558766E4.5020801@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 06/22/2015 03:37 AM, Rik van Riel wrote:
> On 06/21/2015 02:11 PM, Kirill A. Shutemov wrote:
>> On Sat, Jun 20, 2015 at 02:28:06PM +0300, Ebru Akagunduz wrote:
>>> +	__collapse_huge_page_swapin(mm, vma, address, pmd, pte);
>>> +
>> 
>> And now the pages we swapped in are not isolated, right?
>> What prevents them from being swapped out again or whatever?
> 
> Nothing, but __collapse_huge_page_isolate is run with the
> appropriate locks to ensure that once we actually collapse
> the THP, things are present.
> 
> The way do_swap_page is called, khugepaged does not even
> wait for pages to be brought in from swap. It just maps
> in pages that are in the swap cache, and which can be
> immediately locked (without waiting).
> 
> It will also start IO on pages that are not in memory
> yet, and will hopefully get those next round.

Hm so what if the process is slightly larger than available memory and really
doesn't touch the swapped out pages that much? Won't that just be thrashing and
next round you find them swapped out again?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
