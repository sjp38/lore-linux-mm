Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id BD9216B0039
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 15:53:34 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so3221298igb.10
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 12:53:34 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id h8si21279120icv.33.2014.07.21.12.53.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 12:53:34 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id tr6so7234893ieb.21
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 12:53:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140721174218.GD4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
	<1405064267-11678-16-git-send-email-jiang.liu@linux.intel.com>
	<20140721174218.GD4156@linux.vnet.ibm.com>
Date: Mon, 21 Jul 2014 12:53:33 -0700
Message-ID: <CAKgT0UdZdbduP-=R7uRCxJVxt1yCDoHpnercnDoyrCbWNtx=6Q@mail.gmail.com>
Subject: Re: [RFC Patch V1 15/30] mm, igb: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
From: Alexander Duyck <alexander.duyck@gmail.com>
Content-Type: multipart/alternative; boundary=089e013d06e649da2f04feb97643
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Bruce Allan <bruce.w.allan@intel.com>, Carolyn Wyborny <carolyn.wyborny@intel.com>, Don Skidmore <donald.c.skidmore@intel.com>, Greg Rose <gregory.v.rose@intel.com>, Alex Duyck <alexander.h.duyck@intel.com>, John Ronciak <john.ronciak@intel.com>, Mitch Williams <mitch.a.williams@intel.com>, Linux NICS <linux.nics@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>

--089e013d06e649da2f04feb97643
Content-Type: text/plain; charset=UTF-8

I do agree the description should probably be changed.  There shouldn't be
any panics involved, only a performance impact as it will be reallocating
always if it is on a node with no memory.

My intention on this was to make certain that the memory used is from the
closest node possible.  As such I believe this change likely honours that.

Thanks,

Alex


On Mon, Jul 21, 2014 at 10:42 AM, Nishanth Aravamudan <
nacc@linux.vnet.ibm.com> wrote:

