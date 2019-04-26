Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8C8CC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 17:53:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 531D42077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 17:53:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="XKuqRw4V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 531D42077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A33A76B0003; Fri, 26 Apr 2019 13:53:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B8CD6B0005; Fri, 26 Apr 2019 13:53:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 866F26B0006; Fri, 26 Apr 2019 13:53:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 422516B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 13:53:13 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j12so2520322pgl.14
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:53:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=XD4vTM697L/7+bwf8z9pZXV17Y42tWRnZ5Z11cF4DY8=;
        b=G08/Gj0Ts2EETHBkQff8rZBRzSlmIf14WaA34Ug7lUhoGEKtA/iMXOP/GikX49KBwM
         JMgw2qKQEjXnx0NJKFF4AWg4smgvy7QYvooowTkJvzPPPdn6/qL0MZ9YV5Q3bgiBr4qt
         aPgdGD/KlbCewBpRNS/qQfxbgvBjrVzWUrRnXqok1LF3iWSzydXq23+4mslk/nJW2+ZE
         eJjoVBTpSZHZQ6/hvUXlSg6ws+sQtkPWok2JIpC3wqNNqcfsW+joSTXYeaL1pwCTXeGv
         /UNDqRgZie8+TLpLLW9hhxs+niZaBuVxvYzOXN5jTBdmorZsa4YJDQTsyzZfRcm5K3ZM
         LKyA==
X-Gm-Message-State: APjAAAUZ1XcoZ1TjHLZt5RUUjDOSQW34NIWGk8t0blyf4lMnXbIILAWG
	tiTK+n2Xn0FKNTtdq/cDiNafoqFQ6NIzwhsxgJTOwDAJo37ERO3dZ77QiUpJYjg+TFIqVUvrqlt
	WHh3a88D3p652JX5vO0H+dLCVzOwkR6lIxhbCW9rhkZdoutX5/+S6KJDnvYtBUo/zyg==
X-Received: by 2002:a65:448b:: with SMTP id l11mr44547534pgq.185.1556301192714;
        Fri, 26 Apr 2019 10:53:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHuOpIXMIKUKUE7NEjI1TKk/rCjwfJLJVcXZSXkmPpmfT4bDwJlukTF1wzWQvw7EudEU25
X-Received: by 2002:a65:448b:: with SMTP id l11mr44547418pgq.185.1556301191393;
        Fri, 26 Apr 2019 10:53:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556301191; cv=none;
        d=google.com; s=arc-20160816;
        b=JYZq7wp57v3p77YbBZ0VamPVfvW0I21p6NyetKJTLhAa1MGMS3+jl0MoW5nIPsngI4
         fDl9NfV77ABkLTI01VK94s+ZSeYB89miXCittERYZ+EdRYLDw5XO608WloNeopjd7Iok
         O16sPETFaOfNHvgNF4Jgvvg+JcsE0Q+U2AorZWFm9UzFeeu6NTFZJtd3GVBeXUQru48t
         YdR8qDU2Wbd+qzkBsRsfLuxSw5yPzkk2I2yYYrT7HHGAw+zypTBlkPGxClx7xF4DCzXl
         pTs8GuTpv9SQJqzoEDvxTq53yc+3xVwdTG2iMzNkGDtPWq84kICxeIwUmKz9deD+27z1
         ly2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=XD4vTM697L/7+bwf8z9pZXV17Y42tWRnZ5Z11cF4DY8=;
        b=Y7hMXvLJlty61dOfmGFBIu6uUBDp/TkJsF0bWuoyNbTg3F2zIYOfoNi+3lDpKNkH6t
         dWFkEJYk/9Bbksszj8nD92nN0f04mUicutJqVy4lyC8WnDaBrOi8ibybRCSEjplUxMMf
         8sdRAO2/NOiO1lG+QSDYewY7yXwsSUtZ0mMn23Tt99t++4k1rSETcAGu7xxoAc20Ix95
         KSvjSTIibHLW4Iz8ORlCe1TV5ztsVyO2tPXvx1EoYB0QiHuvSdWJy8S9ni/LRylmMjlE
         TZD9oMGDaLjhwPV6GSGyL9QfX6ywL6KrA7QJFpjCmVZaz4BOpipU51cy1NtepEWjRRC2
         u9Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=XKuqRw4V;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id l26si6165131pgb.73.2019.04.26.10.53.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 10:53:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=XKuqRw4V;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cc345830000>; Fri, 26 Apr 2019 10:53:07 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 26 Apr 2019 10:53:10 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 26 Apr 2019 10:53:10 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Apr
 2019 17:53:10 +0000
