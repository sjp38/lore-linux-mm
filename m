Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8DFF6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 03:29:19 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id f9so32490135vke.4
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 00:29:19 -0700 (PDT)
Received: from mail-vk0-x22e.google.com (mail-vk0-x22e.google.com. [2607:f8b0:400c:c05::22e])
        by mx.google.com with ESMTPS id y21si5688543uaa.182.2017.06.26.00.29.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 00:29:18 -0700 (PDT)
Received: by mail-vk0-x22e.google.com with SMTP id r126so27727691vkg.0
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 00:29:18 -0700 (PDT)
MIME-Version: 1.0
From: Ivid Suvarna <ivid.suvarna@gmail.com>
Date: Mon, 26 Jun 2017 12:59:17 +0530
Message-ID: <CABXF_ACjD535xtk5_1MO6O8rdT+eudCn=GG0tM1ntEb6t1JO8w@mail.gmail.com>
Subject: Error in freeing memory with zone reclaimable always returning true.
Content-Type: multipart/alternative; boundary="001a11425adca665500552d7e84d"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11425adca665500552d7e84d
Content-Type: text/plain; charset="UTF-8"

Hi,

I have below code which tries to free memory,
do
{
free=shrink_all_memory;
}while(free>0);

But kernel gets into infinite loop because shrink_all_memory always returns
1.
When I added some debug statements to `mm/vmscan.c` and found that it is
because zone_reclaimable() is always true in shrink_zones()

if (global_reclaim(sc) &&
            !reclaimable && zone_reclaimable(zone))
            reclaimable = true;

This issue gets solved by removing the above lines.
I am using linux-kernel 4.4 and imx board.

Similar Issue is seen here[1]. And it is solved through a patch removing
the offending lines. But it does not explain why the zone reclaimable goes
into infinite loop and what causes it? And I ran the C program from [1]
which is below. And instead of OOM it went on to infinite loop.

#include <stdlib.h>
#include <string.h>

int main(void)
{
for (;;) {
void *p = malloc(1024 * 1024);
memset(p, 0, 1024 * 1024);
}
}

Also can this issue be related to memcg as in here "
https://lwn.net/Articles/508923/" because I see the code flow in my case
enters:

if(nr_soft_reclaimed)
reclaimable=true;

I dont understand memcg correctly. But in my case CONFIG_MEMCG is not set.

After some more debugging, I found a userspace process in sleeping state
and has three threads. This process is in pause state through
system_pause() and is accessing shared memory(`/dev/shm`) which is created
with 100m size. This shared memory has some files.

Also this process has some anonymous private and shared mappings when I saw
the output of `pmap -d PID` and there is no swap space in the system.

I found that this hang situation was not present after I remove that
userspace process. But how can that be a solution since kernel should be
able to handle any exception.

"I found no issues at all if I removed this userspace process".

So my doubts are:

 1. How can this sleeping process in pause state cause issue in zone
reclaimable returning true always.

 2. How are the pages reclaimed from sleeping process which is using shared
memory in linux?

 3. I tried to unmount /dev/shm but was not possible since process was
using it. Can we release shared memory by any way? I tried `munmap` but no
use.

Any info would be helpful.

  [1]: https://groups.google.com/forum/#!topic/fa.linux.kernel/kWwlQzj8mhc

--001a11425adca665500552d7e84d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi,<br><br>I have below code which tries to free memo=
ry, <br>do<br>{<br>free=3Dshrink_all_memory;<br></div>}while(free&gt;0);<br=
><br><div>But kernel gets into infinite loop because shrink_all_memory alwa=
ys returns 1.<br>When I added some debug statements to `mm/vmscan.c` and fo=
und that it is because zone_reclaimable() is always true in shrink_zones()<=
br><br>if (global_reclaim(sc) &amp;&amp;<br>=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=
=C2=A0 =C2=A0=C2=A0=C2=A0 !reclaimable &amp;&amp; zone_reclaimable(zone))<b=
r>=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 reclaimable =3D =
true;<br><br>This issue gets solved by removing the above lines. <br>I am u=
sing linux-kernel 4.4 and imx board.<br><br>Similar Issue is seen here[1]. =
And it is solved through a patch removing the offending lines. But it does =
not explain why the zone reclaimable goes into infinite loop and what cause=
s it? And I ran the C program from [1]=C2=A0 which is below. And instead of=
 OOM it went on to infinite loop.<br><br>#include &lt;stdlib.h&gt; <br>    =
    #include &lt;string.h&gt; <br> <br>        int main(void) <br>        {=
 <br>                for (;;) { <br>                        void *p =3D mal=
loc(1024 * 1024); <br>                        memset(p, 0, 1024 * 1024); <b=
r>                } <br>        } <br><br>Also can this issue be related to=
 memcg as in here &quot;<a href=3D"https://lwn.net/Articles/508923/">https:=
//lwn.net/Articles/508923/</a>&quot; because I see the code flow in my case=
 enters:<br><br>if(nr_soft_reclaimed)<br></div><div>reclaimable=3Dtrue;<br>=
<br></div><div>I dont understand memcg correctly. But in my case CONFIG_MEM=
CG is not set.<br></div><div><br>After some more debugging, I found a users=
pace process in sleeping state and has three threads. This process is in pa=
use state through system_pause() and is accessing shared memory(`/dev/shm`)=
 which is created with 100m size. This shared memory has some files. <br><b=
r>Also this process has some anonymous private and shared mappings when I s=
aw the output of `pmap -d PID` and there is no swap space in the system.<br=
><br>I found that this hang situation was not present after I remove that u=
serspace process. But how can that be a solution since kernel should be abl=
e to handle any exception.<br><br>&quot;I found no issues at all if I remov=
ed this userspace process&quot;.<br><br>So my doubts are:<br><br>=C2=A01. H=
ow can this sleeping process in pause state cause issue in zone reclaimable=
 returning true always.<br><br>=C2=A02. How are the pages reclaimed from sl=
eeping process which is using shared memory in linux?<br><br>=C2=A03. I tri=
ed to unmount /dev/shm but was not possible since process was using it. Can=
 we release shared memory by any way? I tried `munmap` but no use.<br><br>A=
ny info would be helpful.<br><br>=C2=A0 [1]: <a href=3D"https://groups.goog=
le.com/forum/#!topic/fa.linux.kernel/kWwlQzj8mhc">https://groups.google.com=
/forum/#!topic/fa.linux.kernel/kWwlQzj8mhc</a><br></div></div>

--001a11425adca665500552d7e84d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
