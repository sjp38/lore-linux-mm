Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D43266B75DB
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 14:07:57 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id w15so10314597edl.21
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 11:07:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94si309902edl.165.2018.12.05.11.07.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 11:07:56 -0800 (PST)
Date: Wed, 5 Dec 2018 20:07:54 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC Get rid of shrink code - memory-hotplug]
Message-ID: <20181205190754.GU1286@dhcp22.suse.cz>
References: <72455c1d4347d263cb73517187bc1394@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <72455c1d4347d263cb73517187bc1394@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: david@redhat.com, dan.j.williams@gmail.com, pasha.tatashin@soleen.com, linux-mm@kvack.org

On Tue 04-12-18 10:26:00, osalvador@suse.de wrote:
[...]
> __pageblock_pfn_to_page()->pfn_to_online_page()
>      In case zone->contiguous, we just return with pfn_to_page().
>      So we just need to make sure that zone->contiguous has the right value.

Or we can consider removing this optimization altogether. THe only
consumer is compaction and I do not see this to be a hot path.

>  * create_mem_extents
>    - What?

I have crossed that code as well and I cannot say I follow. Anyway I
suspect we should be safe after saveable_*_page uses pfn_to_online_page
is used and David has laready sent a patch for that.

>  * vmemmap_find_next_valid_pfn()
>    - I am not really sure if this represents a problem

git grep doesn't see any user of this function.

>  * kmemleak_scan()
>    - It is ok, but I think we should check for the pfn to belong to the node
> here?

This wants to use pfn_to_online_page and chech the node id. Checking the
node_id would be an optimization because interleaving nodes would check
the same pfn multiple times.

>  * Crash core:
>    - VMCOREINFO_OFFSET(pglist_data, node_start_pfn) is this a problem?

My understanding in this area is very minimal. But I do not see this to
be a problem. Crash, as the only consumer should have to handle offline
holes somehow anyway.

> 
>  * lookup_page_ext()
>    - For !CONFIG_SPARSEMEM, node_start_pfn is used.

HOTPLUG is SPARSEMEM only

> So overall, besides a couple of places I am not sure it would cause trouble,
> I would tend to say this is doable.

Cool! Thanks for crawling all that code. This must have been really
tedious.

> Another thing that needs remark is that Patchset [3] aims for not
> touching pages during hot-remove path, so we will have to find another
> way to trigger clear/set_zone_contiguous, but that is another topic.

I still didn't get around to look into that one, sorry.

> While it is true that the current shrink code can be simplified as
> showed in [2], I think that getting rid of it would be a nice thing to
> do unless we need to keep the code around.

Absolutely agreed.

> I would like to hear other opinions though.
> Is it too risky? Is there anything I overlooked that might cause trouble?
> Did I miss anything?

No, go ahead. This is a relict from the nasty zone shifting times. The
more code we can get rid of the better.
 
> [1] https://patchwork.kernel.org/patch/10700791/
> [2] https://patchwork.kernel.org/patch/10700791/
> [3] https://patchwork.kernel.org/cover/10700783/

Thanks a lot!
-- 
Michal Hocko
SUSE Labs
