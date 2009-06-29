Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 900776B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 14:53:11 -0400 (EDT)
Received: by gxk3 with SMTP id 3so6924305gxk.14
        for <linux-mm@kvack.org>; Mon, 29 Jun 2009 11:54:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090629095729.cc9f183c.akpm@linux-foundation.org>
References: <2f11576a0906290048t29667ae0sd75c96d023b113e2@mail.gmail.com>
	 <7561.1245768237@redhat.com> <26537.1246086769@redhat.com>
	 <20090627125412.GA1667@cmpxchg.org> <20090628113246.GA18409@localhost>
	 <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com>
	 <2f11576a0906280749v25ab725dn8f98fbc1d2e5a5fd@mail.gmail.com>
	 <28c262360906280947o6f9358ddh20ab549e875282a9@mail.gmail.com>
	 <17087.1246279435@redhat.com>
	 <20090629095729.cc9f183c.akpm@linux-foundation.org>
Date: Tue, 30 Jun 2009 03:54:51 +0900
Message-ID: <2f11576a0906291154j727165e0nebdc3813d7af3158@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

2009/6/30 Andrew Morton <akpm@linux-foundation.org>:
> On Mon, 29 Jun 2009 13:43:55 +0100 David Howells <dhowells@redhat.com> wr=
ote:
>
>> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>> > David, Can you please try to following patch? it was posted to LKML
>> > about 1-2 week ago.
>> >
>> > Subject "[BUGFIX][PATCH] fix lumpy reclaim lru handiling at
>> > isolate_lru_pages v2"
>>
>> It is already committed, but I ran a test on the latest Linus kernel any=
way:
>>
>> msgctl11 invoked oom-killer: gfp_mask=3D0xd0, order=3D1, oom_adj=3D0
>> msgctl11 cpuset=3D/ mems_allowed=3D0
>> Pid: 20366, comm: msgctl11 Not tainted 2.6.31-rc1-cachefs #144
>> Call Trace:
>> =A0[<ffffffff810718d2>] ? oom_kill_process.clone.0+0xa9/0x245
>> =A0[<ffffffff81071b99>] ? __out_of_memory+0x12b/0x142
>> =A0[<ffffffff81071c1a>] ? out_of_memory+0x6a/0x94
>> =A0[<ffffffff810742e4>] ? __alloc_pages_nodemask+0x42e/0x51d
>> =A0[<ffffffff81031416>] ? copy_process+0x95/0x114f
>> =A0[<ffffffff8107443c>] ? __get_free_pages+0x12/0x4f
>> =A0[<ffffffff81031439>] ? copy_process+0xb8/0x114f
>> =A0[<ffffffff8108192e>] ? handle_mm_fault+0x5dd/0x62f
>> =A0[<ffffffff8103260f>] ? do_fork+0x13f/0x2ba
>> =A0[<ffffffff81022c22>] ? do_page_fault+0x1f8/0x20d
>> =A0[<ffffffff8100b0d3>] ? stub_clone+0x13/0x20
>> =A0[<ffffffff8100ad6b>] ? system_call_fastpath+0x16/0x1b
>> Mem-Info:
>> DMA per-cpu:
>> CPU =A0 =A00: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>> CPU =A0 =A01: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>> DMA32 per-cpu:
>> CPU =A0 =A00: hi: =A0186, btch: =A031 usd: 159
>> CPU =A0 =A01: hi: =A0186, btch: =A031 usd: =A0 2
>> Active_anon:70477 active_file:1 inactive_anon:4514
>> =A0inactive_file:7 unevictable:0 dirty:0 writeback:0 unstable:0
>> =A0free:1954 slab:42078 mapped:237 pagetables:57791 bounce:0
>
> ~170k pages unreclaimable and ~70k pages unaccounted for.
>
> This does not look like a reclaim problem?

OK. we need learn testcase more.

[read test program source code... ]

this program makes `cat /proc/sys/kernel/msgmni` * 10 processes.
At least, one process creation need one userland stack page (i.e. one anon)
+ one kernel stack page (i.e. one unaccount page) + one pagetable page.

In my 1GB box environment,  default msgmni is 11969.
Oh well, the system physical ram (255744) is less than needed pages (11969 =
* 3).

In addition, those processes call msgsnd(lrand48() % 99) 1000 times.
msgsnd makes one kmalloc. it mean kernel makes tons random size slab heap a=
nd
it become very fragment.

Ummm, I think  this test don't gurantee success on 1GB box.


note: I use distro kernel (Fedora11: kernel-2.6.29+ ).


>> DMA free:3932kB min:60kB low:72kB high:88kB active_anon:236kB inactive_a=
non:0kB active_file:4kB inactive_file:4kB unevictable:0kB present:15364kB p=
ages_scanned:0 all_unreclaimable? no
>> lowmem_reserve[]: 0 968 968 968
>> DMA32 free:3884kB min:3948kB low:4932kB high:5920kB active_anon:281672kB=
 inactive_anon:18056kB active_file:0kB inactive_file:24kB unevictable:0kB p=
resent:992032kB pages_scanned:6 all_unreclaimable? no
>> lowmem_reserve[]: 0 0 0 0
>> DMA: 180*4kB 36*8kB 3*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024k=
B 1*2048kB 0*4096kB =3D 3936kB
>> DMA32: 491*4kB 0*8kB 0*16kB 0*32kB 0*64kB 1*128kB 1*256kB 1*512kB 1*1024=
kB 0*2048kB 0*4096kB =3D 3884kB
>> 1808 total pagecache pages
>> 0 pages in swap cache
>> Swap cache stats: add 0, delete 0, find 0/0
>> Free swap =A0=3D 0kB
>> Total swap =3D 0kB
>> 255744 pages RAM
>> 5589 pages reserved
>> 249340 pages shared
>> 219039 pages non-shared
>> Out of memory: kill process 11471 (msgctl11) score 112393 or a child
>> Killed process 12318 (msgctl11)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
