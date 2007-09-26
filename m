Subject: Re: [PATCH 09/12] mm: remove throttle_vm_writeback
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070405154440.0f42fa9f.akpm@linux-foundation.org>
References: <20070405174209.498059336@programming.kicks-ass.net>
	 <20070405174319.860268120@programming.kicks-ass.net>
	 <20070405154440.0f42fa9f.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 26 Sep 2007 22:42:30 +0200
Message-Id: <1190839350.18147.28.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-05 at 15:44 -0700, Andrew Morton wrote:
> On Thu, 05 Apr 2007 19:42:18 +0200
> root@programming.kicks-ass.net wrote:
> 
> > rely on accurate dirty page accounting to provide enough push back
> 
> I think we'd like to see a bit more justification than that, please.

it should read like this:

        for ( ; ; ) {
		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);

                /*
                 * Boost the allowable dirty threshold a bit for page
                 * allocators so they don't get DoS'ed by heavy writers
                 */
                dirty_thresh += dirty_thresh / 10;      /* wheeee... */

                if (global_page_state(NR_FILE_DIRTY) + 
		    global_page_state(NR_UNSTABLE_NFS) +
		    global_page_state(NR_WRITEBACK) <= dirty_thresh)
                        	break;

                congestion_wait(WRITE, HZ/10);
        }

[ note the extra NR_FILE_DIRTY ]

now, balance_dirty_pages() is there to ensure:

  nr_dirty + nr_unstable + nr_writeback < dirty_thresh      (1)

reclaim will (with the introduction of dirty page tracking) never
generate dirty pages, so the only disturbance of that equation is an
increase in nr_writeback.

[ pageout() sets wbc.for_reclaim=1, so NFS traffic will not generate
  unstable pages ]

So, what throttle_vm_writeout() does is limit the number of added
writeback pages to 10% of the total limit.

pageout() seems to avoid stuffing pages down a congested bdi 
(TODO: has details), along with the much smaller io-queues, the initial
purpose of this function - which was to avoid all memory getting stuck
in io-queues - seems to be handled.

Now the problems...

Trouble is that it currently does not take nr_dirty into account which
in the worst case limits it to 110% of the limit.

Also, I'm seeing (2.6.23-rc8-mm1) live-locks in throttle_vm_writeback()
where nr_dirty + nr_unstable > thresh - which according to (1) should
not happen, and will not change without explicit action.

Hmm maybe the 10% is < nr_cpus * ratelimit_pages.

2 cpus, mem=128M -> ratelimit_pages ~ 512
threshold ~ 1500

so indeed: 150 < 1024.

Still not conclusive but at least getting somewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
