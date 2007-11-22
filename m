Date: Thu, 22 Nov 2007 17:40:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [4/10]
 calculate mapped ratio for memory cgroup
Message-Id: <20071122174015.c5ef61ae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071122083421.49E681CEE8C@siro.lan>
References: <20071119104246.d38de797.kamezawa.hiroyu@jp.fujitsu.com>
	<20071122083421.49E681CEE8C@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, containers@lists.osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Nov 2007 17:34:20 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > > > +	/* usage is recorded in bytes */
> > > > +	total = mem->res.usage >> PAGE_SHIFT;
> > > > +	rss = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
> > > > +	return (rss * 100) / total;
> > > 
> > > Never tried 64 bit division on a 32 bit system. I hope we don't
> > > have to resort to do_div() sort of functionality.
> > > 
> > Hmm, maybe it's better to make these numebrs be just "long".
> > I'll try to change per-cpu-counter implementation.
> > 
> > Thanks,
> > -Kame
> 
> besides that, i think 'total' can be zero here.
> 
Ah, This is what I do now.
==
+/*
+ * Calculate mapped_ratio under memory controller. This will be used in
+ * vmscan.c for deteremining we have to reclaim mapped pages.
+ */
+int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
+{
+       long total, rss;
+
+       /*
+        * usage is recorded in bytes. But, here, we assume the number of
+        * physical pages can be represented by "long" on any arch.
+        */
+       total = (long) (mem->res.usage >> PAGE_SHIFT);
+       rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
+       return (int)((rss * 100L) / total);
+}
==

maybe works well.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
