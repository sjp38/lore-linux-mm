Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D7B4C6B7909
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 03:40:25 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so22120edm.18
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 00:40:25 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 06 Dec 2018 09:40:23 +0100
From: osalvador@suse.de
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
In-Reply-To: <20181206083206.GC1286@dhcp22.suse.cz>
References: <20181203100309.14784-1-mhocko@kernel.org>
 <20181205122918.GL1286@dhcp22.suse.cz>
 <20181205165716.GS1286@dhcp22.suse.cz>
 <20181206052137.GA28595@hori1.linux.bs1.fc.nec.co.jp>
 <20181206083206.GC1286@dhcp22.suse.cz>
Message-ID: <ec66e12d8140ba117a0e98c37f6557bd@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oscar Salvador <OSalvador@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, owner-linux-mm@kvack.org

>> This commit adds shake_page() for mlocked pages to make sure that the 
>> target
>> page is flushed out from LRU cache. Without this shake_page(), 
>> subsequent
>> delete_from_lru_cache() (from me_pagecache_clean()) fails to isolate 
>> it and
>> the page will finally return back to LRU list.  So this scenario leads 
>> to
>> "hwpoisoned by still linked to LRU list" page.
> 
> OK, I see. So does that mean that the LRU handling is no longer needed
> and there is a guanratee that all kernels with the above commit cannot
> ever get an LRU page?

For the sake of completeness:

I made a quick test reverting 286c469a988 on upstream kernel.
As expected, the poisoned page is in LRU when it hits do_migrate_range,
and so, the migration path is taken and I see the exact failure I saw 
on. 4.4


Oscar Salvador
---
Suse L3
