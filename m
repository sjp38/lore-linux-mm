Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47C0F6B1BE3
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 20:36:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s205-v6so110276wmf.7
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 17:36:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y185-v6sor36041wmy.42.2018.08.20.17.36.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 17:36:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CADF2uSqzt+u7vMkcD-vvT6tjz2bdHtrFK+p6s7NXGP-BJ34dRA@mail.gmail.com>
References: <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
 <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz> <20180730144048.GW24267@dhcp22.suse.cz>
 <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
 <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz> <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
 <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz> <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
 <20180806120042.GL19540@dhcp22.suse.cz> <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
 <20180806181638.GE10003@dhcp22.suse.cz> <CADF2uSqzt+u7vMkcD-vvT6tjz2bdHtrFK+p6s7NXGP-BJ34dRA@mail.gmail.com>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Tue, 21 Aug 2018 02:36:05 +0200
Message-ID: <CADF2uSp7MKYWL7Yu5TDOT4qe0v-0iiq+Tv9J6rnzCSgahXbNaA@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="0000000000001e44390573e73628"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Christopher Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

--0000000000001e44390573e73628
Content-Type: text/plain; charset="UTF-8"

> The only way how kmemcg limit could help I can think of would be to
>> enforce metadata reclaim much more often. But that is rather a bad
>> workaround.
>
>would that have some significant performance impact?
>I would be willing to try if you think the idea is not thaaat bad.
>If so, could you please explain what to do?
>
>> > > Because a lot of FS metadata is fragmenting the memory and a large
>> > > number of high order allocations which want to be served reclaim a
lot
>> > > of memory to achieve their gol. Considering a large part of memory is
>> > > fragmented by unmovable objects there is no other way than to use
>> > > reclaim to release that memory.
>> >
>> > Well it looks like the fragmentation issue gets worse. Is that enough
to
>> > consider merging the slab defrag patchset and get some work done on
inodes
>> > and dentries to make them movable (or use targetd reclaim)?
>
>> Is there anything to test?
>
>Are you referring to some known issue there, possibly directly related to
mine?
>If so, I would be willing to test that patchset, if it makes into the
kernel.org sources,
>or if I'd have to patch that manually.
>
>
>> Well, there are some drivers (mostly out-of-tree) which are high order
>> hungry. You can try to trace all allocations which with order > 0 and
>> see who that might be.
>> # mount -t tracefs none /debug/trace/
>> # echo stacktrace > /debug/trace/trace_options
>> # echo "order>0" > /debug/trace/events/kmem/mm_page_alloc/filter
>> # echo 1 > /debug/trace/events/kmem/mm_page_alloc/enable
>> # cat /debug/trace/trace_pipe
>>
>> And later this to disable tracing.
>> # echo 0 > /debug/trace/events/kmem/mm_page_alloc/enable
>
>I just had a major cache-useless situation, with like 100M/8G usage only
>and horrible performance. There you go:
>
>https://nofile.io/f/mmwVedaTFsd
>
>I think mysql occurs mostly, regardless of the binary name this is actually
>mariadb in version 10.1.
>
>> You do not have to drop all caches. echo 2 > /proc/sys/vm/drop_caches
>> should be sufficient to drop metadata only.
>
>that is exactly what I am doing, I already mentioned that 1> does not
>make any difference at all 2> is the only way that helps.
>just 5 minutes after doing that the usage grew to 2GB/10GB and is steadily
>going up, as usual.
>
>
>2018-08-09 10:29 GMT+02:00 Marinko Catovic <marinko.catovic@gmail.com>:
>
>
>
>        On Mon 06-08-18 15:37:14, Cristopher Lameter wrote:
>        > On Mon, 6 Aug 2018, Michal Hocko wrote:
>        >
>        > > Because a lot of FS metadata is fragmenting the memory and a
large
>        > > number of high order allocations which want to be served
reclaim a lot
>        > > of memory to achieve their gol. Considering a large part of
memory is
>        > > fragmented by unmovable objects there is no other way than to
use
>        > > reclaim to release that memory.
>        >
>        > Well it looks like the fragmentation issue gets worse. Is that
enough to
>        > consider merging the slab defrag patchset and get some work done
on inodes
>        > and dentries to make them movable (or use targetd reclaim)?
>
>        Is there anything to test?
>        --
>        Michal Hocko
>        SUSE Labs
>
>
>    > [Please do not top-post]
>
>    like this?
>
>    > The only way how kmemcg limit could help I can think of would be to
>    > enforce metadata reclaim much more often. But that is rather a bad
>    > workaround.
>
>    would that have some significant performance impact?
>    I would be willing to try if you think the idea is not thaaat bad.
>    If so, could you please explain what to do?
>
>    > > > Because a lot of FS metadata is fragmenting the memory and a
large
>    > > > number of high order allocations which want to be served reclaim
a lot
>    > > > of memory to achieve their gol. Considering a large part of
memory is
>    > > > fragmented by unmovable objects there is no other way than to use
>    > > > reclaim to release that memory.
>    > >
>    > > Well it looks like the fragmentation issue gets worse. Is that
enough to
>    > > consider merging the slab defrag patchset and get some work done
on inodes
>    > > and dentries to make them movable (or use targetd reclaim)?
>
>    > Is there anything to test?
>
>    Are you referring to some known issue there, possibly directly related
to mine?
>    If so, I would be willing to test that patchset, if it makes into the
kernel.org sources,
>    or if I'd have to patch that manually.
>
>
>    > Well, there are some drivers (mostly out-of-tree) which are high
order
>    > hungry. You can try to trace all allocations which with order > 0 and
>    > see who that might be.
>    > # mount -t tracefs none /debug/trace/
>    > # echo stacktrace > /debug/trace/trace_options
>    > # echo "order>0" > /debug/trace/events/kmem/mm_page_alloc/filter
>    > # echo 1 > /debug/trace/events/kmem/mm_page_alloc/enable
>    > # cat /debug/trace/trace_pipe
>    >
>    > And later this to disable tracing.
>    > # echo 0 > /debug/trace/events/kmem/mm_page_alloc/enable
>
>    I just had a major cache-useless situation, with like 100M/8G usage
only
>    and horrible performance. There you go:
>
>    https://nofile.io/f/mmwVedaTFsd
>
>    I think mysql occurs mostly, regardless of the binary name this is
actually
>    mariadb in version 10.1.
>
>    > You do not have to drop all caches. echo 2 > /proc/sys/vm/drop_caches
>    > should be sufficient to drop metadata only.
>
>    that is exactly what I am doing, I already mentioned that 1> does not
>    make any difference at all 2> is the only way that helps.
>    just 5 minutes after doing that the usage grew to 2GB/10GB and is
steadily
>    going up, as usual.

