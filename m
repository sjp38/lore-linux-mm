Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 68F926B2CCD
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 20:12:11 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u12-v6so6288586wrc.1
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 17:12:11 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h13-v6sor2283165wrv.32.2018.08.23.17.12.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 17:12:09 -0700 (PDT)
MIME-Version: 1.0
References: <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
 <20180806120042.GL19540@dhcp22.suse.cz> <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
 <20180806181638.GE10003@dhcp22.suse.cz> <CADF2uSqzt+u7vMkcD-vvT6tjz2bdHtrFK+p6s7NXGP-BJ34dRA@mail.gmail.com>
 <CADF2uSp7MKYWL7Yu5TDOT4qe0v-0iiq+Tv9J6rnzCSgahXbNaA@mail.gmail.com>
 <20180821064911.GW29735@dhcp22.suse.cz> <11b4f8cd-6253-262f-4ae6-a14062c58039@suse.cz>
 <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
 <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz> <20180823122111.GG29735@dhcp22.suse.cz>
In-Reply-To: <20180823122111.GG29735@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Fri, 24 Aug 2018 02:11:57 +0200
Message-ID: <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="00000000000004f51f0574233ab0"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

--00000000000004f51f0574233ab0
Content-Type: text/plain; charset="UTF-8"

> Hmm it's actually interesting to see GFP_TRANSHUGE there and not
> GFP_TRANSHUGE_LIGHT. What's your thp defrag setting? (cat
> /sys/kernel/mm/transparent_hugepage/enabled). Maybe it's set to
> "always", or there's a heavily faulting process that's using
> madvise(MADV_HUGEPAGE). If that's the case, setting it to "defer" or
> even "never" could be a workaround.

cat /sys/kernel/mm/transparent_hugepage/enabled
always [madvise] never

according to the docs this is the default
> "madvise" will enter direct reclaim like "always" but only for regions
> that are have used madvise(MADV_HUGEPAGE). This is the default behaviour.

would any change there kick in immediately, even when in the 100M/10G case?

> or there's a heavily faulting process that's using madvise(MADV_HUGEPAGE)

are you suggesting that a/one process can cause this?
how would one be able to identify it..? should killing it allow the cache
to be
populated again instantly? if yes, then I could start killing all processes
on the
host until there is improvement to observe.
so far I can tell that it is not the database server, since restarting it
did not help at all.

Please remember that, suggesting this, I can see how buffers (the 100MB
value)
are `oscillating`. When in the cache-useless state it jumps around
literally every second
from e.g. 100 to 102, then 99, 104, 85, 101, 105, 98, .. and so on, where
it always gets
closer from well-populated several GB in the beginning to those 100MB over
the days.
so doing anything that should cause an effect would be easily measurable
instantly,
which is to date only achieved by dropping caches.

Please tell me if you need any measurements again, when or at what state,
with code
snippets perhaps to fit your needs.


Am Do., 23. Aug. 2018 um 14:21 Uhr schrieb Michal Hocko <mhocko@suse.com>:

> On Thu 23-08-18 14:10:28, Vlastimil Babka wrote:
> > On 08/22/2018 10:02 PM, Marinko Catovic wrote:
> > >> It might be also interesting to do in the problematic state, instead
> of
> > >> dropping caches:
> > >>
> > >> - save snapshot of /proc/vmstat and /proc/pagetypeinfo
> > >> - echo 1 > /proc/sys/vm/compact_memory
> > >> - save new snapshot of /proc/vmstat and /proc/pagetypeinfo
> > >
> > > There was just a worstcase in progress, about 100MB/10GB were used,
> > > super-low perfomance, but could not see any improvement there after
> echo 1,
> > > I watches this for about 3 minutes, the cache usage did not change.
> > >
> > > pagetypeinfo before echo https://pastebin.com/MjSgiMRL
> > > pagetypeinfo 3min after echo https://pastebin.com/uWM6xGDd
> > >
> > > vmstat before echo https://pastebin.com/TjYSKNdE
> > > vmstat 3min after echo https://pastebin.com/MqTibEKi
> >
> > OK, that confirms compaction is useless here. Thanks.
> >
> > It also shows that all orders except order-9 are in fact plentiful.
> > Michal's earlier summary of the trace shows that most allocations are up
> > to order-3 and should be fine, the exception is THP:
> >
> >     277 9 GFP_TRANSHUGE|__GFP_THISNODE
>
> But please note that this is not from the time when the page cache
> dropped to the observed values. So we do not know what happened at the
> time.
>
> Anyway 277 THP pages paging out such a large page cache amount would be
> more than unexpected even for explicitly costly THP fault in methods.
> --
> Michal Hocko
> SUSE Labs
>

