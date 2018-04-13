Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B697C6B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 10:20:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y10so262569wrg.9
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:20:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si1313242edb.361.2018.04.13.07.20.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 07:20:31 -0700 (PDT)
Date: Fri, 13 Apr 2018 16:20:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180413142030.GU17484@dhcp22.suse.cz>
References: <20180413131632.1413-1-david@redhat.com>
 <20180413134414.GS17484@dhcp22.suse.cz>
 <3545ef32-14db-25ab-bf1a-56044402add3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3545ef32-14db-25ab-bf1a-56044402add3@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org

On Fri 13-04-18 16:01:43, David Hildenbrand wrote:
> On 13.04.2018 15:44, Michal Hocko wrote:
> > [If you choose to not CC the same set of people on all patches - which
> > is sometimes a legit thing to do - then please cc them to the cover
> > letter at least.]
> > 
> > On Fri 13-04-18 15:16:24, David Hildenbrand wrote:
> >> I am right now working on a paravirtualized memory device ("virtio-mem").
> >> These devices control a memory region and the amount of memory available
> >> via it. Memory will not be indicated via ACPI and friends, the device
> >> driver is responsible for it.
> > 
> > How does this compare to other ballooning solutions? And why your driver
> > cannot simply use the existing sections and maintain subsections on top?
> > 
> 
> (further down in this mail is a small paragraph about that)

Sorry, I just stopped right there and didn't even finsh to the end.
Shame on me! I will do my homework and read it carefully (next week).

[...]
> "And why your driver cannot simply use the existing sections and
> maintain subsections on top?"
> 
> Can you elaborate how that is going to work? What I do as of now, is to
> remember for each memory block (basically a section because I want to
> make it as small as possible) which chunks ("subsections") are
> online/offline. This works just fine. Is this what you are referring to?

Well, basically yes. I meant to suggest you simply mark pages reserved
and pull them out. You can reuse some parts of such a struct page for
your metadata because we should simply ignore those.

You still have to allocate memmap for the full section but 128MB
sections have a nice effect that they fit into a single PMD for
sparse-vmemmap. So you do not really need to touch mem sections, all you
need is to keep your metadata on top.
-- 
Michal Hocko
SUSE Labs
