Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8BF6B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 02:20:09 -0400 (EDT)
Received: by iyn15 with SMTP id 15so1686994iyn.34
        for <linux-mm@kvack.org>; Tue, 23 Aug 2011 23:20:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E5494D4.1050605@profihost.ag>
References: <4E5494D4.1050605@profihost.ag>
Date: Wed, 24 Aug 2011 09:20:07 +0300
Message-ID: <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
Subject: Re: slow performance on disk/network i/o full speed after drop_caches
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Netdev List <netdev@vger.kernel.org>

On Wed, Aug 24, 2011 at 9:06 AM, Stefan Priebe - Profihost AG
<s.priebe@profihost.ag> wrote:
> i hope this is the correct list to write to if it would be nice to give m=
e a
> hint where i can ask.
>
> Kernel: 2.6.38
>
> I'm seeing some strange problems on some of our servers after upgrading t=
o
> 2.6.38.
>
> I'm copying a 1GB file via scp from Machine A to Machine B. When B is
> freshly booted the file transfer is done with about 80 to 85 Mb/s. I can
> repeat that various times to performance degrease.
>
> Then after some days copying is only done with about 900kb/s up to 3Mb/s
> going up and down while transfering the file.
>
> When i then do drop_caches it works again on 80Mb/s.
>
> sync && echo 3 >/proc/sys/vm/drop_caches && sleep 2 && echo 0
>>/proc/sys/vm/drop_caches
>
> Attached is also an output of meminfo before and after drop_caches.
>
> What's going on here? MemFree is pretty high.
>
> Please CC me i'm not on list.

Interesting. I can imagine one or more of the following to be
involved: networking, vmscan, block, and writeback. Lets CC all of
them!

> # before drop_caches
>
> # cat /proc/meminfo
> MemTotal: =A0 =A0 =A0 =A08185544 kB
> MemFree: =A0 =A0 =A0 =A0 6670292 kB
> Buffers: =A0 =A0 =A0 =A0 =A0105164 kB
> Cached: =A0 =A0 =A0 =A0 =A0 166672 kB
> SwapCached: =A0 =A0 =A0 =A0 =A0 =A00 kB
> Active: =A0 =A0 =A0 =A0 =A0 728308 kB
> Inactive: =A0 =A0 =A0 =A0 567428 kB
> Active(anon): =A0 =A0 639204 kB
> Inactive(anon): =A0 394932 kB
> Active(file): =A0 =A0 =A089104 kB
> Inactive(file): =A0 172496 kB
> Unevictable: =A0 =A0 =A0 =A02976 kB
> Mlocked: =A0 =A0 =A0 =A0 =A0 =A02992 kB
> SwapTotal: =A0 =A0 =A0 1464316 kB
> SwapFree: =A0 =A0 =A0 =A01464316 kB
> Dirty: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A052 kB
> Writeback: =A0 =A0 =A0 =A0 =A0 =A0 0 kB
> AnonPages: =A0 =A0 =A0 1026920 kB
> Mapped: =A0 =A0 =A0 =A0 =A0 =A054208 kB
> Shmem: =A0 =A0 =A0 =A0 =A0 =A0 =A08380 kB
> Slab: =A0 =A0 =A0 =A0 =A0 =A0 =A080724 kB
> SReclaimable: =A0 =A0 =A022844 kB
> SUnreclaim: =A0 =A0 =A0 =A057880 kB
> KernelStack: =A0 =A0 =A0 =A02872 kB
> PageTables: =A0 =A0 =A0 =A035448 kB
> NFS_Unstable: =A0 =A0 =A0 =A0 =A00 kB
> Bounce: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 kB
> WritebackTmp: =A0 =A0 =A0 =A0 =A00 kB
> CommitLimit: =A0 =A0 5557088 kB
> Committed_AS: =A0 =A06187972 kB
> VmallocTotal: =A0 34359738367 kB
> VmallocUsed: =A0 =A0 =A0292360 kB
> VmallocChunk: =A0 34359425327 kB
> HardwareCorrupted: =A0 =A0 0 kB
> DirectMap4k: =A0 =A0 =A0 =A05632 kB
> DirectMap2M: =A0 =A0 2082816 kB
> DirectMap1G: =A0 =A0 6291456 kB
>
> # cat /proc/meminfo
> MemTotal: =A0 =A0 =A0 =A08185544 kB
> MemFree: =A0 =A0 =A0 =A0 6888060 kB
> Buffers: =A0 =A0 =A0 =A0 =A0 =A0 372 kB
> Cached: =A0 =A0 =A0 =A0 =A0 =A061492 kB
> SwapCached: =A0 =A0 =A0 =A0 =A0 =A00 kB
> Active: =A0 =A0 =A0 =A0 =A0 659156 kB
> Inactive: =A0 =A0 =A0 =A0 426664 kB
> Active(anon): =A0 =A0 638892 kB
> Inactive(anon): =A0 395200 kB
> Active(file): =A0 =A0 =A020264 kB
> Inactive(file): =A0 =A031464 kB
> Unevictable: =A0 =A0 =A0 =A02976 kB
> Mlocked: =A0 =A0 =A0 =A0 =A0 =A02992 kB
> SwapTotal: =A0 =A0 =A0 1464316 kB
> SwapFree: =A0 =A0 =A0 =A01464316 kB
> Dirty: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 kB
> Writeback: =A0 =A0 =A0 =A0 =A0 =A0 0 kB
> AnonPages: =A0 =A0 =A0 1026952 kB
> Mapped: =A0 =A0 =A0 =A0 =A0 =A054236 kB
> Shmem: =A0 =A0 =A0 =A0 =A0 =A0 =A08316 kB
> Slab: =A0 =A0 =A0 =A0 =A0 =A0 =A070616 kB
> SReclaimable: =A0 =A0 =A012264 kB
> SUnreclaim: =A0 =A0 =A0 =A058352 kB
> KernelStack: =A0 =A0 =A0 =A02864 kB
> PageTables: =A0 =A0 =A0 =A035448 kB
> NFS_Unstable: =A0 =A0 =A0 =A0 =A00 kB
> Bounce: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 kB
> WritebackTmp: =A0 =A0 =A0 =A0 =A00 kB
> CommitLimit: =A0 =A0 5557088 kB
> Committed_AS: =A0 =A06187932 kB
> VmallocTotal: =A0 34359738367 kB
> VmallocUsed: =A0 =A0 =A0292360 kB
> VmallocChunk: =A0 34359425327 kB
> HardwareCorrupted: =A0 =A0 0 kB
> DirectMap4k: =A0 =A0 =A0 =A05632 kB
> DirectMap2M: =A0 =A0 2082816 kB
> DirectMap1G: =A0 =A0 6291456 kB
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
