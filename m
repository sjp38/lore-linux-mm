Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC6586B0069
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 12:16:12 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 7so82424605uas.6
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:16:12 -0800 (PST)
Received: from mail-ua0-x235.google.com (mail-ua0-x235.google.com. [2607:f8b0:400c:c08::235])
        by mx.google.com with ESMTPS id h64si1715324uad.197.2017.01.11.09.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 09:16:12 -0800 (PST)
Received: by mail-ua0-x235.google.com with SMTP id 96so90967411uaq.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:16:11 -0800 (PST)
MIME-Version: 1.0
From: Cheng-yu Lee <cylee@google.com>
Date: Thu, 12 Jan 2017 01:16:11 +0800
Message-ID: <CAPJVTTimt2CeiiX868+EY2HbbWmKsG05u7QOBbuTb74f-ZrpPQ@mail.gmail.com>
Subject: shrink_inactive_list() failed to reclaim pages
Content-Type: multipart/alternative; boundary=001a113d0020e039610545d4c156
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Luigi Semenzato <semenzato@google.com>, Ben Cheng <bccheng@google.com>

--001a113d0020e039610545d4c156
Content-Type: text/plain; charset=UTF-8

Hi community,

I have a x86_64 Chromebook running 3.14 kernel with 8G of memory. Using
zram with swap size set to ~12GB. When in low memory, kswapd is awaken to
reclaim pages, but under some circumstances the kernel can not find pages
to reclaim while I'm sure there're still plenty of memory which could be
reclaimed from background processes (For example, I run some C programs
which just malloc() lots of memory and get suspended in the background.
There's no reason they could't be swapped). The consequence is that most of
CPU time is spent on page reclamation. The system hangs or becomes very
laggy for a long period. Sometimes it even triggers a kernel panic by the
hung task detector like:
<0>[46246.676366] Kernel panic - not syncing: hung_task: blocked tasks

I've added kernel message to trace the problem. I found shrink_inactive_list()
can barely find any page to reclaim. More precisely, when the problem
happens, lots of page have _count > 2 in __remove_mapping(). So the
condition at line 662 of vmscan.c holds:
http://lxr.free-electrons.com/source/mm/vmscan.c#L662
Thus the kernel fails to reclaim those pages at line 1209
http://lxr.free-electrons.com/source/mm/vmscan.c#L1209

It's weird that the inactive anonymous list is huge (several GB), but
nothing can really be freed. So I did some hack to see if moving more pages
from the active list helps. I commented out the "inactive_list_is_low()"
checking at line 2420
in shrink_node_memcg() so shrink_active_list() is always called.
http://lxr.free-electrons.com/source/mm/vmscan.c#L2420
It turns out that the hack helps. If moving more pages from the active
list, kswapd works smoothly. The whole 12G zram can be used up before
system enters OOM condition.

Any idea why the whole inactive anonymous LRU is occupied by pages which
can not be freed for la long time (several minutes before system dies) ?
Are there any parameters I can tune to help the situation ? I've tried
swappiness but it doesn't help.

An alternative is to patch the kernel to call shrink_active_list() more
frequently when it finds there's nothing that can be reclaimed . But I am
not sure if it's the right direction. Also it's not so trivial to figure
out where to add the call.

Thanks,
Cheng-Yu

--001a113d0020e039610545d4c156
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span style=3D"font-size:12.8px">Hi community,</span><div =
style=3D"font-size:12.8px"><br></div><div style=3D"font-size:12.8px">I have=
 a x86_64 Chromebook running 3.14 kernel with 8G of memory. Using zram with=
 swap size set to ~12GB. When in low memory, kswapd is awaken to reclaim pa=
