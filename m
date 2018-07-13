Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 382176B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:48:11 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u1-v6so5590750wrs.18
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 08:48:11 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y2-v6sor1843996wmg.19.2018.07.13.08.48.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 08:48:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180712113411.GB328@dhcp22.suse.cz>
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Fri, 13 Jul 2018 17:48:08 +0200
Message-ID: <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="0000000000000b6ac30570e36833"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--0000000000000b6ac30570e36833
Content-Type: text/plain; charset="UTF-8"

hello Michal


well these hints were just ideas mentioned by some people, it took me weeks
just to figure
out that 2>drop_caches helps, still not knowing why this happens.

Right now I am observing ~18GB of unused RAM, since yesterday, so this is
not always
about 100MB/3.5GB, but right now it may be in the process of shrinking.
I really can not tell for sure, this is so nondeterministic - I just wish I
could reproduce it for better testing.

Right now top shows:
KiB Mem : 65892044 total, 18169232 free, 11879604 used, 35843208 buff/cache
Where 1GB goes to buffers, the rest to cache, the host *is* busy and the
buff/cache consumed
all RAM yesterday, where I did 2>drop_caches about one day before.

Another host (still) shows full usage. That other one is 1:1 the same by
software and config,
but with different data/users; the use-cases and load are pretty much
similar.

Affected host at this time:
https://pastebin.com/fRQMPuwb
https://pastebin.com/tagXJRi1  .. 3 minutes later
https://pastebin.com/8YNFfKXf  .. 3 minutes later
https://pastebin.com/UEq7NKR4 .. 3 minutes later

To compare - this is the other host, that is still showing full
buffers/cache usage by now:
https://pastebin.com/Jraux2gy

Usually both show this more or less at the same time, sometimes it is the
one, sometimes
the other. Other hosts I have are currently not under similar high load,
making it even harder
to compare.

However, right now I can not observe this dropping towards really low
values, but I am sure it will come.

fs is ext4, mount options are auto,rw,data=writeback,noatime
,nodiratime,nodev,nosuid,async
previous mount options with same behavior also had max_dir_size_kb, quotas
and defaults for data=
so I also played around with these, but that made no difference.

---------

follow up (sorry, messed up with reply-to this mailing list):


https://pastebin.com/0v4ZFNCv .. one hour later, right after my last
report, 22GB free
https://pastebin.com/rReWnHtE .. one day later, 28GB free

It is interesting to see however, that this did not get that low as
mentioned before.
So not sure where this is going right now, but nevertheless, the RAM is not
occupied fully,
there should be no reason to allow 28GB to be free at all.

Still lots I/O, and I am 100% positive that if I'd echo 2 > drop_caches,
this would fill up the
entire RAM again.


What I can see is that buffers are around 500-700MB, the values increase
and decrease
all the time, really "oscillating" around 600. afaik this should get as
high as possible, as long
there is free ram - the other host that is still healthy has about 2GB/48GB
fully occupying RAM.

Currently I have set vm.dirty_ratio = 15, vm.dirty_background_ratio = 3,
vm.vfs_cache_pressure = 1
and the low usage occurred 3 days before, other values like the defaults or
when I was playing
around with vm.dirty_ratio = 90, vm.dirty_background_ratio = 80 and
whatever cache_pressure
showed similar results.


2018-07-12 13:34 GMT+02:00 Michal Hocko <mhocko@kernel.org>:

