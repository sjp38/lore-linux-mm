Date: Sat, 28 Jun 2008 13:36:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 0/5] Memory controller soft limit introduction (v3)
Message-Id: <20080628133615.a5fa16cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jun 2008 20:48:08 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> This patchset implements the basic changes required to implement soft limits
> in the memory controller. A soft limit is a variation of the currently
> supported hard limit feature. A memory cgroup can exceed it's soft limit
> provided there is no contention for memory.
> 
> These patches were tested on a x86_64 box, by running a programs in parallel,
> and checking their behaviour for various soft limit values.
> 
> These patches were developed on top of 2.6.26-rc5-mm3. Comments, suggestions,
> criticism are all welcome!
> 
> A previous version of the patch can be found at
> 
> http://kerneltrap.org/mailarchive/linux-kernel/2008/2/19/904114
> 
I have a couple of comments.

1. Why you add soft_limit to res_coutner ?
   Is there any other controller which uses soft-limit ?
   I'll move watermark handling to memcg from res_counter becasue it's
   required only by memcg.

2. *please* handle NUMA
   There is a fundamental difference between global VMM and memcg.
     global VMM - reclaim memory at memory shortage.
     memcg     - for reclaim memory at memory limit
   Then, memcg wasn't required to handle place-of-memory at hitting limit. 
   *just reducing the usage* was enough.
   In this set, you try to handle memory shortage handling.
   So, please handle NUMA, i.e. "what node do you want to reclaim memory from ?"
   If not, 
    - memory placement of Apps can be terrible.
    - cannot work well with cpuset. (I think)

3. I think  when "mem_cgroup_reclaim_on_contention" exits is unclear.
   plz add explanation of algorithm. It returns when some pages are reclaimed ?

4. When swap-full cgroup is on the top of heap, which tends to contain
   tons of memory, much amount of cpu-time will be wasted.
   Can we add "ignore me" flag  ?

Maybe "2" is the most important to implement this.
I think this feature itself is interesting, so please handle NUMA.

"4" includes the user's (middleware's) memcg handling problem. But maybe
a problem should be fixed in future.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
