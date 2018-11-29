Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2297D6B5357
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:49:26 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id q8so1261930edd.8
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 07:49:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v27si1232206edm.111.2018.11.29.07.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 07:49:24 -0800 (PST)
Date: Thu, 29 Nov 2018 16:49:22 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, show_mem: drop pgdat_resize_lock in show_mem()
Message-ID: <20181129154922.GT6923@dhcp22.suse.cz>
References: <20181128210815.2134-1-richard.weiyang@gmail.com>
 <20181129081703.GN6923@dhcp22.suse.cz>
 <20181129150449.desiutez735agyau@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181129150449.desiutez735agyau@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, jweiner@fb.com, linux-mm@kvack.org

On Thu 29-11-18 15:04:49, Wei Yang wrote:
> On Thu, Nov 29, 2018 at 09:17:03AM +0100, Michal Hocko wrote:
> >On Thu 29-11-18 05:08:15, Wei Yang wrote:
> >> Function show_mem() is used to print system memory status when user
> >> requires or fail to allocate memory. Generally, this is a best effort
> >> information and not willing to affect core mm subsystem.
> >
> >I would drop the part after and
> >
> >> The data protected by pgdat_resize_lock is mostly correct except there is:
> >> 
> >>    * page struct defer init
> >>    * memory hotplug
> >
> >This is more confusing than helpful. I would just drop it.
> >
> >The changelog doesn't explain what is done and why. The second one is
> >much more important. I would say this
> >
> >"
> >Function show_mem() is used to print system memory status when user
> >requires or fail to allocate memory. Generally, this is a best effort
> >information so any races with memory hotplug (or very theoretically an
> >early initialization) should be toleratable and the worst that could
> >happen is to print an imprecise node state.
> >
> >Drop the resize lock because this is the only place which might hold the
> 
> As I mentioned in https://patchwork.kernel.org/patch/10689759/, there is
> one place used in __remove_zone(). I don't get your suggestion of this
> place. And is __remove_zone() could be called in IRQ context?

It is only called from __remove_pages and that one calls cond_resched so
obviosly not.

-- 
Michal Hocko
SUSE Labs
