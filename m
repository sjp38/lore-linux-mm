Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04FBE6B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 11:59:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j10so1249565wri.11
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:59:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b15si6365878edh.143.2018.04.13.08.59.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 08:59:23 -0700 (PDT)
Date: Fri, 13 Apr 2018 17:59:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180413155917.GX17484@dhcp22.suse.cz>
References: <20180413131632.1413-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413131632.1413-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org

On Fri 13-04-18 15:16:24, David Hildenbrand wrote:
[...]
> In contrast to existing balloon solutions:
> - The device is responsible for its own memory only.

Please be more specific. Any ballooning driver is responsible for its
own memory. So what exactly does that mean?

> - Works on a coarser granularity (e.g. 4MB because that's what we can
>   online/offline in Linux). We are not using the buddy allocator when unplugging
>   but really search for chunks of memory we can offline.

Again, more details please. Virtio driver already tries to scan suitable
pages to balloon AFAIK.

> - A device can belong to exactly one NUMA node. This way we can online/offline
>   memory in a fine granularity NUMA aware.

What does prevent existing balloon solutions to be NUMA aware?

> - Architectures that don't have proper memory hotplug interfaces (e.g. s390x)
>   get memory hotplug support. I have a prototype for s390x.

I am pretty sure that s390 does support memory hotplug. Or what do you
mean?

> - Once all 4MB chunks of a memory block are offline, we can remove the
>   memory block and therefore the struct pages (seems to work in my prototype),
>   which is nice.

OK, so our existing ballooning solutions indeed do not free up memmaps
which is suboptimal.

> Todo:
> - We might have to add a parameter to offline_pages(), telling it to not
>   try forever but abort in case it takes too long.

Offlining fails when it see non-migrateable pages but other than that it
should always succeed in the finite time. If not then there is a bug to
be fixed.

-- 
Michal Hocko
SUSE Labs
