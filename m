Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 77ECC6B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 12:52:33 -0400 (EDT)
Received: by mail-bk0-f44.google.com with SMTP id jk13so241107bkc.31
        for <linux-mm@kvack.org>; Fri, 29 Mar 2013 09:52:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130329152209.GC21879@dhcp22.suse.cz>
References: <CAKb7UviwOk9asT=WxYgDUzfm3J+tGXobroUycpoTvzOX5kkofQ@mail.gmail.com>
	<20130329152209.GC21879@dhcp22.suse.cz>
Date: Fri, 29 Mar 2013 12:52:31 -0400
Message-ID: <CAKb7Uvgm7y8T=u7q=eiio30ETiL2A_srgrpydr7dfRsU+rNpgg@mail.gmail.com>
Subject: Re: system death under oom - 3.7.9
From: Ilia Mirkin <imirkin@alum.mit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org

On Fri, Mar 29, 2013 at 11:22 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Wed 27-03-13 14:25:36, Ilia Mirkin wrote:
>> Hello,
>>
>> My system died last night apparently due to OOM conditions. Note that
>> I don't have any swap set up, but my understanding is that this is not
>> required. The full log is at: http://pastebin.com/YCYUXWvV. It was in
>> my messages, so I guess the system took a bit to die completely.
>
> This doesn't seem like OOM:
> [615185.810509] DMA32 free:130456kB min:36364kB low:45452kB high:54544kB =
active_anon:764604kB inactive_anon:13180kB active_file:1282040kB inactive_f=
ile:910648kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:=
3325056kB mlocked:0kB dirty:4472kB writeback:0kB mapped:42836kB shmem:14388=
kB slab_reclaimable:155160kB slab_unreclaimable:13620kB kernel_stack:576kB =
pagetables:8712kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pa=
ges_scanned:0 all_unreclaimable? no
> [615185.810511] lowmem_reserve[]: 0 0 2772 2772
> [615185.810517] Normal free:44288kB min:31044kB low:38804kB high:46564kB =
active_anon:2099560kB inactive_anon:14416kB active_file:271972kB inactive_f=
ile:69684kB unevictable:4kB isolated(anon):0kB isolated(file):0kB present:2=
838528kB mlocked:4kB dirty:12kB writeback:0kB mapped:107868kB shmem:17440kB=
 slab_reclaimable:87304kB slab_unreclaimable:45452kB kernel_stack:3648kB pa=
getables:42840kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pag=
es_scanned:196 all_unreclaimable? no
>
> You are above above high watermark in the DMA32 zone and slightly bellow
> high watermak in the Normal zone.
> Your driver requested
> [615185.810279] xlock: page allocation failure: order:4, mode:0xc0d0
>
> which is GFP_KERNEL |__GFP_COMP|__GFP_ZERO which doesn't look so unusual =
but
>
> [615185.810521] DMA: 0*4kB 0*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*5=
12kB 1*1024kB 1*2048kB 3*4096kB =3D 15888kB
> [615185.810527] DMA32: 5673*4kB 7213*8kB 2142*16kB 461*32kB 30*64kB 0*128=
kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 131340kB
> [615185.810532] Normal: 3382*4kB 3121*8kB 355*16kB 11*32kB 0*64kB 0*128kB=
 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 44528kB
>
> but you ran out of high order pages on DMA32 zone (and zone Normal looks
> even worse). There are only 30 order-4 pages and I suppose that the
> allocation failed on the watermark check for that order.
>
>> nouveau is somewhat implicated, as it is the first thing that hits an
>> allocation failure in nouveau_vm_create, and has a subsequent warn in
>> nouveau_mm_fini, but then there's a GPF in
>> __alloc_skb/__kmalloc_track_caller (and I'm using SLUB). Here is a
>> partial disassembly for __kmalloc_track_caller:
>
> I would start by checking whether the driver handles the allocation
> failure properly and it doesn't clobber slab data from other allocations
> (just a wild guess as I am not familiar with nouveau code at all).

I'm not particularly familiar with it, adding dri-devel as nouveau
appears to be a moderated list.

Glancing at the code, if nouveau_vm_create fails, the drm_open code
calls nouveau_cli_destroy, which in turn calls nouveau_mm_fini (down
the line) which triggered the WARN on my system. This in turn means
that some stuff doesn't get freed, but it shouldn't clobber slab data.
But there's probably more going on...

>
>>
>>    0xffffffff811325b1 <+138>:   e8 a0 60 56 00  callq
>> 0xffffffff81698656 <__slab_alloc.constprop.68>
>>    0xffffffff811325b6 <+143>:   49 89 c4        mov    %rax,%r12
>>    0xffffffff811325b9 <+146>:   eb 27   jmp    0xffffffff811325e2
>> <__kmalloc_track_caller+187>
>>    0xffffffff811325bb <+148>:   49 63 45 20     movslq 0x20(%r13),%rax
>>    0xffffffff811325bf <+152>:   48 8d 4a 01     lea    0x1(%rdx),%rcx
>>    0xffffffff811325c3 <+156>:   49 8b 7d 00     mov    0x0(%r13),%rdi
>>    0xffffffff811325c7 <+160>:   49 8b 1c 04     mov    (%r12,%rax,1),%rb=
x
>>    0xffffffff811325cb <+164>:   4c 89 e0        mov    %r12,%rax
>>    0xffffffff811325ce <+167>:   48 8d 37        lea    (%rdi),%rsi
>>    0xffffffff811325d1 <+170>:   e8 3a 38 1b 00  callq
>> 0xffffffff812e5e10 <this_cpu_cmpxchg16b_emu>
>>
>> The GPF happens at +160, which is in the argument setup for the
>> cmpxchg in slab_alloc_node. I think it's the call to
>> get_freepointer(). There was a similar bug report a while back,
>> https://lkml.org/lkml/2011/5/23/199, and the recommendation was to run
>> with slub debugging. Is that still the case, or is there a simpler
>> explanation? I can't reproduce this at will, not sure how many times
>> this has happened but definitely not many.
>>
>>   -ilia
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
