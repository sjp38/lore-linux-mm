Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8857A6B5535
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 18:49:59 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id q8so1900583edd.8
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 15:49:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor2245447eda.25.2018.11.29.15.49.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 15:49:58 -0800 (PST)
Date: Thu, 29 Nov 2018 23:49:56 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, show_mem: drop pgdat_resize_lock in show_mem()
Message-ID: <20181129234956.vdlz5hkfxoawda4y@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181128210815.2134-1-richard.weiyang@gmail.com>
 <20181129081703.GN6923@dhcp22.suse.cz>
 <20181129150449.desiutez735agyau@master>
 <20181129154922.GT6923@dhcp22.suse.cz>
 <20181129160524.ewjn2x7spyloitu4@master>
 <20181129161847.GU6923@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181129161847.GU6923@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, jweiner@fb.com, linux-mm@kvack.org

On Thu, Nov 29, 2018 at 05:18:47PM +0100, Michal Hocko wrote:
>On Thu 29-11-18 16:05:24, Wei Yang wrote:
>> On Thu, Nov 29, 2018 at 04:49:22PM +0100, Michal Hocko wrote:
>[...]
>> >It is only called from __remove_pages and that one calls cond_resched so
>> >obviosly not.
>> >
>> 
>> Forgive my poor background knowledge, I went throught the code, but not
>> found where call cond_resched.
>> 
>>   __remove_pages()
>>     release_mem_region_adjustable()
>>     clear_zone_contiguous()
>>     __remove_section()
>>       unregister_memory_section()
>>       __remove_zone()
>>       sparse_remove_one_section()
>>     set_zone_contiguous()
>> 
>> Would you mind giving me a hint?
>
>This is the code as of 4.20-rc2
>
>	for (i = 0; i < sections_to_remove; i++) {
>		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
>
>		cond_resched();
>		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset,
>				altmap);
>		map_offset = 0;
>		if (ret)
>			break;
>	}
>
>Maybe things have changed in the meantime but in general the code is
>sleepable (e.g. release_mem_region_adjustable does GFP_KERNEL
>allocation) and that rules out IRQ context.

Thanks, my code is not up to date.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
