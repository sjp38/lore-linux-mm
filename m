Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 25A716B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 10:13:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g25-v6so3654768wmh.6
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 07:13:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w13-v6sor1902413wrl.31.2018.08.03.07.13.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Aug 2018 07:13:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz>
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz> <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
 <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com>
 <20180716162337.GY17280@dhcp22.suse.cz> <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
 <20180716164500.GZ17280@dhcp22.suse.cz> <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
 <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz> <20180730144048.GW24267@dhcp22.suse.cz>
 <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com> <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Fri, 3 Aug 2018 16:13:41 +0200
Message-ID: <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="000000000000ed843f0572888830"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

--000000000000ed843f0572888830
Content-Type: text/plain; charset="UTF-8"

Thanks for the analysis.

So since I am no mem management dev, what exactly does this mean?
Is there any way of workaround or quickfix or something that can/will
be fixed at some point in time?

I can not imagine that I am the only one who is affected by this, nor do I
know why my use case would be so much different from any other.
Most 'cloud' services should be affected as well.

Tell me if you need any other snapshots or whatever info.

2018-08-02 18:15 GMT+02:00 Vlastimil Babka <vbabka@suse.cz>:

> On 07/31/2018 12:08 AM, Marinko Catovic wrote:
> >
> >> Can you provide (a single snapshot) /proc/pagetypeinfo and
> >> /proc/slabinfo from a system that's currently experiencing the issue,
> >> also with /proc/vmstat and /proc/zoneinfo to verify? Thanks.
> >
> > your request came in just one day after I 2>drop_caches again when the
> > ram usage
> > was really really low again. Up until now it did not reoccur on any of
> > the 2 hosts,
> > where one shows 550MB/11G with 37G of totally free ram for now - so not
> > that low
> > like last time when I dropped it, I think it was like 300M/8G or so, but
> > I hope it helps:
>
> Thanks.
>
> > /proc/pagetypeinfo  https://pastebin.com/6QWEZagL
>
> Yep, looks like fragmented by reclaimable slabs:
>
> Node    0, zone   Normal, type    Unmovable  29101  32754   8372   2790
>  1334    354     23      3      4      0      0
> Node    0, zone   Normal, type      Movable 142449  83386  99426  69177
> 36761  12931   1378     24      0      0      0
> Node    0, zone   Normal, type  Reclaimable 467195 530638 355045 192638
> 80358  15627   2029    231     18      0      0
>
> Number of blocks type     Unmovable      Movable  Reclaimable
>  HighAtomic      Isolate
> Node 0, zone      DMA            1            7            0            0
>           0
> Node 0, zone    DMA32           34          703          375            0
>           0
> Node 0, zone   Normal         1672        14276        15659            1
>           0
>
> Half of the memory is marked as reclaimable (2 megabyte) pageblocks.
> zoneinfo has nr_slab_reclaimable 1679817 so the reclaimable slabs occupy
> only 3280 (6G) pageblocks, yet they are spread over 5 times as much.
> It's also possible they pollute the Movable pageblocks as well, but the
> stats can't tell us. Either the page grouping mobility heuristics are
> broken here, or the worst case scenario happened - memory was at some point
> really wholly filled with reclaimable slabs, and the rather random reclaim
> did not result in whole pageblocks being freed.
>
> > /proc/slabinfo  https://pastebin.com/81QAFgke
>
> Largest caches seem to be:
> # name            <active_objs> <num_objs> <objsize> <objperslab>
> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata
> <active_slabs> <num_slabs> <sharedavail>
> ext4_inode_cache  3107754 3759573   1080    3    1 : tunables   24   12
> 8 : slabdata 1253191 1253191      0
> dentry            2840237 7328181    192   21    1 : tunables  120   60
> 8 : slabdata 348961 348961    120
>
> The internal framentation of dentry cache is significant as well.
> Dunno if some of those objects pin movable pages as well...
>
> So looks like there's insufficient slab reclaim (shrinker activity), and
> possibly problems with page grouping by mobility heuristics as well...
>
> > /proc/vmstat  https://pastebin.com/S7mrQx1s
> > /proc/zoneinfo  https://pastebin.com/csGeqNyX
> >
> > also please note - whether this makes any difference: there is no swap
> > file/partition
> > I am using this without swap space. imho this should not be necessary
> since
> > applications running on the hosts would not consume more than 20GB, the
> rest
> > should be used by buffers/cache.
> >
>

