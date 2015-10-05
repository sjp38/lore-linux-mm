Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0F01B82F66
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 15:26:46 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so188815839pac.2
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 12:26:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id kg6si18345799pad.12.2015.10.05.12.26.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 12:26:45 -0700 (PDT)
Date: Mon, 5 Oct 2015 21:26:39 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Message-ID: <20151005212639.35932b6c@redhat.com>
In-Reply-To: <20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
	<20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
	<20151002114118.75aae2f9@redhat.com>
	<20151002154039.69f82bdc@redhat.com>
	<20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Hannes Frederic Sowa <hannes@redhat.com>, brouer@redhat.com, Andi Kleen <ak@linux.intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>

On Fri, 2 Oct 2015 14:50:44 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 2 Oct 2015 15:40:39 +0200 Jesper Dangaard Brouer <brouer@redhat.c=
om> wrote:
>=20
> > > Thus, I need introducing new code like this patch and at the same time
> > > have to reduce the number of instruction-cache misses/usage.  In this
> > > case we solve the problem by kmem_cache_free_bulk() not getting called
> > > too often. Thus, +17 bytes will hopefully not matter too much... but =
on
> > > the other hand we sort-of know that calling kmem_cache_free_bulk() wi=
ll
> > > cause icache misses.
> >=20
> > I just tested this change on top of my net-use-case patchset... and for
> > some strange reason the code with this WARN_ON is faster and have much
> > less icache-misses (1,278,276 vs 2,719,158 L1-icache-load-misses).
> >=20
> > Thus, I think we should keep your fix.
> >=20
> > I cannot explain why using WARN_ON() is better and cause less icache
> > misses.  And I hate when I don't understand every detail.
> >=20
> >  My theory is, after reading the assembler code, that the UD2
> > instruction (from BUG_ON) cause some kind of icache decoder stall
> > (Intel experts???).  Now that should not be a problem, as UD2 is
> > obviously placed as an unlikely branch and left at the end of the asm
> > function call.  But the call to __slab_free() is also placed at the end
> > of the asm function (gets inlined from slab_free() as unlikely).  And
> > it is actually fairly likely that bulking is calling __slab_free (slub
> > slowpath call).
>=20
> Yes, I was looking at the asm code and the difference is pretty small:
> a not-taken ud2 versus a not-taken "call warn_slowpath_null", mainly.

Actually managed to find documentation that the UD2 instruction do
stops the instruction prefetcher.

=46rom "Intel=C2=AE 64 and IA-32 Architectures Optimization Reference Manual"
 Section 3.4.1.6 "Branch Type Selection":
 Cite:
  "[...] follow the indirect branch with a UD2 instruction, which will
   stop the processor from decoding down the fall-through path."

And from LWN article: https://lwn.net/Articles/255364/
 Cite: "[...] like using the ud2 instruction [...]. This instruction,
 which cannot be executed itself, is used after an indirect jump
 instruction; it is used as a signal to the instruction fetcher that
 the processor should not waste efforts decoding the following memory
 since the execution will continue at a different location."

Thus, we were hitting a very unfortunately combination of code, there
the UD2 instruction was located before the call to __slab_free() in the
ASM code, causing instruction prefetching to fail/stop.

Now I understand all the details again :-)

My only problem left, is I want a perf measurement that pinpoint these
kind of spots.  The difference in L1-icache-load-misses were significant
(1,278,276 vs 2,719,158).  I tried to somehow perf record this with
different perf events without being able to pinpoint the location (even
though I know the spot now).  Even tried Andi's ocperf.py... maybe he
will know what event I should try?


> But I wouldn't assume that the microbenchmarking is meaningful.  I've
> seen shockingly large (and quite repeatable) microbenchmarking
> differences from small changes in code which isn't even executed (and
> this is one such case, actually).  You add or remove just one byte of
> text and half the kernel (or half the .o file?) gets a different
> alignment and this seems to change everything.

I do know alignment of code is important, but this performance impact
was just too large.  And I think I found documentation to back my theory.

=20
> Deleting the BUG altogether sounds the best solution.  As long as the
> kernel crashes in some manner, we'll be able to work out what happened.
> And it's cant-happen anyway, isn't it?

To me WARN_ON() seems like a good "documentation" if it does not hurt
performance.  I don't think removing the WARN_ON() will improve
performance, but I'm willing to actually test if it matters.

Below is how it will crash, it is fairly obvious (if you know x86_64
call convention).=20

API is: void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void *=
*p)

Below it clearly shows second arg "size" in %RSI =3D=3D 0.

