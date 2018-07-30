Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF43F6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 18:08:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4-v6so419784wme.7
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 15:08:10 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j124-v6sor171572wmd.21.2018.07.30.15.08.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 15:08:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180730144048.GW24267@dhcp22.suse.cz>
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz> <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
 <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com>
 <20180716162337.GY17280@dhcp22.suse.cz> <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
 <20180716164500.GZ17280@dhcp22.suse.cz> <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
 <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz> <20180730144048.GW24267@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Tue, 31 Jul 2018 00:08:08 +0200
Message-ID: <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="000000000000508f0705723eb22d"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--000000000000508f0705723eb22d
Content-Type: text/plain; charset="UTF-8"

> Can you provide (a single snapshot) /proc/pagetypeinfo and
> /proc/slabinfo from a system that's currently experiencing the issue,
> also with /proc/vmstat and /proc/zoneinfo to verify? Thanks.

your request came in just one day after I 2>drop_caches again when the ram
usage
was really really low again. Up until now it did not reoccur on any of the
2 hosts,
where one shows 550MB/11G with 37G of totally free ram for now - so not
that low
like last time when I dropped it, I think it was like 300M/8G or so, but I
hope it helps:

/proc/pagetypeinfo  https://pastebin.com/6QWEZagL
/proc/slabinfo  https://pastebin.com/81QAFgke
/proc/vmstat  https://pastebin.com/S7mrQx1s
/proc/zoneinfo  https://pastebin.com/csGeqNyX

also please note - whether this makes any difference: there is no swap
file/partition
I am using this without swap space. imho this should not be necessary since
applications running on the hosts would not consume more than 20GB, the rest
should be used by buffers/cache.

2018-07-30 16:40 GMT+02:00 Michal Hocko <mhocko@suse.com>:

> On Fri 27-07-18 13:15:33, Vlastimil Babka wrote:
> > On 07/21/2018 12:03 AM, Marinko Catovic wrote:
> > > I let this run for 3 days now, so it is quite a lot, there you go:
> > > https://nofile.io/f/egGyRjf0NPs/vmstat.tar.gz
> >
> > The stats show that compaction has very bad results. Between first and
> > last snapshot, compact_fail grew by 80k and compact_success by 1300.
> > High-order allocations will thus cycle between (failing) compaction and
> > reclaim that removes the buffer/caches from memory.
>
> I guess you are right. I've just looked at random large direct reclaim
> activity
> $ grep -w pgscan_direct  vmstat*| awk  '{diff=$2-old; if (old && diff >
> 100000) printf "%s %d\n", $1, diff; old=$2}'
> vmstat.1531957422:pgscan_direct 114334
> vmstat.1532047588:pgscan_direct 111796
>
> $ paste-with-diff.sh vmstat.1532047578 vmstat.1532047588 | grep
> "pgscan\|pgsteal\|compact\|pgalloc" | sort
> # counter                       value1          value2-value1
> compact_daemon_free_scanned     2628160139      0
> compact_daemon_migrate_scanned  797948703       0
> compact_daemon_wake     23634   0
> compact_fail    124806  108
> compact_free_scanned    226181616304    295560271
> compact_isolated        2881602028      480577
> compact_migrate_scanned 147900786550    27834455
> compact_stall   146749  108
> compact_success 21943   0
> pgalloc_dma     0       0
> pgalloc_dma32   1577060946      10752
> pgalloc_movable 0       0
> pgalloc_normal  29389246430     343249
> pgscan_direct   737335028       111796
> pgscan_direct_throttle  0       0
> pgscan_kswapd   1177909394      0
> pgsteal_direct  704542843       111784
> pgsteal_kswapd  898170720       0
>
> There is zero kswapd activity so this must have been higher order
> allocation activity and all the direct compaction failed so we keep
> reclaiming.
> --
> Michal Hocko
> SUSE Labs
>

--000000000000508f0705723eb22d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span class=3D"gmail-im"><br>
</span>&gt; Can you provide (a single snapshot) /proc/pagetypeinfo and<br>&=
gt; /proc/slabinfo from a system that&#39;s currently experiencing the issu=
e,<br><div>&gt; also with /proc/vmstat and /proc/zoneinfo to verify? Thanks=
.</div><div><br></div><div>your request came in just one day after I 2&gt;d=
rop_caches again when the ram usage</div><div>was really really low again. =
Up until now it did not reoccur on any of the 2 hosts,</div><div>where one =
shows 550MB/11G with 37G of totally free ram for now - so not that low</div=
><div>like last time when I dropped it, I think it was like 300M/8G or so, =
but I hope it helps:</div><div><br></div><div>/proc/pagetypeinfo=C2=A0 <a h=
ref=3D"https://pastebin.com/6QWEZagL">https://pastebin.com/6QWEZagL</a></di=
v><div>/proc/slabinfo=C2=A0 <a href=3D"https://pastebin.com/81QAFgke">https=
://pastebin.com/81QAFgke</a><br></div><div>/proc/vmstat=C2=A0 <a href=3D"ht=
tps://pastebin.com/S7mrQx1s">https://pastebin.com/S7mrQx1s</a></div><div>/p=
roc/zoneinfo=C2=A0 <a href=3D"https://pastebin.com/csGeqNyX">https://pasteb=
in.com/csGeqNyX</a></div><div><br></div><div>also please note - whether thi=
s makes any difference: there is no swap file/partition<br></div><div class=
=3D"gmail_extra">I am using this without swap space. imho this should not b=
e necessary since</div><div class=3D"gmail_extra">applications running on t=
he hosts would not consume more than 20GB, the rest</div><div class=3D"gmai=
l_extra">should be used by buffers/cache. <br></div><div class=3D"gmail_ext=
ra"><br><div class=3D"gmail_quote">2018-07-30 16:40 GMT+02:00 Michal Hocko =
<span dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@suse.com" target=3D"_blank">=
mhocko@suse.com</a>&gt;</span>:<br><blockquote class=3D"gmail_quote" style=
=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding=
-left:1ex"><span class=3D"gmail-">On Fri 27-07-18 13:15:33, Vlastimil Babka=
 wrote:<br>
