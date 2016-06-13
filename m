Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B04216B0253
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 01:13:59 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 132so53469747lfz.3
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 22:13:59 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id gs6si28013952wjc.83.2016.06.12.22.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Jun 2016 22:13:58 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id v199so61508992wmv.0
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 22:13:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160613044237.GC23754@bbox>
References: <1465289804-4913-1-git-send-email-opensource.ganesh@gmail.com>
 <20160608001625.GB27258@bbox> <CADAEsF_wYQpMP_Hpr2LEnafxteV7aN1kCdAhLWhk13Ed1ueZ+A@mail.gmail.com>
 <20160608051352.GA28155@bbox> <CADAEsF_q0qzk2D_cKMCcvHxF7_eY1cQVKrBp0eM_v05jjOjSOA@mail.gmail.com>
 <20160613044237.GC23754@bbox>
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Date: Mon, 13 Jun 2016 13:13:57 +0800
Message-ID: <CADAEsF9dLbuKmsTtonjNMtVpPzE_ZFOHurRxjfLmDX4AUHTCOw@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: add trace events for zs_compact
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, rostedt@goodmis.org, mingo@redhat.com

2016-06-13 12:42 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> On Wed, Jun 08, 2016 at 02:39:19PM +0800, Ganesh Mahendran wrote:
>
> <snip>
>
>> zsmalloc is not only used by zram, but also zswap. Maybe
>> others in the future.
>>
>> I tried to use function_graph. It seems there are too much log
>> printed:
>> ------
>> root@leo-test:/sys/kernel/debug/tracing# cat trace
>> # tracer: function_graph
>> #
>> # CPU  DURATION                  FUNCTION CALLS
>> # |     |   |                     |   |   |   |
>>  2)               |  zs_compact [zsmalloc]() {
>>  2)               |  /* zsmalloc_compact_start: pool zram0 */
>>  2)   0.889 us    |    _raw_spin_lock();
>>  2)   0.896 us    |    isolate_zspage [zsmalloc]();
>>  2)   0.938 us    |    _raw_spin_lock();
>>  2)   0.875 us    |    isolate_zspage [zsmalloc]();
>>  2)   0.942 us    |    _raw_spin_lock();
>>  2)   0.962 us    |    isolate_zspage [zsmalloc]();
>> ...
>>  2)   0.879 us    |      insert_zspage [zsmalloc]();
>>  2)   4.520 us    |    }
>>  2)   0.975 us    |    _raw_spin_lock();
>>  2)   0.890 us    |    isolate_zspage [zsmalloc]();
>>  2)   0.882 us    |    _raw_spin_lock();
>>  2)   0.894 us    |    isolate_zspage [zsmalloc]();
>>  2)               |  /* zsmalloc_compact_end: pool zram0: 0 pages
>> compacted(total 0) */
>>  2) # 1351.241 us |  }
>> ------
>> => 1351.241 us used
>>
>> And it seems the overhead of function_graph is bigger than trace event.
>>
>> bash-3682  [002] ....  1439.180646: zsmalloc_compact_start: pool zram0
>> bash-3682  [002] ....  1439.180659: zsmalloc_compact_end: pool zram0:
>> 0 pages compacted(total 0)
>> => 13 us > 1351.241 us
>
> You could use  to cut out.
>
> To introduce new event trace to get a elasped time, it's pointless,
> I think.

Agree.

>
> It should have more like pool name you mentioned.
> Like saying other thread, It would be better to show
> [pool name, compact size_class,
> the number of object moved, the number of freed page], IMO.

Thanks for you suggestion!
I would be useful to see compact details for each class.
I will send another patch to do this.

Thanks.

>
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
