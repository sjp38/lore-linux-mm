From: Dominik Stadler <dominik.stadler@gmx.at>
Subject: Re: strange OOM receiving a wireless network
	packet on a SLUB system
Date: Thu, 5 Nov 2009 13:28:45 +0100
Message-ID: <c7a347a10911050428i7b2b5080y64f36f3cd8913ccc@mail.gmail.com>
References: <c7a347a10911041421u35b102behe0ed2d94506680c1@mail.gmail.com>
	<87zl71lt7l.fsf_-_@spindle.srvr.nix>
	<20091105094611.2081.A69D9226@jp.fujitsu.com>
Reply-To: TuxOnIce users' list <tuxonice-users@lists.tuxonice.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0529319248885295886=="
Return-path: <tuxonice-users-bounces@lists.tuxonice.net>
In-Reply-To: <20091105094611.2081.A69D9226@jp.fujitsu.com>
List-Unsubscribe: <http://lists.tuxonice.net/options/tuxonice-users>,
	<mailto:tuxonice-users-request@lists.tuxonice.net?subject=unsubscribe>
List-Archive: <http://lists.tuxonice.net/pipermail/tuxonice-users>
List-Post: <mailto:tuxonice-users@lists.tuxonice.net>
List-Help: <mailto:tuxonice-users-request@lists.tuxonice.net?subject=help>
List-Subscribe: <http://lists.tuxonice.net/listinfo/tuxonice-users>,
	<mailto:tuxonice-users-request@lists.tuxonice.net?subject=subscribe>
Sender: tuxonice-users-bounces@lists.tuxonice.net
Errors-To: tuxonice-users-bounces@lists.tuxonice.net
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux-Kernel-Mailing-List <linux-kernel@vger.kernel.org>, TuxOnIce users' list <tuxonice-users@lists.tuxonice.net>
List-Id: linux-mm.kvack.org

--===============0529319248885295886==
Content-Type: multipart/alternative; boundary=0016e6d7e32d5933b304779eded2

--0016e6d7e32d5933b304779eded2
Content-Type: text/plain; charset=ISO-8859-1

Hi,

Thanks for the detailed response, it was not killing my system, I was doing
a few things in parallel at that moment, but don't think base memory would
run out that easily. this is what went on:

- formatting an 500G USB disk with mkfs.ext3
- ripping a CD from the internal DVD drive
- looking for specific filename in the whole local disc with "find"

As Kenneth indicated it is a known issue in .31 and does not hugely affect
me, so no big deal for now.

Thanks... Dominik.

