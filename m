Date: Thu, 3 Jul 2008 16:43:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm] [3/7] add shmem page to active list.
Message-Id: <20080703164320.1087f758.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0807030750110.22097@blonde.site>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
	<20080702211057.7a7cf3dc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080703091144.93465ba5.kamezawa.hiroyu@jp.fujitsu.com>
	<20080703132730.b64dcd19.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0807030750110.22097@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jul 2008 08:03:17 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> On Thu, 3 Jul 2008, KAMEZAWA Hiroyuki wrote:
> > 
> > BTW, is there a way to see the RSS usage of shmem from /proc or somewhere ?
> 
> No, it's just been a (very weirdly backed!) filesystem until these
> -mm developments.  If you add such stats (for more than temporary
> debugging), you'll need to use per_cpu counters for it: more global
> locking or atomic ops on those paths would be sure to upset SGI.
> 

like zone stat ? but I think struct address_space->nr_pages is udapted and
shmem's inode has alloced/swapped paremeters.

It seems alloced == address_space->nr_pages + info->swapped, right ?

I just wanted to ask whether they are exported or not.
(Or can I get that information by some ioctl ?)

BTW,  current meminfo is following.
==
[kamezawa@blackonyx test-2.6.26-rc5-mm3++]$ cat /proc/meminfo
MemTotal:       49471980 kB
MemFree:        44448528 kB
Buffers:          472412 kB
Cached:          3721388 kB
SwapCached:        22616 kB
Active:           658480 kB
Inactive:        3609828 kB
Active(anon):      14900 kB
Inactive(anon):    64496 kB
Active(file):     643580 kB
Inactive(file):  3545332 kB
Unevictable:        2020 kB
Mlocked:            2020 kB
SwapTotal:       2031608 kB
SwapFree:        1982656 kB
Dirty:                60 kB
Writeback:             0 kB
AnonPages:         62476 kB
Mapped:            32092 kB
Slab:             548584 kB
SReclaimable:     490284 kB
SUnreclaim:        58300 kB
PageTables:        12648 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
==

Cached = filesystem + shmem
Active(anon) = anon-active + shmem-active
Inactive(anon) = anon-inactive + shmem-inactive
Active(file) = file cache-active
Inactive(file) = file cache-inactive.

Right ? Maybe I have to drop the patch 2/7 and leave FLAG_CACHE.

Thanks,
-Kame

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