Is there anything you can read from these results?
The issue keeps occuring, the latest one was even totally unexpected in the
morning hours,
causing downtime the entire morning until noon when I could check and drop
the caches again.

I also reset O_DIRECT from mariadb to `fsync`, the new default in their
latest release, hoping
that this would help, but it did not.

Before giving totally up I'd like to know whether there is any solution for
this, where again I can
not believe that I am the only one affected. this *has* to affect anyone
with similar a use case,
I do not see what is so special about mine. this is simply many users with
many files, every
larger shared hosting provider should experience the totally same behaviour
with the 4.x kernel branch.

--0000000000001e44390573e73628
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">&gt; The only way how kmemcg limit could help I can think =
of would be to<br>&gt;&gt; enforce metadata reclaim much more often. But th=
at is rather a bad<br>&gt;&gt; workaround.<br>&gt;<br>&gt;would that have s=
ome significant performance impact?<br>&gt;I would be willing to try if you=
 think the idea is not thaaat bad.<br>&gt;If so, could you please explain w=
hat to do?<br>&gt;<br>&gt;&gt; &gt; &gt; Because a lot of FS metadata is fr=
agmenting the memory and a large<br>&gt;&gt; &gt; &gt; number of high order=
 allocations which want to be served reclaim a lot<br>&gt;&gt; &gt; &gt; of=
 memory to achieve their gol. Considering a large part of memory is<br>&gt;=
&gt; &gt; &gt; fragmented by unmovable objects there is no other way than t=
o use<br>&gt;&gt; &gt; &gt; reclaim to release that memory.<br>&gt;&gt; &gt=
; <br>&gt;&gt; &gt; Well it looks like the fragmentation issue gets worse. =
Is that enough to<br>&gt;&gt; &gt; consider merging the slab defrag patchse=
t and get some work done on inodes<br>&gt;&gt; &gt; and dentries to make th=
em movable (or use targetd reclaim)?<br>&gt;<br>&gt;&gt; Is there anything =
to test?<br>&gt;<br>&gt;Are you referring to some known issue there, possib=
ly directly related to mine?<br>&gt;If so, I would be willing to test that =
patchset, if it makes into the <a href=3D"http://kernel.org">kernel.org</a>=
 sources,<br>&gt;or if I&#39;d have to patch that manually.<br>&gt;<br>&gt;=
