Date: Fri, 3 Aug 2007 10:32:07 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070803093207.GA20987@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com> <20070802140904.GA16940@skynet.ie> <Pine.LNX.4.64.0708021152370.7719@schroedinger.engr.sgi.com> <20070802194211.GE23133@skynet.ie> <Pine.LNX.4.64.0708021251180.8527@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708021251180.8527@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On (02/08/07 12:52), Christoph Lameter didst pronounce:
> On Thu, 2 Aug 2007, Mel Gorman wrote:
> 
> > 
> > --- 
> > diff --git a/drivers/base/node.c b/drivers/base/node.c
> > index cae346e..3656489 100644
> > --- a/drivers/base/node.c
> > +++ b/drivers/base/node.c
> > @@ -98,6 +98,7 @@ static SYSDEV_ATTR(meminfo, S_IRUGO, node_read_meminfo, NULL);
> >  
> >  static ssize_t node_read_numastat(struct sys_device * dev, char * buf)
> >  {
> > +	refresh_all_cpu_vm_stats();
> 
> The function is called refresh_vmstats(). Just export it.
> 
> >  		       "numa_miss %lu\n"
> > diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> > index 75370ec..31046e2 100644
> > --- a/include/linux/vmstat.h
> > +++ b/include/linux/vmstat.h
> > @@ -213,6 +213,7 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
> >  extern void __dec_zone_state(struct zone *, enum zone_stat_item);
> >  
> >  void refresh_cpu_vm_stats(int);
> > +void refresh_all_cpu_vm_stats(void);
> 
> No need to add another one.
> 

diff --git a/drivers/base/node.c b/drivers/base/node.c
index cae346e..5a7f898 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -98,6 +98,7 @@ static SYSDEV_ATTR(meminfo, S_IRUGO, node_read_meminfo, NULL);
 
 static ssize_t node_read_numastat(struct sys_device * dev, char * buf)
 {
+	refresh_vm_stats();
 	return sprintf(buf,
 		       "numa_hit %lu\n"
 		       "numa_miss %lu\n"
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 75370ec..c9f6dad 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -261,4 +261,6 @@ static inline void __dec_zone_page_state(struct page *page,
 static inline void refresh_cpu_vm_stats(int cpu) { }
 #endif
 
+void refresh_vm_stats(void);
+
 #endif /* _LINUX_VMSTAT_H */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c64d169..970fb74 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -642,6 +642,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	m->private = v;
 	if (!v)
 		return ERR_PTR(-ENOMEM);
+	refresh_vm_stats();
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		v[i] = global_page_state(i);
 #ifdef CONFIG_VM_EVENT_COUNTERS
-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
