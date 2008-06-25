Received: by an-out-0708.google.com with SMTP id d17so902722and.105
        for <linux-mm@kvack.org>; Wed, 25 Jun 2008 06:05:40 -0700 (PDT)
Message-ID: <28c262360806250605le31ba48ma8bb16f996783142@mail.gmail.com>
Date: Wed, 25 Jun 2008 22:05:40 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [RFC][PATCH] prevent incorrect oom under split_lru
In-Reply-To: <1214395885.15232.17.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080624092824.4f0440ca@bree.surriel.com>
	 <28c262360806242259k3ac308c4n7cee29b72456e95b@mail.gmail.com>
	 <20080625150141.D845.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <28c262360806242356n3f7e02abwfee1f6acf0fd2c61@mail.gmail.com>
	 <1214395885.15232.17.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, Takenori Nagano <t-nagano@ah.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 25, 2008 at 9:11 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Wed, 2008-06-25 at 15:56 +0900, MinChan Kim wrote:
>> On Wed, Jun 25, 2008 at 3:08 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Hi Kim-san,
>> >
>> >> >> So, if priority==0, We should try to reclaim all page for prevent OOM.
>> >> >
>> >> > You are absolutely right.  Good catch.
>> >>
>> >> I have a concern about application latency.
>> >> If lru list have many pages, it take a very long time to scan pages.
>> >> More system have many ram, More many time to scan pages.
>> >
>> > No problem.
>> >
>> > priority==0 indicate emergency.
>> > it doesn't happend on typical workload.
>> >
>>
>> I see :)
>>
>> But if such emergency happen in embedded system, application can't be
>> executed for some time.
>> I am not sure how long time it take.
>> But In some application, schedule period is very important than memory
>> reclaim latency.
>>
>> Now, In your patch, when such emergency happen, it continue to reclaim
>> page until it will scan entire page of lru list.
>> It
>
> IMHO embedded real-time apps shoud mlockall() and not do anything that
> can result in memory allocations in their fast (deterministic) paths.
Hi peter,

I agree with you.  but if application's virtual address space is big,
we have a hard problem with mlockall since memory pressure might be a
big.
Of course, It will be a RT application design problem.

> The much more important case is desktop usage - that is where we run non
> real-time code, but do expect 'low' latency due to user-interaction.
>
> >From hitting swap on my 512M laptop (rather frequent occurance) I know
> we can do better here,..
>

Absolutely. It is another example. So, I suggest following patch.
It's based on idea of Takenori Nagano's memory reclaim more efficiently.

I expect It will reduce application latency and will not have a regression.
How about you ?

Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9a5e423..07477cc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1460,9 +1460,12 @@ static unsigned long shrink_zone(int priority,
struct zone *zone,
                         * kernel will slowly sift through each list.
                         */
                        scan = zone_page_state(zone, NR_LRU_BASE + l);
-                       scan >>= priority;
-                       scan = (scan * percent[file]) / 100;
+                       if (priority) {
+                               scan >>= priority;
+                               scan = (scan * percent[file])/10;
+                       }
                        zone->lru[l].nr_scan += scan + 1;
+
                        nr[l] = zone->lru[l].nr_scan;
                        if (nr[l] >= sc->swap_cluster_max)
                                zone->lru[l].nr_scan = 0;
@@ -1489,6 +1492,9 @@ static unsigned long shrink_zone(int priority,
struct zone *zone,

                                nr_reclaimed += shrink_list(l, nr_to_scan,
                                                        zone, sc, priority);
+                               if (priority == 0 && !current_is_kswapd() &&
+                                       nr_reclaimed >= sc->swap_cluster_max)
+                                       break;
                        }
                }
        }
-- 
1.5.4.3




-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
