Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j978D2Qt006000
	for <linux-mm@kvack.org>; Fri, 7 Oct 2005 04:13:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j978D2XV085320
	for <linux-mm@kvack.org>; Fri, 7 Oct 2005 04:13:02 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j978D1Yk032624
	for <linux-mm@kvack.org>; Fri, 7 Oct 2005 04:13:01 -0400
Date: Fri, 7 Oct 2005 13:42:49 +0530
From: Bharata B Rao <bharata@in.ibm.com>
Subject: Re: shrinkable cache statistics [was Re: VM balancing issues on 2.6.13: dentry cache not getting shrunk enough]
Message-ID: <20051007081249.GA3781@in.ibm.com>
Reply-To: bharata@in.ibm.com
References: <20050911120045.GA4477@in.ibm.com> <20050912031636.GB16758@thunk.org> <20050913084752.GC4474@in.ibm.com> <20050914230843.GA11748@dmt.cnet> <20050915093945.GD3869@in.ibm.com> <20050915132910.GA6806@dmt.cnet> <20051002163229.GB5190@in.ibm.com> <20051002200640.GB9865@xeon.cnet> <20051004133635.GA23575@in.ibm.com> <20051005212551.GA10057@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051005212551.GA10057@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Dipankar Sarma <dipankar@in.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 05, 2005 at 06:25:51PM -0300, Marcelo Tosatti wrote:
> Hi Bharata,
> 
> On Tue, Oct 04, 2005 at 07:06:35PM +0530, Bharata B Rao wrote:
> > Marcelo,
> > 
> > Here's my next attempt in breaking the "slabs_scanned" from /proc/vmstat
> > into meaningful per cache statistics. Now I have the statistics counters
> > as percpu. [an issue remaining is that there are more than one cache as
> > part of mbcache and they all have a common shrinker routine and I am
> > displaying the collective shrinker stats info on each of them in
> > /proc/slabinfo ==> some kind of duplication]
> 
> Looks good to me! IMO it should be a candidate for -mm/mainline.
> 
> Nothing useful to suggest on the mbcache issue... sorry.

Thanks Marcelo for reviewing.

<snip>

> > 
> > [root@llm09 bharata]# grep shrinker /proc/slabinfo
> > # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail> : shrinker stat <nr requested> <nr freed>
> > ext3_xattr             0      0     48   78    1 : tunables  120   60    8 : slabdata      0      0      0 : shrinker stat       0       0
> > dquot                  0      0    160   24    1 : tunables  120   60    8 : slabdata      0      0      0 : shrinker stat       0       0
> > inode_cache         1301   1390    400   10    1 : tunables   54   27    8 : slabdata    139    139      0 : shrinker stat  682752  681900
> > dentry_cache       82110 114452    152   26    1 : tunables  120   60    8 : slabdata   4402   4402      0 : shrinker stat 1557760  760100
> > 
> > [root@llm09 bharata]# grep slabs_scanned /proc/vmstat
> > slabs_scanned 2240512
> > 
> > [root@llm09 bharata]# cat /proc/sys/fs/dentry-state
> > 82046   75369   45      0       3599    0
> > [The order of dentry-state o/p is like this:
> > total dentries in dentry hash list, total dentries in lru list, age limit,
> > want_pages, inuse dentries in lru list, dummy]
> > 
> > So, we can see that with low memory pressure, even though the
> > shrinker runs on dcache repeatedly, not many dentries are freed
> > by dcache. And dcache lru list still has huge number of free
> > dentries.
> 
> The success/attempt ratio is about 1/2, which seems alright? 
> 

Hmm... when compared to inode_cache, I felt dcache shrinker wasn't
doing a good job. Anyway I will analyze further to see if things
can be made better with the existing shrinker.

Regards,
Bharata.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