--000000000000ed843f0572888830
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Thanks for the analysis.</div><div><br></div><div>So =
since I am no mem management dev, what exactly does this mean?</div><div>Is=
 there any way of workaround or quickfix or something that can/will</div><d=
iv>be fixed at some point in time?</div><div><br></div><div>I can not imagi=
ne that I am the only one who is affected by this, nor do I</div><div>know =
why my use case would be so much different from any other.</div><div>Most &=
#39;cloud&#39; services should be affected as well.<br></div><div><br></div=
><div>Tell me if you need any other snapshots or whatever info.<br></div><d=
iv class=3D"gmail_extra"><br><div class=3D"gmail_quote">2018-08-02 18:15 GM=
T+02:00 Vlastimil Babka <span dir=3D"ltr">&lt;<a href=3D"mailto:vbabka@suse=
.cz" target=3D"_blank">vbabka@suse.cz</a>&gt;</span>:<br><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex"><span class=3D"">On 07/31/2018 12:08 AM, Marinko Catovic wrot=
e:<br>
&gt; <br>
&gt;&gt; Can you provide (a single snapshot) /proc/pagetypeinfo and<br>
&gt;&gt; /proc/slabinfo from a system that&#39;s currently experiencing the=
 issue,<br>
&gt;&gt; also with /proc/vmstat and /proc/zoneinfo to verify? Thanks.<br>
&gt; <br>
&gt; your request came in just one day after I 2&gt;drop_caches again when =
the<br>
&gt; ram usage<br>
&gt; was really really low again. Up until now it did not reoccur on any of=
<br>
&gt; the 2 hosts,<br>
&gt; where one shows 550MB/11G with 37G of totally free ram for now - so no=
t<br>
&gt; that low<br>
&gt; like last time when I dropped it, I think it was like 300M/8G or so, b=
ut<br>
&gt; I hope it helps:<br>
<br>
</span>Thanks.<br>
<br>
&gt; /proc/pagetypeinfo=C2=A0 <a href=3D"https://pastebin.com/6QWEZagL" rel=
=3D"noreferrer" target=3D"_blank">https://pastebin.com/6QWEZagL</a><br>
<br>
Yep, looks like fragmented by reclaimable slabs:<br>
<br>
Node=C2=A0 =C2=A0 0, zone=C2=A0 =C2=A0Normal, type=C2=A0 =C2=A0 Unmovable=
=C2=A0 29101=C2=A0 32754=C2=A0 =C2=A08372=C2=A0 =C2=A02790=C2=A0 =C2=A01334=
=C2=A0 =C2=A0 354=C2=A0 =C2=A0 =C2=A023=C2=A0 =C2=A0 =C2=A0 3=C2=A0 =C2=A0 =
=C2=A0 4=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=A0 0 <br>
Node=C2=A0 =C2=A0 0, zone=C2=A0 =C2=A0Normal, type=C2=A0 =C2=A0 =C2=A0 Mova=
ble 142449=C2=A0 83386=C2=A0 99426=C2=A0 69177=C2=A0 36761=C2=A0 12931=C2=
=A0 =C2=A01378=C2=A0 =C2=A0 =C2=A024=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=
=A0 0=C2=A0 =C2=A0 =C2=A0 0 <br>
Node=C2=A0 =C2=A0 0, zone=C2=A0 =C2=A0Normal, type=C2=A0 Reclaimable 467195=
 530638 355045 192638=C2=A0 80358=C2=A0 15627=C2=A0 =C2=A02029=C2=A0 =C2=A0=
 231=C2=A0 =C2=A0 =C2=A018=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=A0 0 <br>
