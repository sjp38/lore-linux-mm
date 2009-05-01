Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4E86B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 19:28:44 -0400 (EDT)
Date: Fri, 1 May 2009 16:25:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v3)
Message-Id: <20090501162506.f9243dca.akpm@linux-foundation.org>
In-Reply-To: <49FB8031.8000602@redhat.com>
References: <20090428044426.GA5035@eskimo.com>
	<20090428192907.556f3a34@bree.surriel.com>
	<1240987349.4512.18.camel@laptop>
	<20090429114708.66114c03@cuia.bos.redhat.com>
	<2f11576a0904290907g48e94e74ye97aae593f6ac519@mail.gmail.com>
	<20090429131436.640f09ab@cuia.bos.redhat.com>
	<20090501153255.0f412420.akpm@linux-foundation.org>
	<49FB8031.8000602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, peterz@infradead.org, elladan@eskimo.com, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 01 May 2009 19:05:21 -0400
Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> > On Wed, 29 Apr 2009 13:14:36 -0400
> > Rik van Riel <riel@redhat.com> wrote:
> > 
> >> When the file LRU lists are dominated by streaming IO pages,
> >> evict those pages first, before considering evicting other
> >> pages.
> >>
> >> This should be safe from deadlocks or performance problems
> >> because only three things can happen to an inactive file page:
> >> 1) referenced twice and promoted to the active list
> >> 2) evicted by the pageout code
> >> 3) under IO, after which it will get evicted or promoted
> >>
> >> The pages freed in this way can either be reused for streaming
> >> IO, or allocated for something else. If the pages are used for
> >> streaming IO, this pageout pattern continues. Otherwise, we will
> >> fall back to the normal pageout pattern.
> >>
> >> ..
> >>
> >> +int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
> >> +{
> >> +	unsigned long active;
> >> +	unsigned long inactive;
> >> +
> >> +	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
> >> +	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
> >> +
> >> +	return (active > inactive);
> >> +}
> > 
> > This function could trivially be made significantly more efficient by
> > changing it to do a single pass over all the zones of all the nodes,
> > rather than two passes.
> 
> How would I do that in a clean way?

copy-n-paste :(

static unsigned long foo(struct mem_cgroup *mem,
			enum lru_list idx1, enum lru_list idx2)
{
	int nid, zid;
	struct mem_cgroup_per_zone *mz;
	u64 total = 0;

	for_each_online_node(nid)
		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
			mz = mem_cgroup_zoneinfo(mem, nid, zid);
			total += MEM_CGROUP_ZSTAT(mz, idx1);
			total += MEM_CGROUP_ZSTAT(mz, idx3);
		}
	return total;
}

dunno if that's justifiable.

> The function mem_cgroup_inactive_anon_is_low and
> the global versions all do the same.  It would be
> nice to make all four of them go fast :)
> 
> If there is no standardized infrastructure for
> getting multiple statistics yet, I can probably
> whip something up.

It depends how often it would be called for, I guess.

One approach would be pass in a variable-length array of `enum
lru_list's, get returned a same-lengthed array of totals.

Or perhaps all we need to return is the sum of those totals.

I'd let the memcg guys worry about this if I were you ;)

> Optimizing them might make sense if it turns out to
> use a significant amount of CPU.

Yeah.  By then it's often too late though.  The sort of people for whom
(num_online_nodes*MAX_NR_ZONES) is nuttily large tend not to run
kernel.org kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
