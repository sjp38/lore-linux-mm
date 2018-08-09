Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 99D896B000A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 04:29:35 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id a9-v6so4025130wrw.20
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 01:29:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e3-v6sor2607793wru.81.2018.08.09.01.29.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Aug 2018 01:29:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180806181638.GE10003@dhcp22.suse.cz>
References: <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
 <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz> <20180730144048.GW24267@dhcp22.suse.cz>
 <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
 <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz> <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
 <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz> <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
 <20180806120042.GL19540@dhcp22.suse.cz> <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
 <20180806181638.GE10003@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Thu, 9 Aug 2018 10:29:33 +0200
Message-ID: <CADF2uSqzt+u7vMkcD-vvT6tjz2bdHtrFK+p6s7NXGP-BJ34dRA@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="0000000000003edf8c0572fc6dd1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Christopher Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

--0000000000003edf8c0572fc6dd1
Content-Type: text/plain; charset="UTF-8"

On Mon 06-08-18 15:37:14, Cristopher Lameter wrote:
> > On Mon, 6 Aug 2018, Michal Hocko wrote:
> >
> > > Because a lot of FS metadata is fragmenting the memory and a large
> > > number of high order allocations which want to be served reclaim a lot
> > > of memory to achieve their gol. Considering a large part of memory is
> > > fragmented by unmovable objects there is no other way than to use
> > > reclaim to release that memory.
> >
> > Well it looks like the fragmentation issue gets worse. Is that enough to
> > consider merging the slab defrag patchset and get some work done on
> inodes
> > and dentries to make them movable (or use targetd reclaim)?
>
> Is there anything to test?
> --
> Michal Hocko
> SUSE Labs
>

> [Please do not top-post]

like this?

> The only way how kmemcg limit could help I can think of would be to
> enforce metadata reclaim much more often. But that is rather a bad
> workaround.

would that have some significant performance impact?
I would be willing to try if you think the idea is not thaaat bad.
If so, could you please explain what to do?

> > > Because a lot of FS metadata is fragmenting the memory and a large
> > > number of high order allocations which want to be served reclaim a lot
> > > of memory to achieve their gol. Considering a large part of memory is
> > > fragmented by unmovable objects there is no other way than to use
> > > reclaim to release that memory.
> >
> > Well it looks like the fragmentation issue gets worse. Is that enough to
> > consider merging the slab defrag patchset and get some work done on
inodes
> > and dentries to make them movable (or use targetd reclaim)?

> Is there anything to test?

Are you referring to some known issue there, possibly directly related to
mine?
If so, I would be willing to test that patchset, if it makes into the
kernel.org sources,
or if I'd have to patch that manually.


> Well, there are some drivers (mostly out-of-tree) which are high order
> hungry. You can try to trace all allocations which with order > 0 and
> see who that might be.
> # mount -t tracefs none /debug/trace/
> # echo stacktrace > /debug/trace/trace_options
> # echo "order>0" > /debug/trace/events/kmem/mm_page_alloc/filter
> # echo 1 > /debug/trace/events/kmem/mm_page_alloc/enable
> # cat /debug/trace/trace_pipe
>
> And later this to disable tracing.
> # echo 0 > /debug/trace/events/kmem/mm_page_alloc/enable

I just had a major cache-useless situation, with like 100M/8G usage only
and horrible performance. There you go:

https://nofile.io/f/mmwVedaTFsd

I think mysql occurs mostly, regardless of the binary name this is actually
mariadb in version 10.1.

> You do not have to drop all caches. echo 2 > /proc/sys/vm/drop_caches
> should be sufficient to drop metadata only.

that is exactly what I am doing, I already mentioned that 1> does not
make any difference at all 2> is the only way that helps.
just 5 minutes after doing that the usage grew to 2GB/10GB and is steadily
going up, as usual.

--0000000000003edf8c0572fc6dd1
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><div class=3D"gmail_quote">=
<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bor=
der-left:1px solid rgb(204,204,204);padding-left:1ex"><div class=3D"m_32074=
42179543416013gmail-HOEnZb"><div class=3D"m_3207442179543416013gmail-h5">On=
 Mon 06-08-18 15:37:14, Cristopher Lameter wrote:<br>
&gt; On Mon, 6 Aug 2018, Michal Hocko wrote:<br>
&gt; <br>
&gt; &gt; Because a lot of FS metadata is fragmenting the memory and a larg=
e<br>
&gt; &gt; number of high order allocations which want to be served reclaim =
a lot<br>
&gt; &gt; of memory to achieve their gol. Considering a large part of memor=
y is<br>
&gt; &gt; fragmented by unmovable objects there is no other way than to use=
<br>
&gt; &gt; reclaim to release that memory.<br>
&gt; <br>
&gt; Well it looks like the fragmentation issue gets worse. Is that enough =
to<br>
&gt; consider merging the slab defrag patchset and get some work done on in=
odes<br>
&gt; and dentries to make them movable (or use targetd reclaim)?<br>
<br>
</div></div>Is there anything to test?<br>
<div class=3D"m_3207442179543416013gmail-HOEnZb"><div class=3D"m_3207442179=
543416013gmail-h5">-- <br>
Michal Hocko<br>
SUSE Labs<br></div></div></blockquote><div><br></div><div>&gt; [Please do n=
ot top-post]<br></div><div><br></div><div>like this?</div><div><br></div><d=
iv>&gt; The only way how kmemcg limit could help I can think of would be to=
<br>&gt; enforce metadata reclaim much more often. But that is rather a bad=
<br>&gt; workaround.<br></div></div></div><div class=3D"gmail_extra"><br></=
div><div class=3D"gmail_extra">would that have some significant performance=
 impact?</div><div class=3D"gmail_extra">I would be willing to try if you t=
