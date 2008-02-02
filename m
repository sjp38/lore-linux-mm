Date: Sat, 2 Feb 2008 10:09:14 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't works on memoryless node.
Message-ID: <20080202090914.GA27723@one.firstfloor.org>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <andi@firstfloor.org>, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

[intentional full quote]

On Sat, Feb 02, 2008 at 05:12:30PM +0900, KOSAKI Motohiro wrote:
> I tested numactl on 2.6.24-rc8-mm1.
> and I found strange behavior.
> 
> test method and result.
> 
> 	$ numactl --interleave=all ls
> 	set_mempolicy: Invalid argument
> 	setting interleave mask: Invalid argument
> 
> numactl command download from
> 	ftp://ftp.suse.com/pub/people/ak/numa/
> 	(I choice numactl-1.0.2)
> 
> 
> Of course, older kernel(RHEL5.1) works good.
> 
> 
> 
> more detail:
> 
> 1. my machine node and memory.
> 
> $ numactl --hardware
> available: 16 nodes (0-15)
> node 0 size: 0 MB
> node 0 free: 0 MB
> node 1 size: 0 MB
> node 1 free: 0 MB
> node 2 size: 3872 MB
> node 2 free: 1487 MB
> node 3 size: 4032 MB
> node 3 free: 3671 MB
> node 4 size: 0 MB
> node 4 free: 0 MB
> node 5 size: 0 MB
> node 5 free: 0 MB
> node 6 size: 0 MB
> node 6 free: 0 MB
> node 7 size: 0 MB
> node 7 free: 0 MB
> node 8 size: 0 MB
> node 8 free: 0 MB
> node 9 size: 0 MB
> node 9 free: 0 MB
> node 10 size: 0 MB
> node 10 free: 0 MB
> node 11 size: 0 MB
> node 11 free: 0 MB
> node 12 size: 0 MB
> node 12 free: 0 MB
> node 13 size: 0 MB
> node 13 free: 0 MB
> node 14 size: 0 MB
> node 14 free: 0 MB
> node 15 size: 0 MB
> node 15 free: 0 MB
> 
> 
> 2. numactl behavior of --interleave=all
>    2.1  scan "/sys/devices/system/node" dir
>    2.2  calculate max node number
>    2.3  all bit turn on of existing node.
>         (i.e. 0xFF generated on my environment.)
>    2.4  call set_mempolicy()
> 
> 3. 2.6.24-rc8-mm1 set_mempolicy(2) behavior
>    3.1 check nodesubset(nodemask argument, node_states[N_HIGH_MEMORY])
>        in mpol_check_policy()
> 
> 	-> check failed when memmoryless node exist.
>            (i.e. node_states[N_HIGH_MEMORY] of my machine is 0xc)
> 
> 4. RHEL5.1 set_mempolicy(2) behavior
>    4.1 check nodesubset(nodemask argument, node_online_map)
>        in mpol_check_policy().
> 
> 	-> check success.
> 
> 
> I don't know wrong either kernel or libnuma.

When the kernel behaviour changes and breaks user space then the kernel
is usually wrong. Cc'ed Lee S. who maintains the kernel code now.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
