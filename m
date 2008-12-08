Received: by rv-out-0708.google.com with SMTP id f25so1120897rvb.26
        for <linux-mm@kvack.org>; Mon, 08 Dec 2008 09:48:40 -0800 (PST)
Message-ID: <2f11576a0812080948k135e15c5h2bc727355235f94@mail.gmail.com>
Date: Tue, 9 Dec 2008 02:48:40 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
In-Reply-To: <20081208220016.53FB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081129195357.813D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081208205842.53F8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081208220016.53FB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> example,
>
>  Called zone_watermark_ok(zone, 2, pages_min, 0, 0);
>  pages_min  = 64
>  free pages = 80
>
> case A.
>
>     order    nr_pages
>   --------------------
>      2         5
>      1        10
>      0        30
>
>        -> zone_watermark_ok() return 1
>
> case B.
>
>     order    nr_pages
>   --------------------
>      3        10
>      2         0
>      1         0
>      0         0
>
>        -> zone_watermark_ok() return 0

Doh!
this example is obiously buggy.

I guess Mr. KOSAKI is very silly or Idiot.
I recommend to he get feathery blanket and good sleeping, instead
black black coffee ;-)


...but below mesurement result still true.

> This patch change zone_watermark_ok() logic to prefer large contenious block.
>
>
> Result:
>
>  test machine:
>    CPU: ia64 x 8
>    MEM: 8GB
>
>  benchmark:
>    $ tbench 8  (three times mesurement)
>
>    tbench works between about 600sec.
>    alloc_pages() and zone_watermark_ok() are called about 15,000,000 times.
>
>
>              2.6.28-rc6                        this patch
>
>       throughput    max-latency       throughput       max-latency
>        ---------------------------------------------------------
>        1480.92         20.896          1,490.27        19.606
>        1483.94         19.202          1,482.86        21.082
>        1478.93         22.215          1,490.57        23.493
>
> avg     1,481.26        20.771          1,487.90        21.394
> std         2.06         1.233              3.56         1.602
> min     1,478.93        19.202          1,477.86        19.606
> max     1,483.94        22.215          1,490.57        23.493
>
>
> throughput improve about 5MB/sec. it over measurement wobbly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