<br>&gt;&gt; Well, there are some drivers (mostly out-of-tree) which are hi=
gh order<br>&gt;&gt; hungry. You can try to trace all allocations which wit=
h order &gt; 0 and<br>&gt;&gt; see who that might be.<br>&gt;&gt; # mount -=
t tracefs none /debug/trace/<br>&gt;&gt; # echo stacktrace &gt; /debug/trac=
e/trace_options<br>&gt;&gt; # echo &quot;order&gt;0&quot; &gt; /debug/trace=
/events/kmem/mm_page_alloc/filter<br>&gt;&gt; # echo 1 &gt; /debug/trace/ev=
ents/kmem/mm_page_alloc/enable<br>&gt;&gt; # cat /debug/trace/trace_pipe<br=
>&gt;&gt; <br>&gt;&gt; And later this to disable tracing.<br>&gt;&gt; # ech=
o 0 &gt; /debug/trace/events/kmem/mm_page_alloc/enable<br>&gt;<br>&gt;I jus=
t had a major cache-useless situation, with like 100M/8G usage only<br>&gt;=
and horrible performance. There you go:<br>&gt;<br>&gt;<a href=3D"https://n=
ofile.io/f/mmwVedaTFsd">https://nofile.io/f/mmwVedaTFsd</a><br>&gt;<br>&gt;=
I think mysql occurs mostly, regardless of the binary name this is actually=
<br>&gt;mariadb in version 10.1.<br>&gt;<br>&gt;&gt; You do not have to dro=
p all caches. echo 2 &gt; /proc/sys/vm/drop_caches<br>&gt;&gt; should be su=
fficient to drop metadata only.<br>&gt;<br>&gt;that is exactly what I am do=
ing, I already mentioned that 1&gt; does not<br>&gt;make any difference at =
all 2&gt; is the only way that helps.<br>&gt;just 5 minutes after doing tha=
t the usage grew to 2GB/10GB and is steadily<br>&gt;going up, as usual.<br>=
&gt;<br>&gt;<br>&gt;2018-08-09 10:29 GMT+02:00 Marinko Catovic &lt;<a href=
=3D"mailto:marinko.catovic@gmail.com">marinko.catovic@gmail.com</a>&gt;:<br=
>&gt;<br>&gt;<br>&gt;<br>&gt;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 On =
Mon 06-08-18 15:37:14, Cristopher Lameter wrote:<br>&gt;=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 &gt; On Mon, 6 Aug 2018, Michal Hocko wrote:<br>&g=
t;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 &gt;<br>&gt;=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 &gt; &gt; Because a lot of FS metadata is fragment=
ing the memory and a large<br>&gt;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 &gt; &gt; number of high order allocations which want to be served recl=
aim a lot<br>&gt;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 &gt; &gt; of me=
mory to achieve their gol. Considering a large part of memory is<br>&gt;=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 &gt; &gt; fragmented by unmovable o=
bjects there is no other way than to use<br>&gt;=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 &gt; &gt; reclaim to release that memory.<br>&gt;=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 &gt;<br>&gt;=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 &gt; Well it looks like the fragmentation issue gets worse.=
 Is that enough to<br>&gt;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 &gt; c=
onsider merging the slab defrag patchset and get some work done on inodes<b=
r>&gt;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 &gt; and dentries to make =
them movable (or use targetd reclaim)?<br>&gt;<br>&gt;=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 Is there anything to test?<br>&gt;=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 -- <br>&gt;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 Michal Hocko<br>&gt;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 SUSE Lab=
s<br>&gt;<br>&gt;<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; [Please do not top-post]<b=
r>&gt;<br>&gt;=C2=A0=C2=A0=C2=A0 like this?<br>&gt;<br>&gt;=C2=A0=C2=A0=C2=
=A0 &gt; The only way how kmemcg limit could help I can think of would be t=
o<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; enforce metadata reclaim much more often. =
But that is rather a bad<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; workaround.<br>&gt;=
<br>&gt;=C2=A0=C2=A0=C2=A0 would that have some significant performance imp=
act?<br>&gt;=C2=A0=C2=A0=C2=A0 I would be willing to try if you think the i=
dea is not thaaat bad.<br>&gt;=C2=A0=C2=A0=C2=A0 If so, could you please ex=
plain what to do?<br>&gt;<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; &gt; &gt; Because =
a lot of FS metadata is fragmenting the memory and a large<br>&gt;=C2=A0=C2=
=A0=C2=A0 &gt; &gt; &gt; number of high order allocations which want to be =
served reclaim a lot<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; &gt; &gt; of memory to =
achieve their gol. Considering a large part of memory is<br>&gt;=C2=A0=C2=
=A0=C2=A0 &gt; &gt; &gt; fragmented by unmovable objects there is no other =
way than to use<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; &gt; &gt; reclaim to release=
 that memory.<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; &gt; <br>&gt;=C2=A0=C2=A0=C2=