--00000000000004f51f0574233ab0
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">&gt; Hmm it&#39;s actually interesting to see GFP_TRANSHUG=
E there and not<br>
&gt; GFP_TRANSHUGE_LIGHT. What&#39;s your thp defrag setting? (cat<br>
&gt; /sys/kernel/mm/transparent_hugepage/enabled). Maybe it&#39;s set to<br=
>&gt;=20
&quot;always&quot;, or there&#39;s a heavily faulting process that&#39;s us=
ing<br>&gt;=20
madvise(MADV_HUGEPAGE). If that&#39;s the case, setting it to &quot;defer&q=
uot; or<br><div>&gt;=20
even &quot;never&quot; could be a workaround.</div><div><br></div><div>cat =
/sys/kernel/mm/transparent_hugepage/enabled<br>always [madvise] never<br></=
div><div><br></div><div>according to the docs this is the default</div><div=
>&gt; &quot;madvise&quot; will enter direct reclaim like &quot;always&quot;=
 but only for regions<br>&gt; that are have used madvise(MADV_HUGEPAGE). Th=
is is the default behaviour.</div><div><br></div><div>would any change ther=
e kick in immediately, even when in the 100M/10G case?<br></div><div><br></=
div><div>&gt; or there&#39;s a heavily faulting process that&#39;s using ma=
dvise(MADV_HUGEPAGE)</div><div><br></div><div>are you suggesting that a/one=
 process can cause this?</div><div>how would one be able to identify it..? =
should killing it allow the cache to be</div><div>populated again instantly=
? if yes, then I could start killing all processes on the</div><div>host un=
til there is improvement to observe.</div><div>so far I can tell that it is=
 not the database server, since restarting it did not help at all.<br></div=
><div><br></div><div>Please remember that, suggesting this, I can see how b=
uffers (the 100MB value)</div><div>are `oscillating`. When in the cache-use=
less state it jumps around literally every second</div><div>from e.g. 100 t=
o 102, then 99, 104, 85, 101, 105, 98, .. and so on, where it always gets</=
div><div>closer from well-populated several GB in the beginning to those 10=
0MB over the days.<br></div><div>so doing anything that should cause an eff=
ect would be easily measurable instantly,</div><div>which is to date only a=
chieved by dropping caches.</div><div><br></div><div>Please tell me if you =
need any measurements again, when or at what state, with code</div><div>sni=
ppets perhaps to fit your needs.<br></div><div><br></div></div><br><div cla=
ss=3D"gmail_quote"><div dir=3D"ltr">Am Do., 23. Aug. 2018 um 14:21=C2=A0Uhr=
 schrieb Michal Hocko &lt;<a href=3D"mailto:mhocko@suse.com">mhocko@suse.co=
m</a>&gt;:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex">On Thu 23-08-18 14:10:28=
, Vlastimil Babka wrote:<br>
&gt; On 08/22/2018 10:02 PM, Marinko Catovic wrote:<br>
&gt; &gt;&gt; It might be also interesting to do in the problematic state, =
instead of<br>
&gt; &gt;&gt; dropping caches:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; - save snapshot of /proc/vmstat and /proc/pagetypeinfo<br>
&gt; &gt;&gt; - echo 1 &gt; /proc/sys/vm/compact_memory<br>
&gt; &gt;&gt; - save new snapshot of /proc/vmstat and /proc/pagetypeinfo<br=
>
&gt; &gt; <br>
&gt; &gt; There was just a worstcase in progress, about 100MB/10GB were use=
d,<br>
&gt; &gt; super-low perfomance, but could not see any improvement there aft=
er echo 1,<br>
&gt; &gt; I watches this for about 3 minutes, the cache usage did not chang=
e.<br>
&gt; &gt; <br>
&gt; &gt; pagetypeinfo before echo <a href=3D"https://pastebin.com/MjSgiMRL=
" rel=3D"noreferrer" target=3D"_blank">https://pastebin.com/MjSgiMRL</a><br=
>
&gt; &gt; pagetypeinfo 3min after echo <a href=3D"https://pastebin.com/uWM6=
xGDd" rel=3D"noreferrer" target=3D"_blank">https://pastebin.com/uWM6xGDd</a=
><br>
&gt; &gt; <br>
&gt; &gt; vmstat before echo <a href=3D"https://pastebin.com/TjYSKNdE" rel=
=3D"noreferrer" target=3D"_blank">https://pastebin.com/TjYSKNdE</a><br>
&gt; &gt; vmstat 3min after echo <a href=3D"https://pastebin.com/MqTibEKi" =
rel=3D"noreferrer" target=3D"_blank">https://pastebin.com/MqTibEKi</a><br>
&gt; <br>
&gt; OK, that confirms compaction is useless here. Thanks.<br>
&gt; <br>
&gt; It also shows that all orders except order-9 are in fact plentiful.<br=
>
&gt; Michal&#39;s earlier summary of the trace shows that most allocations =
are up<br>
&gt; to order-3 and should be fine, the exception is THP:<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0277 9 GFP_TRANSHUGE|__GFP_THISNODE<br>
<br>
But please note that this is not from the time when the page cache<br>
dropped to the observed values. So we do not know what happened at the<br>
time.<br>
<br>
Anyway 277 THP pages paging out such a large page cache amount would be<br>
more than unexpected even for explicitly costly THP fault in methods.<br>
-- <br>
Michal Hocko<br>
SUSE Labs<br>
</blockquote></div>

--00000000000004f51f0574233ab0--
