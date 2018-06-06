Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D43136B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 08:43:24 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k12-v6so3502795wrl.21
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 05:43:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h53-v6si7154872ede.286.2018.06.06.05.43.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Jun 2018 05:43:23 -0700 (PDT)
Date: Wed, 6 Jun 2018 14:43:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory mapped pages not being swapped out
Message-ID: <20180606124322.GB32498@dhcp22.suse.cz>
References: <CAJ6kbHezPzbLW=1mwdnywMn639X4eLz9nnRZdk6oeyLjXR6mQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJ6kbHezPzbLW=1mwdnywMn639X4eLz9nnRZdk6oeyLjXR6mQg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Telles <rafaelt@simbioseventures.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue 05-06-18 16:14:02, Rafael Telles wrote:
> Hi there, I am running a program where I need to map hundreds of thousands
> of files and each file has several kilobytes (min. of 4kb per file). The
> program calls mmap() for every 4096 bytes on each file, ending up with
> millions of memory mapped pages, so I have ceil(N/4096) pages for each
> file, where N is the file size.
> 
> As the program runs, more files are created and the older files get bigger,
> then I need to remap those pages, so it's always adding more pages.
> 
> I am concerned about when and how Linux is going to swap out pages in order
> to get more memory, the program seems to only increase memory usage overall
> and I am afraid it runs out of memory.

We definitely do reclaim mmaped memory - be it a page cache or anonymous
memory. The code doing that is mostly in shrink_page_list (resp.
page_check_references for aging decisions) - somehow non-trivial to
follow but you know where to start looking at least ;)

> I tried setting these sysctl parameters so it would swap out as soon as
> possible (just to understand how Linux memory management works), but it
> didn't change anything:
> 
> vm.zone_reclaim_mode = 1

This will make difference only for NUMA machines and it will try to
keep allocations to local nodes. It can lead to a more extensive
reclaim but I would definitely not recommend setting it up unless you
want a strong NUMA locality payed by reclaiming more while the rest of
the memory might be sitting idle.


> vm.min_unmapped_ratio = 99

This one is active only for the zone/node reclaim and tells whether to
reclaim the specific node based on how much of memory is mapped. Your
setting would tell that the node is not worth to be reclaimed unless 99%
of it is clean page cache (the behavior depends on the zone_reclaim_mode
because zone_reclaim_mode = 1 excludes mapped pages AFAIR).

So this will most likely not do what you think.

> How can I be sure the program won't run out of memory?

The default overcommit setting should not allow you to mmap too much in
many cases.

> Do I have to manually unmap pages to free memory?

No.
-- 
Michal Hocko
SUSE Labs
