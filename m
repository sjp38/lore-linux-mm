Date: Wed, 20 Aug 2008 11:35:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 1/2] Show quicklist at meminfo
Message-Id: <20080820113559.f559a411.akpm@linux-foundation.org>
In-Reply-To: <20080820200607.12ED.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080820200607.12ED.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Aug 2008 20:07:06 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Now, Quicklist can spent several GB memory.
> So, if end user can't hou much spent memory, he misunderstand to memory leak happend.
> 
> 
> after this patch applied, /proc/meminfo output following.
> 
> % cat /proc/meminfo
> 
> MemTotal:        7701504 kB
> MemFree:         5159040 kB
> Buffers:          112960 kB
> Cached:           337536 kB
> SwapCached:            0 kB
> Active:           218944 kB
> Inactive:         350848 kB
> Active(anon):     120832 kB
> Inactive(anon):        0 kB
> Active(file):      98112 kB
> Inactive(file):   350848 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:       2031488 kB
> SwapFree:        2031488 kB
> Dirty:               320 kB
> Writeback:             0 kB
> AnonPages:        119488 kB
> Mapped:            38528 kB
> Slab:            1595712 kB
> SReclaimable:      23744 kB
> SUnreclaim:      1571968 kB
> PageTables:        14336 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:     5882240 kB
> Committed_AS:     356672 kB
> VmallocTotal:   17592177655808 kB
> VmallocUsed:       29056 kB
> VmallocChunk:   17592177626304 kB
> Quicklists:       283776 kB
> HugePages_Total:     0
> HugePages_Free:      0
> HugePages_Rsvd:      0
> HugePages_Surp:      0
> Hugepagesize:    262144 kB
> 
> ...
>
>  		K(committed),
>  		(unsigned long)VMALLOC_TOTAL >> 10,
>  		vmi.used >> 10,
> -		vmi.largest_chunk >> 10
> +		vmi.largest_chunk >> 10,
> +		K(quicklist_total_size())
>  		);

quicklist_total_size() is racy against cpu hotplug.  That's OK for
/proc/meminfo purposes (occasional transient inaccuracy?), but will it
crash?  Not in the current implementation of per_cpu() afaict, but it
might crash if we ever teach cpu hotunplug to free up the percpu
resources.

I see no cpu hotplug handling in the quicklist code.  Do we leak all
the hot-unplugged CPU's pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