> On 11.07.2014 [15:37:32 +0800], Jiang Liu wrote:
> > When CONFIG_HAVE_MEMORYLESS_NODES is enabled,
> cpu_to_node()/numa_node_id()
> > may return a node without memory, and later cause system failure/panic
> > when calling kmalloc_node() and friends with returned node id.
> > So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
> > memory for the/current cpu.
> >
> > If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
> > is the same as cpu_to_node()/numa_node_id().
> >
> > Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> > ---
> >  drivers/net/ethernet/intel/igb/igb_main.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> b/drivers/net/ethernet/intel/igb/igb_main.c
> > index f145adbb55ac..2b74bffa5648 100644
> > --- a/drivers/net/ethernet/intel/igb/igb_main.c
> > +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> > @@ -6518,7 +6518,7 @@ static bool igb_can_reuse_rx_page(struct
> igb_rx_buffer *rx_buffer,
> >                                 unsigned int truesize)
> >  {
> >       /* avoid re-using remote pages */
> > -     if (unlikely(page_to_nid(page) != numa_node_id()))
> > +     if (unlikely(page_to_nid(page) != numa_mem_id()))
> >               return false;
> >
> >  #if (PAGE_SIZE < 8192)
> > @@ -6588,7 +6588,7 @@ static bool igb_add_rx_frag(struct igb_ring
> *rx_ring,
> >               memcpy(__skb_put(skb, size), va, ALIGN(size,
> sizeof(long)));
> >
> >               /* we can reuse buffer as-is, just make sure it is local */
> > -             if (likely(page_to_nid(page) == numa_node_id()))
> > +             if (likely(page_to_nid(page) == numa_mem_id()))
> >                       return true;
> >
> >               /* this page cannot be reused so discard it */
>
> This doesn't seem to have anything to do with crashes or errors?
>
> The original code is checking if the NUMA node of a page is remote to
> the NUMA node current is running on. Your change makes it check if the
> NUMA node of a page is not equal to the nearest NUMA node with memory.
> That's not necessarily local, though, which seems like that is the whole
> point. In this case, perhaps the driver author doesn't want to reuse the
> memory at all for performance reasons? In any case, I don't think this
> patch has appropriate justification.
>
> Thanks,
> Nish
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--089e013d06e649da2f04feb97643
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>I do agree the description should probably be changed=
.=C2=A0 There shouldn&#39;t be any panics involved, only a performance impa=
ct as it will be reallocating always if it is on a node with no memory.<br>=
</div>
<div><br>My intention on this was to make certain that the memory used is f=
rom the closest node possible.=C2=A0 As such I believe this change likely h=
onours that.<br><br></div>Thanks,<br><br>Alex<br></div><div class=3D"gmail_=
extra">
<br><br><div class=3D"gmail_quote">On Mon, Jul 21, 2014 at 10:42 AM, Nishan=
th Aravamudan <span dir=3D"ltr">&lt;<a href=3D"mailto:nacc@linux.vnet.ibm.c=
om" target=3D"_blank">nacc@linux.vnet.ibm.com</a>&gt;</span> wrote:<br><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #c=
cc solid;padding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5">On 11.07.2014 [15:37:32 +0800], Jia=
ng Liu wrote:<br>
&gt; When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_=
id()<br>
&gt; may return a node without memory, and later cause system failure/panic=
<br>
&gt; when calling kmalloc_node() and friends with returned node id.<br>
&gt; So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with=
<br>
&gt; memory for the/current cpu.<br>
&gt;<br>
&gt; If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id(=
)<br>
&gt; is the same as cpu_to_node()/numa_node_id().<br>
&gt;<br>
&gt; Signed-off-by: Jiang Liu &lt;<a href=3D"mailto:jiang.liu@linux.intel.c=
om">jiang.liu@linux.intel.com</a>&gt;<br>
&gt; ---<br>
&gt; =C2=A0drivers/net/ethernet/intel/igb/igb_main.c | =C2=A0 =C2=A04 ++--<=
br>
&gt; =C2=A01 file changed, 2 insertions(+), 2 deletions(-)<br>
&gt;<br>
&gt; diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/e=
thernet/intel/igb/igb_main.c<br>
&gt; index f145adbb55ac..2b74bffa5648 100644<br>
&gt; --- a/drivers/net/ethernet/intel/igb/igb_main.c<br>
&gt; +++ b/drivers/net/ethernet/intel/igb/igb_main.c<br>
&gt; @@ -6518,7 +6518,7 @@ static bool igb_can_reuse_rx_page(struct igb_rx_=
buffer *rx_buffer,<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int truesize)<br>
&gt; =C2=A0{<br>
&gt; =C2=A0 =C2=A0 =C2=A0 /* avoid re-using remote pages */<br>
&gt; - =C2=A0 =C2=A0 if (unlikely(page_to_nid(page) !=3D numa_node_id()))<b=
r>
&gt; + =C2=A0 =C2=A0 if (unlikely(page_to_nid(page) !=3D numa_mem_id()))<br=
>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;<br>
&gt;<br>
&gt; =C2=A0#if (PAGE_SIZE &lt; 8192)<br>
&gt; @@ -6588,7 +6588,7 @@ static bool igb_add_rx_frag(struct igb_ring *rx_=
ring,<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(__skb_put(skb,=
 size), va, ALIGN(size, sizeof(long)));<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* we can reuse buffe=
r as-is, just make sure it is local */<br>
&gt; - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(page_to_nid(pag=
e) =3D=3D numa_node_id()))<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(page_to_nid(pag=
e) =3D=3D numa_mem_id()))<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return true;<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* this page cannot b=
e reused so discard it */<br>
<br>
</div></div>This doesn&#39;t seem to have anything to do with crashes or er=
rors?<br>
<br>
The original code is checking if the NUMA node of a page is remote to<br>
the NUMA node current is running on. Your change makes it check if the<br>
NUMA node of a page is not equal to the nearest NUMA node with memory.<br>
That&#39;s not necessarily local, though, which seems like that is the whol=
e<br>
point. In this case, perhaps the driver author doesn&#39;t want to reuse th=
e<br>
memory at all for performance reasons? In any case, I don&#39;t think this<=
br>
patch has appropriate justification.<br>
<br>
Thanks,<br>
Nish<br>
<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel=
&quot; in<br>
<div class=3D"">the body of a message to <a href=3D"mailto:majordomo@vger.k=
ernel.org">majordomo@vger.kernel.org</a><br>
More majordomo info at =C2=A0<a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><b=
r>
</div>Please read the FAQ at =C2=A0<a href=3D"http://www.tux.org/lkml/" tar=
get=3D"_blank">http://www.tux.org/lkml/</a><br>
</blockquote></div><br></div>

--089e013d06e649da2f04feb97643--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
