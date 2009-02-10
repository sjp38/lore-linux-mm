Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3A3E96B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 05:47:27 -0500 (EST)
Received: by yw-out-1718.google.com with SMTP id 9so520099ywk.26
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 02:47:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090209222416.GA9758@cmpxchg.org>
References: <20090209222416.GA9758@cmpxchg.org>
Date: Tue, 10 Feb 2009 19:47:26 +0900
Message-ID: <28c262360902100247x1d537dc2kfef3c4c0f769a259@mail.gmail.com>
Subject: Re: [RFC] vmscan: initialize sc->nr_reclaimed in do_try_to_free_pages()
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, William Lee Irwin III <wli@movementarian.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 7:24 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Commit a79311c14eae4bb946a97af25f3e1b17d625985d "vmscan: bail out of
> direct reclaim after swap_cluster_max pages" moved the nr_reclaimed
> counter into the scan control to accumulate the number of all
> reclaimed pages in one direct reclaim invocation.
>
> The commit missed to actually adjust do_try_to_free_pages() which now
> does not initialize sc.nr_reclaimed and makes shrink_zone() make
> assumptions on whether to bail out of the reclaim cycle based on an
> uninitialized value.
>
> Fix it up by initializing the counter to zero before entering the
> priority loop.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c |    1 +
>  1 file changed, 1 insertion(+)
>
> The comment of the .nr_reclaimed field says it accumulates the reclaim
> counter over ONE shrink_zones() call.  This means, we should break out
> if ONE shrink_zones() call alone does more than swap_cluster_max.
>
> OTOH, the patch title suggests that we break out if ALL shrink_zones()
> calls in the priority loop have reclaimed that much.  I.e.
> accumulating the reclaimed number over the prio loop, not just over
> one zones iteration.
>
> From the patch description I couldn't really make sure what the
> intended behaviour was.
>
> So, should the sc.nr_reclaimed be reset before the prio loop or in
> each iteration of the prio loop?
>
> Either this patch is wrong or the comment above .nr_reclaimed is.
>
> And why didn't this have any observable effects?  Do I miss something

Nice catch!!
I think that's because situation Rik said is unusual.

> really obvious here?


> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1618,6 +1618,7 @@ static unsigned long do_try_to_free_page
>                }
>        }
>
> +       sc->nr_reclaimed = 0;
>        for (priority = DEF_PRIORITY; priority >= 0; priority--) {
>                sc->nr_scanned = 0;
>                if (!priority)
>
> --

I have a one comment.

If you directly initialize nr_reclaimed in do_try_to_free_pages function,
it might be a side effect.
Because old functions use scan_control declaration and initialization
method for initializing scan_control before calling
do_try_to_free_pages.

In future, If some function call do_try_to_free_pages after
scan_control declaration and initialization of nr_reclaimed, your
patch implementation reset nr_reclaimed to zero forcely, again.

but I think it is unlikely that it initializes nr_reclaimed with not zero. :(

But, like old functions, way to declaration and initialization is good
for readability and portability, I think.

Make sure below code is mangled and word-wrapped.
It just is example.

---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9a27c44..18406ee 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1699,6 +1699,7 @@ unsigned long try_to_free_pages(struct zonelist
*zonelist, int order,
                .order = order,
                .mem_cgroup = NULL,
                .isolate_pages = isolate_pages_global,
+               .nr_reclaimed = 0,
        };

        return do_try_to_free_pages(zonelist, &sc);
@@ -1719,6 +1720,7 @@ unsigned long
try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
                .order = 0,
                .mem_cgroup = mem_cont,
                .isolate_pages = mem_cgroup_isolate_pages,
+               .nr_reclaimed = 0;
        };
        struct zonelist *zonelist;



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
