Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EFABA8D0040
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 13:45:18 -0400 (EDT)
Received: by wyf19 with SMTP id 19so2366481wyf.14
        for <linux-mm@kvack.org>; Sat, 26 Mar 2011 10:45:14 -0700 (PDT)
Subject: Re: [PATCH] slub: Disable the lockless allocator
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20110326114736.GA8251@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
	 <20110324142146.GA11682@elte.hu>
	 <alpine.DEB.2.00.1103240940570.32226@router.home>
	 <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
	 <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu>
	 <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6>
	 <20110324192247.GA5477@elte.hu>
	 <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com>
	 <20110326112725.GA28612@elte.hu>  <20110326114736.GA8251@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 26 Mar 2011 18:45:07 +0100
Message-ID: <1301161507.2979.105.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Le samedi 26 mars 2011 A  12:47 +0100, Ingo Molnar a A(C)crit :
> The commit below solves this crash for me. Could we please apply this simple 
> patch, until the real bug has been found, to keep upstream debuggable? The 
> eventual fix can then re-enable the lockless allocator.
> 
> Thanks,
> 
> 	Ingo
> 
> --------------->
> From bb764182707216faeb815c3bbdf6a9e9992a459a Mon Sep 17 00:00:00 2001
> From: Ingo Molnar <mingo@elte.hu>
> Date: Sat, 26 Mar 2011 12:40:30 +0100
> Subject: [PATCH] slub: Disable the lockless allocator
> 
> This boot crash:
> 
> Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
> Memory: 1011352k/1048512k available (11595k kernel code, 452k absent, 36708k reserved, 6343k data, 1024k init)
> BUG: unable to handle kernel paging request at ffff87ffc1fdd020
> IP: [<ffffffff812b50c2>] this_cpu_cmpxchg16b_emu+0x2/0x1c
> PGD 0
> Oops: 0000 [#1]
> last sysfs file:
> CPU 0
> Pid: 0, comm: swapper Not tainted 2.6.38-08569-g16c29da #110593 System manufacturer System Product Name/A8N-E
> RIP: 0010:[<ffffffff812b50c2>]  [<ffffffff812b50c2>] this_cpu_cmpxchg16b_emu+0x2/0x1c
> RSP: 0000:ffffffff82003e78  EFLAGS: 00010086
> RAX: ffff88003f8020c0 RBX: ffff88003f802180 RCX: 0000000000000002
> RDX: 0000000000000001 RSI: ffff88003ffc2020 RDI: ffffffff8219be43


Interesting. I am wondering if its not a per_cpu problem, or another
problem uncovered by lockless allocator ?


Old values of cmpxchg16b() :

RAX = ffff88003f8020c0 , RDX = 1

New values

RBX = ffff88003f802180 , RCX = 2

address : RSI = ffff88003ffc2020

RSI is supposed to be a dynamic percpu addr
Yet this value seems pretty outside of pcpu pools

CR2: ffff87ffc1fdd020

On my machine, if I add this patch to display cpu_slab values :

diff --git a/mm/slub.c b/mm/slub.c
index f881874..3b118f3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2364,7 +2364,7 @@ static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
 	/* Regular alignment is sufficient */
 	s->cpu_slab = alloc_percpu(struct kmem_cache_cpu);
 #endif
-
+	pr_err("cpu_slab=%p\n", s->cpu_slab);
 	if (!s->cpu_slab)
 		return 0;

I get following traces :

First ones are allocated from the static pcpu area (zero based)
Looks consistent with :
00000000000127c0 D __per_cpu_end

[    0.000000] cpu_slab=00000000000147c0
[    0.000000] cpu_slab=00000000000147e0
[    0.000000] cpu_slab=0000000000014800
[    0.000000] cpu_slab=0000000000014820
[    0.000000] cpu_slab=0000000000014840
[    0.000000] cpu_slab=0000000000014860
[    0.000000] cpu_slab=0000000000014880
[    0.000000] cpu_slab=00000000000148a0
[    0.000000] cpu_slab=00000000000148c0
[    0.000000] cpu_slab=00000000000148e0
[    0.000000] cpu_slab=0000000000014900
[    0.000000] cpu_slab=0000000000014920
[    0.000000] cpu_slab=0000000000014940
[    0.000000] cpu_slab=0000000000014960
[    0.000000] cpu_slab=0000000000014980
[    0.000000] cpu_slab=00000000000149a0
[    0.000000] cpu_slab=00000000000149c0
[    0.000000] cpu_slab=00000000000149e0
[    0.000000] cpu_slab=0000000000014a00
[    0.000000] cpu_slab=0000000000014a20
[    0.000000] cpu_slab=0000000000014a40
[    0.000000] cpu_slab=0000000000014a60
[    0.000000] cpu_slab=0000000000014a80
[    0.000000] cpu_slab=0000000000014aa0
[    0.000000] cpu_slab=0000000000014ac0
[    0.000000] cpu_slab=0000000000014ae0
[    0.000000] cpu_slab=0000000000014b00
[    0.000000] cpu_slab=0000000000014b20
[    0.000000] cpu_slab=0000000000014b40
[    0.000000] cpu_slab=0000000000014c80
[    0.000000] cpu_slab=0000000000017240
[    0.000000] cpu_slab=0000000000017260
[    0.000350] cpu_slab=0000000000017280
[    0.000461] cpu_slab=00000000000172a0
[    0.000573] cpu_slab=00000000000172c0
[    0.000684] cpu_slab=00000000000172e0
[    0.000797] cpu_slab=0000000000017300
[    0.000918] cpu_slab=0000000000017320
[    0.001031] cpu_slab=0000000000017340
[    0.001141] cpu_slab=0000000000017360
[    0.001253] cpu_slab=0000000000017380
[    0.001365] cpu_slab=00000000000173a0
[    0.001477] cpu_slab=00000000000173c0
[    0.001589] cpu_slab=00000000000173e0
[    0.001713] cpu_slab=0000000000017400
[    0.001833] cpu_slab=0000000000017420
[    0.001946] cpu_slab=0000000000017440
[    0.002057] cpu_slab=0000000000017460
[    0.003548] cpu_slab=0000000000017480
[    0.004380] cpu_slab=00000000000174a0
[    0.004508] cpu_slab=00000000000174d0
[    0.004727] cpu_slab=00000000000174f0
[    0.005006] cpu_slab=0000000000017550
[    0.005187] cpu_slab=0000000000017590
[    0.005345] cpu_slab=00000000000175c0
[    0.007824] cpu_slab=0000000000017600
[    0.007935] cpu_slab=0000000000017620
[    0.008048] cpu_slab=0000000000017640
[    0.008159] cpu_slab=0000000000017660
[    0.008271] cpu_slab=0000000000017680
[    1.496852] cpu_slab=00000000000177b0
[    1.497347] cpu_slab=0000000000017870
[    1.497509] cpu_slab=0000000000017890
[    1.497632] cpu_slab=00000000000178b0
[    1.497749] cpu_slab=00000000000178d0
[    1.497868] cpu_slab=0000000000017970
[    1.510931] cpu_slab=0000000000017a70
[    1.511000] cpu_slab=0000000000017a90
[    1.511068] cpu_slab=0000000000017ab0
[    1.511139] cpu_slab=0000000000017ad0
[    1.511208] cpu_slab=0000000000017c70
[    1.511430] cpu_slab=0000000000017c90
[    1.511543] cpu_slab=0000000000017cb0
[    1.511659] cpu_slab=0000000000017cd0
[    1.511816] cpu_slab=0000000000017d70
[    1.511929] cpu_slab=0000000000017d90
[    1.538272] cpu_slab=0000000000017db0
[    1.538384] cpu_slab=0000000000017dd0
[    1.538500] cpu_slab=0000000000017e70
[    1.538615] cpu_slab=0000000000017e90
[    1.538731] cpu_slab=0000000000017eb0
[    1.538851] cpu_slab=0000000000017ed0
[    1.555795] cpu_slab=0000000000017f70
[    1.555908] cpu_slab=0000000000017f90
[    1.578009] cpu_slab=0000000000017fc0
[    1.578122] cpu_slab=0000000000017fe0
[    1.578240] cpu_slab=0000000000018070
[    1.578352] cpu_slab=0000000000018090
[    1.578466] cpu_slab=00000000000180b0
[    1.578685] cpu_slab=00000000000180d0
[    1.578843] cpu_slab=00000000000181d0
[    1.579371] cpu_slab=0000000000018270
[    1.579453] cpu_slab=0000000000018290
[    1.579531] cpu_slab=00000000000182b0
[    1.579636] cpu_slab=00000000000182d0
[    1.580122] cpu_slab=0000000000019370
[    1.580202] cpu_slab=0000000000019390
[    1.580482] cpu_slab=0000000000019e20
[    1.606265] cpu_slab=0000000000019e40
[    1.606337] cpu_slab=0000000000019e60
[    1.606405] cpu_slab=0000000000019e80
[    1.633467] cpu_slab=0000000000019ea0
[    1.633622] cpu_slab=0000000000019ec0
[    1.633753] cpu_slab=0000000000019ee0
[    1.633881] cpu_slab=0000000000019f00
[    1.634013] cpu_slab=0000000000019f20
[    1.634139] cpu_slab=0000000000019f40
[    1.634294] cpu_slab=0000000000019f60
[    1.634582] cpu_slab=0000000000019f80
[    1.634918] cpu_slab=0000000000019fc0
[    1.635051] cpu_slab=0000000000019fe0

After exhaustion of static pcpu area we switch do vmalloc() based ones :

[    1.635175] cpu_slab=000060fee0002070
[    1.635324] cpu_slab=000060fee0002090
[    1.635445] cpu_slab=000060fee00020b0
[    1.635563] cpu_slab=000060fee00020d0
[    1.635690] cpu_slab=000060fee00020f0
[    1.635802] cpu_slab=000060fee0002110
[    1.635951] cpu_slab=000060fee0002140
[    1.636081] cpu_slab=000060fee0002170
[    1.636309] cpu_slab=000060fee0002190
[    1.636882] cpu_slab=000060fee00021d0
[    1.637257] cpu_slab=000060fee0002270
[    1.637381] cpu_slab=000060fee0002290
[    3.264327] cpu_slab=000060fee0002860
[    3.264465] cpu_slab=000060fee0002880
[    3.267217] cpu_slab=000060fee0002900
[    3.294910] cpu_slab=000060fee0002950
[    3.302653] cpu_slab=000060fee0002bb0
[    3.302783] cpu_slab=000060fee0002bd0
[    3.302899] cpu_slab=000060fee0002bf0
[    3.303033] cpu_slab=000060fee0002c10
[    3.303153] cpu_slab=000060fee0002c30
[    3.303268] cpu_slab=000060fee0002c50
[    3.303539] cpu_slab=000060fee0004f90
[    3.303675] cpu_slab=000060fee0004fb0
[    3.303811] cpu_slab=000060fee0005030
[    3.303939] cpu_slab=000060fee0005050

# grep pcpu_get_vm_areas /proc/vmallocinfo 
0xffffe8ff5fc00000-0xffffe8ff5fe00000 2097152 pcpu_get_vm_areas+0x0/0x580 vmalloc
0xffffe8ffffc00000-0xffffe8ffffe00000 2097152 pcpu_get_vm_areas+0x0/0x580 vmalloc



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
