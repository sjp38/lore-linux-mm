Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 12AEF6B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:37:18 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so130708859wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 05:37:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id en7si18363149wjd.61.2015.09.14.05.37.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Sep 2015 05:37:16 -0700 (PDT)
Subject: Re: Can we disable transparent hugepages for lack of a legitimate use
 case please?
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
 <20150824201952.5931089.66204.70511@amd.com>
 <BLUPR02MB1698B29C7908833FA1364C8ACD620@BLUPR02MB1698.namprd02.prod.outlook.com>
 <20150910164506.GK10639@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F6BF79.4010801@suse.cz>
Date: Mon, 14 Sep 2015 14:37:13 +0200
MIME-Version: 1.0
In-Reply-To: <20150910164506.GK10639@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, James Hartshorn <jhartshorn@connexity.com>
Cc: "Bridgman, John" <John.Bridgman@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 09/10/2015 06:45 PM, Andrea Arcangeli wrote:
>> >Mysql (tokudb)
>> >https://dzone.com/articles/why-tokudb-hates-transparent
> This seems a THP issue: unless the alternate malloc allocator starts
> using MADV_NOHUGEPAGE, its memory loss would become extreme with the
> split_huge_page pending changes from Kirill. There's little the kernel
> can do about this, in fact Kirill's latest changes goes in the very
> opposite direction of what's needed to reduce the memory footprint for
> this MADV_DONTNEED 4kb case.
>
> With current code however the best you can do is:
>
> echo 0 >/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
>
> That will guarantee that khugepaged never increases the memory
> footprint after a MADV_DONTNEED done by the alternate malloc
> allocator. Just that will definitely stop to help with the
> split_huge_page pending changes. You could consider testing that but
> if the split_huge_page pending changes are merged, this tuning shall
> disappear.

I don't think it's that pessimistic after Kirill's patchset? 
MADV_DONTNEED should still result in unmaps, which results in 
split_huge_pmd. Then the THP is put in a shrinker list and will be fully 
split in response to memory pressure, see:

  [PATCHv10 34/36] thp: introduce deferred_split_huge_page()


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
