Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0006B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 19:55:14 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F39C03EE0AE
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 08:55:10 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 80CFA45DF0D
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 08:55:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 64E2F45DF15
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 08:55:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 562AF1DB803E
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 08:55:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 142081DB8045
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 08:55:07 +0900 (JST)
Date: Fri, 15 Jul 2011 08:47:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-Id: <20110715084755.1e0a4c14.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110714125555.GA27954@tiehlicka.suse.cz>
References: <50d526ee242916bbfb44b9df4474df728c4892c6.1310561078.git.mhocko@suse.cz>
	<20110714100259.cedbf6af.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714115913.cf8d1b9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714090017.GD19408@tiehlicka.suse.cz>
	<20110714183014.8b15e9b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714095152.GG19408@tiehlicka.suse.cz>
	<20110714191728.058859cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714110935.GK19408@tiehlicka.suse.cz>
	<20110714113009.GL19408@tiehlicka.suse.cz>
	<20110714205012.8b78691e.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714125555.GA27954@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu, 14 Jul 2011 14:55:55 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 14-07-11 20:50:12, KAMEZAWA Hiroyuki wrote:
> > On Thu, 14 Jul 2011 13:30:09 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> [...]
> > >  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
> > >  {
> > > -	int x, lock_count = 0;
> > > -	struct mem_cgroup *iter;
> > > +	int x, lock_count = -1;
> > > +	struct mem_cgroup *iter, *failed = NULL;
> > > +	bool cond = true;
> > >  
> > > -	for_each_mem_cgroup_tree(iter, mem) {
> > > -		x = atomic_inc_return(&iter->oom_lock);
> > > -		lock_count = max(x, lock_count);
> > > +	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
> > > +		x = !!atomic_add_unless(&iter->oom_lock, 1, 1);
> > > +		if (lock_count == -1)
> > > +			lock_count = x;
> > > +		else if (lock_count != x) {
> > > +			/*
> > > +			 * this subtree of our hierarchy is already locked
> > > +			 * so we cannot give a lock.
> > > +			 */
> > > +			lock_count = 0;
> > > +			failed = iter;
> > > +			cond = false;
> > > +		}
> > >  	}
> > 
> > Hm ? assuming B-C-D is locked and a new thread tries a lock on A-B-C-D-E.
> > And for_each_mem_cgroup_tree will find groups in order of A->B->C->D->E.
> > Before lock
> >   A  0
> >   B  1
> >   C  1
> >   D  1
> >   E  0
> > 
> > After lock
> >   A  1
> >   B  1
> >   C  1
> >   D  1
> >   E  0
> > 
> > here, failed = B, cond = false. Undo routine will unlock A.
> > Hmm, seems to work in this case.
> > 
> > But....A's oom_lock==0 and memcg_oom_wakeup() at el will not able to
> > know "A" is in OOM. wakeup processes in A which is waiting for oom recover..
> 
> Hohm, we need to have 2 different states. lock and mark_oom.
> oom_recovert would check only the under_oom.
> 

yes. I think so, too.

> > 
> > Will this work ?
> 
> No it won't because the rest of the world has no idea that A is
> under_oom as well.
> 
> > ==
> >  # cgcreate -g memory:A
> >  # cgset -r memory.use_hierarchy=1 A
> >  # cgset -r memory.oom_control=1   A
> >  # cgset -r memory.limit_in_bytes= 100M
> >  # cgset -r memory.memsw.limit_in_bytes= 100M
> >  # cgcreate -g memory:A/B
> >  # cgset -r memory.oom_control=1 A/B
> >  # cgset -r memory.limit_in_bytes=20M
> >  # cgset -r memory.memsw.limit_in_bytes=20M
> > 
> >  Assume malloc XXX is a program allocating XXX Megabytes of memory.
> > 
> >  # cgexec -g memory:A/B malloc 30  &    #->this will be blocked by OOM of group B
> >  # cgexec -g memory:A   malloc 80  &    #->this will be blocked by OOM of group A
> > 
> > 
> > Here, 2 procs are blocked by OOM. Here, relax A's limitation and clear OOM.
> > 
> >  # cgset -r memory.memsw.limit_in_bytes=300M A
> >  # cgset -r memory.limit_in_bytes=300M A
> > 
> >  malloc 80 will end.
> 
> What about yet another approach? Very similar what you proposed, I
> guess. Again not tested and needs some cleanup just to illustrate.
> What do you think?

Hmm, I think this will work. Please go ahead.
Unfortunately, I'll not be able to make a quick response for a week
because of other tasks. I'm sorry.

Anyway,
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> 

BTW, it's better to add "How-to-test" and the result in description.
Some test similar to mine will show the result we want.
==
Make a hierarchy of memcg, which has 300MB memory+swap limit.

 %cgcreate -g memory:A
 %cgset -r memory.limit_in_bytes=300M A
 %cgset -r memory.memsw.limit_in_bytes=300M A

Then, running folloing program under A.
 %cgexec -g memory:A ./fork
==
int main(int argc, char *argv[])
{
        int i;
        int status;

        for (i = 0; i < 5000; i++) {
                if (fork() == 0) {
                        char *c;
                        c = malloc(1024*1024);
                        memset(c, 0, 1024*1024);
                        sleep(20);
                        fprintf(stderr, "[%d]\n", i);
                        exit(0);
                }
                printf("%d\n", i);
                waitpid(-1, &status, WNOHANG);
        }
        while (1) {
                int ret;
                ret = waitpid(-1, &status, WNOHANG);

                if (ret == -1)
                        break;
                if (!ret)
                        sleep(1);
        }
        return 0;
}
==

Thank you for your effort.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