&gt; On 07/21/2018 12:03 AM, Marinko Catovic wrote:<br>
&gt; &gt; I let this run for 3 days now, so it is quite a lot, there you go=
:<br>
&gt; &gt; <a href=3D"https://nofile.io/f/egGyRjf0NPs/vmstat.tar.gz" rel=3D"=
noreferrer" target=3D"_blank">https://nofile.io/f/<wbr>egGyRjf0NPs/vmstat.t=
ar.gz</a><br>
&gt; <br>
&gt; The stats show that compaction has very bad results. Between first and=
<br>
&gt; last snapshot, compact_fail grew by 80k and compact_success by 1300.<b=
r>
&gt; High-order allocations will thus cycle between (failing) compaction an=
d<br>
&gt; reclaim that removes the buffer/caches from memory.<br>
<br>
</span>I guess you are right. I&#39;ve just looked at random large direct r=
eclaim activity<br>
$ grep -w pgscan_direct=C2=A0 vmstat*| awk=C2=A0 &#39;{diff=3D$2-old; if (o=
ld &amp;&amp; diff &gt; 100000) printf &quot;%s %d\n&quot;, $1, diff; old=
=3D$2}&#39;<br>
vmstat.1531957422:pgscan_<wbr>direct 114334<br>
vmstat.1532047588:pgscan_<wbr>direct 111796<br>
<br>
$ paste-with-diff.sh vmstat.1532047578 vmstat.1532047588 | grep &quot;pgsca=
n\|pgsteal\|compact\|<wbr>pgalloc&quot; | sort<br>
# counter=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0value1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 value2-value1<br>
compact_daemon_free_scanned=C2=A0 =C2=A0 =C2=A02628160139=C2=A0 =C2=A0 =C2=
=A0 0<br>
compact_daemon_migrate_scanned=C2=A0 797948703=C2=A0 =C2=A0 =C2=A0 =C2=A00<=
br>
compact_daemon_wake=C2=A0 =C2=A0 =C2=A023634=C2=A0 =C2=A00<br>
compact_fail=C2=A0 =C2=A0 124806=C2=A0 108<br>
compact_free_scanned=C2=A0 =C2=A0 226181616304=C2=A0 =C2=A0 295560271<br>
compact_isolated=C2=A0 =C2=A0 =C2=A0 =C2=A0 2881602028=C2=A0 =C2=A0 =C2=A0 =
480577<br>
compact_migrate_scanned 147900786550=C2=A0 =C2=A0 27834455<br>
compact_stall=C2=A0 =C2=A0146749=C2=A0 108<br>
compact_success 21943=C2=A0 =C2=A00<br>
pgalloc_dma=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A0 =C2=A0 =C2=A00<br>
pgalloc_dma32=C2=A0 =C2=A01577060946=C2=A0 =C2=A0 =C2=A0 10752<br>
pgalloc_movable 0=C2=A0 =C2=A0 =C2=A0 =C2=A00<br>
pgalloc_normal=C2=A0 29389246430=C2=A0 =C2=A0 =C2=A0343249<br>
pgscan_direct=C2=A0 =C2=A0737335028=C2=A0 =C2=A0 =C2=A0 =C2=A0111796<br>
pgscan_direct_throttle=C2=A0 0=C2=A0 =C2=A0 =C2=A0 =C2=A00<br>
pgscan_kswapd=C2=A0 =C2=A01177909394=C2=A0 =C2=A0 =C2=A0 0<br>
pgsteal_direct=C2=A0 704542843=C2=A0 =C2=A0 =C2=A0 =C2=A0111784<br>
pgsteal_kswapd=C2=A0 898170720=C2=A0 =C2=A0 =C2=A0 =C2=A00<br>
<br>
There is zero kswapd activity so this must have been higher order<br>
allocation activity and all the direct compaction failed so we keep<br>
reclaiming.<br>
<div class=3D"gmail-HOEnZb"><div class=3D"gmail-h5">-- <br>
Michal Hocko<br>
SUSE Labs<br>
</div></div></blockquote></div><br></div></div>

--000000000000508f0705723eb22d--