On Thu, Nov 5, 2009 at 2:21 AM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi
>
> (cc to linux-mm)
>
> > On 4 Nov 2009, Dominik Stadler stated:
> > > I just saw a very similar thing happening to me here, ThinkPad T500,
> Ubuntu
> > > 9.10, latest 3.0.1+TOI-Kernel from Karmic-PPA, I  have some other
> weirdness
> > > as well which I am not sure if TOI-related or Karmic, will do some
> > > Divide-And-Conquer analysis next to find out the root cause of these
> and
> > > report back.
> > >
> > > $ uname -a
> > > Linux XXXXXX 2.6.31-15-generic #49+tuxonice2-Ubuntu SMP Sat Oct 31
> 01:46:15
> > > UTC 2009 x86_64 GNU/Linux
> > >
> > > This is what I got just now:
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] swapper: page
> allocation
> > > failure. order:2, mode:0x4020
>
> This is only page allocation failure. not OOM.
> We don't gurantee GFP_ATOMIC allocation success.
>
> >
> > That doesn't really look similar to me (not a decompressor -22 error).
> > To me it looks more like you ran out of memory, or at least ran very
> close
> > to out: an order-2 allocation is not enormous (16Kb on x86) and should
> > definitely work after everything's been chucked out. (mode 0x4020 implies
> > a compound-page GFP_ATOMIC allocation, so it couldn't swap, but it
> > could certainly discard clean pages.)
>
> No. GFP_ATOMIC can't discard clean pages, anyway. because irq-context don't
> tolerate from reclaim latency.
>
> >
> > Did this happen at suspension time, resumption time,or what? It looks
> > like the kernel hadn't been up for long, so I guess we can rule out
> > really really bad arena fragmentation... but it was long enough that I
> > guess this was at suspension time?
> >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Pid: 0, comm: swapper
> > > Tainted: G         C 2.6.31-15-generic #49+tuxonice2-Ubuntu
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Call
> > > Trace:
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178]  <IRQ>
> > > [<ffffffff810f1abc>]
> > > __alloc_pages_slowpath+0x4cc/0x4e0
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffff810f1c1e>]
> > > __alloc_pages_nodemask+0x14e/0x150
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffff811230ca>]
> > > kmalloc_large_node+0x5a/0xb0
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffff81127275>]
> > > __kmalloc_node_track_caller+0x135/0x180
> >
> > This is SLUB stuff. Is SLUB production-ready yet? (I haven't been
> > following it.)
> >
> > (Networking, wireless, SLUB, no idea where to Cc this. I'll just Cc LKML
> > and see if anyone notices :) )
>
> SLUB is perfectly stable and usable for production.
>
> >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffffa0245899>]
> ?
> > > iwl_rx_allocate+0x1a9/0x230
> > > [iwlcore]
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffff8144088b>]
> > > __alloc_skb+0x7b/0x180
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffffa0245899>]
> > > iwl_rx_allocate+0x1a9/0x230
> > > [iwlcore]
> >
> > Wireless network packet reception leading to OOM. Not TuxOnIce, I'd say.
> > Certainly not the same problem as me: I don't even *have* any wireless
> > hardware (with my RSI, laptops might as well have razor blades on their
> > keys).
> >
> > (Why does it need a 16Kb contiguous region anyway?
>
> Dunno ;)
>
>
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffff81010e12>]
> ?
> > > cpu_idle+0xb2/0x100
> >
> > Idle, not suspending...
> >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Active_anon:365111
> > > active_file:88612 inactive_anon:162361
> >
> > Lots of inactive pages. Why were none chucked out?
> >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178]  inactive_file:243222
> > > unevictable:4 dirty:214598 writeback:320 unstable:0
> >
> > 214000+ dirty pages seems awfully high.
> >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178]  free:6876 slab:51582
> > > mapped:40147 pagetables:8440 bounce:0
> >
> > 6876 free pages, a reasonable-enough figure, yet it couldn't find four
> > in a row to receive a network packet? Seems unlikely.
> >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA
> free:15644kB
> > > min:28kB low:32kB high:40kB active_anon:12kB inactive_anon:32kB
> > > active_file:4kB inactive_file:208kB unevictable:0kB present:15336kB
> > > pages_scanned:0 all_unreclaimable? no
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] lowmem_reserve[]: 0
> 2958
> > > 3905 3905
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA32
> free:10124kB
> > > min:6044kB low:7552kB high:9064kB active_anon:1223088kB
> > > inactive_anon:367500kB active_file:218036kB inactive_file:833596kB
> > > unevictable:16kB present:3029636kB pages_scanned:0 all_unreclaimable?
> > > no
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] lowmem_reserve[]: 0 0
> 946
> > > 946
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 Normal
> free:1736kB
> > > min:1932kB low:2412kB high:2896kB active_anon:237344kB
> > > inactive_anon:281912kB active_file:136408kB inactive_file:139084kB
> > > unevictable:0kB present:969600kB pages_scanned:0 all_unreclaimable?
> > > no
> >
> > Again, heaps of inactive.
>
> On normal zone, free(1736kB) < min(1932kB). It mean we can't use normal
> zone.
> On DMA32 zone, free(10124kB) < min(6044kB) + lowmem_reserve(946*4kB).
> It mean we can't use DMA32 zone too.
> Of cource, DMA zone is protected by lowmem_reserve too.
>
> It's normal memory shortage.
>
> >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] lowmem_reserve[]: 0 0
> 0
> > > 0
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA: 7*4kB
> 4*8kB
> > > 2*16kB 2*32kB 2*64kB 2*128kB 3*256kB 2*512kB 3*1024kB 3*2048kB 1*4096kB
> 15644kB
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA32: 2249*4kB
> > > 35*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB
> > > 0*4096kB = 10124kB
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 Normal: 132*4kB
> > > 127*8kB 2*16kB 1*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB
> > > 0*4096kB = 1736kB
>
> All zones have order-2 contenious memory.
>
>
> The conclusion is, the system is not so fragmentaion. but It doesn't have
> enough memory.
> Maybe, the system is under temporal memory pressure. you don't need care
> it.
> It automatically restored soon.
>
>
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] 390803 total pagecache
> > > pages
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] 12039 pages in swap
> > > cache
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Swap cache stats: add
> > > 41296, delete 29257, find
> > > 4825/7516
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Free swap  8330844kB
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] Total swap 8393952kB
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] 1032192 pages
> > > RAM
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] 76928 pages
> > > reserved
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] 488347 pages
> > > shared
> > >
> > > Nov  4 22:40:22 dstathink kernel: [39835.951178] 596692 pages
> non-shared
> >
> > OK, I don't know why this failed, but I'm an mm neophyte running on pure
> > grep. Any ideas from anyone with an actual clue in this area? (I know OOM
> > is all the rage right now, so maybe this will garner some attention :) )
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel"
> in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
>
>
>

