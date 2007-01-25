Date: Thu, 25 Jan 2007 12:12:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Limit the size of the pagecache
Message-Id: <20070125121254.a2e91875.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0701241841000.12325@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
	<20070124121318.6874f003.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0701232028520.6820@schroedinger.engr.sgi.com>
	<20070124141510.7775829c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070125093259.74f76144.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0701241841000.12325@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: aubreylee@gmail.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, rgetz@blackfin.uclinux.org, Michael.Hennerich@analog.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jan 2007 18:41:27 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:
> > But I can't think of the way to show that.
> > ==
> > [kamezawa@aworks src]$ free
> >             total       used       free     shared    buffers     cached
> > Mem:        741604     724628      16976          0      62700     564600
> > -/+ buffers/cache:      97328     644276
> > Swap:      1052216       2532    1049684
> > ==
> 
> Could we call the free memory "unused memory" and not talk about free 
> memory at all?
> 
Ah, maybe it's better.

I met several memory troubles in user's systems in these days. (on older kernels)
Thousands/hundreds of process works on it.

When I explain the cutomers about memory management, I devides memory into..

(1) unused memory  --- memory which is not used, in free-list of zones.

(2) reclaimable memory --- page cache, which is reclaimable
	clean pages  --- can be reclaimed soon
	dirty pages  --- need to be written back
	*BUT* busy pages are unreclaimable. 

(3) swappable memory --- user process's pages. basically reclaimable if 
                         swap is available.
			 shmem pages are included here.

(4) locked memory --- mlocked memory, which is not reclaimable(but movable)

(5) kernel memory --- used by kernel, 
                      (and we can't see how many pages are reclaimable)
 
We can know the amount of (1) and (5) and total memory.
Basically, (3) = (Total) - (2) - (1).
busy data-set of (2)(3) is not reclaimable. but the amount of busy data-set
is unknown. Many users takes log of 'ps' or 'sar' to estimate their memory
usage. (and sometimes page-cache of 'log-file' eats their memory.....)

The amount of (4) is unknown. But there was a system with 6GB of 8GB
memory was mlocked (--; and OOM works.

I'm sorry that I can't catch up how the current kernel can show memory usage.
I should investigate that. 

FYI:
Because some customers are migrated from mainframes, they want to control
almost all features in OS, IOW, designing memory usages.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