ges, but under=C2=A0some circumstances the kernel can not find pages to rec=
laim while I&#39;m sure there&#39;re still plenty of memory which could be =
reclaimed from background processes (For example, I run some C programs whi=
ch just malloc() lots of memory and get suspended in the background. There&=
#39;s no reason they could&#39;t be swapped). The consequence is that most =
of CPU time is spent on page reclamation. The system hangs or becomes very =
laggy for a long period. Sometimes it even triggers a kernel panic by the h=
ung task detector like:</div><div style=3D"font-size:12.8px"><span style=3D=
"font-family:arial,helvetica,sans-serif;font-size:13px">&lt;0&gt;[46246.676=
366] Kernel panic - not syncing: hung_task: blocked tasks</span></div><div =
style=3D"font-size:12.8px"><span style=3D"font-family:arial,helvetica,sans-=
serif;font-size:13px"><br></span></div><div style=3D"font-size:12.8px"><spa=
n style=3D"font-family:arial,helvetica,sans-serif;font-size:13px">I&#39;ve =
added kernel message to trace the problem. I found=C2=A0</span><span style=
=3D"font-family:arial,helvetica,sans-serif;font-size:13px">shrink_inactive_=
list</span><span style=3D"font-family:arial,helvetica,sans-serif;font-size:=
13px">() can barely find any page to reclaim. More precisely, when the prob=
lem happens, lots of page have _count &gt; 2 in __remove_mapping(). So the =
condition at line 662 of vmscan.c holds:</span></div><div style=3D"font-siz=
e:12.8px"><font face=3D"arial, helvetica, sans-serif"><a href=3D"http://lxr=
.free-electrons.com/source/mm/vmscan.c#L662" target=3D"_blank">http://lxr.f=
ree-electrons.com/<wbr>source/mm/vmscan.c#L662</a></font><br></div><div sty=
le=3D"font-size:12.8px"><font face=3D"arial, helvetica, sans-serif">Thus th=
e kernel fails to reclaim those pages=C2=A0</font><span style=3D"font-famil=
y:arial,helvetica,sans-serif;font-size:13px">at line 1209</span></div><div =
style=3D"font-size:12.8px"><font face=3D"arial, helvetica, sans-serif"><a h=
ref=3D"http://lxr.free-electrons.com/source/mm/vmscan.c#L1209" target=3D"_b=
lank">http://lxr.free-electrons.com/<wbr>source/mm/vmscan.c#L1209</a></font=
></div><div style=3D"font-size:12.8px"><font face=3D"arial, helvetica, sans=
-serif"><br></font></div><div style=3D"font-size:12.8px"><font face=3D"aria=
l, helvetica, sans-serif">It&#39;s weird that the inactive anonymous list i=
s huge (several GB), but nothing can really be freed. So I did some hack to=
 see if moving more pages from the active list helps. I commented=C2=A0</fo=
nt>out the &quot;inactive_list_is_low()&quot; checking at line 2420=C2=A0</=
div><span style=3D"font-size:12.8px">in shrink_node_memcg() so shrink_activ=
e_list() is always called.</span><div style=3D"font-size:12.8px"><a href=3D=
"http://lxr.free-electrons.com/source/mm/vmscan.c#L2420" target=3D"_blank">=
http://lxr.free-electrons.com/<wbr>source/mm/vmscan.c#L2420</a></div><div s=
tyle=3D"font-size:12.8px">It turns out that the hack helps. If moving more =
pages from the active list, kswapd works smoothly. The whole 12G zram can b=
e used up before system enters OOM condition.=C2=A0<br></div><div style=3D"=
font-size:12.8px"><br></div><div style=3D"font-size:12.8px">Any idea why th=
e whole inactive anonymous LRU is occupied by pages which can not be freed =
for la long time (several minutes before system dies) ? Are there any param=
eters I can tune to help the situation ? I&#39;ve tried swappiness but it d=
oesn&#39;t help. =C2=A0</div><div style=3D"font-size:12.8px"><br></div><div=
 style=3D"font-size:12.8px">An alternative is to patch the kernel to call s=
hrink_active_list() more frequently when it finds there&#39;s nothing that =
can be reclaimed . But I am not sure if it&#39;s the right direction. Also =
it&#39;s not so trivial to figure out where to add the call.<br></div><div =
style=3D"font-size:12.8px"><br></div><div style=3D"font-size:12.8px">Thanks=
,</div><div style=3D"font-size:12.8px">Cheng-Yu</div></div>

--001a113d0020e039610545d4c156--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
