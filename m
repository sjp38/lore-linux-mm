Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 735506B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 15:42:56 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id z20so275207yhz.40
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 12:42:56 -0800 (PST)
Received: from mail-pb0-x231.google.com (mail-pb0-x231.google.com [2607:f8b0:400e:c01::231])
        by mx.google.com with ESMTPS id r46si2234515yhm.197.2014.01.14.12.42.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 12:42:55 -0800 (PST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so134725pbb.36
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 12:42:54 -0800 (PST)
Date: Tue, 14 Jan 2014 12:42:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
In-Reply-To: <20140114142610.GF32227@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1401141201120.3762@eggly.anvils>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils> <alpine.LSU.2.11.1401131751080.2229@eggly.anvils> <20140114132727.GB32227@dhcp22.suse.cz> <20140114142610.GF32227@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Jan 2014, Michal Hocko wrote:
> On Tue 14-01-14 14:27:27, Michal Hocko wrote:
> > On Mon 13-01-14 17:52:30, Hugh Dickins wrote:
> > > On one home machine I can easily reproduce (by rmdir of memcgdir during
> > > reclaim) multiple processes stuck looping forever in mem_cgroup_iter():
> > > __mem_cgroup_iter_next() keeps selecting the memcg being destroyed, fails
> > > to tryget it, returns NULL to mem_cgroup_iter(), which goes around again.
> > 
> > So you had a single memcg (without any children) and a limit-reclaim
> > on it when you removed it, right?
> 
> Hmm, thinking about this once more how can this happen? There must be a
> task to trigger the limit reclaim so the cgroup cannot go away (or is
> this somehow related to kmem accounting?). Only if the taks was migrated
> after the reclaim was initiated but before we started iterating?

Yes, I believe that's how it comes about (but no kmem accounting:
it's configured in but I'm not setting limits).

The "cg" script I run for testing appended below.  Normally I just run
it as "cg 2" to set up two memcgs, then my dual-tmpfs-kbuild script runs
one kbuild on tmpfs in cg 1, and another kbuild on ext4 on loop on tmpfs
in cg 2, mainly to test swapping.  But for this bug I run it as "cg m",
to repeatedly create new memcg, move running tasks from old to new, and
remove old.

Sometimes I'm doing swapoff and swapon in the background too, but
that's not needed to see this bug.  And although we're accustomed to
move_charge_at_immigrate being a beast, for this bug it's much quicker
to have that turned off.