[ 2986.977708] BUG: unable to handle kernel paging request at ffffffffa03c4=
d58
[ 2986.977760] IP: [<ffffffff8116d044>] kmem_cache_free_bulk+0x54/0x1b0
[ 2986.977805] PGD 19a4067 PUD 19a5063 PMD 408a66067 PTE 3f6407161
[ 2986.977879] Oops: 0003 [#1] SMP=20
[ 2986.977936] Modules linked in: slab_bulk_test03(O+) time_bench(O) netcon=
sole tun coretemp kvm_intel kvm mxm_wmi microcode sg i2c_i801 i2c_core pcsp=
kr wmi video shpchp acpi_pad nfsd auth_rpcgss oid_registry nfs_acl lockd gr=
ace sunrpc serio_raw sd_mod hid_generic ixgbe mdio vxlan ip6_udp_tunnel e10=
00e udp_tunnel ptp pps_core mlx5_core [last unloaded: slab_bulk_test03]
[ 2986.978190] CPU: 1 PID: 12495 Comm: modprobe Tainted: G           O    4=
.3.0-rc2-net-next-mm+ #442
[ 2986.978265] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M.=
/Z97 Extreme4, BIOS P2.10 05/12/2015
[ 2986.978341] task: ffff88040a89d200 ti: ffff8803e3c50000 task.ti: ffff880=
3e3c50000
[ 2986.978414] RIP: 0010:[<ffffffff8116d044>]  [<ffffffff8116d044>] kmem_ca=
che_free_bulk+0x54/0x1b0
[ 2986.978490] RSP: 0018:ffff8803e3c53aa8  EFLAGS: 00010282
[ 2986.978528] RAX: 0000000000000000 RBX: ffff8803e3c53c30 RCX: 00000001002=
00016
[ 2986.978571] RDX: ffff8803e3c53ad8 RSI: 0000000000000000 RDI: 000077ff800=
00000
[ 2986.978614] RBP: ffff8803e3c53ad0 R08: ffff8803e3db3600 R09: 00000000e3d=
b3b01
[ 2986.978655] R10: ffffffffa03c4d58 R11: 0000000000000001 R12: fffffffffff=
fffff
[ 2986.978698] R13: ffff8803e3c53ae0 R14: 000077ff80000000 R15: ffff88040d7=
74c00
[ 2986.978740] FS:  00007fbf31190740(0000) GS:ffff88041fa40000(0000) knlGS:=
0000000000000000
[ 2986.978814] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2986.978853] CR2: ffffffffa03c4d58 CR3: 00000003f6406000 CR4: 00000000001=
406e0
[ 2986.978895] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 2986.978938] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 2986.978979] Stack:
[ 2986.979014]  ffff8803e3c53c30 0000000000000009 0000000000000000 ffffffff=
a002e000
[ 2986.979099]  ffff8803fc40db40 ffff8803e3c53cf0 ffffffffa03c4d58 00000000=
00000000
[ 2986.979184]  0000000000000000 0000000000000000 0000000000000000 00000000=
00000000
[ 2986.979259] Call Trace:
[ 2986.979296]  [<ffffffffa002e000>] ? 0xffffffffa002e000
[ 2986.979335]  [<ffffffffa03c4d58>] run_try_crash_tests+0x378/0x3a6 [slab_=
bulk_test03]
[ 2986.979409]  [<ffffffffa002e12d>] slab_bulk_test03_module_init+0x12d/0x1=
000 [slab_bulk_test03]
[ 2986.979485]  [<ffffffff810002ed>] do_one_initcall+0xad/0x1d0
[ 2986.979526]  [<ffffffff8111c117>] do_init_module+0x60/0x1e8
[ 2986.979567]  [<ffffffff810c2778>] load_module+0x1bb8/0x2420
[ 2986.979608]  [<ffffffff810bf1b0>] ? __symbol_put+0x40/0x40
[ 2986.979647]  [<ffffffff810c31b0>] SyS_finit_module+0x80/0xb0
[ 2986.979690]  [<ffffffff8166b697>] entry_SYSCALL_64_fastpath+0x12/0x6a
[ 2986.979732] Code: f8 eb 05 4d 85 e4 74 13 4c 8b 10 49 83 ec 01 48 89 c2 =
48 83 e8 08 4d 85 d2 74 e8 4d 85 d2 0f 84 2e 01 00 00 49 63 47 20 4c 89 f7 =
<49> c7 04 02 00 00 00 00 b8 00 00 00 80 4c 01 d0 48 0f 42 3d b4=20
[ 2986.979904] RIP  [<ffffffff8116d044>] kmem_cache_free_bulk+0x54/0x1b0
[ 2986.979945]  RSP <ffff8803e3c53aa8>
[ 2986.979982] CR2: ffffffffa03c4d58
[ 2986.980130] ---[ end trace 64f42b02f4347220 ]---


(gdb) list *(kmem_cache_free_bulk)+0x54
0xffffffff8116d044 is in kmem_cache_free_bulk (mm/slub.c:269).
264		return p;
265	}
266=09
267	static inline void set_freepointer(struct kmem_cache *s, void *object, =
void *fp)
268	{
269		*(void **)(object + s->offset) =3D fp;
270	}
271=09
272	/* Loop over all objects in a slab */
273	#define for_each_object(__p, __s, __addr, __objects) \


--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
