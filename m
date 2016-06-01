Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4802B6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 21:54:19 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id b126so15861349ite.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 18:54:19 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id l69si15764436otc.233.2016.05.31.18.54.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 18:54:18 -0700 (PDT)
Subject: =?UTF-8?Q?Re:_=e7=ad=94=e5=a4=8d:_[PATCH]_reusing_of_mapping_page_s?=
 =?UTF-8?Q?upplies_a_way_for_file_page_allocation_under_low_memory_due_to_pa?=
 =?UTF-8?Q?gecache_over_size_and_is_controlled_by_sysctl_parameters._it_is_u?=
 =?UTF-8?Q?sed_only_for_rw_page_allocation_rather_than_fault_or_readahead_al?=
 =?UTF-8?Q?location._it_is_like...?=
References: <1464685702-100211-1-git-send-email-zhouxianrong@huawei.com>
 <20160531093631.GH26128@dhcp22.suse.cz>
 <AE94847B1D9E864B8593BD8051012AF36D70EA02@SZXEML505-MBS.china.huawei.com>
 <20160531140354.GM26128@dhcp22.suse.cz>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <ea553117-3735-fccb-0e7a-e289633cdd9f@huawei.com>
Date: Wed, 1 Jun 2016 09:52:45 +0800
MIME-Version: 1.0
In-Reply-To: <20160531140354.GM26128@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhouxiyu <zhouxiyu@huawei.com>, "wanghaijun (E)" <wanghaijun5@huawei.com>, "Yuchao (T)" <yuchao0@huawei.com>

 >> A page suitable for reusing within mapping is
 >> 1. clean
 >> 2. map count is zero
 >> 3. whose mapping is evictable
 >
 > Those pages are trivially reclaimable so why should we tag them in a
 > special way?
   yes, those pages can be reclaimed by reclaim procedure. i think in low memory
   case for a process that doing file rw directly-reusing-mapping-page may be
   a choice than alloc_page just like directly reclaim. alloc_page could failed return
   due to gfp and watermark in low memory. for reusing-mapping-page procedure quickly
   select a page that is be reused so introduce a tag for this purpose.


 > So is this a form of a page cache limit to trigger the reclaim earlier
 > than on the global memory pressure?
   my thinking is that page cache limit trigger reuse-mapping-page . the limit is earlier than on the global memory pressure.
   reuse-mapping-page can suppress increment of page cache size and big page cache size
   is one reason of low memory and fragment.

On 2016/5/31 22:03, Michal Hocko wrote:
> On Tue 31-05-16 13:35:37, zhouxianrong wrote:
>> Hey :
>> the consideration of this patch is that reusing mapping page
>> rather than allocating a new page for page cache when system be
>> placed in some states.  For lookup pages quickly add a new tag
>> PAGECACHE_TAG_REUSE for radix tree which tag the pages that is
>> suitable for reusing.
>>
>> A page suitable for reusing within mapping is
>> 1. clean
>> 2. map count is zero
>> 3. whose mapping is evictable
>
> Those pages are trivially reclaimable so why should we tag them in a
> special way?
>
> [...]
>
>> How to startup the functional
>> 1. the system is under low memory state and there are fs rw operations
>> 2. page cache size is get bigger over sysctl limit
>
> So is this a form of a page cache limit to trigger the reclaim earlier
> than on the global memory pressure?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