=A0 &gt; &gt; Well it looks like the fragmentation issue gets worse. Is tha=
t enough to<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; &gt; consider merging the slab d=
efrag patchset and get some work done on inodes<br>&gt;=C2=A0=C2=A0=C2=A0 &=
gt; &gt; and dentries to make them movable (or use targetd reclaim)?<br>&gt=
;<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; Is there anything to test?<br>&gt;<br>&gt;=
=C2=A0=C2=A0=C2=A0 Are you referring to some known issue there, possibly di=
rectly related to mine?<br>&gt;=C2=A0=C2=A0=C2=A0 If so, I would be willing=
 to test that patchset, if it makes into the <a href=3D"http://kernel.org">=
kernel.org</a> sources,<br>&gt;=C2=A0=C2=A0=C2=A0 or if I&#39;d have to pat=
ch that manually.<br>&gt;<br>&gt;<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; Well, ther=
e are some drivers (mostly out-of-tree) which are high order<br>&gt;=C2=A0=
=C2=A0=C2=A0 &gt; hungry. You can try to trace all allocations which with o=
rder &gt; 0 and<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; see who that might be.<br>&g=
t;=C2=A0=C2=A0=C2=A0 &gt; # mount -t tracefs none /debug/trace/<br>&gt;=C2=
=A0=C2=A0=C2=A0 &gt; # echo stacktrace &gt; /debug/trace/trace_options<br>&=
gt;=C2=A0=C2=A0=C2=A0 &gt; # echo &quot;order&gt;0&quot; &gt; /debug/trace/=
events/kmem/mm_page_alloc/filter<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; # echo 1 &g=
t; /debug/trace/events/kmem/mm_page_alloc/enable<br>&gt;=C2=A0=C2=A0=C2=A0 =
&gt; # cat /debug/trace/trace_pipe<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; <br>&gt;=
=C2=A0=C2=A0=C2=A0 &gt; And later this to disable tracing.<br>&gt;=C2=A0=C2=
=A0=C2=A0 &gt; # echo 0 &gt; /debug/trace/events/kmem/mm_page_alloc/enable<=
br>&gt;<br>&gt;=C2=A0=C2=A0=C2=A0 I just had a major cache-useless situatio=
n, with like 100M/8G usage only<br>&gt;=C2=A0=C2=A0=C2=A0 and horrible perf=
ormance. There you go:<br>&gt;<br>&gt;=C2=A0=C2=A0=C2=A0 <a href=3D"https:/=
/nofile.io/f/mmwVedaTFsd">https://nofile.io/f/mmwVedaTFsd</a><br>&gt;<br>&g=
t;=C2=A0=C2=A0=C2=A0 I think mysql occurs mostly, regardless of the binary =
name this is actually<br>&gt;=C2=A0=C2=A0=C2=A0 mariadb in version 10.1.<br=
>&gt;<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; You do not have to drop all caches. ec=
ho 2 &gt; /proc/sys/vm/drop_caches<br>&gt;=C2=A0=C2=A0=C2=A0 &gt; should be=
 sufficient to drop metadata only.<br>&gt;<br>&gt;=C2=A0=C2=A0=C2=A0 that i=
s exactly what I am doing, I already mentioned that 1&gt; does not<br>&gt;=
=C2=A0=C2=A0=C2=A0 make any difference at all 2&gt; is the only way that he=
lps.<br>&gt;=C2=A0=C2=A0=C2=A0 just 5 minutes after doing that the usage gr=
ew to 2GB/10GB and is steadily<br>&gt;=C2=A0=C2=A0=C2=A0 going up, as usual=
.<br><div><br></div><div>Is there anything you can read from these results?=
</div><div>The issue keeps occuring, the latest one was even totally unexpe=
cted in the morning hours,</div><div>causing downtime the entire morning un=
til noon when I could check and drop the caches again.</div><div><br></div>=
<div>I also reset O_DIRECT from mariadb to `fsync`, the new default in thei=
r latest release, hoping</div><div>that this would help, but it did not.<br=
></div><div><br></div><div>Before giving totally up I&#39;d like to know wh=
ether there is any solution for this, where again I can</div><div>not belie=
ve that I am the only one affected. this *has* to affect anyone with simila=
r a use case,</div><div>I do not see what is so special about mine. this is=
 simply many users with many files, every</div><div>larger shared hosting p=
rovider should experience the totally same behaviour with the 4.x kernel br=
anch.</div><div><br></div></div>

--0000000000001e44390573e73628--
