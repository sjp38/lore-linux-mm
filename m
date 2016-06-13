Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 279C06B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 00:42:39 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id y82so54078811oig.3
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 21:42:39 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u84si8078368iod.54.2016.06.12.21.42.37
        for <linux-mm@kvack.org>;
        Sun, 12 Jun 2016 21:42:38 -0700 (PDT)
Date: Mon, 13 Jun 2016 13:42:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: add trace events for zs_compact
Message-ID: <20160613044237.GC23754@bbox>
References: <1465289804-4913-1-git-send-email-opensource.ganesh@gmail.com>
 <20160608001625.GB27258@bbox>
 <CADAEsF_wYQpMP_Hpr2LEnafxteV7aN1kCdAhLWhk13Ed1ueZ+A@mail.gmail.com>
 <20160608051352.GA28155@bbox>
 <CADAEsF_q0qzk2D_cKMCcvHxF7_eY1cQVKrBp0eM_v05jjOjSOA@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CADAEsF_q0qzk2D_cKMCcvHxF7_eY1cQVKrBp0eM_v05jjOjSOA@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, rostedt@goodmis.org, mingo@redhat.com

On Wed, Jun 08, 2016 at 02:39:19PM +0800, Ganesh Mahendran wrote:

<snip>

> zsmalloc is not only used by zram, but also zswap. Maybe
> others in the future.
> 
> I tried to use function_graph. It seems there are too much log
> printed:
> ------
> root@leo-test:/sys/kernel/debug/tracing# cat trace
> # tracer: function_graph
> #
> # CPU  DURATION                  FUNCTION CALLS
> # |     |   |                     |   |   |   |
>  2)               |  zs_compact [zsmalloc]() {
>  2)               |  /* zsmalloc_compact_start: pool zram0 */
>  2)   0.889 us    |    _raw_spin_lock();
>  2)   0.896 us    |    isolate_zspage [zsmalloc]();
>  2)   0.938 us    |    _raw_spin_lock();
>  2)   0.875 us    |    isolate_zspage [zsmalloc]();
>  2)   0.942 us    |    _raw_spin_lock();
>  2)   0.962 us    |    isolate_zspage [zsmalloc]();
> ...
>  2)   0.879 us    |      insert_zspage [zsmalloc]();
>  2)   4.520 us    |    }
>  2)   0.975 us    |    _raw_spin_lock();
>  2)   0.890 us    |    isolate_zspage [zsmalloc]();
>  2)   0.882 us    |    _raw_spin_lock();
>  2)   0.894 us    |    isolate_zspage [zsmalloc]();
>  2)               |  /* zsmalloc_compact_end: pool zram0: 0 pages
> compacted(total 0) */
>  2) # 1351.241 us |  }
> ------
> => 1351.241 us used
> 
> And it seems the overhead of function_graph is bigger than trace event.
> 
> bash-3682  [002] ....  1439.180646: zsmalloc_compact_start: pool zram0
> bash-3682  [002] ....  1439.180659: zsmalloc_compact_end: pool zram0:
> 0 pages compacted(total 0)
> => 13 us > 1351.241 us

You could use set_ftrace_filter to cut out.

To introduce new event trace to get a elasped time, it's pointless,
I think.

It should have more like pool name you mentioned.
Like saying other thread, It would be better to show
[pool name, compact size_class,
the number of object moved, the number of freed page], IMO.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
