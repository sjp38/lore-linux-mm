Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20C396B4813
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:17:02 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id q8so5477890edd.8
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:17:02 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a26-v6si323276ejg.119.2018.11.27.05.17.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 05:17:00 -0800 (PST)
Date: Tue, 27 Nov 2018 14:16:58 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181127131658.GV12455@dhcp22.suse.cz>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
 <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
 <20181121025231.ggk7zgq53nmqsqds@master>
 <20181121071549.GG12932@dhcp22.suse.cz>
 <CADZGycYghU=_vXR759mwFhvV=7KKu3z3h1FyWb4OeEMeOY5isg@mail.gmail.com>
 <20181126081608.GE12455@dhcp22.suse.cz>
 <20181127031200.46mu6moxcxat57wz@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127031200.46mu6moxcxat57wz@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Oscar Salvador <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>

On Tue 27-11-18 03:12:00, Wei Yang wrote:
> On Mon, Nov 26, 2018 at 09:16:08AM +0100, Michal Hocko wrote:
> >On Mon 26-11-18 10:28:40, Wei Yang wrote:
> >[...]
> >> But I get some difficulty to understand this TODO. You want to get rid of
> >> these lock? While these locks seem necessary to protect those data of
> >> pgdat/zone. Would you mind sharing more on this statement?
> >
> >Why do we need this lock to be irqsave? Is there any caller that uses
> >the lock from the IRQ context?
> 
> Went through the code, we have totally 9 place acquire
> pgdat_resize_lock:
> 
>    lib/show_mem.c:         1    show_mem()
>    mm/memory_hotplug.c:    4    online/offline_pages/__remove_zone()
>    mm/page_alloc.c:        2    defer_init
>    mm/sparse.c:            2    not necessary
> 
> Two places I am not sure:
> 
>    * show_mem() would be called from __alloc_pages_slowpath()

This shouldn't really need the lock. It is a mostly debugging aid rather
than something that cannot tolarate racing with hotplug. What is the
worst case that can happen?

>    * __remove_zone() is related to acpi_scan() on x86, may related to
>      other method on different arch

This one really needs a lock qwith a larger scope anyway.
-- 
Michal Hocko
SUSE Labs
