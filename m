Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AB4338D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 03:21:28 -0400 (EDT)
Date: Tue, 29 Mar 2011 09:21:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] memcg: update documentation to describe
 usage_in_bytes
Message-ID: <20110329072122.GA30671@tiehlicka.suse.cz>
References: <20110322073150.GA12940@tiehlicka.suse.cz>
 <20110323092708.021d555d.nishimura@mxp.nes.nec.co.jp>
 <20110323133517.de33d624.kamezawa.hiroyu@jp.fujitsu.com>
 <20110328085508.c236e929.nishimura@mxp.nes.nec.co.jp>
 <20110328132550.08be4389.nishimura@mxp.nes.nec.co.jp>
 <20110328074341.GA5693@tiehlicka.suse.cz>
 <20110328181127.b8a2a1c5.kamezawa.hiroyu@jp.fujitsu.com>
 <20110328094820.GC5693@tiehlicka.suse.cz>
 <20110328193108.07965b4a.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329101511.d30f3518.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110329101511.d30f3518.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 29-03-11 10:15:11, Daisuke Nishimura wrote:
[...]
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Since 569b846d(memcg: coalesce uncharge during unmap/truncate), we do batched
> (delayed) uncharge at truncation/unmap. And since cdec2e42(memcg: coalesce
> charging via percpu storage), we have percpu cache for res_counter.
> 
> These changes improved performance of memory cgroup very much, but made
> res_counter->usage usually have a bigger value than the actual value of memory usage.
> So, *.usage_in_bytes, which show res_counter->usage, are not desirable for precise
> values of memory(and swap) usage anymore.
> 
> Instead of removing these files completely(because we cannot know res_counter->usage
> without them), this patch updates the meaning of those files.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  Documentation/cgroups/memory.txt |   15 +++++++++++++--
>  1 files changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 7781857..4f49d91 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -52,8 +52,10 @@ Brief summary of control files.
>   tasks				 # attach a task(thread) and show list of threads
>   cgroup.procs			 # show list of processes
>   cgroup.event_control		 # an interface for event_fd()
> - memory.usage_in_bytes		 # show current memory(RSS+Cache) usage.
> - memory.memsw.usage_in_bytes	 # show current memory+Swap usage
> + memory.usage_in_bytes		 # show current res_counter usage for memory
> +				 (See 5.5 for details)
> + memory.memsw.usage_in_bytes	 # show current res_counter usage for memory+Swap
> +				 (See 5.5 for details)
>   memory.limit_in_bytes		 # set/show limit of memory usage
>   memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
>   memory.failcnt			 # show the number of memory usage hits limits
> @@ -453,6 +455,15 @@ memory under it will be reclaimed.
>  You can reset failcnt by writing 0 to failcnt file.
>  # echo 0 > .../memory.failcnt
>  
> +5.5 usage_in_bytes
> +
> +For efficiency, as other kernel components, memory cgroup uses some optimization
> +to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
> +method and doesn't show 'exact' value of memory(and swap) usage, it's an fuzz
> +value for efficient access. (Of course, when necessary, it's synchronized.)
> +If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
> +value in memory.stat(see 5.2).
> +
>  6. Hierarchy support
>  
>  The memory controller supports a deep hierarchy and hierarchical accounting.

Acked-by: Michal Hocko <mhocko@suse.cz>

Although I would like to see a mention about what is the reason for
keeping that file(s) if their usage is very limited. Something like.
"We are keeping the file because we want to be consistent with other
cgroups implementations and all of them export usage counter in some
way. Make sure you exactly know the meaning before you use the value
in userspace."

If nobody else feels that this is that important then please forget
about this comment.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
