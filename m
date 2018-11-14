Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1AC6B0283
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:54:09 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so2297971edz.15
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:54:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k24-v6si607763edq.309.2018.11.14.00.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 00:54:08 -0800 (PST)
Date: Wed, 14 Nov 2018 09:54:06 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: skip zone who has no managed_pages in
 calculate_totalreserve_pages()
Message-ID: <20181114085406.GF23419@dhcp22.suse.cz>
References: <20181112080926.GA14987@dhcp22.suse.cz>
 <20181112142641.6oxn4fv4pocm7fmt@master>
 <20181112144020.GC14987@dhcp22.suse.cz>
 <20181113013942.zgixlky4ojbzikbd@master>
 <20181113080834.GK15120@dhcp22.suse.cz>
 <20181113081644.giu5vxhsfqjqlexh@master>
 <20181113090758.GL15120@dhcp22.suse.cz>
 <20181114074341.r53rukmj25ydvaqi@master>
 <20181114074821.GE23419@dhcp22.suse.cz>
 <20181114082047.tenvzvorifd56emd@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082047.tenvzvorifd56emd@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Wed 14-11-18 08:20:47, Wei Yang wrote:
> On Wed, Nov 14, 2018 at 08:48:21AM +0100, Michal Hocko wrote:
> >On Wed 14-11-18 07:43:41, Wei Yang wrote:
> >> On Tue, Nov 13, 2018 at 10:07:58AM +0100, Michal Hocko wrote:
> >> >On Tue 13-11-18 08:16:44, Wei Yang wrote:
> >> >
> >> >No, I believe we want all three of them. But reviewing
> >> >for_each_populated_zone users and explicit checks for present/managed
> >> >pages and unify them would be a step forward both a more optimal code
> >> >and more maintainable code. I haven't checked but
> >> >for_each_populated_zone would seem like a proper user for managed page
> >> >counter. But that really requires to review all current users.
> >> >
> >> 
> >> To sync with your purpose, I searched the user of
> >> for_each_populated_zone() and replace it with a new loop
> >> for_each_managed_zone().
> >
> >I do not think we really want a new iterator. Is there any users of
> >for_each_populated_zone which would be interested in something else than
> >managed pages?
> 
> Your purpose is replace the populated_zone() in
> for_each_populated_zone() with managed_zone()?

Well, we might rename as well but I if we have only one or two users
then an opencoded variant with populated_zone() check sounds better than
a new iterator.

> If this is the case, most of them is possible. Some places I am not sure
> is:
> 
>     kernel/power/snapshot.c

This one really looks like it wants the full pfn range whether it is
managed or not. So changing this to opencoded for_each_zone + populated_zone
check should be OK.

>     mm/huge_memory.c
>     mm/khugepaged.c

These two are definitely page allocator related so they do care about
managed.

-- 
Michal Hocko
SUSE Labs
