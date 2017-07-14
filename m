Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62896440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 09:26:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b20so9207425wmd.6
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 06:26:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 77si2369158wmi.90.2017.07.14.06.26.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 06:26:13 -0700 (PDT)
Date: Fri, 14 Jul 2017 15:26:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm/hmm: documents how device memory is accounted in
 rss and memcg
Message-ID: <20170714132611.GS2618@dhcp22.suse.cz>
References: <20170713211532.970-1-jglisse@redhat.com>
 <20170713211532.970-7-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170713211532.970-7-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>

On Thu 13-07-17 17:15:32, Jerome Glisse wrote:
> For now we account device memory exactly like a regular page in
> respect to rss counters and memory cgroup. We do this so that any
> existing application that starts using device memory without knowing
> about it will keep running unimpacted. This also simplify migration
> code.
> 
> We will likely revisit this choice once we gain more experience with
> how device memory is use and how it impacts overall memory resource
> management. For now we believe this is a good enough choice.
> 
> Note that device memory can not be pin. Nor by device driver, nor
> by GUP thus device memory can always be free and unaccounted when
> a process exit.

I have to look at the implementation but this gives a good idea of what
is going on and why.

> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  Documentation/vm/hmm.txt | 40 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 40 insertions(+)
> 
> diff --git a/Documentation/vm/hmm.txt b/Documentation/vm/hmm.txt
> index 192dcdb38bd1..4d3aac9f4a5d 100644
> --- a/Documentation/vm/hmm.txt
> +++ b/Documentation/vm/hmm.txt
> @@ -15,6 +15,15 @@ section present the new migration helper that allow to leverage the device DMA
>  engine.
>  
>  
> +1) Problems of using device specific memory allocator:
> +2) System bus, device memory characteristics
> +3) Share address space and migration
> +4) Address space mirroring implementation and API
> +5) Represent and manage device memory from core kernel point of view
> +6) Migrate to and from device memory
> +7) Memory cgroup (memcg) and rss accounting
> +
> +
>  -------------------------------------------------------------------------------
>  
>  1) Problems of using device specific memory allocator:
> @@ -342,3 +351,34 @@ that happens then the finalize_and_map() can catch any pages that was not
>  migrated. Note those page were still copied to new page and thus we wasted
>  bandwidth but this is considered as a rare event and a price that we are
>  willing to pay to keep all the code simpler.
> +
> +
> +-------------------------------------------------------------------------------
> +
> +7) Memory cgroup (memcg) and rss accounting
> +
> +For now device memory is accounted as any regular page in rss counters (either
> +anonymous if device page is use for anonymous, file if device page is use for
> +file back page or shmem if device page is use for share memory). This is a
> +deliberate choice to keep existing application that might start using device
> +memory without knowing about it to keep runing unimpacted.
> +
> +Drawbacks is that OOM killer might kill an application using a lot of device
> +memory and not a lot of regular system memory and thus not freeing much system
> +memory. We want to gather more real world experience on how application and
> +system react under memory pressure in the presence of device memory before
> +deciding to account device memory differently.
> +
> +
> +Same decision was made for memory cgroup. Device memory page are accounted
> +against same memory cgroup a regular page would be accounted to. This does
> +simplify migration to and from device memory. This also means that migration
> +back from device memory to regular memory can not fail because it would
> +go above memory cgroup limit. We might revisit this choice latter on once we
> +get more experience in how device memory is use and its impact on memory
> +resource control.
> +
> +
> +Note that device memory can never be pin nor by device driver nor through GUP
> +and thus such memory is always free upon process exit. Or when last reference
> +is drop in case of share memory or file back memory.
> -- 
> 2.13.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
