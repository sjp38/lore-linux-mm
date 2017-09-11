Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAB86B02AA
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 04:17:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l19so6780624wmi.1
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 01:17:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b130si6153988wmh.126.2017.09.11.01.17.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 01:17:16 -0700 (PDT)
Date: Mon, 11 Sep 2017 10:17:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
Message-ID: <20170911081714.4zc33r7wlj2nnbho@dhcp22.suse.cz>
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-2-mhocko@kernel.org>
 <eb5bf356-f498-b430-1ae8-4ff1ad15ad7f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eb5bf356-f498-b430-1ae8-4ff1ad15ad7f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 08-09-17 19:26:06, Vlastimil Babka wrote:
> On 09/04/2017 10:21 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Memory offlining can fail just too eagerly under a heavy memory pressure.
> > 
> > [ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
> > [ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
> > [ 5410.336811] page dumped because: isolation failed
> > [ 5410.336813] page->mem_cgroup:ffff8801cd662000
> > [ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed
> > 
> > Isolation has failed here because the page is not on LRU. Most probably
> > because it was on the pcp LRU cache or it has been removed from the LRU
> > already but it hasn't been freed yet. In both cases the page doesn't look
> > non-migrable so retrying more makes sense.
> > 
> > __offline_pages seems rather cluttered when it comes to the retry
> > logic. We have 5 retries at maximum and a timeout. We could argue
> > whether the timeout makes sense but failing just because of a race when
> > somebody isoltes a page from LRU or puts it on a pcp LRU lists is just
> > wrong. It only takes it to race with a process which unmaps some pages
> > and remove them from the LRU list and we can fail the whole offline
> > because of something that is a temporary condition and actually not
> > harmful for the offline. Please note that unmovable pages should be
> > already excluded during start_isolate_page_range.
> 
> Hmm, the has_unmovable_pages() check doesn't offer any strict guarantees due to
> races, per its comment. Also at the very quick glance, I see a check where it
> assumes that MIGRATE_MOVABLE pageblock will have no unmovable pages. There is no
> such guarantee even without races.

Yes, you are right that there are races possible but practically
speaking non-movable memblocks (in !MOVABLE_ZONE) would be very likely
to have reliably unmovable pages and so has_unmovable_pages would bail
out. And ZONE_MOVABLE memblocks with permanently pinned pages sound like
a bug to me.

> > Fix this by removing the max retry count and only rely on the timeout
> > resp. interruption by a signal from the userspace. Also retry rather
> > than fail when check_pages_isolated sees some !free pages because those
> > could be a result of the race as well.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Even within a movable node where has_unmovable_pages() is a non-issue, you could
> have pinned movable pages where the pinning is not temporary.

Who would pin those pages? Such a page would be unreclaimable as well
and thus a memory leak and I would argue it would be a bug.

> So after this
> patch, this will really keep retrying forever. I'm not saying it's wrong, just
> pointing it out, since the changelog seems to assume there would be only
> temporary failures possible and thus unbound retries are always correct.
> The obvious problem if we wanted to avoid this, is how to recognize
> non-temporary failures...

Yes, we should be able to distinguish the two and hopefully we can teach
the migration code to distinguish between EBUSY (likely permanent) and
EGAIN (temporal) failure. This sound like something we should aim for
longterm I guess. Anyway as I've said in other email. If somebody really
wants to have a guaratee of a bounded retry then it is trivial to set up
an alarm and send a signal itself to bail out.

Do you think that the changelog should be more clear about this?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
