Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5892F6B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 18:53:19 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id j202so6543728qke.2
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 15:53:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7sor6825650qtk.65.2017.11.13.15.53.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Nov 2017 15:53:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <9631b871-99cc-82bb-363f-9d429b56f5b9@gmail.com>
References: <9631b871-99cc-82bb-363f-9d429b56f5b9@gmail.com>
From: Yang Shi <shy828301@gmail.com>
Date: Mon, 13 Nov 2017 15:53:16 -0800
Message-ID: <CAHbLzkpYD2w2s07tdcdAY3kLB-6RXBnO1xc1KR37s=U7VWJOMw@mail.gmail.com>
Subject: Re: Allocation failure of ring buffer for trace
Content-Type: multipart/alternative; boundary="001a114553f06b08e6055de5f9eb"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, rostedt@goodmis.org, mingo@kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, koki.sanagi@us.fujitsu.com

--001a114553f06b08e6055de5f9eb
Content-Type: text/plain; charset="UTF-8"

AFAIK, CONFIG_DEFERRED_STRUCT_PAGE_INIT will just initialize a small amount
of page structs, then defer the remaining page structs initialization to
kernel threads (one thread per node, called pgdatinit0/1/2/3). So, if your
trace buffer allocation is *before* the kernel threads finishing the page
struct initialization, you may run into this case.

Yang

On Mon, Nov 13, 2017 at 9:48 AM, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
wrote:

> When using trace_buf_size= boot option, memory allocation of ring buffer
> for trace fails as follows:
>
> [ ] x86: Booting SMP configuration:
> [ ] .... node  #0, CPUs:          #1   #2   #3   #4   #5   #6   #7   #8
>  #9  #10  #11  #12  #13  #14  #15  #16  #17  #18  #19  #20  #21  #22  #23
> [ ] .... node  #1, CPUs:    #24  #25  #26  #27  #28  #29  #30  #31  #32
> #33  #34  #35  #36  #37  #38  #39  #40  #41  #42  #43  #44  #45  #46  #47
> [ ] .... node  #2, CPUs:    #48  #49  #50  #51  #52  #53  #54  #55  #56
> #57  #58  #59  #60  #61  #62  #63  #64  #65  #66  #67  #68  #69  #70  #71
> [ ] .... node  #3, CPUs:    #72  #73  #74  #75  #76  #77  #78  #79  #80
> #81  #82  #83  #84  #85  #86  #87  #88  #89  #90  #91  #92  #93  #94  #95
> [ ] .... node  #4, CPUs:    #96  #97  #98  #99 #100 #101 #102 #103 #104
> #105 #106 #107 #108 #109 #110 #111 #112 #113 #114 #115 #116 #117 #118 #119
> [ ] .... node  #5, CPUs:   #120 #121 #122 #123 #124 #125 #126 #127 #128
> #129 #130 #131 #132 #133 #134 #135 #136 #137 #138 #139 #140 #141 #142 #143
> [ ] .... node  #6, CPUs:   #144 #145 #146 #147 #148 #149 #150 #151 #152
> #153 #154
> [ ] swapper/0: page allocation failure: order:0,
> mode:0x16004c0(GFP_KERNEL|__GFP_RETRY_MAYFAIL|__GFP_NOTRACK),
> nodemask=(null)
> [ ] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.14.0-rc8+ #13
> [ ] Hardware name: ...
> [ ] Call Trace:
> [ ]  dump_stack+0x63/0x89
> [ ]  warn_alloc+0x114/0x1c0
> [ ]  ? _find_next_bit+0x60/0x60
> [ ]  __alloc_pages_slowpath+0x9a6/0xba7
> [ ]  __alloc_pages_nodemask+0x26a/0x290
> [ ]  new_slab+0x297/0x500
> [ ]  ___slab_alloc+0x335/0x4a0
> [ ]  ? __rb_allocate_pages+0xae/0x180
> [ ]  ? __rb_allocate_pages+0xae/0x180
> [ ]  __slab_alloc+0x40/0x66
> [ ]  __kmalloc_node+0xbd/0x270
> [ ]  __rb_allocate_pages+0xae/0x180
> [ ]  rb_allocate_cpu_buffer+0x204/0x2f0
> [ ]  trace_rb_cpu_prepare+0x7e/0xc5
> [ ]  cpuhp_invoke_callback+0x3ea/0x5c0
> [ ]  ? init_idle+0x1a7/0x1c0
> [ ]  ? ring_buffer_record_is_on+0x20/0x20
> [ ]  _cpu_up+0xbc/0x190
> [ ]  do_cpu_up+0x87/0xb0
> [ ]  cpu_up+0x13/0x20
> [ ]  smp_init+0x69/0xca
> [ ]  kernel_init_freeable+0x115/0x244
> [ ]  ? rest_init+0xb0/0xb0
> [ ]  kernel_init+0xe/0x109
> [ ]  ret_from_fork+0x25/0x30
> [ ] Mem-Info:
> [ ] active_anon:0 inactive_anon:0 isolated_anon:0
> [ ]  active_file:0 inactive_file:0 isolated_file:0
> [ ]  unevictable:0 dirty:0 writeback:0 unstable:0
> [ ]  slab_reclaimable:1260 slab_unreclaimable:489185
> [ ]  mapped:0 shmem:0 pagetables:0 bounce:0
> [ ]  free:46 free_pcp:1421 free_cma:0
> .
> [ ] failed to allocate ring buffer on CPU 155
>
> In my server, there are 384 CPUs, 512 GB memory and 8 nodes. And
> "trace_buf_size=100M" is set.
>
> When using trace_buf_size=100M, kernel allocates 100 MB memory
> per CPU before calling free_are_init_core(). Kernel tries to
> allocates 38.4GB (100 MB * 384 CPU) memory. But available memory
> at this time is about 16GB (2 GB * 8 nodes) due to the following commit:
>
>   3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages
>                  if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")
>
> So allocation failure occurs.
>
> Thanks,
> Yasuaki Ishimatsu
>

