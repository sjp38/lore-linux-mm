Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A95466B02D7
	for <linux-mm@kvack.org>; Fri,  3 May 2013 10:07:28 -0400 (EDT)
Message-ID: <5183C49D.1010000@bitsync.net>
Date: Fri, 03 May 2013 16:07:25 +0200
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: lru milestones, timestamps and ages
References: <20130430110214.22179.26139.stgit@zurg>
In-Reply-To: <20130430110214.22179.26139.stgit@zurg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org

On 30.04.2013 13:02, Konstantin Khlebnikov wrote:
> This patch adds engine for estimating rotation time for pages in lru lists.
>
> This adds bunch of 'milestones' into each struct lruvec and inserts them into
> lru lists periodically. Milestone flows in lru together with pages and brings
> timestamp to the end of lru. Because milestones are embedded into lruvec they
> can be easily distinguished from pages by comparing pointers.
> Only few functions should care about that.
>
> This machinery provides discrete-time estimation for age of pages from the end
> of each lru and average age of each kind of evictable lrus in each zone.

Great stuff!

Believe it or not, I had an idea of writing something similar to this, 
but of course having an idea and actually implementing it are two very 
different things. Thank you for your work!

I will use this to prove (or not) that file pages in the normal zone on 
a 4GB RAM machine are reused waaaay too soon. Actually, I already have 
the patch applied and running on the desktop, but it should be much more 
useful on server workloads. Desktops have erratic load and can go for a 
long time with very little I/O activity. But, here are the current 
numbers anyway:

Node 0, zone    DMA32
   pages free     5371
     nr_inactive_anon 4257
     nr_active_anon 139719
     nr_inactive_file 617537
     nr_active_file 51671
   inactive_ratio:    5
   avg_age_inactive_anon: 2514752
   avg_age_active_anon:   2514752
   avg_age_inactive_file: 876416
   avg_age_active_file:   2514752
Node 0, zone   Normal
   pages free     424
     nr_inactive_anon 253
     nr_active_anon 54480
     nr_inactive_file 63274
     nr_active_file 44116
   inactive_ratio:    1
   avg_age_inactive_anon: 2531712
   avg_age_active_anon:   2531712
   avg_age_inactive_file: 901120
   avg_age_active_file:   2531712

> In our kernel we use similar engine as source of statistics for scheduler in
> memory reclaimer. This is O(1) scheduler which shifts vmscan priorities for lru
> vectors depending on their sizes, limits and ages. It tries to balance memory
> pressure among containers. I'll try to rework it for the mainline kernel soon.
>
> Seems like these ages also can be used for optimal memory pressure distribution
> between file and anon pages, and probably for balancing pressure among zones.

This all sounds very promising. Especially because I currently observe 
quite some imbalance among zones.

Regards,
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