(Until a couple of months ago, I was working in /cg/1 and /cg/2; but
have now pushed down a level to /cg/cg/1 and /cg/cg/2 after realizing
that working at the root would miss some important issues - in particular
the mem_cgroup_reparent_charges wrong-usage hang; but in fact I have
*never* caught that here, just know that it still exists from some
Google watchdog dumps, but we've still not identified the cause -
seen even without MEMCG_SWAP and with Hannes's extra reparent_charges.)

> 
> I am confused now and have to rush shortly so I will think about it
> tomorrow some more.

Thanks, yes, I knew it's one you'd want to think about first: no rush.

> 
> > This is nasty because __mem_cgroup_iter_next will try to skip it but
> > there is nothing else so it returns NULL. We update iter->generation++
> > but that doesn't help us as prev = NULL as this is the first iteration
> > so
> > 		if (prev && reclaim->generation != iter->generation)
> > 
> > break out will not help us.
> 
> > You patch will surely help I am just not sure it is the right thing to
> > do. Let me think about this.
> 
> The patch is actually not correct after all. You are returning root
> memcg without taking a reference. So there is a risk that memcg will
> disappear. Although, it is true that the race with removal is not that
> probable because mem_cgroup_css_offline (resp. css_free) will see some
> pages on LRUs and they will reclaim as well.
> 
> Ouch. And thinking about this shows that out_css_put is broken as well
> for subtree walks (those that do not start at root_mem_cgroup level). We
> need something like the the snippet bellow.

It's the out_css_put precedent that I was following in not incrementing
for the root.  I think that's been discussed in the past, and rightly or
wrongly we've concluded that the caller of mem_cgroup_iter() always has
some hold on the root, which makes it safe to skip get/put on it here.
No doubt one of those many short cuts to avoid memcg overhead when
there's no memcg other than the root_mem_cgroup.

I've not given enough thought to whether that is still a good assumption.
The try_charge route does a css_tryget, and that will be the hold on the
root in the reclaim case, won't it?  And its css_tryget succeeding does
not guarantee that a css_tryget a moment later will also succeed, which
is what happens in this bug.

But I have not attempted to audit other uses of mem_cgroup_iter() and
for_each_mem_cgroup_tree().  I've not hit any problems from them, but
may not have exercised those paths at all.  And the question of
whether there's a good hold on the root is a separate issue, really.

Hugh

> I really hate this code, especially when I tried to de-obfuscate it and
> that introduced other subtle issues.
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1f9d14e2f8de..f75277b0bf82 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1080,7 +1080,7 @@ skip_node:
>  	if (next_css) {
>  		struct mem_cgroup *mem = mem_cgroup_from_css(next_css);
>  
> -		if (css_tryget(&mem->css))
> +		if (mem == root_mem_cgroup || css_tryget(&mem->css))
>  			return mem;
>  		else {
>  			prev_css = next_css;
> @@ -1219,7 +1219,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  out_unlock:
>  	rcu_read_unlock();
>  out_css_put:
> -	if (prev && prev != root)
> +	if (prev && prev != root_mem_cgroup)
>  		css_put(&prev->css);
>  
>  	return memcg;
> 
> > Anyway very well spotted!
> > 
> > > It's better to err on the side of leaving the loop too soon than never
> > > when such races occur: once we've served prev (using root if none),
> > > get out the next time __mem_cgroup_iter_next() cannot deliver.
> > > 
> > > Signed-off-by: Hugh Dickins <hughd@google.com>
> > > ---
> > > Securing the tree iterator against such races is difficult, I've
> > > certainly got it wrong myself before.  Although the bug is real, and
> > > deserves a Cc stable, you may want to play around with other solutions
> > > before committing to this one.  The current iterator goes back to v3.12:
> > > I'm really not sure if v3.11 was good or not - I never saw the problem
> > > in the vanilla kernel, but with Google mods in we also had to make an
> > > adjustment, there to stop __mem_cgroup_iter() being called endlessly
> > > from the reclaim level.
> > > 
> > >  mm/memcontrol.c |    5 ++++-
> > >  1 file changed, 4 insertions(+), 1 deletion(-)
> > > 
> > > --- mmotm/mm/memcontrol.c	2014-01-10 18:25:02.236448954 -0800
> > > +++ linux/mm/memcontrol.c	2014-01-12 22:21:10.700570471 -0800
> > > @@ -1254,8 +1252,11 @@ struct mem_cgroup *mem_cgroup_iter(struc
> > >  				reclaim->generation = iter->generation;
> > >  		}
> > >  
> > > -		if (prev && !memcg)
> > > +		if (!memcg) {
> > > +			if (!prev)
> > > +				memcg = root;
> > >  			goto out_unlock;
> > > +		}
> > >  	}
> > >  out_unlock:
> > >  	rcu_read_unlock();
> > 
> > -- 
> > Michal Hocko
> > SUSE Labs
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Michal Hocko
> SUSE Labs

#!/bin/sh
seconds=60

move() {
	s=$1
	d=$2
	mkdir $cg/$d || exit $?
	echo $mem >$cg/$d/memory.limit_in_bytes || exit $?
	[ -z "$soft" ] || echo $soft >$cg/$d/memory.soft_limit_in_bytes || exit $?
	[ -z "$swam" ] || echo $swam >$cg/$d/memory.memsw.limit_in_bytes || exit $?
#	echo 3 >$cg/$d/memory.move_charge_at_immigrate || exit $?
	tasks=0
	while [ $tasks -lt 4 ]
	do	sleep 1
		[ -f /tmp/swapswap ] || exit 0
		set -- `wc -l $cg/$s/tasks`
		tasks=$1
	done
	while :
	do
		while :
		do	read task <$cg/$s/tasks  || break
			echo $task >$cg/$d/tasks # but might have gone already
			[ -f /tmp/swapswap ] || exit 0
		done	2>/dev/null
		rmdir $cg/$s 2>/dev/null && break
		sleep 1
		[ -f /tmp/swapswap ] || exit 0
	done
	sleep $seconds
	[ -f /tmp/swapswap ] || exit 0
}

case "x$1" in
x)	mem=700M ; soft=""  ; memcgs=1 ;;
x1)	mem=700M ; soft=""  ; memcgs=1 ;;
x2)	mem=300M ; soft=250M; memcgs=2 ;;
xm)	mem=300M ; soft=250M; memcgs=2 ;;
*)	mem=$1   ; soft=""  ; memcgs=1 ;;
esac

> /tmp/swapswap
mkdir -p /cg || exit $?
[ -f /cg/memory.usage_in_bytes ] ||
	mount -t cgroup -o memory cg /cg || exit $?
[ -f /cg/memory.memsw.usage_in_bytes ] && swam=1000M || swam=""
echo 1 >/cg/memory.use_hierarchy || exit $?

cg=/cg/cg
mkdir -p $cg || exit $?
echo 1000M >$cg/memory.limit_in_bytes
[ -z "$soft" ] || echo  800M >$cg/memory.soft_limit_in_bytes
[ -z "$swam" ] || echo 2000M >$cg/memory.memsw.limit_in_bytes
echo $$ >$cg/tasks

i=0
while [ $i -lt $memcgs ]
do	let i=$i+1
	mkdir -p $cg/$i || exit $?
	echo $mem >$cg/$i/memory.limit_in_bytes || exit $?
	[ -z "$soft" ] || echo $soft >$cg/$i/memory.soft_limit_in_bytes || exit $?
	[ -z "$swam" ] || echo $swam >$cg/$i/memory.memsw.limit_in_bytes || swam=""

	chmod a+w $cg/$i/tasks || exit $?
done
while [ $i -lt 4 ]
do	let i=$i+1
	[ ! -d $cg/$i ] || rmdir $cg/$i || exit $?
done
[ "x$1" = xm ] || exit 0

while :
do	move 1 3
	move 2 4
	move 3 1
	move 4 2
done &

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