--001a114553f06b08e6055de5f9eb
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">AFAIK,=C2=A0<span style=3D"font-size:12.8px">CONFIG_DEFERR=
ED_STRUCT_PAGE_</span><wbr style=3D"font-size:12.8px"><span style=3D"font-s=
ize:12.8px">INIT will just initialize a small amount of page structs, then =
defer the remaining page structs initialization to kernel threads (one thre=
ad per node, called pgdatinit0/1/2/3). So, if your trace buffer allocation =
is *before* the kernel threads finishing the page struct initialization, yo=
u may run into this case.</span><div><span style=3D"font-size:12.8px"><br><=
/span></div><div><span style=3D"font-size:12.8px">Yang</span></div></div><d=
iv class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Mon, Nov 13, 201=
7 at 9:48 AM, YASUAKI ISHIMATSU <span dir=3D"ltr">&lt;<a href=3D"mailto:yas=
u.isimatu@gmail.com" target=3D"_blank">yasu.isimatu@gmail.com</a>&gt;</span=
> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex">When using trace_buf_size=3D boo=
t option, memory allocation of ring buffer<br>
for trace fails as follows:<br>
<br>
[ ] x86: Booting SMP configuration:<br>
[ ] .... node=C2=A0 #0, CPUs:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 #1=C2=A0 =
=C2=A0#2=C2=A0 =C2=A0#3=C2=A0 =C2=A0#4=C2=A0 =C2=A0#5=C2=A0 =C2=A0#6=C2=A0 =
=C2=A0#7=C2=A0 =C2=A0#8=C2=A0 =C2=A0#9=C2=A0 #10=C2=A0 #11=C2=A0 #12=C2=A0 =
#13=C2=A0 #14=C2=A0 #15=C2=A0 #16=C2=A0 #17=C2=A0 #18=C2=A0 #19=C2=A0 #20=
=C2=A0 #21=C2=A0 #22=C2=A0 #23<br>
[ ] .... node=C2=A0 #1, CPUs:=C2=A0 =C2=A0 #24=C2=A0 #25=C2=A0 #26=C2=A0 #2=
7=C2=A0 #28=C2=A0 #29=C2=A0 #30=C2=A0 #31=C2=A0 #32=C2=A0 #33=C2=A0 #34=C2=
=A0 #35=C2=A0 #36=C2=A0 #37=C2=A0 #38=C2=A0 #39=C2=A0 #40=C2=A0 #41=C2=A0 #=
42=C2=A0 #43=C2=A0 #44=C2=A0 #45=C2=A0 #46=C2=A0 #47<br>
[ ] .... node=C2=A0 #2, CPUs:=C2=A0 =C2=A0 #48=C2=A0 #49=C2=A0 #50=C2=A0 #5=
1=C2=A0 #52=C2=A0 #53=C2=A0 #54=C2=A0 #55=C2=A0 #56=C2=A0 #57=C2=A0 #58=C2=
=A0 #59=C2=A0 #60=C2=A0 #61=C2=A0 #62=C2=A0 #63=C2=A0 #64=C2=A0 #65=C2=A0 #=
66=C2=A0 #67=C2=A0 #68=C2=A0 #69=C2=A0 #70=C2=A0 #71<br>
[ ] .... node=C2=A0 #3, CPUs:=C2=A0 =C2=A0 #72=C2=A0 #73=C2=A0 #74=C2=A0 #7=
5=C2=A0 #76=C2=A0 #77=C2=A0 #78=C2=A0 #79=C2=A0 #80=C2=A0 #81=C2=A0 #82=C2=
=A0 #83=C2=A0 #84=C2=A0 #85=C2=A0 #86=C2=A0 #87=C2=A0 #88=C2=A0 #89=C2=A0 #=
90=C2=A0 #91=C2=A0 #92=C2=A0 #93=C2=A0 #94=C2=A0 #95<br>
[ ] .... node=C2=A0 #4, CPUs:=C2=A0 =C2=A0 #96=C2=A0 #97=C2=A0 #98=C2=A0 #9=
9 #100 #101 #102 #103 #104 #105 #106 #107 #108 #109 #110 #111 #112 #113 #11=
4 #115 #116 #117 #118 #119<br>
[ ] .... node=C2=A0 #5, CPUs:=C2=A0 =C2=A0#120 #121 #122 #123 #124 #125 #12=
6 #127 #128 #129 #130 #131 #132 #133 #134 #135 #136 #137 #138 #139 #140 #14=
1 #142 #143<br>
[ ] .... node=C2=A0 #6, CPUs:=C2=A0 =C2=A0#144 #145 #146 #147 #148 #149 #15=
0 #151 #152 #153 #154<br>
[ ] swapper/0: page allocation failure: order:0, mode:0x16004c0(GFP_KERNEL|=
__<wbr>GFP_RETRY_MAYFAIL|__GFP_<wbr>NOTRACK), nodemask=3D(null)<br>
[ ] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.14.0-rc8+ #13<br>
[ ] Hardware name: ...<br>
[ ] Call Trace:<br>
[ ]=C2=A0 dump_stack+0x63/0x89<br>
[ ]=C2=A0 warn_alloc+0x114/0x1c0<br>
[ ]=C2=A0 ? _find_next_bit+0x60/0x60<br>
[ ]=C2=A0 __alloc_pages_slowpath+0x9a6/<wbr>0xba7<br>
[ ]=C2=A0 __alloc_pages_nodemask+0x26a/<wbr>0x290<br>
[ ]=C2=A0 new_slab+0x297/0x500<br>
[ ]=C2=A0 ___slab_alloc+0x335/0x4a0<br>
[ ]=C2=A0 ? __rb_allocate_pages+0xae/0x180<br>
[ ]=C2=A0 ? __rb_allocate_pages+0xae/0x180<br>
[ ]=C2=A0 __slab_alloc+0x40/0x66<br>
[ ]=C2=A0 __kmalloc_node+0xbd/0x270<br>
[ ]=C2=A0 __rb_allocate_pages+0xae/0x180<br>
[ ]=C2=A0 rb_allocate_cpu_buffer+0x204/<wbr>0x2f0<br>
[ ]=C2=A0 trace_rb_cpu_prepare+0x7e/0xc5<br>
[ ]=C2=A0 cpuhp_invoke_callback+0x3ea/<wbr>0x5c0<br>
[ ]=C2=A0 ? init_idle+0x1a7/0x1c0<br>
[ ]=C2=A0 ? ring_buffer_record_is_on+0x20/<wbr>0x20<br>
[ ]=C2=A0 _cpu_up+0xbc/0x190<br>
[ ]=C2=A0 do_cpu_up+0x87/0xb0<br>
[ ]=C2=A0 cpu_up+0x13/0x20<br>
[ ]=C2=A0 smp_init+0x69/0xca<br>
[ ]=C2=A0 kernel_init_freeable+0x115/<wbr>0x244<br>
[ ]=C2=A0 ? rest_init+0xb0/0xb0<br>
[ ]=C2=A0 kernel_init+0xe/0x109<br>
[ ]=C2=A0 ret_from_fork+0x25/0x30<br>
[ ] Mem-Info:<br>
[ ] active_anon:0 inactive_anon:0 isolated_anon:0<br>
[ ]=C2=A0 active_file:0 inactive_file:0 isolated_file:0<br>
[ ]=C2=A0 unevictable:0 dirty:0 writeback:0 unstable:0<br>
[ ]=C2=A0 slab_reclaimable:1260 slab_unreclaimable:489185<br>
[ ]=C2=A0 mapped:0 shmem:0 pagetables:0 bounce:0<br>
[ ]=C2=A0 free:46 free_pcp:1421 free_cma:0<br>
.<br>
[ ] failed to allocate ring buffer on CPU 155<br>
<br>
In my server, there are 384 CPUs, 512 GB memory and 8 nodes. And<br>
&quot;trace_buf_size=3D100M&quot; is set.<br>
<br>
When using trace_buf_size=3D100M, kernel allocates 100 MB memory<br>
per CPU before calling free_are_init_core(). Kernel tries to<br>
allocates 38.4GB (100 MB * 384 CPU) memory. But available memory<br>
at this time is about 16GB (2 GB * 8 nodes) due to the following commit:<br=
>
<br>
=C2=A0 3a80a7fa7989 (&quot;mm: meminit: initialise a subset of struct pages=
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if CONFIG_DEF=
ERRED_STRUCT_PAGE_<wbr>INIT is set&quot;)<br>
<br>
So allocation failure occurs.<br>
<br>
Thanks,<br>
Yasuaki Ishimatsu<br>
</blockquote></div><br></div>

--001a114553f06b08e6055de5f9eb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
