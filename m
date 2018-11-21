Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 00D766B24CC
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 02:14:15 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m19so2565904edc.6
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 23:14:15 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g4si564929edp.176.2018.11.20.23.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 23:14:14 -0800 (PST)
Date: Wed, 21 Nov 2018 08:14:12 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181121071412.GF12932@dhcp22.suse.cz>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
 <20181121024435.zbd76wqplc2obpxb@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121024435.zbd76wqplc2obpxb@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed 21-11-18 02:44:35, Wei Yang wrote:
> On Tue, Nov 20, 2018 at 08:31:41AM +0100, Michal Hocko wrote:
> >On Tue 20-11-18 09:48:22, Wei Yang wrote:
> >> After memory hot-added, users could online pages through sysfs, and this
> >> could be done in parallel.
> >> 
> >> In case two threads online pages in two different empty zones at the
> >> same time, there would be a contention to update the nr_zones.
> >
> >No, this shouldn't be the case as I've explained in the original thread.
> >We use memory hotplug lock over the online phase. So there shouldn't be
> >any race possible.
> 
> Sorry for misunderstanding your point.
> 
> >
> >On the other hand I would like to see the global lock to go away because
> >it causes scalability issues and I would like to change it to a range
> >lock. This would make this race possible.
> 
> The global lock you want to remove is mem_hotplug_begin() ?

Yes

> 
> Hmm... my understanding may not correct. While mem_hotplug_begin() use
> percpu lock, which means if there are two threads running on two
> different cpus to online pages at the same time, they could get their
> own lock?

No. The per-cpu is a mere implementation detail on how the
synchronization is done. Only one path might aquire the exclusive lock.

-- 
Michal Hocko
SUSE Labs