Subject: Re: [PATCH] docs/vm: Minor editorial changes in the THP and hugetlbfs
 documentation.
To: Yang Shi <shy828301@gmail.com>
CC: Linux MM <linux-mm@kvack.org>, <linux-doc@vger.kernel.org>, Jonathan
 Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike
 Kravetz <mike.kravetz@oracle.com>
References: <20190425190426.10051-1-rcampbell@nvidia.com>
 <CAHbLzkojmk73xsHXtteiMif5_=Cqo13M1HeQedyuV4MTCEEk+Q@mail.gmail.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <d25da167-8f8d-acbe-64a6-b9722a6697ed@nvidia.com>
Date: Fri, 26 Apr 2019 10:53:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <CAHbLzkojmk73xsHXtteiMif5_=Cqo13M1HeQedyuV4MTCEEk+Q@mail.gmail.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1556301187; bh=XD4vTM697L/7+bwf8z9pZXV17Y42tWRnZ5Z11cF4DY8=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=XKuqRw4V290DArXBw/r6gHe4DxhUhDzoqBig2+/ADAO3Vh91lYfxwoLgr6DkYy0PU
	 7a8+QB344fVzHDkOQPjWSJIVR4rRND6qRdwm1jTFsNt4DpB9xUiDBAp1sinjCGTLqF
	 K7isFiAAne7qpyGRdo/Dbs/MGjcgvVPyRQ4btx3d5/gB/9S0nKREk7Y6SVVNpF92TK
	 zjiaTYPoFIxU9hdykJ3Rb+YTsugw+BNuc0tcttM4TdkcoOw/nTGEo3ushLrqik4zFF
	 k9LEA/IJMv3+zTelAOBKtKoMnf+Qc5gNsF2ndXwQ2C/29tAFE5K2QUe6cxHvmnQs7t
	 P+tTTr/wf7c2w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/25/19 12:38 PM, Yang Shi wrote:
