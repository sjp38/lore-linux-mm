Message-ID: <394C1D13.F39ECFD8@norran.net>
Date: Sun, 18 Jun 2000 02:51:31 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: PATCH: Improvements in shrink_mmap and kswapd
References: <ytt3dmcyli7.fsf@serpe.mitica>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Comments below,


"Juan J. Quintela" wrote:
> 
> Hi
>         this patch makes kswapd use less resources.  It should solve
> the kswapd eats xx% of my CPU problems.  It appears that it improves
> IO a bit here.  Could people having problems with IO told me if this
> patch improves things, I am interested in knowing that it don't makes
> things worst never.  This patch is stable here.  I am finishing the
> deferred mmaped pages form file writing patch, that should solve
> several other problems.
> 
> Reports of success/failure are welcome.  Comments are also welcome.
> 
> Later, Juan.
> 

> +/**
> + * shrink_mmap - Tries to free memory
> + * @priority: how hard we will try to free pages (0 hardest)
> + * @gfp_mask: Restrictions to free pages
> + *
> + * This function walks the lru list searching for free pages. It
> + * returns 1 to indicate success and 0 in the opposite case. It gets a
> + * lock in the pagemap_lru_lock and the pagecache_lock.
>   */
> +/* nr_to_examinate counts the number of pages that we will read as
> + * maximum as each call.  This means that we don't loop.
> + */
> +/* nr_writes counts the number of writes that we have started to the
> + * moment. We limitate the number of writes in each round to
> + * max_page_launder. ToDo: Make that variable tunable through sysctl.
> + */
> +const int max_page_launder = 100;
> +
>  int shrink_mmap(int priority, int gfp_mask)
>  {
> -       int ret = 0, count, nr_dirty;
>         struct list_head * page_lru;
>         struct page * page = NULL;
> -
> -       count = nr_lru_pages / (priority + 1);
> -       nr_dirty = priority;
> +       int ret;
> +       int nr_to_examinate = nr_lru_pages;

Is this really enough?
  PG_AGE_MAX * nr_lru_pages / (priority + 1)
is required to ensure that all pages have been scanned at an age of 0.
But that is probably an overkill... there is a sum involved here...
  PG_AGE_START * ...
Could be nice to get rid of streaming pages before other attempts are
done.


> diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/vmscan.c working/mm/vmscan.c
> --- base/mm/vmscan.c    Sat Jun 17 23:51:24 2000
> +++ working/mm/vmscan.c Sun Jun 18 00:28:12 2000
>
> [removed stuff]
>
> @@ -427,6 +425,32 @@
>         return __ret;
>  }
> 
> +/**
> + * memory_pressure - Is the system under memory pressure
> + *
> + * Returns 1 if the system is low on memory in any of its zones,
> + * otherwise returns 0.
> + */
> +int memory_pressure(void)
> +{
> +       pg_data_t *pgdat = pgdat_list;
> +
> +       do {
> +               int i;
> +               for(i = 0; i < MAX_NR_ZONES; i++) {
> +                       zone_t *zone = pgdat->node_zones + i;
> +                       if (!zone->size || !zone->zone_wake_kswapd)
> +                               continue;
> +                       if (zone->free_pages < zone->pages_low)
> +                               return 1;
> +               }
> +               pgdat = pgdat->node_next;
> +
> +       } while (pgdat);
> +
> +       return 0;
> +}
> +

This function effectively ignore 'zone_wake_kswapd' since it should
always be set when free < low - if correct behaviour remove the test.

>         priority = 64;
>         do {
>                 while (shrink_mmap(priority, gfp_mask)) {
> -                       ret = 1;
>                         if (!--count)
>                                 goto done;
>                 }
>  
> +               if(!memory_pressure())
> +                       return 1;
>  

Needs lower than pages_low after shrink_mmap to pass this test and
enter swapping... might be correct behaviour!

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
