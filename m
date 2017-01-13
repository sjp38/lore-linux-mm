Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 116496B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:08:38 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so15933144wmd.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 05:08:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si11171689wra.193.2017.01.13.05.08.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 05:08:36 -0800 (PST)
Subject: Re: [PATCH 4/4] lib/show_mem.c: teach show_mem to work with the given
 nodemask
References: <20170112131659.23058-1-mhocko@kernel.org>
 <20170112131659.23058-5-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <13903870-92bd-1ea2-aefc-0481c850da19@suse.cz>
Date: Fri, 13 Jan 2017 14:08:34 +0100
MIME-Version: 1.0
In-Reply-To: <20170112131659.23058-5-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

On 01/12/2017 02:16 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> show_mem() allows to filter out node specific data which is irrelevant
> to the allocation request via SHOW_MEM_FILTER_NODES. The filtering
> is done in skip_free_areas_node which skips all nodes which are not
> in the mems_allowed of the current process. This works most of the
> time as expected because the nodemask shouldn't be outside of the
> allocating task but there are some exceptions. E.g. memory hotplug might
> want to request allocations from outside of the allowed nodes (see
> new_node_page).

Hm AFAICS memory hotplug's new_node_page() is restricted both by cpusets (by 
using GFP_USER), and by the nodemask it constructs. That's probably a bug in 
itself, as it shouldn't matter which task is triggering the offline?

Which probably means that if show_mem() wants to be really precise, it would 
have to start from nodemask and intersect with cpuset when the allocation in 
question cannot escape it. But if we accept that it's ok when we print too many 
nodes (because we can filter them out when reading the output by having also 
nodemask and mems_allowed printed), and strive only to not miss any nodes, then 
this patch could really fix cases when we do miss (although new_node_page() 
currently isn't such example).

Or am I wrong?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