> On Wed 11-07-18 15:18:30, Marinko Catovic wrote:
> > hello guys
> >
> >
> > I tried in a few IRC, people told me to ask here, so I'll give it a try.
> >
> >
> > I have a very weird issue with mm on several hosts.
> > The systems are for shared hosting, so lots of users there with lots of
> > files.
> > Maybe 5TB of files per host, several million at least, there is lots of
> I/O
> > which can be handled perfectly fine with buffers/cache
> >
> > The kernel version is the latest stable, 4.17.4, I had 3.x before and did
> > not notice any issues until now. the same is for 4.16 which was in use
> > before:
> >
> > The hosts altogether have 64G of RAM and operate with SSD+HDD.
> > HDDs are the issue here, since those 5TB of data are stored there, there
> > goes the high I/O.
> > Running applications need about 15GB, so say 40GB of RAM are left for
> > buffers/caching.
> >
> > Usually this works perfectly fine. The buffers take about 1-3G of RAM,
> the
> > cache the rest, say 35GB as an example.
> > But every now and then, maybe every 2 days it happens that both drop to
> > really low values, say 100MB buffers, 3GB caches and the rest of the RAM
> is
> > not in use, so there are about 35GB+ of totally free RAM.
> >
> > The performance of the host goes down significantly then, as it becomes
> > unusable at some point, since it behaves as if the buffers/cache were
> > totally useless.
> > After lots and lots of playing around I noticed that when shutting down
> all
> > services that access the HDDs on the system and restarting them, that
> this
> > does *not* make any difference.
> >
> > But what did make a difference was stopping and umounting the fs,
> mounting
> > it again and starting the services.
> > Then the buffers+cache built up to 5GB/35GB as usual after a while and
> > everything was perfectly fine again!
> >
> > I noticed that what happens when umount is called, that the caches are
> > being dropped. So I gave it a try:
> >
> > sync; echo 2 > /proc/sys/vm/drop_caches
> >
> > has the exactly same effect. Note that echo 1 > .. does not.
> >
> > So if that low usage like 100MB/3GB occurs I'd have to drop the caches by
> > echoing 2 to drop_caches. The 3GB then become even lower, which is
> > expected, but then at least the buffers/cache built up again to ordinary
> > values and the usual performance is restored after a few minutes.
> > I have never seen this before, this happened after I switched the systems
> > to newer ones, where the old ones had kernel 3.x, this behavior was never
> > observed before.
> >
> > Do you have *any idea* at all what could be causing this? that issue is
> > bugging me since over a month and seriously really disturbs everything
> I'm
> > doing since lot of people access that data and all of them start to
> > complain at some point where I see that the caches became useless at that
> > time, having to drop them to rebuild again.
> >
> > Some guys in IRC suggested that his could be a fragmentation problem or
> > something, or about slab shrinking.
>
> Well, the page cache shouldn't really care about fragmentation because
> single pages are used. Btw. what is the filesystem that you are using?
>
> > The problem is that I can not reproduce this, I have to wait a while,
> maybe
> > 2 days to observe that, until that the buffers/caches are fully in use
> and
> > at some point they decrease within a few hours to those useless values.
> > Sadly this is a production system and I can not play that much around,
> > already causing downtime when dropping caches (populating caches needs
> > maybe 5-10 minutes until the performance is ok again).
>
> This doesn't really ring bells for me.
>
> > Please tell me whatever info you need me to pastebin and when
> (before/after
> > what event).
> > Any hints are appreciated a lot, it really gives me lots of headache,
> since
> > I am really busy with other things. Thank you very much!
>
> Could you collect /proc/vmstat every few seconds over that time period?
> Maybe it will tell us more.
> --
> Michal Hocko
> SUSE Labs
>

--0000000000000b6ac30570e36833
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>hello Michal</div><div><br></div><div><br></div><div>=
well these hints were just ideas mentioned by some people, it took me weeks=
 just to figure</div><div>out that 2&gt;drop_caches helps, still not knowin=
g why this happens.</div><div><br></div><div>Right now I am observing ~18GB=
 of unused RAM, since yesterday, so this is not always</div><div>about 100M=
B/3.5GB, but right now it may be in the process of shrinking.</div><div>I r=
eally can not tell for sure, this is so nondeterministic - I just wish I co=
uld reproduce it for better testing.</div><div><br></div><div>Right now top=
 shows:</div><div>KiB Mem : 65892044 total, 18169232 free, 11879604 used, 3=
5843208 buff/cache<br></div><div>Where 1GB goes to buffers, the rest to cac=
he, the host *is* busy and the buff/cache consumed</div><div>all RAM yester=
day, where I did 2&gt;drop_caches about one day before.<br></div><div><br><=
/div><div>Another host (still) shows full usage. That other one is 1:1 the =
same by software and config,</div><div>but with different data/users; the u=
se-cases and load are pretty much similar.</div><div><br></div><div>Affecte=
d host at this time:</div><div><a href=3D"https://pastebin.com/fRQMPuwb" ta=
rget=3D"_blank">https://pastebin.com/fRQMPuwb</a> <br></div><div><a href=3D=
"https://pastebin.com/tagXJRi1" target=3D"_blank">https://pastebin.com/tagX=
JRi1</a>=C2=A0 .. 3 minutes later<br></div><div><a href=3D"https://pastebin=
.com/8YNFfKXf" target=3D"_blank">https://pastebin.com/8YNFfKXf</a>=C2=A0 ..=
 3 minutes later</div><div><a href=3D"https://pastebin.com/UEq7NKR4" target=