--0016e6d7e32d5933b304779eded2
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi, <br><br>Thanks for the detailed response, it was not killing my system,=
 I was doing a few things in parallel at that moment, but don&#39;t think b=
ase memory would run out that easily. this is what went on:<br><br>- format=
ting an 500G USB disk with mkfs.ext3<br>

- ripping a CD from the internal DVD drive<br>- looking for specific filena=
me in the whole local disc with &quot;find&quot;<br><br>As Kenneth indicate=
d it is a known issue in .31 and does not hugely affect me, so no big deal =
for now.<br>
<br>Thanks... Dominik.<br><br><div class=3D"gmail_quote">On Thu, Nov 5, 200=
9 at 2:21 AM, KOSAKI Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosak=
i.motohiro@jp.fujitsu.com" target=3D"_blank">kosaki.motohiro@jp.fujitsu.com=
</a>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"border-left: 1px solid rgb(204, =
204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">Hi<br>
<br>
(cc to linux-mm)<br>
<div><br>
&gt; On 4 Nov 2009, Dominik Stadler stated:<br>
&gt; &gt; I just saw a very similar thing happening to me here, ThinkPad T5=
00, Ubuntu<br>
&gt; &gt; 9.10, latest 3.0.1+TOI-Kernel from Karmic-PPA, I =A0have some oth=
er weirdness<br>
&gt; &gt; as well which I am not sure if TOI-related or Karmic, will do som=
e<br>
&gt; &gt; Divide-And-Conquer analysis next to find out the root cause of th=
ese and<br>
&gt; &gt; report back.<br>
&gt; &gt;<br>
&gt; &gt; $ uname -a<br>
&gt; &gt; Linux XXXXXX 2.6.31-15-generic #49+tuxonice2-Ubuntu SMP Sat Oct 3=
1 01:46:15<br>
&gt; &gt; UTC 2009 x86_64 GNU/Linux<br>
&gt; &gt;<br>
&gt; &gt; This is what I got just now:<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] swapper: page =
allocation<br>
&gt; &gt; failure. order:2, mode:0x4020<br>
<br>
</div>This is only page allocation failure. not OOM.<br>
We don&#39;t gurantee GFP_ATOMIC allocation success.<br>
<div><br>
&gt;<br>
&gt; That doesn&#39;t really look similar to me (not a decompressor -22 err=
or).<br>
&gt; To me it looks more like you ran out of memory, or at least ran very c=
lose<br>
&gt; to out: an order-2 allocation is not enormous (16Kb on x86) and should=
<br>
&gt; definitely work after everything&#39;s been chucked out. (mode 0x4020 =
implies<br>
&gt; a compound-page GFP_ATOMIC allocation, so it couldn&#39;t swap, but it=
<br>
&gt; could certainly discard clean pages.)<br>
<br>
</div>No. GFP_ATOMIC can&#39;t discard clean pages, anyway. because irq-con=
text don&#39;t<br>
tolerate from reclaim latency.<br>
<div><br>
&gt;<br>
&gt; Did this happen at suspension time, resumption time,or what? It looks<=
br>
&gt; like the kernel hadn&#39;t been up for long, so I guess we can rule ou=
t<br>
&gt; really really bad arena fragmentation... but it was long enough that I=
<br>
&gt; guess this was at suspension time?<br>
&gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Pid: 0, comm: =
swapper<br>
&gt; &gt; Tainted: G =A0 =A0 =A0 =A0 C 2.6.31-15-generic #49+tuxonice2-Ubun=
tu<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Call<br>
&gt; &gt; Trace:<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] =A0&lt;IRQ&gt;=
<br>
&gt; &gt; [&lt;ffffffff810f1abc&gt;]<br>
&gt; &gt; __alloc_pages_slowpath+0x4cc/0x4e0<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] =A0[&lt;ffffff=
ff810f1c1e&gt;]<br>
&gt; &gt; __alloc_pages_nodemask+0x14e/0x150<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] =A0[&lt;ffffff=
ff811230ca&gt;]<br>
&gt; &gt; kmalloc_large_node+0x5a/0xb0<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] =A0[&lt;ffffff=
ff81127275&gt;]<br>
&gt; &gt; __kmalloc_node_track_caller+0x135/0x180<br>
&gt;<br>
&gt; This is SLUB stuff. Is SLUB production-ready yet? (I haven&#39;t been<=
br>
&gt; following it.)<br>
&gt;<br>
&gt; (Networking, wireless, SLUB, no idea where to Cc this. I&#39;ll just C=
c LKML<br>
&gt; and see if anyone notices :) )<br>
<br>
</div>SLUB is perfectly stable and usable for production.<br>
<div><br>
&gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] =A0[&lt;ffffff=
ffa0245899&gt;] ?<br>
&gt; &gt; iwl_rx_allocate+0x1a9/0x230<br>
&gt; &gt; [iwlcore]<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] =A0[&lt;ffffff=
ff8144088b&gt;]<br>
&gt; &gt; __alloc_skb+0x7b/0x180<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] =A0[&lt;ffffff=
ffa0245899&gt;]<br>
&gt; &gt; iwl_rx_allocate+0x1a9/0x230<br>
&gt; &gt; [iwlcore]<br>
&gt;<br>
&gt; Wireless network packet reception leading to OOM. Not TuxOnIce, I&#39;=
d say.<br>
&gt; Certainly not the same problem as me: I don&#39;t even *have* any wire=
less<br>
&gt; hardware (with my RSI, laptops might as well have razor blades on thei=
r<br>
&gt; keys).<br>
&gt;<br>
&gt; (Why does it need a 16Kb contiguous region anyway?<br>
<br>
</div>Dunno ;)<br>
<div><div></div><div><br>
<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] =A0[&lt;ffffff=
ff81010e12&gt;] ?<br>
&gt; &gt; cpu_idle+0xb2/0x100<br>
&gt;<br>
&gt; Idle, not suspending...<br>
&gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Active_anon:36=
5111<br>
&gt; &gt; active_file:88612 inactive_anon:162361<br>
&gt;<br>
&gt; Lots of inactive pages. Why were none chucked out?<br>
&gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] =A0inactive_fi=
le:243222<br>
&gt; &gt; unevictable:4 dirty:214598 writeback:320 unstable:0<br>
&gt;<br>
&gt; 214000+ dirty pages seems awfully high.<br>
&gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] =A0free:6876 s=
lab:51582<br>
&gt; &gt; mapped:40147 pagetables:8440 bounce:0<br>
&gt;<br>
&gt; 6876 free pages, a reasonable-enough figure, yet it couldn&#39;t find =
four<br>
&gt; in a row to receive a network packet? Seems unlikely.<br>
&gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA fre=
e:15644kB<br>
&gt; &gt; min:28kB low:32kB high:40kB active_anon:12kB inactive_anon:32kB<b=
r>
&gt; &gt; active_file:4kB inactive_file:208kB unevictable:0kB present:15336=
kB<br>
&gt; &gt; pages_scanned:0 all_unreclaimable? no<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] lowmem_reserve=
[]: 0 2958<br>
&gt; &gt; 3905 3905<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA32 f=
ree:10124kB<br>
&gt; &gt; min:6044kB low:7552kB high:9064kB active_anon:1223088kB<br>
&gt; &gt; inactive_anon:367500kB active_file:218036kB inactive_file:833596k=
B<br>
&gt; &gt; unevictable:16kB present:3029636kB pages_scanned:0 all_unreclaima=
ble?<br>
&gt; &gt; no<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] lowmem_reserve=
[]: 0 0 946<br>
&gt; &gt; 946<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Node 0 Normal =
free:1736kB<br>
&gt; &gt; min:1932kB low:2412kB high:2896kB active_anon:237344kB<br>
&gt; &gt; inactive_anon:281912kB active_file:136408kB inactive_file:139084k=
B<br>
&gt; &gt; unevictable:0kB present:969600kB pages_scanned:0 all_unreclaimabl=
e?<br>
&gt; &gt; no<br>
&gt;<br>
&gt; Again, heaps of inactive.<br>
<br>
</div></div>On normal zone, free(1736kB) &lt; min(1932kB). It mean we can&#=
39;t use normal zone.<br>
On DMA32 zone, free(10124kB) &lt; min(6044kB) + lowmem_reserve(946*4kB).<br=
>
It mean we can&#39;t use DMA32 zone too.<br>
Of cource, DMA zone is protected by lowmem_reserve too.<br>
<br>
It&#39;s normal memory shortage.<br>
<div><br>
&gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] lowmem_reserve=
[]: 0 0 0<br>
&gt; &gt; 0<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA: 7*=
4kB 4*8kB<br>
&gt; &gt; 2*16kB 2*32kB 2*64kB 2*128kB 3*256kB 2*512kB 3*1024kB 3*2048kB 1*=
4096kB 15644kB<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA32: =
2249*4kB<br>
&gt; &gt; 35*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*20=
48kB<br>
&gt; &gt; 0*4096kB =3D 10124kB<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Node 0 Normal:=
 132*4kB<br>