hink the idea is not thaaat bad.</div><div class=3D"gmail_extra">If so, cou=
ld you please explain what to do?</div><div class=3D"gmail_extra"><br></div=
><div class=3D"gmail_extra"><div class=3D"m_3207442179543416013gmail-HOEnZb=
"><div class=3D"m_3207442179543416013gmail-h5">&gt; &gt; &gt; Because a lot=
 of FS metadata is fragmenting the memory and a large<br>
&gt; &gt; &gt; number of high order allocations which want to be served rec=
laim a lot<br>
&gt; &gt; &gt; of memory to achieve their gol. Considering a large part of =
memory is<br>
&gt; &gt; &gt; fragmented by unmovable objects there is no other way than t=
o use<br>
&gt; &gt; &gt; reclaim to release that memory.<br>
&gt; &gt; <br>
&gt; &gt; Well it looks like the fragmentation issue gets worse. Is that en=
ough to<br>
&gt; &gt; consider merging the slab defrag patchset and get some work done =
on inodes<br>
&gt; &gt; and dentries to make them movable (or use targetd reclaim)?<br>
<br>
</div></div>&gt; Is there anything to test?<br></div><div class=3D"gmail_ex=
tra"><br></div><div class=3D"gmail_extra">Are you referring to some known i=
ssue there, possibly directly related to mine?</div><div class=3D"gmail_ext=
ra">If so, I would be willing to test that patchset, if it makes into the <=
a href=3D"http://kernel.org" target=3D"_blank">kernel.org</a> sources,</div=
><div class=3D"gmail_extra">or if I&#39;d have to patch that manually.<br><=
/div><div class=3D"gmail_extra"><br></div><div class=3D"gmail_extra"><br></=
div><div class=3D"gmail_extra">&gt; Well, there are some drivers (mostly ou=
t-of-tree) which are high order<br>
&gt; hungry. You can try to trace all allocations which with order &gt; 0 a=
nd<br>
&gt; see who that might be.<br>
&gt; # mount -t tracefs none /debug/trace/<br>
&gt; # echo stacktrace &gt; /debug/trace/trace_options<br>
&gt; # echo &quot;order&gt;0&quot; &gt; /debug/trace/events/kmem/mm_pa<wbr>=
ge_alloc/filter<br>
&gt; # echo 1 &gt; /debug/trace/events/kmem/mm_pa<wbr>ge_alloc/enable<br>
&gt; # cat /debug/trace/trace_pipe<br>
&gt; <br>
&gt; And later this to disable tracing.<br>&gt; # echo 0 &gt; /debug/trace/=
events/kmem/mm_pa<wbr>ge_alloc/enable<br></div><div class=3D"gmail_extra"><=
br></div><div class=3D"gmail_extra">I just had a major cache-useless situat=
ion, with like 100M/8G usage only</div><div class=3D"gmail_extra">and horri=
ble performance. There you go:<br></div><div class=3D"gmail_extra"><br></di=
v><div class=3D"gmail_extra"><a href=3D"https://nofile.io/f/mmwVedaTFsd" ta=
rget=3D"_blank">https://nofile.io/f/<wbr>mmwVedaTFsd</a><br></div><div clas=
s=3D"gmail_extra"><br></div><div class=3D"gmail_extra">I think mysql occurs=
 mostly, regardless of the binary name this is actually</div><div class=3D"=
gmail_extra">mariadb in version 10.1.</div><div class=3D"gmail_extra"><br><=
/div><div class=3D"gmail_extra"><span class=3D"m_3207442179543416013gmail-i=
m">
</span>&gt; You do not have to drop all caches. echo 2 &gt; /proc/sys/vm/dr=
op_caches<br>&gt; should be sufficient to drop metadata only.</div><div cla=
ss=3D"gmail_extra"><br></div><div class=3D"gmail_extra">that is exactly wha=
t I am doing, I already mentioned that 1&gt; does not</div><div class=3D"gm=
ail_extra">make any difference at all 2&gt; is the only way that helps.</di=
v><div class=3D"gmail_extra">just 5 minutes after doing that the usage grew=
 to 2GB/10GB and is steadily</div><div class=3D"gmail_extra">going up, as u=
sual.<br></div></div>

--0000000000003edf8c0572fc6dd1--
