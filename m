Date: Thu, 22 May 2008 23:32:07 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
Message-ID: <20080522233207.6ddfa884@bree.surriel.com>
In-Reply-To: <20080523121027.b0eecfa0.kamezawa.hiroyu@jp.fujitsu.com>
References: <48350F15.9070007@mxp.nes.nec.co.jp>
	<20080522222655.166657da@bree.surriel.com>
	<20080523121027.b0eecfa0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Fri, 23 May 2008 12:10:27 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 22 May 2008 22:26:55 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> > Even worse is that a cgroup has NO CONTROL over how much
> > of its memory is kept in RAM and how much is swapped out.
> Could you explain "NO CONTROL" ? cgroup has LRU....
> 'how mucch memory should be swapped out from memory' is well controlled
> in the VM besides LRU logic ?

The kernel controls what is swapped out.  The userland
processes in the cgroup can do nothing to reduce their
swap usage.

> Consider following system. (and there is no swap controller.) 
> Memory 4G. Swap 1G. with 2 cgroups A, B.
> 
> state 1) swap is not used.
>   A....memory limit to be 1G  no swap usage memory_usage=0M
>   B....memory limit to be 1G  no swap usage memory_usage=0M
> 
> state 2) Run a big program on A.
>   A....memory limit to be 1G and try to use 1.7G. uses 700MBytes of swap.
>        memory_usage=1G swap_usage=700M
>   B....memory_usage=0M
> 
> state 3) A some of programs ends in 'A'
>   A....memory_usage=500M swap_usage=700M
>   B....memory_usage=0M.
> 
> state 4) Run a big program on B.
>   A...memory_usage=500M swap_usage=700M.
>   B...memory_usage=1G   swap_usage=300M
> 
> Group B can only use 1.3G because of unfair swap use of group A.
> But users think why A uses 700M of swap with 500M of free memory....
> 
> If we don't have limitation to swap, we'll have to innovate a way to move swap
> to memory in some reasonable logic.

OK, I see the use case.

In the above example, it would be possible for cgroup A
to have only 800MB of anonymous memory total, in addition
to 400MB of page cache.  The page cache could push the
anonymous memory into swap, indirectly penalizing how much
memory cgroup B can use.

Of course, it could be argued that the system should just
be run with enough swap space, but that is another story :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
