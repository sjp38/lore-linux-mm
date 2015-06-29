Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5642D6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 17:48:35 -0400 (EDT)
Received: by obbop1 with SMTP id op1so113855046obb.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 14:48:35 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c204si27606286oih.6.2015.06.29.14.48.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 14:48:34 -0700 (PDT)
Message-ID: <5591BD0F.7050809@oracle.com>
Date: Mon, 29 Jun 2015 14:47:59 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC v5 PATCH 1/9] mm/hugetlb: add region_del() to delete a specific
 range of entries
References: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com> <1435019919-29225-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1435019919-29225-2-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On 06/22/2015 05:38 PM, Mike Kravetz wrote:
> fallocate hole punch will want to remove a specific range of pages.
> The existing region_truncate() routine deletes all region/reserve
> map entries after a specified offset.  region_del() will provide
> this same functionality if the end of region is specified as -1.
> Hence, region_del() can replace region_truncate().
>
> Unlike region_truncate(), region_del() can return an error in the
> rare case where it can not allocate memory for a region descriptor.
> This ONLY happens in the case where an existing region must be split.
> Current callers passing -1 as end of range will never experience
> this error and do not need to deal with error handling.  Future
> callers of region_del() (such as fallocate hole punch) will need to
> handle this error.

Unfortunately, this new region_del() functionality required for hole
punch conflicts with existing region_chg()/region_add() assumptions.

region_chg/region_add is something like a two step commit process for
adding new region entries.  region_chg is first called to determine
the changes required for the new entry.  If the new entry can be
represented by expanding an existing region, no changes are made to
the map in region_chg.  If the new entry is not adjacent to an
existing region, a placeholder is created during region_chg.  Later
when region_add is called, the assumption is that a region (real or
placeholder) can be expanded to represent the new entry.  Since
all required entries already exist in the map, region_add can not
fail.

It is possible for the new region_del to modify the map between the
region_chg and region_add calls.  It can not modify the same map
entry being added by region_chg/region_add as that is protected by
the fault mutex.  However, it can modify an entry adjacent to the
new entry.  The entry could be modified so that it is no longer
adjacent to the new entry.  As a result, when region_add is called
it will not find a region which can be expanded to represent the
new entry.

In this situation, region_add only needs to add a new region to
the map.  However, to do so would require allocating a new region
descriptor.  The allocation could fail which would result in
region_add failing.

I'm thinking about having a cache of region descriptors pre-allocated
to handle this (rare) situation.  The number of descriptors needed
in the cache would correspond to the number of page faults in
progress (between region_chg and region_add).  region_chg would make
sure there are sufficient descriptors and allocate one if needed.
Error handling for region_chg ENOMEM already exists.  A sufficient
number of entries would be pre-allocated such that in the normal
case no allocation would be necessary.

Thoughts?
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