=3D"_blank">https://pastebin.com/UEq7NKR4</a> .. 3 minutes later<br></div><=
div><br></div><div>To compare - this is the other host, that is still showi=
ng full buffers/cache usage by now:</div><div><a href=3D"https://pastebin.c=
om/Jraux2gy" target=3D"_blank">https://pastebin.com/Jraux2gy</a></div><div>=
<br></div><div>Usually both show this more or less at the same time, someti=
mes it is the one, sometimes</div><div>the other. Other hosts I have are cu=
rrently not under similar high load, making it even harder</div><div>to com=
pare.</div><div><br></div><div>However, right now I can not observe this dr=
opping towards really low values, but I am sure it will come.</div><div><br=
></div><div>fs is ext4, mount options are auto,rw,data=3Dwriteback,noatime<=
wbr>,nodiratime,nodev,nosuid,async</div><div></div><div>previous mount opti=
ons with same behavior also had max_dir_size_kb, quotas and defaults for da=
ta=3D</div><div>so I also played around with these, but that made no differ=
ence.</div><div><br></div><div>---------</div><div><br></div><div>follow up=
 (sorry, messed up with reply-to this mailing list):<br><br><br><a href=3D"=
https://pastebin.com/0v4ZFNCv" target=3D"_blank">https://pastebin.com/0v4ZF=
NCv</a> .. one hour later, right after my last report, 22GB free<br><a href=
=3D"https://pastebin.com/rReWnHtE" target=3D"_blank">https://pastebin.com/r=
ReWnHtE</a> .. one day later, 28GB free <br><br>It is interesting to see ho=
wever, that this did not get that low as mentioned before.<br>So not sure w=
here this is going right now, but nevertheless, the RAM is not occupied ful=
ly,<br>there should be no reason to allow 28GB to be free at all.<br><br>St=
ill lots I/O, and I am 100% positive that if I&#39;d echo 2 &gt; drop_cache=
s, this would fill up the<br>entire RAM again.<br><br><br>What I can see is=
 that buffers are around 500-700MB, the values increase and decrease<br>all=
 the time, really &quot;oscillating&quot; around 600. afaik this should get=
 as high as possible, as long<br>there is free ram - the other host that is=
 still healthy has about 2GB/48GB fully occupying RAM.<br><br>Currently I h=
ave set vm.dirty_ratio =3D 15, vm.dirty_background_ratio =3D 3, vm.vfs_cach=
e_pressure =3D 1<br>and the low usage occurred 3 days before, other values =
like the defaults or when I was playing<br>around with vm.dirty_ratio =3D 9=
0, vm.dirty_background_ratio =3D 80 and whatever cache_pressure<br>showed s=
imilar results.<br></div><div><br></div><div class=3D"gmail_extra"><br><div=
 class=3D"gmail_quote">2018-07-12 13:34 GMT+02:00 Michal Hocko <span dir=3D=
"ltr">&lt;<a href=3D"mailto:mhocko@kernel.org" target=3D"_blank">mhocko@ker=
nel.org</a>&gt;</span>:<br><blockquote class=3D"gmail_quote" style=3D"margi=
n:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div><div>On Wed =
11-07-18 15:18:30, Marinko Catovic wrote:<br>
&gt; hello guys<br>
&gt; <br>
&gt; <br>
&gt; I tried in a few IRC, people told me to ask here, so I&#39;ll give it =
a try.<br>
&gt; <br>
&gt; <br>
&gt; I have a very weird issue with mm on several hosts.<br>
&gt; The systems are for shared hosting, so lots of users there with lots o=
f<br>
&gt; files.<br>
&gt; Maybe 5TB of files per host, several million at least, there is lots o=
f I/O<br>
&gt; which can be handled perfectly fine with buffers/cache<br>
&gt; <br>
&gt; The kernel version is the latest stable, 4.17.4, I had 3.x before and =
did<br>
&gt; not notice any issues until now. the same is for 4.16 which was in use=
<br>
&gt; before:<br>
&gt; <br>
&gt; The hosts altogether have 64G of RAM and operate with SSD+HDD.<br>
&gt; HDDs are the issue here, since those 5TB of data are stored there, the=
re<br>
&gt; goes the high I/O.<br>
&gt; Running applications need about 15GB, so say 40GB of RAM are left for<=
br>
&gt; buffers/caching.<br>
&gt; <br>
&gt; Usually this works perfectly fine. The buffers take about 1-3G of RAM,=
 the<br>
