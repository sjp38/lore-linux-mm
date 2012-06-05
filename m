Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 008456B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 14:52:44 -0400 (EDT)
Date: Tue, 5 Jun 2012 14:52:39 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: oomkillers gone wild.
Message-ID: <20120605185239.GA28172@redhat.com>
References: <20120604152710.GA1710@redhat.com>
 <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com>
 <20120605174454.GA23867@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120605174454.GA23867@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Jun 05, 2012 at 01:44:54PM -0400, Dave Jones wrote:
 > On Mon, Jun 04, 2012 at 04:30:57PM -0700, David Rientjes wrote:
 >  > On Mon, 4 Jun 2012, Dave Jones wrote:
 >  > 
 >  > > we picked this..
 >  > > 
 >  > > [21623.066911] [  588]     0   588    22206        1   2       0             0 dhclient
 >  > > 
 >  > > over say..
 >  > > 
 >  > > [21623.116597] [ 7092]  1000  7092  1051124    31660   3       0             0 trinity-child3
 >  > > 
 >  > > What went wrong here ?
 >  > > 
 >  > > And why does that score look so.. weird.
 >  > > 
 >  > 
 >  > It sounds like it's because pid 588 has uid=0 and the adjustment for root 
 >  > processes is causing an overflow.  I assume this fixes it?
 > 
 > Still doesn't seem right..
 > 
 > eg..
 > 
 > [42309.542776] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
 > ..
 > [42309.553933] [  500]    81   500     5435        1   4     -13          -900 dbus-daemon
 > ..
 > [42309.597531] [ 9054]  1000  9054   528677    14540   3       0             0 trinity-child3
 > ..
 > 
 > [42309.643057] Out of memory: Kill process 500 (dbus-daemon) score 511952 or sacrifice child
 > [42309.643620] Killed process 500 (dbus-daemon) total-vm:21740kB, anon-rss:0kB, file-rss:4kB
 > 
 > and a slew of similar 'wrong process' death spiral kills follows..

So after manually killing all the greedy processes, and getting the box to stop oom-killing
random things, it settled down. But I noticed something odd, that I think I also saw a few
weeks ago..

# free
             total       used       free     shared    buffers     cached
Mem:       3886296    3666924     219372          0       2904      20008
-/+ buffers/cache:    3644012     242284
Swap:      6029308      14488    6014820

What's using up that memory ?

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME 
142524 142420  99%    9.67K  47510	  3   1520320K task_struct
142560 142417  99%    1.75K   7920	 18    253440K signal_cache
142428 142302  99%    1.19K   5478	 26    175296K task_xstate
306064 289292  94%    0.36K   6956	 44    111296K debug_objects_cache
143488 143306  99%    0.50K   4484	 32     71744K cred_jar
142560 142421  99%    0.50K   4455       32     71280K task_delay_info
150753 145021  96%    0.45K   4308	 35     68928K kmalloc-128

Why so many task_structs ? There's only 128 processes running, and most of them
are kernel threads.

/sys/kernel/slab/task_struct/alloc_calls shows..

 142421 copy_process.part.21+0xbb/0x1790 age=8/19929576/48173720 pid=0-16867 cpus=0-7

I get the impression that the oom-killer hasn't cleaned up properly after killing some of
those forked processes.

any thoughts ?

	Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
