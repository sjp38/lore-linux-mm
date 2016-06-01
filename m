Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 727A36B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 05:15:21 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id f62so40064559vkc.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 02:15:21 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id q6si33231884qkd.109.2016.06.01.02.15.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 02:15:20 -0700 (PDT)
Subject: =?UTF-8?Q?Re:_=e7=ad=94=e5=a4=8d:_[PATCH]_reusing_of_mapping_page_s?=
 =?UTF-8?Q?upplies_a_way_for_file_page_allocation_under_low_memory_due_to_pa?=
 =?UTF-8?Q?gecache_over_size_and_is_controlled_by_sysctl_parameters._it_is_u?=
 =?UTF-8?Q?sed_only_for_rw_page_allocation_rather_than_fault_or_readahead_al?=
 =?UTF-8?Q?location._it_is_like...?=
References: <1464685702-100211-1-git-send-email-zhouxianrong@huawei.com>
 <20160531093631.GH26128@dhcp22.suse.cz>
 <AE94847B1D9E864B8593BD8051012AF36D70EA02@SZXEML505-MBS.china.huawei.com>
 <20160531140354.GM26128@dhcp22.suse.cz>
 <ea553117-3735-fccb-0e7a-e289633cdd9f@huawei.com>
 <20160601081820.GG26601@dhcp22.suse.cz>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <3b343dc4-a27b-9ed9-a1fd-e8a773352508@huawei.com>
Date: Wed, 1 Jun 2016 17:06:09 +0800
MIME-Version: 1.0
In-Reply-To: <20160601081820.GG26601@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhouxiyu <zhouxiyu@huawei.com>, "wanghaijun (E)" <wanghaijun5@huawei.com>, "Yuchao (T)" <yuchao0@huawei.com>

 > Why would you want to reuse a page about which you have no idea about
 > its age compared to the LRU pages which would be mostly clean as well?
 > I mean this needs a deep justification!

reusing could not reuse page with page_mapcount > 0; it only reuse a pure file page without mmap.
only file pages producted by rw syscall can be reuse; so no AF consideration for it and just use
active/inactive flag to distinguish.

On 2016/6/1 16:18, Michal Hocko wrote:
> On Wed 01-06-16 09:52:45, zhouxianrong wrote:
>>>> A page suitable for reusing within mapping is
>>>> 1. clean
>>>> 2. map count is zero
>>>> 3. whose mapping is evictable
>>>
>>> Those pages are trivially reclaimable so why should we tag them in a
>>> special way?
>> yes, those pages can be reclaimed by reclaim procedure. i think in low memory
>> case for a process that doing file rw directly-reusing-mapping-page may be
>> a choice than alloc_page just like directly reclaim. alloc_page could failed return
>> due to gfp and watermark in low memory. for reusing-mapping-page procedure quickly
>> select a page that is be reused so introduce a tag for this purpose.
>
> Why would you want to reuse a page about which you have no idea about
> its age compared to the LRU pages which would be mostly clean as well?
> I mean this needs a deep justification!
>
>>> So is this a form of a page cache limit to trigger the reclaim earlier
>>> than on the global memory pressure?
>
>> my thinking is that page cache limit trigger reuse-mapping-page. the
>> limit is earlier than on the global memory pressure.
>> reuse-mapping-page can suppress increment of page cache size and big page cache size
>> is one reason of low memory and fragment.
>
> But why would you want to limit the amount of the page cache in the
> first place when it should be trivially reclaimable most of the time?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
