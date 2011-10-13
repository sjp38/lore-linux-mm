Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4DA6B0035
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 12:55:01 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Thu, 13 Oct 2011 12:54:40 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB516D459@USINDEVS02.corp.hds.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
 <20110901100650.6d884589.rdunlap@xenotime.net>
 <20110901152650.7a63cb8b@annuminas.surriel.com>
 <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
 <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com>
 <alpine.DEB.2.00.1110111612120.5236@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1110111612120.5236@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/11/2011 07:22 PM, David Rientjes wrote:
> On Tue, 11 Oct 2011, Satoru Moriya wrote:
>=20
> I don't know if your test case is the only thing that Rik is looking=20
> at, but if so, then that statement makes me believe that this patch is=20
> definitely in the wrong direction, so NACK on it until additional=20
> information is presented.  The reasoning is simple: if tuning the=20
> bonus given to rt-tasks in the page allocator itself would fix the=20
> issue, then we can certainly add logic specifically for rt-tasks that=20
> can reclaim more aggressively without needing any tunable from=20
> userspace (and _certainly_ not a global tunable that affects every applic=
ation!).

My test case is just a simple one (maybe too simple), and I tried
to demonstrate following issues that current kernel has with it.

1. Current kernel uses free memory as pagecache.
2. Applications may allocate memory burstly and when it happens
   they may get a latency issue because there are not enough free
   memory. Also the amount of required memory is wide-ranging.
3. Some users would like to control the amount of free memory
   to avoid the situation above.
4. User can't setup the amount of free memory explicitly.
   From user's point of view, the amount of free memory is the delta
   between high watermark - min watermark because below min watermark
   user applications incur a penalty (direct reclaim). The width of
   delta depends on min_free_kbytes, actually min watermark / 2, and
   so if we want to make free memory bigger, we must make
   min_free_kbytes bigger. It's not a intuitive and it introduces
   another problem that is possibility of direct reclaim is increased.

I think my test case is too simple and so we may be able to avoid
the latency issue with my case by setting the workload rt-task,
improving how to decide rt-task bonus and/or introducing the
Con's patches below.

But my concern described above is still alive because whether
latency issue happen or not depends on how heavily workloads
allocate memory at a short time. Of cource we can say same
things for extra_free_kbytes, but we can change it and test
an effect easily.

>>> Does there exist anything like a test case which demonstrates the=20
>>> need for this feature?
>>
>> Unfortunately I don't have a real test case but just simple one.
>> And in my simple test case, I can avoid direct reclaim if we set=20
>> workload as rt-task.
>>
>> The simple test case I used is following:
>> http://marc.info/?l=3Dlinux-mm&m=3D131605773321672&w=3D2
>>
>=20
> I tried proposing one of Con's patches from his BFS scheduler ("mm:=20
> adjust kswapd nice level for high priority page") about 1 1/2 years=20
> ago that I recall and believe may significantly help your test case. =20
> The thread is at http://marc.info/?t=3D126743860700002.  (There's a lot=20
> of interesting things in Con's patchset that can be pulled into the=20
> VM, this isn't the only one.)
>=20
> The patch wasn't merged back then because we wanted a test case that=20
> was specifically fixed by this issue, and it may be that we have just=20
> found one.  If you could try it out without any extra_free_kbytes, I=20
> think we may be able to help your situation.

Thank you, David. I'll try my simple workload with it.

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
