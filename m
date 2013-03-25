Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 2D1846B0074
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 05:13:48 -0400 (EDT)
Received: by mail-ea0-f173.google.com with SMTP id h14so2175433eak.18
        for <linux-mm@kvack.org>; Mon, 25 Mar 2013 02:13:46 -0700 (PDT)
Message-ID: <51501545.50908@suse.cz>
Date: Mon, 25 Mar 2013 10:13:41 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd reclaims
 at each priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-2-git-send-email-mgorman@suse.de> <20130325090758.GO2154@dhcp22.suse.cz>
In-Reply-To: <20130325090758.GO2154@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On 03/25/2013 10:07 AM, Michal Hocko wrote:
> On Sun 17-03-13 13:04:07, Mel Gorman wrote:
>> The number of pages kswapd can reclaim is bound by the number of pages it
>> scans which is related to the size of the zone and the scanning priority. In
>> many cases the priority remains low because it's reset every SWAP_CLUSTER_MAX
>> reclaimed pages but in the event kswapd scans a large number of pages it
>> cannot reclaim, it will raise the priority and potentially discard a large
>> percentage of the zone as sc->nr_to_reclaim is ULONG_MAX. The user-visible
>> effect is a reclaim "spike" where a large percentage of memory is suddenly
>> freed. It would be bad enough if this was just unused memory but because
>> of how anon/file pages are balanced it is possible that applications get
>> pushed to swap unnecessarily.
>>
>> This patch limits the number of pages kswapd will reclaim to the high
>> watermark. Reclaim will will overshoot due to it not being a hard limit as
>> shrink_lruvec() will ignore the sc.nr_to_reclaim at DEF_PRIORITY but it
>> prevents kswapd reclaiming the world at higher priorities. The number of
>> pages it reclaims is not adjusted for high-order allocations as kswapd will
>> reclaim excessively if it is to balance zones for high-order allocations.
>>
>> Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> It seems I forgot to add
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks, now I applied all ten.

BTW I very pray this will fix also the issue I have when I run ltp tests
(highly I/O intensive, esp. `growfiles') in a VM while playing a movie
on the host resulting in a stuttered playback ;).

-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
