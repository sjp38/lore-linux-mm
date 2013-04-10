From: Wanpeng Li <liwanp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Date: Wed, 10 Apr 2013 16:46:06 +0800
Message-ID: <11288.8913638473$1365583589@news.gmane.org>
References: <1364548450-28254-3-git-send-email-glommer@parallels.com>
	<20130408084202.GA21654@lge.com> <51628412.6050803@parallels.com>
	<20130408090131.GB21654@lge.com> <51628877.5000701@parallels.com>
	<20130409005547.GC21654@lge.com> <20130409012931.GE17758@dastard>
	<20130409020505.GA4218@lge.com> <20130409123008.GM17758@dastard>
	<20130410025115.GA5872@lge.com>
Reply-To: Wanpeng Li <liwanp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130410025115.GA5872-Hm3cg6mZ9cc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: linux-mm.kvack.org

Hi Glauber,
On Wed, Apr 10, 2013 at 11:51:16AM +0900, Joonsoo Kim wrote:
>Hello, Dave.
>
>On Tue, Apr 09, 2013 at 10:30:08PM +1000, Dave Chinner wrote:
>> On Tue, Apr 09, 2013 at 11:05:05AM +0900, Joonsoo Kim wrote:
>> > On Tue, Apr 09, 2013 at 11:29:31AM +1000, Dave Chinner wrote:
>> > > On Tue, Apr 09, 2013 at 09:55:47AM +0900, Joonsoo Kim wrote:
>> > > > lowmemkiller makes spare memory via killing a task.
>> > > > 
>> > > > Below is code from lowmem_shrink() in lowmemorykiller.c
>> > > > 
>> > > >         for (i = 0; i < array_size; i++) {
>> > > >                 if (other_free < lowmem_minfree[i] &&
>> > > >                     other_file < lowmem_minfree[i]) {
>> > > >                         min_score_adj = lowmem_adj[i];
>> > > >                         break;
>> > > >                 }   
>> > > >         } 
>> > > 
>> > > I don't think you understand what the current lowmemkiller shrinker
>> > > hackery actually does.
>> > > 
>> > >         rem = global_page_state(NR_ACTIVE_ANON) +
>> > >                 global_page_state(NR_ACTIVE_FILE) +
>> > >                 global_page_state(NR_INACTIVE_ANON) +
>> > >                 global_page_state(NR_INACTIVE_FILE);
>> > >         if (sc->nr_to_scan <= 0 || min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
>> > >                 lowmem_print(5, "lowmem_shrink %lu, %x, return %d\n",
>> > >                              sc->nr_to_scan, sc->gfp_mask, rem);
>> > >                 return rem;
>> > >         }
>> > > 
>> > > So, when nr_to_scan == 0 (i.e. the count phase), the shrinker is
>> > > going to return a count of active/inactive pages in the cache. That
>> > > is almost always going to be non-zero, and almost always be > 1000
>> > > because of the minimum working set needed to run the system.
>> > > Even after applying the seek count adjustment, total_scan is almost
>> > > always going to be larger than the shrinker default batch size of
>> > > 128, and that means this shrinker will almost always run at least
>> > > once per shrink_slab() call.
>> > 
>> > I don't think so.
>> > Yes, lowmem_shrink() return number of (in)active lru pages
>> > when nr_to_scan is 0. And in shrink_slab(), we divide it by lru_pages.
>> > lru_pages can vary where shrink_slab() is called, anyway, perhaps this
>> > logic makes total_scan below 128.
>> 
>> "perhaps"
>> 
>> 
>> There is no "perhaps" here - there is *zero* guarantee of the
>> behaviour you are claiming the lowmem killer shrinker is dependent
>> on with the existing shrinker infrastructure. So, lets say we have:
>> 
>> 	nr_pages_scanned = 1000
>> 	lru_pages = 100,000
>> 
>> Your shrinker is going to return 100,000 when nr_to_scan = 0. So,
>> we have:
>> 
>> 	batch_size = SHRINK_BATCH = 128
>> 	max_pass= 100,000
>> 
>> 	total_scan = shrinker->nr_in_batch = 0
>> 	delta = 4 * 1000 / 32 = 128
>> 	delta = 128 * 100,000 = 12,800,000
>> 	delta = 12,800,000 / 100,001 = 127
>> 	total_scan += delta = 127
>> 
>> Assuming the LRU pages count does not change(*), nr_pages_scanned is
>> irrelevant and delta always comes in 1 count below the batch size,
>> and the shrinker is not called. The remainder is then:
>> 
>> 	shrinker->nr_in_batch += total_scan = 127
>> 
>> (*) the lru page count will change, because reclaim and shrinkers
>> run concurrently, and so we can't even make a simple contrived case
>> where delta is consistently < batch_size here.
>> 
>> Anyway, the next time the shrinker is entered, we start with:
>> 
>> 	total_scan = shrinker->nr_in_batch = 127
>> 	.....
>> 	total_scan += delta = 254
>> 
>> 	<shrink once, total scan -= batch_size = 126>
>> 
>> 	shrinker->nr_in_batch += total_scan = 126
>> 
>> And so on for all the subsequent shrink_slab calls....
>> 
>> IOWs, this algorithm effectively causes the shrinker to be called
>> 127 times out of 128 in this arbitrary scenario. It does not behave
>> as you are assuming it to, and as such any code based on those
>> assumptions is broken....
>
>Thanks for good example. I got your point :)
>But, my concern is not solved entirely, because this is not problem
>just for lowmem killer and I can think counter example. And other drivers
>can be suffered from this change.
>
>I look at the code for "huge_zero_page_shrinker".
>They return HPAGE_PMD_NR if there is shrikerable object.
>
>I try to borrow your example for this case.
>
> 	nr_pages_scanned = 1,000
> 	lru_pages = 100,000
> 	batch_size = SHRINK_BATCH = 128
> 	max_pass= 512 (HPAGE_PMD_NR)
>
> 	total_scan = shrinker->nr_in_batch = 0
> 	delta = 4 * 1,000 / 2 = 2,000
> 	delta = 2,000 * 512 = 1,024,000
> 	delta = 1,024,000 / 100,001 = 10
> 	total_scan += delta = 10
>
>As you can see, before this patch, do_shrinker_shrink() for
>"huge_zero_page_shrinker" is not called until we call shrink_slab() more
>than 13 times. *Frequency* we call do_shrinker_shrink() actually is
>largely different with before. With this patch, we actually call
>do_shrinker_shrink() for "huge_zero_page_shrinker" 12 times more
>than before. Can we be convinced that there will be no problem?
>
>This is why I worry about this change.
>Am I worried too much? :)
>
>I show another scenario what I am thinking for lowmem killer.
>
>In reality, 'nr_pages_scanned' reflect sc->priority.
>You can see it get_scan_count() in vmscan.c
>
>	size = get_lru_size(lruvec, lru);
>	scan = size >> sc->priority;
>
>So, I try to re-construct your example with above assumption.
>
>If sc->priority is DEF_PRIORITY (12)
>
> 	nr_pages_scanned = 25 (100,000 / 4,096)
> 	lru_pages = 100,000
> 	batch_size = SHRINK_BATCH = 128
> 	max_pass= 100,000
>
> 	total_scan = shrinker->nr_in_batch = 0
> 	delta = 4 * 25 / 32 = 3
> 	delta = 3 * 100,000 = 300,000
> 	delta = 300,000 / 100,001 = 3
> 	total_scan += delta = 3
>
>So, do_shrinker_shrink() is not called for lowmem killer until
>we call shrink_slab() more than 40 times if sc->priority is DEF_PRIORITY.
>So, AICT, if we don't have trouble too much in reclaiming memory, it will not
>triggered frequently.
>

As the example from Joonsoo, before the patch, if scan priority is low, 
slab cache won't be shrinked, however, after the patch, slab cache is 
shrinked more aggressive. Furthmore, these slab cache pages maybe more 
seek expensive than lru pages.

Regards,
Wanpeng Li 

>I like this patchset, and I think shrink_slab interface should be
>re-worked. What I want to say is just that this patch is not trivial
>change and should notify user to test it.
>I want to say again, I don't want to become a stopper for this patchset :)
>
>Please let me know what I am missing.
>
>Thanks.
>
>> Cheers,
>> 
>> Dave.
>> -- 
>> Dave Chinner
>> david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
