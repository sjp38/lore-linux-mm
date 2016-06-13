Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 05AF16B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 03:49:39 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id na2so46961367lbb.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 00:49:38 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id wp4si28513095wjb.173.2016.06.13.00.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 00:49:37 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id r5so12664163wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 00:49:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160613051214.GA491@swordfish>
References: <1465289804-4913-1-git-send-email-opensource.ganesh@gmail.com>
 <20160608001625.GB27258@bbox> <CADAEsF_wYQpMP_Hpr2LEnafxteV7aN1kCdAhLWhk13Ed1ueZ+A@mail.gmail.com>
 <20160608051352.GA28155@bbox> <CADAEsF_q0qzk2D_cKMCcvHxF7_eY1cQVKrBp0eM_v05jjOjSOA@mail.gmail.com>
 <20160613044237.GC23754@bbox> <20160613051214.GA491@swordfish>
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Date: Mon, 13 Jun 2016 15:49:36 +0800
Message-ID: <CADAEsF8icKGBcCV83BxSc2-pmK46rsZc1wgB8=Y=3m5CnN6K3A@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: add trace events for zs_compact
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, rostedt@goodmis.org, mingo@redhat.com

2016-06-13 13:12 GMT+08:00 Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com>:
> Hello,
>
> On (06/13/16 13:42), Minchan Kim wrote:
> [..]
>> > compacted(total 0) */
>> >  2) # 1351.241 us |  }
>> > ------
>> > => 1351.241 us used
>> >
>> > And it seems the overhead of function_graph is bigger than trace event.
>> >
>> > bash-3682  [002] ....  1439.180646: zsmalloc_compact_start: pool zram0
>> > bash-3682  [002] ....  1439.180659: zsmalloc_compact_end: pool zram0:
>> > 0 pages compacted(total 0)
>> > => 13 us > 1351.241 us
>>
>> You could use set_ftrace_filter to cut out.
>>
>> To introduce new event trace to get a elasped time, it's pointless,
>> I think.
>>
>> It should have more like pool name you mentioned.
>> Like saying other thread, It would be better to show
>> [pool name, compact size_class,
>> the number of object moved, the number of freed page], IMO.
>
> just my 5 cents:
>
> some parts (of the info above) are already available: zram<ID> maps to
> pool<ID> name, which maps to a sysfs file name, that can contain the rest.
> I'm just trying to understand what kind of optimizations we are talking
> about here and how would timings help... compaction can spin on class
> lock, for example, if the device in question is busy, etc. etc. on the
> other hand we have a per-class info in zsmalloc pool stats output, so
> why not extend it instead of introducing a new debugging interface?

I've considered adding new interface in /sys/../zsmalloc/ or uasing
trace_mm_shrink_slab_[start/end] to get such information.
But none of them can cover all the cases:
1) distinguish which zs pool is compacted.
2) freed pages of zs_compact(), total freed pages of zs_compact()
3) realtime log printed

Actually, the trace event added in zs_compact not only just for
debugging/optimization inside zsmalloc, but also for system level.
We can do some analysis by combining data from zs_compac(), system
information(like free mem, swap info, LMK, etc)

Thanks.

>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
