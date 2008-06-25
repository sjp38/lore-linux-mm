Received: by an-out-0708.google.com with SMTP id d17so867721and.105
        for <linux-mm@kvack.org>; Tue, 24 Jun 2008 22:59:26 -0700 (PDT)
Message-ID: <28c262360806242259k3ac308c4n7cee29b72456e95b@mail.gmail.com>
Date: Wed, 25 Jun 2008 14:59:26 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [RFC][PATCH] prevent incorrect oom under split_lru
In-Reply-To: <20080624092824.4f0440ca@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080624171816.D835.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080624092824.4f0440ca@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, Takenori Nagano <t-nagano@ah.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 24, 2008 at 10:28 PM, Rik van Riel <riel@redhat.com> wrote:
> On Tue, 24 Jun 2008 17:31:54 +0900
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> if zone->recent_scanned parameter become inbalanceing anon and file,
>> OOM killer can happened although swappable page exist.
>>
>> So, if priority==0, We should try to reclaim all page for prevent OOM.
>
> You are absolutely right.  Good catch.

I have a concern about application latency.
If lru list have many pages, it take a very long time to scan pages.
More system have many ram, More many time to scan pages.

Of course I know this is trade-off between memory efficiency VS latency.
But In embedded, some application think latency is more important
thing than memory efficiency.
We need some mechanism to cut off scanning time.


I think Takenori Nagano's "memory reclaim more efficiently patch" is
proper to reduce application latency in this case If we modify some
code.

What do you think about it ?

>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> Acked-by: Rik van Riel <riel@redhat.com>
>
>> ---
>>  mm/vmscan.c |    6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> Index: b/mm/vmscan.c
>> ===================================================================
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1464,8 +1464,10 @@ static unsigned long shrink_zone(int pri
>>                        * kernel will slowly sift through each list.
>>                        */
>>                       scan = zone_page_state(zone, NR_LRU_BASE + l);
>> -                     scan >>= priority;
>> -                     scan = (scan * percent[file]) / 100;
>> +                     if (priority) {
>> +                             scan >>= priority;
>> +                             scan = (scan * percent[file]) / 100;
>> +                     }
>>                       zone->lru[l].nr_scan += scan + 1;
>>                       nr[l] = zone->lru[l].nr_scan;
>>                       if (nr[l] >= sc->swap_cluster_max)
>>
>
>
> --
> All rights reversed.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