> On Thu, Apr 25, 2019 at 12:05 PM <rcampbell@nvidia.com> wrote:
>>
>> From: Ralph Campbell <rcampbell@nvidia.com>
>>
>> Some minor wording changes and typo corrections.
>>
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>> Cc: Jonathan Corbet <corbet@lwn.net>
>> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
>> Cc: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>   Documentation/vm/hugetlbfs_reserv.rst | 17 +++---
>>   Documentation/vm/transhuge.rst        | 77 ++++++++++++++-------------
>>   2 files changed, 48 insertions(+), 46 deletions(-)
>>
>> diff --git a/Documentation/vm/hugetlbfs_reserv.rst b/Documentation/vm/hugetlbfs_reserv.rst
>> index 9d200762114f..f143954e0d05 100644
>> --- a/Documentation/vm/hugetlbfs_reserv.rst
>> +++ b/Documentation/vm/hugetlbfs_reserv.rst
>> @@ -85,10 +85,10 @@ Reservation Map Location (Private or Shared)
>>   A huge page mapping or segment is either private or shared.  If private,
>>   it is typically only available to a single address space (task).  If shared,
>>   it can be mapped into multiple address spaces (tasks).  The location and
>> -semantics of the reservation map is significantly different for two types
>> +semantics of the reservation map is significantly different for the two types
>>   of mappings.  Location differences are:
>>
>> -- For private mappings, the reservation map hangs off the the VMA structure.
>> +- For private mappings, the reservation map hangs off the VMA structure.
>>     Specifically, vma->vm_private_data.  This reserve map is created at the
>>     time the mapping (mmap(MAP_PRIVATE)) is created.
>>   - For shared mappings, the reservation map hangs off the inode.  Specifically,
>> @@ -109,15 +109,15 @@ These operations result in a call to the routine hugetlb_reserve_pages()::
>>                                    struct vm_area_struct *vma,
>>                                    vm_flags_t vm_flags)
>>
>> -The first thing hugetlb_reserve_pages() does is check for the NORESERVE
>> +The first thing hugetlb_reserve_pages() does is check if the NORESERVE
>>   flag was specified in either the shmget() or mmap() call.  If NORESERVE
>> -was specified, then this routine returns immediately as no reservation
>> +was specified, then this routine returns immediately as no reservations
>>   are desired.
>>
>>   The arguments 'from' and 'to' are huge page indices into the mapping or
>>   underlying file.  For shmget(), 'from' is always 0 and 'to' corresponds to
>>   the length of the segment/mapping.  For mmap(), the offset argument could
>> -be used to specify the offset into the underlying file.  In such a case
>> +be used to specify the offset into the underlying file.  In such a case,
>>   the 'from' and 'to' arguments have been adjusted by this offset.
>>
>>   One of the big differences between PRIVATE and SHARED mappings is the way
>> @@ -138,7 +138,8 @@ to indicate this VMA owns the reservations.
>>
>>   The reservation map is consulted to determine how many huge page reservations
>>   are needed for the current mapping/segment.  For private mappings, this is
>> -always the value (to - from).  However, for shared mappings it is possible that some reservations may already exist within the range (to - from).  See the
>> +always the value (to - from).  However, for shared mappings it is possible that
>> +some reservations may already exist within the range (to - from).  See the
>>   section :ref:`Reservation Map Modifications <resv_map_modifications>`
>>   for details on how this is accomplished.
>>
>> @@ -165,7 +166,7 @@ these counters.
>>   If there were enough free huge pages and the global count resv_huge_pages
>>   was adjusted, then the reservation map associated with the mapping is
>>   modified to reflect the reservations.  In the case of a shared mapping, a
>> -file_region will exist that includes the range 'from' 'to'.  For private
>> +file_region will exist that includes the range 'from' - 'to'.  For private
>>   mappings, no modifications are made to the reservation map as lack of an
>>   entry indicates a reservation exists.
>>
>> @@ -239,7 +240,7 @@ subpool accounting when the page is freed.
>>   The routine vma_commit_reservation() is then called to adjust the reserve
>>   map based on the consumption of the reservation.  In general, this involves
>>   ensuring the page is represented within a file_region structure of the region
>> -map.  For shared mappings where the the reservation was present, an entry
>> +map.  For shared mappings where the reservation was present, an entry
>>   in the reserve map already existed so no change is made.  However, if there
>>   was no reservation in a shared mapping or this was a private mapping a new
>>   entry must be created.
>> diff --git a/Documentation/vm/transhuge.rst b/Documentation/vm/transhuge.rst
>> index a8cf6809e36e..0be61b0d75d3 100644
>> --- a/Documentation/vm/transhuge.rst
>> +++ b/Documentation/vm/transhuge.rst
>> @@ -4,8 +4,9 @@
>>   Transparent Hugepage Support
>>   ============================
>>
>> -This document describes design principles Transparent Hugepage (THP)
>> -Support and its interaction with other parts of the memory management.
>> +This document describes design principles for Transparent Hugepage (THP)
>> +support and its interaction with other parts of the memory management
>> +system.
>>
>>   Design principles
>>   =================
>> @@ -35,27 +36,27 @@ Design principles
>>   get_user_pages and follow_page
>>   ==============================
>>
>> -get_user_pages and follow_page if run on a hugepage, will return the
>> +get_user_pages and follow_page, if run on a hugepage, will return the
>>   head or tail pages as usual (exactly as they would do on
>> -hugetlbfs). Most gup users will only care about the actual physical
>> +hugetlbfs). Most GUP users will only care about the actual physical
>>   address of the page and its temporary pinning to release after the I/O
>>   is complete, so they won't ever notice the fact the page is huge. But
>>   if any driver is going to mangle over the page structure of the tail
>>   page (like for checking page->mapping or other bits that are relevant
>>   for the head page and not the tail page), it should be updated to jump
>> -to check head page instead. Taking reference on any head/tail page would
>> -prevent page from being split by anyone.
>> +to check head page instead. Taking a reference on any head/tail page would
>> +prevent the page from being split by anyone.
>>
>>   .. note::
>>      these aren't new constraints to the GUP API, and they match the
>> -   same constrains that applies to hugetlbfs too, so any driver capable
>> +   same constraints that apply to hugetlbfs too, so any driver capable
>>      of handling GUP on hugetlbfs will also work fine on transparent
>>      hugepage backed mappings.
>>
>>   In case you can't handle compound pages if they're returned by
>> -follow_page, the FOLL_SPLIT bit can be specified as parameter to
>> +follow_page, the FOLL_SPLIT bit can be specified as a parameter to
>>   follow_page, so that it will split the hugepages before returning
>> -them. Migration for example passes FOLL_SPLIT as parameter to
>> +them. Migration for example passes FOLL_SPLIT as a parameter to
> 
> The migration example has been removed by me. The patch has been on
> linux-next. Please check "doc: mm: migration doesn't use FOLL_SPLIT
> anymore" out.
> 
> Thanks,
> Yang

Thanks, I will send out a v2 with this correction.


-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------

