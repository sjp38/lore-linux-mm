Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5CF2D6B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 05:37:35 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2329D3EE0C0
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 18:37:32 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED39C45DE7F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 18:37:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D532A45DE6A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 18:37:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C5DAD1DB804A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 18:37:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 80FEB1DB8047
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 18:37:31 +0900 (JST)
Date: Thu, 14 Jul 2011 18:30:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-Id: <20110714183014.8b15e9b9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110714090017.GD19408@tiehlicka.suse.cz>
References: <cover.1310561078.git.mhocko@suse.cz>
	<50d526ee242916bbfb44b9df4474df728c4892c6.1310561078.git.mhocko@suse.cz>
	<20110714100259.cedbf6af.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714115913.cf8d1b9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714090017.GD19408@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu, 14 Jul 2011 11:00:17 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 14-07-11 11:59:13, KAMEZAWA Hiroyuki wrote:
> > On Thu, 14 Jul 2011 10:02:59 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Wed, 13 Jul 2011 13:05:49 +0200
> > > Michal Hocko <mhocko@suse.cz> wrote:
> [...]
> > > > This patch replaces the counter by a simple {un}lock semantic. We are
> > > > using only 0 and 1 to distinguish those two states.
> > > > As mem_cgroup_oom_{un}lock works on the hierarchy we have to make sure
> > > > that we cannot race with somebody else which is already guaranteed
> > > > because we call both functions with the mutex held. All other consumers
> > > > just read the value atomically for a single group which is sufficient
> > > > because we set the value atomically.
> > > > The other thing is that only that process which locked the oom will
> > > > unlock it once the OOM is handled.
> > > > 
> > > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > > ---
> > > >  mm/memcontrol.c |   24 +++++++++++++++++-------
> > > >  1 files changed, 17 insertions(+), 7 deletions(-)
> > > > 
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > index e013b8e..f6c9ead 100644
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -1803,22 +1803,31 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > > >  /*
> > > >   * Check OOM-Killer is already running under our hierarchy.
> > > >   * If someone is running, return false.
> > > > + * Has to be called with memcg_oom_mutex
> > > >   */
> > > >  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
> > > >  {
> > > > -	int x, lock_count = 0;
> > > > +	int x, lock_count = -1;
> > > >  	struct mem_cgroup *iter;
> > > >  
> > > >  	for_each_mem_cgroup_tree(iter, mem) {
> > > > -		x = atomic_inc_return(&iter->oom_lock);
> > > > -		lock_count = max(x, lock_count);
> > > > +		x = !!atomic_add_unless(&iter->oom_lock, 1, 1);
> > > > +		if (lock_count == -1)
> > > > +			lock_count = x;
> > > > +
> > > 
> > > 
> > > Hmm...Assume following hierarchy.
> > > 
> > > 	  A
> > >        B     C
> > >       D E 
> 
> IIUC, A, B, D, E are one hierarchy, right?
> 
yes.


> > > 
> > > The orignal code hanldes the situation
> > > 
> > >  1. B-D-E is under OOM
> > >  2. A enters OOM after 1.
> > > 
> > > In original code, A will not invoke OOM (because B-D-E oom will kill a process.)
> > > The new code invokes A will invoke new OOM....right ?
> 
> Sorry, I do not understand what you mean by that. 

This is your code.
==
 	for_each_mem_cgroup_tree(iter, mem) {
-		x = atomic_inc_return(&iter->oom_lock);
-		lock_count = max(x, lock_count);
+		x = !!atomic_add_unless(&iter->oom_lock, 1, 1);
+		if (lock_count == -1)
+			lock_count = x;
+
+		/* New child can be created but we shouldn't race with
+		 * somebody else trying to oom because we are under
+		 * memcg_oom_mutex
+		 */
+		BUG_ON(lock_count != x);
 	}
==

When, B,D,E is under OOM,  

   A oom_lock = 0
   B oom_lock = 1
   C oom_lock = 0
   D oom_lock = 1
   E oom_lock = 1

Here, assume A enters OOM.

   A oom_lock = 1 -- (*)
   B oom_lock = 1
   C oom_lock = 1
   D oom_lock = 1
   E oom_lock = 1

because of (*), mem_cgroup_oom_lock() will return lock_count=1, true.

Then, a new oom-killer will another oom-kiiler running in B-D-E.




> The original code and
> the new code do the same in that regards they lock the whole hierarchy.
> The only difference is that the original one increments the counter for
> all groups in the hierarchy while the new one just sets it to from 0->1
> BUG_ON just checks that we are not racing with somebody else.
> 


In above situation, old code's result is

   A oom_lock = 1
   B oom_lock = 2
   C oom_lock = 1
   D oom_lock = 2
   E oom_lock = 2

Then, max lockcount== 2 and return value is false. 



> > > 
> > > I wonder this kind of code
> > > ==
> > > 	bool success = true;
> > > 	...
> > > 	for_each_mem_cgroup_tree(iter, mem) {
> > > 		success &= !!atomic_add_unless(&iter->oom_lock, 1, 1);
> > > 		/* "break" loop is not allowed because of css refcount....*/
> > > 	}
> > > 	return success.
> > > ==
> > > Then, one hierarchy can invoke one OOM kill within it.
> > > But this will not work because we can't do proper unlock.
> 
> Why cannot we do a proper unlock?
> 

After 1st lock by oom in B-D-E

   A oom_lock = 0
   B oom_lock = 1
   C oom_lock = 0
   D oom_lock = 1
   E oom_lock = 1

returns true. and mem_cgroup_oom_unlock() will scan B-D-E and set oom_lock==0.

2nd lock by oom in A-B-C-D-E

  A oom_lock = 1
  B oom_lock = 1
  C oom_lock = 1
  D oom_lock = 1
  E oom_lock = 1

returns false, then, mem_cgroup_oom_unlock() will not be called.

After unlock, we see

  A oom_lock = 1
  B oom_lock = 0
  C oom_lock = 1
  D oom_lock = 0
  E oom_lock = 0


> > > 
> > > 
> > > Hm. how about this ? This has only one lock point and we'll not see the BUG.
> > > Not tested yet..
> > > 
> > Here, tested patch + test program. this seems to work well.
> 
> Will look at it later. At first glance it looks rather complicated. But
> maybe I am missing something. I have to confess I am not absolutely sure
> when it comes to hierarchies.
> 


With my patch, oom_lock shows the lock owner memcg. oom status is divided to
the vairable, under_oom.

(1) At 1st vistor by oom in B-D-E

  A oom_lock = 0  under_oom=0
  B oom_lock = 1  under_oom=1
  C oom_lock = 0  under_oom=0
  D oom_lock = 0  under_oom=1
  E oom_lock - 0  under_oom=0

returns true.

(2) At 2nd visrot by oom in A-B-C-D-E

  A oom_lock = 1  under_oom=1
  B oom_lock = 0  under_oom=1
  C oom_lock = 0  under_oom=1
  D oom_lock = 0  under_oom=1
  E oom_lock = 0  under_oom=1

The lock moves to A and returns false.

(3) at unlock, the thread which did (1) will find group A and
    unlock all hierarchy.


  A oom_lock = 0  under_oom=0
  B oom_lock = 0  under_oom=0
  C oom_lock = 0  under_oom=0
  D oom_lock = 0  under_oom=0
  E oom_lock = 0  under_oom=0


Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
