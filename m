Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2DB6B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 16:36:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s63so805759wme.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 13:36:46 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id b187si7369388wmh.51.2016.05.04.13.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 13:36:45 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id n129so204128440wmn.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 13:36:45 -0700 (PDT)
Date: Wed, 4 May 2016 22:36:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
Message-ID: <20160504203643.GI21490@dhcp22.suse.cz>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com>
 <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Wed 04-05-16 19:41:59, Odzioba, Lukasz wrote:
> On Thu 02-05-16 03:00:00, Michal Hocko wrote:
> > So I have given this a try (not tested yet) and it doesn't look terribly
> > complicated. It is hijacking vmstat for a purpose it wasn't intended for
> > originally but creating a dedicated kenrnel threads/WQ sounds like an
> > overkill to me. Does this helps or do we have to be more aggressive and
> > wake up shepherd from the allocator slow path. Could you give it a try
> > please?
> 
> It seems to work fine, but it takes quite random time to drain lists, sometimes
> a couple of seconds sometimes over two minutes. It is acceptable I believe.

I guess you mean that some CPUs are not drained for few minutes, right?
This might be a quite long and I tried to not flush LRU drain to the
idle entry because I felt it would be too expensive. Maybe it would be
better to kick the vmstat_shepherd from the allocator slow path. It
would still take unpredictable amount of time but it would at list be
called when we are getting short on memory.
 
> I have an app which allocates almost all of the memory from numa node and
> with just second patch and 100 consecutive executions 30-50% got killed.

This is still not acceptable. So I guess we need a way to kick
vmstat_shepherd from the reclaim path. I will think about that. Sounds a
bit tricky at first sight.

> After applying also your first patch I haven't seen any oom kill
> activity - great.

As I've said the first patch is quite dangerous as it depends on the WQ
to make a forward progress which might depend on the memory allocation
to create a new worker.
 
> I was wondering how many lru_add_drain()'s are called and after boot when
> machine was idle it was a bit over 5k calls during first 400s, and with some 
> activity it went up to 15k calls during 700s (including 5k from previous 
> experiment) which sounds fair to me given big cpu count.
> 
> Do you see any advantages of dropping THP from pagevecs over this
> solution?

Well the general purpose of pcp pagevecs is to reduce the lru_lock
contention. I have never measured the effect of THP pages. It is true
THP amortizes the contention by the page number handled at once so it
might be the easiest way (and certainly more acceptable for an old
kernel which you seem to be running as mentioned by Dave) but it sounds
too special cased and I would rather see less special casing for THP. So
if the async pcp sync is not too tricky or hard to maintain and worsk I
would rather go that way.

Thanks for testing those patches!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
