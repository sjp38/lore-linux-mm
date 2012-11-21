Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id D63406B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 06:33:07 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Date: Wed, 21 Nov 2012 11:32:43 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB982690469CC00@008-AM1MPN1-002.mgdnok.nokia.com>
References: <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net>
 <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
 <20121115085224.GA4635@lizard>
 <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com>
 <50A60873.3000607@parallels.com>
 <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com>
 <50A6AC48.6080102@parallels.com>
 <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com>
 <50AA3ABF.4090803@parallels.com>
 <alpine.DEB.2.00.1211200950120.4200@chino.kir.corp.google.com>
 <20121121093056.GA31882@shutemov.name>
In-Reply-To: <20121121093056.GA31882@shutemov.name>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill@shutemov.name, rientjes@google.com
Cc: glommer@parallels.com, anton.vorontsov@linaro.org, penberg@kernel.org, mgorman@suse.de, kosaki.motohiro@gmail.com, minchan@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hannes@cmpxchg.org, tj@kernel.org

-----Original Message-----
From: ext Kirill A. Shutemov [mailto:kirill@shutemov.name]=20
Sent: 21 November, 2012 11:31
...

BTW, there's interface for OOM notification in memcg. See oom_control.
I guess other pressure levels can also fit to the interface.

---
Hi,

I have tracking this conversation very little, but as person somehow relate=
d to this round of development and requestor of memcg notification mechanis=
m in past (Kirill implemented that) I have to point there are reasons not t=
o use memcg. The situation in latest kernels could be different but practic=
ally in past the following troubles were observed with memcg:
1. by default memcg is turned off on Android (at least on 4.1 I see it)
2. you need to produce memory partitioning, and that maybe non-trivial task=
 in general case when apps/use cases are not so limited
3. memcg takes into account cached memory. Yes, you can play with MADV_DONT=
NEED  as it was mentioned  but in generic case that is insane
4. memcg need be extended in a way you need to track some other kinds of me=
mory
5. in case of situation in some partition changed fast (e.g. process moved =
to another partition) it may cause pages trashing and device lock. The in-k=
ernel lock was fixed in May 2012, but even pages trashing knock out device =
number of seconds (even minutes).

Thus, I would prefer to avoid memcg even it is powerful feature.

Memory notifications are quite irrelevant to partitioning and cgroups. The =
use-case is related to user-space handling low memory. Meaning the function=
ality should be accurate with specific granularity (e.g. 1 MB) and time (0.=
25s is OK) but better to have it as simple and battery-friendly. I prefer t=
o have pseudo-device-based  text API because it is easy to debug and invest=
igate. It would be nice if it will be possible to use simple scripting to p=
oint what kind of memory on which levels need to be tracked but private/sha=
red dirty is #1 and memcg cannot handle it.

There are two use-cases related to this notification feature:

1. direct usage -> reaction to coming low memory situation and do something=
 ahead of time. E.g. system calibrated to 80% dirty memory border, and if w=
e crossed it we can compensate device slowness by flushing application cach=
es, closing background images even notify user but without killing apps by =
any OOM killer and corruption unsaved data.

2. permission to do some heavy actions. If memory level is low enough for s=
ome application use case (e.g. 50 MB available) application can start heavy=
 use-case, otherwise - do something to prevent potential problems.=20

So, seems to me, the levels depends from application memory usage e.g. calc=
ulator does not need memory information but browser and image gallery needs=
. Thus, tracking daemons in user-space looks as overhead, and such construc=
tion we used in n900 (ke-recv -> dbus -> apps) is quite fragile and slow.
=20
These bits [1] was developed initially for n9 to replace memcg notification=
s with great support of kernel community about a year ago. Unfortunately fo=
r n9 I was a bit late and code was integrated to another product's kernel (=
say M), but at last Summer project M was forced to die due to moving produc=
t line to W. Practically arm device produced signals ON/OFF which fit well =
into space/time requirements, so I have what I need. Even it is quite primi=
tive code but I prefer do not over-engineering complexity without necessity=
.

Best Wishes,
Leonid

PS: but seems code related to vmpressure_fd solves some other problem so yo=
u can ignore my speech.=20

[1] http://maemo.gitorious.org/maemo-tools/libmemnotify/blobs/master/src/ke=
rnel/memnotify.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