<br>
Number of blocks type=C2=A0 =C2=A0 =C2=A0Unmovable=C2=A0 =C2=A0 =C2=A0 Mova=
ble=C2=A0 Reclaimable=C2=A0 =C2=A0HighAtomic=C2=A0 =C2=A0 =C2=A0 Isolate <b=
r>
Node 0, zone=C2=A0 =C2=A0 =C2=A0 DMA=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 7=C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 0 <br>
Node 0, zone=C2=A0 =C2=A0 DMA32=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A034=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 703=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 37=
5=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 0 <br>
Node 0, zone=C2=A0 =C2=A0Normal=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01672=C2=A0=
 =C2=A0 =C2=A0 =C2=A0 14276=C2=A0 =C2=A0 =C2=A0 =C2=A0 15659=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0<br=
>
<br>
Half of the memory is marked as reclaimable (2 megabyte) pageblocks.<br>
zoneinfo has nr_slab_reclaimable 1679817 so the reclaimable slabs occupy<br=
>
only 3280 (6G) pageblocks, yet they are spread over 5 times as much.<br>
It&#39;s also possible they pollute the Movable pageblocks as well, but the=
<br>
stats can&#39;t tell us. Either the page grouping mobility heuristics are<b=
r>
broken here, or the worst case scenario happened - memory was at some point=
<br>
really wholly filled with reclaimable slabs, and the rather random reclaim<=
br>
did not result in whole pageblocks being freed.<br>
<br>
&gt; /proc/slabinfo=C2=A0 <a href=3D"https://pastebin.com/81QAFgke" rel=3D"=
noreferrer" target=3D"_blank">https://pastebin.com/81QAFgke</a><br>
<br>
Largest caches seem to be:<br>
# name=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &lt;active_objs&gt; &lt;num=
_objs&gt; &lt;objsize&gt; &lt;objperslab&gt; &lt;pagesperslab&gt; : tunable=
s &lt;limit&gt; &lt;batchcount&gt; &lt;sharedfactor&gt; : slabdata &lt;acti=
ve_slabs&gt; &lt;num_slabs&gt; &lt;sharedavail&gt;<br>
ext4_inode_cache=C2=A0 3107754 3759573=C2=A0 =C2=A01080=C2=A0 =C2=A0 3=C2=
=A0 =C2=A0 1 : tunables=C2=A0 =C2=A024=C2=A0 =C2=A012=C2=A0 =C2=A0 8 : slab=
data 1253191 1253191=C2=A0 =C2=A0 =C2=A0 0<br>
dentry=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2840237 7328181=C2=A0 =C2=
=A0 192=C2=A0 =C2=A021=C2=A0 =C2=A0 1 : tunables=C2=A0 120=C2=A0 =C2=A060=
=C2=A0 =C2=A0 8 : slabdata 348961 348961=C2=A0 =C2=A0 120<br>
<br>
The internal framentation of dentry cache is significant as well.<br>
Dunno if some of those objects pin movable pages as well...<br>
<br>
So looks like there&#39;s insufficient slab reclaim (shrinker activity), an=
d<br>
possibly problems with page grouping by mobility heuristics as well...<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt; /proc/vmstat=C2=A0 <a href=3D"https://pastebin.com/S7mrQx1s" rel=3D"no=
referrer" target=3D"_blank">https://pastebin.com/S7mrQx1s</a><br>
&gt; /proc/zoneinfo=C2=A0 <a href=3D"https://pastebin.com/csGeqNyX" rel=3D"=
noreferrer" target=3D"_blank">https://pastebin.com/csGeqNyX</a><br>
&gt; <br>
&gt; also please note - whether this makes any difference: there is no swap=
<br>
&gt; file/partition<br>
&gt; I am using this without swap space. imho this should not be necessary =
since<br>
&gt; applications running on the hosts would not consume more than 20GB, th=
e rest<br>
&gt; should be used by buffers/cache.<br>
&gt; <br>
</div></div></blockquote></div><br></div></div>

--000000000000ed843f0572888830--
