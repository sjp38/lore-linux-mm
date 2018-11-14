Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 712CE6B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 02:43:44 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id n32-v6so7761830edc.17
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 23:43:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18-v6sor11413411edu.15.2018.11.13.23.43.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 23:43:42 -0800 (PST)
Date: Wed, 14 Nov 2018 07:43:41 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: skip zone who has no managed_pages in
 calculate_totalreserve_pages()
Message-ID: <20181114074341.r53rukmj25ydvaqi@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181112071404.13620-1-richard.weiyang@gmail.com>
 <20181112080926.GA14987@dhcp22.suse.cz>
 <20181112142641.6oxn4fv4pocm7fmt@master>
 <20181112144020.GC14987@dhcp22.suse.cz>
 <20181113013942.zgixlky4ojbzikbd@master>
 <20181113080834.GK15120@dhcp22.suse.cz>
 <20181113081644.giu5vxhsfqjqlexh@master>
 <20181113090758.GL15120@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113090758.GL15120@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Tue, Nov 13, 2018 at 10:07:58AM +0100, Michal Hocko wrote:
>On Tue 13-11-18 08:16:44, Wei Yang wrote:
>
>No, I believe we want all three of them. But reviewing
>for_each_populated_zone users and explicit checks for present/managed
>pages and unify them would be a step forward both a more optimal code
>and more maintainable code. I haven't checked but
>for_each_populated_zone would seem like a proper user for managed page
>counter. But that really requires to review all current users.
>

To sync with your purpose, I searched the user of
for_each_populated_zone() and replace it with a new loop
for_each_managed_zone().

Here is a summary of what I have done.

file                          used     changed
----------------------------------------------
arch/s390/mm/page-states.c    1        1
kernel/power/snapshot.c       7        3
mm/highmem.c                  1        1
mm/huge_memory.c              1        0
mm/khugepaged.c               1        1
mm/madvise.c                  1        1
mm/page_alloc.c               8        8
mm/vmstat.c                   5        5

The general idea to replace for_each_populated_zone() with
for_each_populated_zone() is:

   * access zone->freelist
   * access zone pcp
   * access zone_page_state

Is my understanding comply with what you want? 

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