&gt; cache the rest, say 35GB as an example.<br>
&gt; But every now and then, maybe every 2 days it happens that both drop t=
o<br>
&gt; really low values, say 100MB buffers, 3GB caches and the rest of the R=
AM is<br>
&gt; not in use, so there are about 35GB+ of totally free RAM.<br>
&gt; <br>
&gt; The performance of the host goes down significantly then, as it become=
s<br>
&gt; unusable at some point, since it behaves as if the buffers/cache were<=
br>
&gt; totally useless.<br>
&gt; After lots and lots of playing around I noticed that when shutting dow=
n all<br>
&gt; services that access the HDDs on the system and restarting them, that =
this<br>
&gt; does *not* make any difference.<br>
&gt; <br>
&gt; But what did make a difference was stopping and umounting the fs, moun=
ting<br>
&gt; it again and starting the services.<br>
&gt; Then the buffers+cache built up to 5GB/35GB as usual after a while and=
<br>
&gt; everything was perfectly fine again!<br>
&gt; <br>
&gt; I noticed that what happens when umount is called, that the caches are=
<br>
&gt; being dropped. So I gave it a try:<br>
&gt; <br>
&gt; sync; echo 2 &gt; /proc/sys/vm/drop_caches<br>
&gt; <br>
&gt; has the exactly same effect. Note that echo 1 &gt; .. does not.<br>
&gt; <br>
&gt; So if that low usage like 100MB/3GB occurs I&#39;d have to drop the ca=
ches by<br>
&gt; echoing 2 to drop_caches. The 3GB then become even lower, which is<br>
&gt; expected, but then at least the buffers/cache built up again to ordina=
ry<br>
&gt; values and the usual performance is restored after a few minutes.<br>
&gt; I have never seen this before, this happened after I switched the syst=
ems<br>
&gt; to newer ones, where the old ones had kernel 3.x, this behavior was ne=
ver<br>
&gt; observed before.<br>
&gt; <br>
&gt; Do you have *any idea* at all what could be causing this? that issue i=
s<br>
&gt; bugging me since over a month and seriously really disturbs everything=
 I&#39;m<br>
&gt; doing since lot of people access that data and all of them start to<br=
>
&gt; complain at some point where I see that the caches became useless at t=
hat<br>
&gt; time, having to drop them to rebuild again.<br>
&gt; <br>
&gt; Some guys in IRC suggested that his could be a fragmentation problem o=
r<br>
&gt; something, or about slab shrinking.<br>
<br>
</div></div>Well, the page cache shouldn&#39;t really care about fragmentat=
ion because<br>
single pages are used. Btw. what is the filesystem that you are using?<br>
<span><br>
&gt; The problem is that I can not reproduce this, I have to wait a while, =
maybe<br>
&gt; 2 days to observe that, until that the buffers/caches are fully in use=
 and<br>
&gt; at some point they decrease within a few hours to those useless values=
.<br>
&gt; Sadly this is a production system and I can not play that much around,=
<br>
&gt; already causing downtime when dropping caches (populating caches needs=
<br>
&gt; maybe 5-10 minutes until the performance is ok again).<br>
<br>
</span>This doesn&#39;t really ring bells for me.<br>
<span><br>
&gt; Please tell me whatever info you need me to pastebin and when (before/=
after<br>
&gt; what event).<br>
&gt; Any hints are appreciated a lot, it really gives me lots of headache, =
since<br>
&gt; I am really busy with other things. Thank you very much!<br>
<br>
</span>Could you collect /proc/vmstat every few seconds over that time peri=
od?<br>
Maybe it will tell us more.<br>
<span><font color=3D"#888888">-- <br>
Michal Hocko<br>
SUSE Labs<br>
</font></span></blockquote></div><br></div></div>

--0000000000000b6ac30570e36833--
