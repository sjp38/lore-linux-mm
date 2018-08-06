Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E6E806B000C
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 06:29:45 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o25-v6so9037807wmh.1
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 03:29:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g2-v6sor4102549wru.26.2018.08.06.03.29.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 03:29:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz>
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz> <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
 <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com>
 <20180716162337.GY17280@dhcp22.suse.cz> <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
 <20180716164500.GZ17280@dhcp22.suse.cz> <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
 <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz> <20180730144048.GW24267@dhcp22.suse.cz>
 <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
 <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz> <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
 <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Mon, 6 Aug 2018 12:29:43 +0200
Message-ID: <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="0000000000007ecf140572c1c1d8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

--0000000000007ecf140572c1c1d8
Content-Type: text/plain; charset="UTF-8"

> Maybe a memcg with kmemcg limit? Michal could know more.

Could you/Michael explain this perhaps?

The hardware is pretty much high end datacenter grade, I really would
not know how this is to be related with the hardware :(

I do not understand why apparently the caching is working very much
fine for the beginning after a drop_caches, then degrades to low usage
somewhat later. I can not possibly drop caches automatically, since
this requires monitoring for overload with temporary dropping traffic
on specific ports until the writes/reads cool down.


2018-08-06 11:40 GMT+02:00 Vlastimil Babka <vbabka@suse.cz>:

> On 08/03/2018 04:13 PM, Marinko Catovic wrote:
> > Thanks for the analysis.
> >
> > So since I am no mem management dev, what exactly does this mean?
> > Is there any way of workaround or quickfix or something that can/will
> > be fixed at some point in time?
>
> Workaround would be the manual / periodic cache flushing, unfortunately.
>
> Maybe a memcg with kmemcg limit? Michal could know more.
>
> A long-term generic solution will be much harder to find :(
>
> > I can not imagine that I am the only one who is affected by this, nor do
> I
> > know why my use case would be so much different from any other.
> > Most 'cloud' services should be affected as well.
>
> Hmm, either your workload is specific in being hungry for fs metadata
> and not much data (page cache). And/Or there's some source of the
> high-order allocations that others don't have, possibly related to some
> piece of hardware?
>
> > Tell me if you need any other snapshots or whatever info.
> >
> > 2018-08-02 18:15 GMT+02:00 Vlastimil Babka <vbabka@suse.cz
> > <mailto:vbabka@suse.cz>>:
> >
> >     On 07/31/2018 12:08 AM, Marinko Catovic wrote:
> >     >
> >     >> Can you provide (a single snapshot) /proc/pagetypeinfo and
> >     >> /proc/slabinfo from a system that's currently experiencing the
> issue,
> >     >> also with /proc/vmstat and /proc/zoneinfo to verify? Thanks.
> >     >
> >     > your request came in just one day after I 2>drop_caches again when
> the
> >     > ram usage
> >     > was really really low again. Up until now it did not reoccur on
> any of
> >     > the 2 hosts,
> >     > where one shows 550MB/11G with 37G of totally free ram for now -
> so not
> >     > that low
> >     > like last time when I dropped it, I think it was like 300M/8G or
> so, but
> >     > I hope it helps:
> >
> >     Thanks.
> >
> >     > /proc/pagetypeinfo  https://pastebin.com/6QWEZagL
> >
> >     Yep, looks like fragmented by reclaimable slabs:
> >
> >     Node    0, zone   Normal, type    Unmovable  29101  32754   8372
> >      2790   1334    354     23      3      4      0      0
> >     Node    0, zone   Normal, type      Movable 142449  83386  99426
> >     69177  36761  12931   1378     24      0      0      0
> >     Node    0, zone   Normal, type  Reclaimable 467195 530638 355045
> >     192638  80358  15627   2029    231     18      0      0
> >
> >     Number of blocks type     Unmovable      Movable  Reclaimable
> >      HighAtomic      Isolate
> >     Node 0, zone      DMA            1            7            0
> >         0            0
> >     Node 0, zone    DMA32           34          703          375
> >         0            0
> >     Node 0, zone   Normal         1672        14276        15659
> >         1            0
> >
> >     Half of the memory is marked as reclaimable (2 megabyte) pageblocks.
> >     zoneinfo has nr_slab_reclaimable 1679817 so the reclaimable slabs
> occupy
> >     only 3280 (6G) pageblocks, yet they are spread over 5 times as much.
> >     It's also possible they pollute the Movable pageblocks as well, but
> the
> >     stats can't tell us. Either the page grouping mobility heuristics are
> >     broken here, or the worst case scenario happened - memory was at
> >     some point
> >     really wholly filled with reclaimable slabs, and the rather random
> >     reclaim
> >     did not result in whole pageblocks being freed.
> >
> >     > /proc/slabinfo  https://pastebin.com/81QAFgke
> >
> >     Largest caches seem to be:
> >     # name            <active_objs> <num_objs> <objsize> <objperslab>
> >     <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> :
> >     slabdata <active_slabs> <num_slabs> <sharedavail>
> >     ext4_inode_cache  3107754 3759573   1080    3    1 : tunables   24
> >      12    8 : slabdata 1253191 1253191      0
> >     dentry            2840237 7328181    192   21    1 : tunables  120
> >      60    8 : slabdata 348961 348961    120
> >
> >     The internal framentation of dentry cache is significant as well.
> >     Dunno if some of those objects pin movable pages as well...
> >
> >     So looks like there's insufficient slab reclaim (shrinker activity),
> and
> >     possibly problems with page grouping by mobility heuristics as
> well...
> >
> >     > /proc/vmstat  https://pastebin.com/S7mrQx1s
> >     > /proc/zoneinfo  https://pastebin.com/csGeqNyX
> >     >
> >     > also please note - whether this makes any difference: there is no
> swap
> >     > file/partition
> >     > I am using this without swap space. imho this should not be
> >     necessary since
> >     > applications running on the hosts would not consume more than
> >     20GB, the rest
> >     > should be used by buffers/cache.
> >     >
> >
> >
>
>

--0000000000007ecf140572c1c1d8
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>&gt;=20
Maybe a memcg with kmemcg limit? Michal could know more.</div><div><br></di=
v><div>Could you/Michael explain this perhaps?</div><div><br></div><div>The=
 hardware is pretty much high end datacenter grade, I really would</div><di=
v>not know how this is to be related with the hardware :(</div><div><br></d=
iv><div>I do not understand why apparently the caching is working very much=
</div><div>fine for the beginning after a drop_caches, then degrades to low=
 usage</div><div>somewhat later. I can not possibly drop caches automatical=
ly, since</div><div>this requires monitoring for overload with temporary dr=
opping traffic</div><div>on specific ports until the writes/reads cool down=
.<br></div><br></div><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2018-08-06 11:40 GMT+02:00 Vlastimil Babka <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:vbabka@suse.cz" target=3D"_blank">vbabka@suse.cz</a>&gt;</span>=
:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-le=
ft:1px #ccc solid;padding-left:1ex"><span class=3D"">On 08/03/2018 04:13 PM=
, Marinko Catovic wrote:<br>
&gt; Thanks for the analysis.<br>
&gt; <br>
&gt; So since I am no mem management dev, what exactly does this mean?<br>
&gt; Is there any way of workaround or quickfix or something that can/will<=
br>
&gt; be fixed at some point in time?<br>
<br>
</span>Workaround would be the manual / periodic cache flushing, unfortunat=
ely.<br>
<br>
Maybe a memcg with kmemcg limit? Michal could know more.<br>
<br>
A long-term generic solution will be much harder to find :(<br>
<span class=3D""><br>
&gt; I can not imagine that I am the only one who is affected by this, nor =
do I<br>
&gt; know why my use case would be so much different from any other.<br>
&gt; Most &#39;cloud&#39; services should be affected as well.<br>
<br>
</span>Hmm, either your workload is specific in being hungry for fs metadat=
a<br>
and not much data (page cache). And/Or there&#39;s some source of the<br>
high-order allocations that others don&#39;t have, possibly related to some=
<br>
piece of hardware?<br>
<span class=3D""><br>
&gt; Tell me if you need any other snapshots or whatever info.<br>
&gt; <br>
&gt; 2018-08-02 18:15 GMT+02:00 Vlastimil Babka &lt;<a href=3D"mailto:vbabk=
a@suse.cz">vbabka@suse.cz</a><br>
</span>&gt; &lt;mailto:<a href=3D"mailto:vbabka@suse.cz">vbabka@suse.cz</a>=
&gt;&gt;:<br>
<div class=3D"HOEnZb"><div class=3D"h5">&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0On 07/31/2018 12:08 AM, Marinko Catovic wrote:<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;&gt; Can you provide (a single snapshot) /proc/=
pagetypeinfo and<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;&gt; /proc/slabinfo from a system that&#39;s cu=
rrently experiencing the issue,<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;&gt; also with /proc/vmstat and /proc/zoneinfo =
to verify? Thanks.<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; your request came in just one day after I 2&gt=
;drop_caches again when the<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; ram usage<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; was really really low again. Up until now it d=
id not reoccur on any of<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; the 2 hosts,<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; where one shows 550MB/11G with 37G of totally =
free ram for now - so not<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; that low<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; like last time when I dropped it, I think it w=
as like 300M/8G or so, but<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; I hope it helps:<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0Thanks.<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; /proc/pagetypeinfo=C2=A0 <a href=3D"https://pa=
stebin.com/6QWEZagL" rel=3D"noreferrer" target=3D"_blank">https://pastebin.=
com/6QWEZagL</a><br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0Yep, looks like fragmented by reclaimable slabs:<br=
>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0Node=C2=A0 =C2=A0 0, zone=C2=A0 =C2=A0Normal, type=
=C2=A0 =C2=A0 Unmovable=C2=A0 29101=C2=A0 32754=C2=A0 =C2=A08372=C2=A0<br>
&gt;=C2=A0 =C2=A0 =C2=A0=C2=A02790=C2=A0 =C2=A01334=C2=A0 =C2=A0 354=C2=A0 =
=C2=A0 =C2=A023=C2=A0 =C2=A0 =C2=A0 3=C2=A0 =C2=A0 =C2=A0 4=C2=A0 =C2=A0 =
=C2=A0 0=C2=A0 =C2=A0 =C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0Node=C2=A0 =C2=A0 0, zone=C2=A0 =C2=A0Normal, type=
=C2=A0 =C2=A0 =C2=A0 Movable 142449=C2=A0 83386=C2=A0 99426=C2=A0<br>
&gt;=C2=A0 =C2=A0 =C2=A069177=C2=A0 36761=C2=A0 12931=C2=A0 =C2=A01378=C2=
=A0 =C2=A0 =C2=A024=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=
=A0 =C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0Node=C2=A0 =C2=A0 0, zone=C2=A0 =C2=A0Normal, type=
=C2=A0 Reclaimable 467195 530638 355045<br>
&gt;=C2=A0 =C2=A0 =C2=A0192638=C2=A0 80358=C2=A0 15627=C2=A0 =C2=A02029=C2=
=A0 =C2=A0 231=C2=A0 =C2=A0 =C2=A018=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=
=A0 0<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0Number of blocks type=C2=A0 =C2=A0 =C2=A0Unmovable=
=C2=A0 =C2=A0 =C2=A0 Movable=C2=A0 Reclaimable=C2=A0<br>
&gt;=C2=A0 =C2=A0 =C2=A0=C2=A0HighAtomic=C2=A0 =C2=A0 =C2=A0 Isolate<br>
&gt;=C2=A0 =C2=A0 =C2=A0Node 0, zone=C2=A0 =C2=A0 =C2=A0 DMA=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 7=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=A0 =C2=A0<br>
&gt;=C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0Node 0, zone=C2=A0 =C2=A0 DMA32=C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A034=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 703=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 375=C2=A0 =C2=A0 =C2=A0 =C2=A0<br>
&gt;=C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0Node 0, zone=C2=A0 =C2=A0Normal=C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A01672=C2=A0 =C2=A0 =C2=A0 =C2=A0 14276=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 15659=C2=A0 =C2=A0 =C2=A0 =C2=A0<br>
&gt;=C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0Half of the memory is marked as reclaimable (2 mega=
byte) pageblocks.<br>
&gt;=C2=A0 =C2=A0 =C2=A0zoneinfo has nr_slab_reclaimable 1679817 so the rec=
laimable slabs occupy<br>
&gt;=C2=A0 =C2=A0 =C2=A0only 3280 (6G) pageblocks, yet they are spread over=
 5 times as much.<br>
&gt;=C2=A0 =C2=A0 =C2=A0It&#39;s also possible they pollute the Movable pag=
eblocks as well, but the<br>
&gt;=C2=A0 =C2=A0 =C2=A0stats can&#39;t tell us. Either the page grouping m=
obility heuristics are<br>
&gt;=C2=A0 =C2=A0 =C2=A0broken here, or the worst case scenario happened - =
memory was at<br>
&gt;=C2=A0 =C2=A0 =C2=A0some point<br>
&gt;=C2=A0 =C2=A0 =C2=A0really wholly filled with reclaimable slabs, and th=
e rather random<br>
&gt;=C2=A0 =C2=A0 =C2=A0reclaim<br>
&gt;=C2=A0 =C2=A0 =C2=A0did not result in whole pageblocks being freed.<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; /proc/slabinfo=C2=A0 <a href=3D"https://pasteb=
in.com/81QAFgke" rel=3D"noreferrer" target=3D"_blank">https://pastebin.com/=
81QAFgke</a><br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0Largest caches seem to be:<br>
&gt;=C2=A0 =C2=A0 =C2=A0# name=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &lt=
;active_objs&gt; &lt;num_objs&gt; &lt;objsize&gt; &lt;objperslab&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&lt;pagesperslab&gt; : tunables &lt;limit&gt; &lt;b=
atchcount&gt; &lt;sharedfactor&gt; :<br>
&gt;=C2=A0 =C2=A0 =C2=A0slabdata &lt;active_slabs&gt; &lt;num_slabs&gt; &lt=
;sharedavail&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0ext4_inode_cache=C2=A0 3107754 3759573=C2=A0 =C2=A0=
1080=C2=A0 =C2=A0 3=C2=A0 =C2=A0 1 : tunables=C2=A0 =C2=A024=C2=A0<br>
&gt;=C2=A0 =C2=A0 =C2=A0=C2=A012=C2=A0 =C2=A0 8 : slabdata 1253191 1253191=
=C2=A0 =C2=A0 =C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0dentry=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 284=
0237 7328181=C2=A0 =C2=A0 192=C2=A0 =C2=A021=C2=A0 =C2=A0 1 : tunables=C2=
=A0 120=C2=A0<br>
&gt;=C2=A0 =C2=A0 =C2=A0=C2=A060=C2=A0 =C2=A0 8 : slabdata 348961 348961=C2=
=A0 =C2=A0 120<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0The internal framentation of dentry cache is signif=
icant as well.<br>
&gt;=C2=A0 =C2=A0 =C2=A0Dunno if some of those objects pin movable pages as=
 well...<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0So looks like there&#39;s insufficient slab reclaim=
 (shrinker activity), and<br>
&gt;=C2=A0 =C2=A0 =C2=A0possibly problems with page grouping by mobility he=
uristics as well...<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; /proc/vmstat=C2=A0 <a href=3D"https://pastebin=
.com/S7mrQx1s" rel=3D"noreferrer" target=3D"_blank">https://pastebin.com/S7=
mrQx1s</a><br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; /proc/zoneinfo=C2=A0 <a href=3D"https://pasteb=
in.com/csGeqNyX" rel=3D"noreferrer" target=3D"_blank">https://pastebin.com/=
csGeqNyX</a><br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; also please note - whether this makes any diff=
erence: there is no swap<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; file/partition<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; I am using this without swap space. imho this =
should not be<br>
&gt;=C2=A0 =C2=A0 =C2=A0necessary since<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; applications running on the hosts would not co=
nsume more than<br>
&gt;=C2=A0 =C2=A0 =C2=A020GB, the rest<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; should be used by buffers/cache.<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt; <br>
&gt; <br>
<br>
</div></div></blockquote></div><br></div>

--0000000000007ecf140572c1c1d8--
