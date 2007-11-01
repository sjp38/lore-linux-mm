Date: Thu, 1 Nov 2007 09:29:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory cgroup enhancements take 4 [5/8] add status
 accounting function for memory cgroup
Message-Id: <20071101092956.489798fb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071031151234.4fcb42b2.akpm@linux-foundation.org>
References: <20071031192213.4f736fac.kamezawa.hiroyu@jp.fujitsu.com>
	<20071031193046.a58f2ef0.kamezawa.hiroyu@jp.fujitsu.com>
	<20071031151234.4fcb42b2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp
List-ID: <linux-mm.kvack.org>

At first, thank you for review.

On Wed, 31 Oct 2007 15:12:34 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> > +static inline void __mem_cgroup_stat_add(struct mem_cgroup_stat *stat,
> > +                enum mem_cgroup_stat_index idx, int val)
> > +{
> > +	int cpu = smp_processor_id();
> > +	preempt_disable();
> > +	stat->cpustat[cpu].count[idx] += val;
> > +	preempt_enable();
> > +}
> 
> This is clearly doing smp_processor_id() in preemptible code.  (or the
> preempt_disable() just isn't needed).  I fixed it up.
> 
Thanks,
> Please ensure that you test with all runtime debugging options enabled -
> you should have seen a warning here.
> 
Sorry, I'll take care.


> > +/*
> > + * For accounting under irq disable, no need for increment preempt count.
> > + */
> > +static inline void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat *stat,
> > +		enum mem_cgroup_stat_index idx, int val)
> > +{
> > +	int cpu = smp_processor_id();
> > +	stat->cpustat[cpu].count[idx] += val;
> > +}
> 
> There's a wild amount of inlining in that file.  Please, just don't do it -
> inline is a highly specialised thing and is rarely needed.
> 
> When I removed the obviously-wrong inline statements, the size of
> mm/memcontrol.o went from 3823 bytes down to 3495.
> 
> It also caused this:
> 
> mm/memcontrol.c:65: warning: '__mem_cgroup_stat_add' defined but not used
> 
> so I guess I'll just remove that.
> 
ok. I'll add again if it is needed again.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