&gt; &gt; 127*8kB 2*16kB 1*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2=
048kB<br>
&gt; &gt; 0*4096kB =3D 1736kB<br>
<br>
</div>All zones have order-2 contenious memory.<br>
<br>
<br>
The conclusion is, the system is not so fragmentaion. but It doesn&#39;t ha=
ve<br>
enough memory.<br>
Maybe, the system is under temporal memory pressure. you don&#39;t need car=
e it.<br>
It automatically restored soon.<br>
<div><br>
<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] 390803 total p=
agecache<br>
&gt; &gt; pages<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] 12039 pages in=
 swap<br>
&gt; &gt; cache<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Swap cache sta=
ts: add<br>
&gt; &gt; 41296, delete 29257, find<br>
&gt; &gt; 4825/7516<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Free swap =A08=
330844kB<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] Total swap 839=
3952kB<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] 1032192 pages<=
br>
&gt; &gt; RAM<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] 76928 pages<br=
>
&gt; &gt; reserved<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] 488347 pages<b=
r>
&gt; &gt; shared<br>
&gt; &gt;<br>
&gt; &gt; Nov =A04 22:40:22 dstathink kernel: [39835.951178] 596692 pages n=
on-shared<br>
&gt;<br>
&gt; OK, I don&#39;t know why this failed, but I&#39;m an mm neophyte runni=
ng on pure<br>
&gt; grep. Any ideas from anyone with an actual clue in this area? (I know =
OOM<br>
&gt; is all the rage right now, so maybe this will garner some attention :)=
 )<br>
</div>&gt; --<br>
&gt; To unsubscribe from this list: send the line &quot;unsubscribe linux-k=
ernel&quot; in<br>
&gt; the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org" =
target=3D"_blank">majordomo@vger.kernel.org</a><br>
&gt; More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-=
info.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a>=
<br>
&gt; Please read the FAQ at =A0<a href=3D"http://www.tux.org/lkml/" target=
=3D"_blank">http://www.tux.org/lkml/</a><br>
<br>
<br>
</blockquote></div><br>

--0016e6d7e32d5933b304779eded2--

--===============0529319248885295886==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
TuxOnIce-users mailing list
TuxOnIce-users@lists.tuxonice.net
http://lists.tuxonice.net/listinfo/tuxonice-users
--===============0529319248885295886==--
