Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9910F6B026E
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:18:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w21-v6so1868646wmc.4
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:18:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c6-v6sor8851806wrf.61.2018.07.11.06.18.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 06:18:30 -0700 (PDT)
MIME-Version: 1.0
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Wed, 11 Jul 2018 15:18:30 +0200
Message-ID: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
Subject: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="00000000000032cbf60570b91534"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--00000000000032cbf60570b91534
Content-Type: text/plain; charset="UTF-8"

hello guys


I tried in a few IRC, people told me to ask here, so I'll give it a try.


I have a very weird issue with mm on several hosts.
The systems are for shared hosting, so lots of users there with lots of
files.
Maybe 5TB of files per host, several million at least, there is lots of I/O
which can be handled perfectly fine with buffers/cache

The kernel version is the latest stable, 4.17.4, I had 3.x before and did
not notice any issues until now. the same is for 4.16 which was in use
before:

The hosts altogether have 64G of RAM and operate with SSD+HDD.
HDDs are the issue here, since those 5TB of data are stored there, there
goes the high I/O.
Running applications need about 15GB, so say 40GB of RAM are left for
buffers/caching.

Usually this works perfectly fine. The buffers take about 1-3G of RAM, the
cache the rest, say 35GB as an example.
But every now and then, maybe every 2 days it happens that both drop to
really low values, say 100MB buffers, 3GB caches and the rest of the RAM is
not in use, so there are about 35GB+ of totally free RAM.

The performance of the host goes down significantly then, as it becomes
unusable at some point, since it behaves as if the buffers/cache were
totally useless.
After lots and lots of playing around I noticed that when shutting down all
services that access the HDDs on the system and restarting them, that this
does *not* make any difference.

But what did make a difference was stopping and umounting the fs, mounting
it again and starting the services.
Then the buffers+cache built up to 5GB/35GB as usual after a while and
everything was perfectly fine again!

I noticed that what happens when umount is called, that the caches are
being dropped. So I gave it a try:

sync; echo 2 > /proc/sys/vm/drop_caches

has the exactly same effect. Note that echo 1 > .. does not.

So if that low usage like 100MB/3GB occurs I'd have to drop the caches by
echoing 2 to drop_caches. The 3GB then become even lower, which is
expected, but then at least the buffers/cache built up again to ordinary
values and the usual performance is restored after a few minutes.
I have never seen this before, this happened after I switched the systems
to newer ones, where the old ones had kernel 3.x, this behavior was never
observed before.

Do you have *any idea* at all what could be causing this? that issue is
bugging me since over a month and seriously really disturbs everything I'm
doing since lot of people access that data and all of them start to
complain at some point where I see that the caches became useless at that
time, having to drop them to rebuild again.

Some guys in IRC suggested that his could be a fragmentation problem or
something, or about slab shrinking.

The problem is that I can not reproduce this, I have to wait a while, maybe
2 days to observe that, until that the buffers/caches are fully in use and
at some point they decrease within a few hours to those useless values.
Sadly this is a production system and I can not play that much around,
already causing downtime when dropping caches (populating caches needs
maybe 5-10 minutes until the performance is ok again).

Please tell me whatever info you need me to pastebin and when (before/after
what event).
Any hints are appreciated a lot, it really gives me lots of headache, since
I am really busy with other things. Thank you very much!


Marinko

--00000000000032cbf60570b91534
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>hello guys</div><div><br></div><div><br></div><div>I =
tried in a few IRC, people told me to ask here, so I&#39;ll give it a try.<=
/div><div><br></div><div></div><div><br></div><div>I have a very weird issu=
e with mm on several hosts.</div><div>The systems are for shared hosting, s=
o lots of users there with lots of files.</div><div>Maybe 5TB of files per =
host, several million at least, there is lots of I/O which can be handled p=
erfectly fine with buffers/cache</div><div><br>The kernel version is the la=
test stable, 4.17.4, I had 3.x before and did not notice any issues until n=
ow. the same is for 4.16 which was in use before:</div><div><br>The hosts a=
ltogether have 64G of RAM and operate with SSD+HDD.</div><div>HDDs are the =
issue here, since those 5TB of data are stored there, there goes the high I=
/O.<br></div><div>Running applications need about 15GB, so say 40GB of RAM =
are left for buffers/caching.</div><div><br></div><div>Usually this works p=
erfectly fine. The buffers take about 1-3G of RAM, the cache the rest, say =
35GB as an example.</div><div>But every now and then, maybe every 2 days it=
 happens that both drop to really low values, say 100MB buffers, 3GB caches=
 and the rest of the RAM is not in use, so there are about 35GB+ of totally=
 free RAM.</div><div><br></div><div>The performance of the host goes down s=
ignificantly then, as it becomes unusable at some point, since it behaves a=
s if the buffers/cache were totally useless.<br>After lots and lots of play=
ing around I noticed that when shutting down all services that access the H=
DDs on the system and restarting them, that this does *not* make any differ=
ence.</div><div><br></div><div>But what did make a difference was stopping =
and umounting the fs, mounting it again and starting the services.<br>Then =
the buffers+cache built up to 5GB/35GB as usual after a while and everythin=
g was perfectly fine again!</div><div><br></div><div>I noticed that what ha=
ppens when umount is called, that the caches are being dropped. So I gave i=
t a try:</div><div><br>sync; echo 2 &gt; /proc/sys/vm/drop_caches<br></div>=
<div><br></div><div>has the exactly same effect. Note that echo 1 &gt; .. d=
oes not.</div><div><br></div><div>So if that low usage like 100MB/3GB occur=
s I&#39;d have to drop the caches by echoing 2 to drop_caches. The 3GB then=
 become even lower, which is expected, but then at least the buffers/cache =
built up again to ordinary values and the usual performance is restored aft=
er a few minutes.<br>I have never seen this before, this happened after I s=
witched the systems to newer ones, where the old ones had kernel 3.x, this =
behavior was never observed before.</div><div><br></div><div>Do you have *a=
ny idea* at all what could be causing this? that issue is bugging me since =
over a month and seriously really disturbs everything I&#39;m doing since l=
ot of people access that data and all of them start to complain at some poi=
nt where I see that the caches became useless at that time, having to drop =
them to rebuild again.</div><div><br></div><div>Some guys in IRC suggested =
that his could be a fragmentation problem or something, or about slab shrin=
king.</div><div><br></div><div>The problem is that I can not reproduce this=
, I have to wait a while, maybe 2 days to observe that, until that the buff=
ers/caches are fully in use and at some point they decrease within a few ho=
urs to those useless values.<br></div><div>Sadly this is a production syste=
m and I can not play that much around, already causing downtime when droppi=
ng caches (populating caches needs maybe 5-10 minutes until the performance=
 is ok again).</div><div><br></div><div>Please tell me whatever info you ne=
ed me to pastebin and when (before/after what event).<br></div><div>Any hin=
ts are appreciated a lot, it really gives me lots of headache, since I am r=
eally busy with other things. Thank you very much!</div><div><br></div><div=
><br></div><div>Marinko</div><div><br></div></div>

--00000000000032cbf60570b91534--
