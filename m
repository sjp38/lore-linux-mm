Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id DC8076B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 04:59:07 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 3.2.0-rc1 3/3] Used Memory Meter pseudo-device module
Date: Mon, 9 Jan 2012 09:58:18 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB9826904554AFD@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
 <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com>
 <20120104195521.GA19181@suse.de>
In-Reply-To: <20120104195521.GA19181@suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

> -----Original Message-----
> From: ext Greg KH [mailto:gregkh@suse.de]
> Sent: 04 January, 2012 21:55
...
> Note, I don't agree that this code is the correct thing to be doing here,=
 you'll
> have to get the buy-in from the mm developers on that, but I do have some
> comments on the implementation:

Hello everyone and thanks for comments.

If I not wrong in addition to Greg's remarks about polishing I got 14 findi=
ngs (see details below):
1. Alternative solutions: why not Android OOM or memcg
2. How to connect to MM - the current variant is no-go and that is a critic=
al part
3. What should be tracked (e.g. memory pressure 3.1)

For sure I used wrong approach to solve notification problem. The user-spac=
e reaction should fit under 1s, so to react 250-500 ms on kernel side absol=
utely not necessary hook page_alloc due to this component=20
should be used only for notification and not denying allocations. It also i=
nadequate idea due to I need only data from global_page_state/vm_stat which=
 is cpu-independent and has a lot of traces in MM where=20
it could be updated.=20

So major changes in coming version will be:
1. timer-based access to global_page_state() data. If I understand document=
ation right the deferred timer will not wake up if cpu frozen. Otherwise ti=
mer must be set using register_cpu_notifier
2. to track high memory pressure cases the shrinker should be added without=
 filtering by last call time
3. used memory calculation will be changed and active page set added
4. file renamed to memnotify.c and interface to /dev/memnotify due to it wi=
ll report not only used memory + low probability it will be accepted as mm/=
notify.c as advised below (but maybe someone will use it).

With Best Wishes,
Leonid

Remarks collected from emails
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

1. Alternative solutions
------------------------

1.1. Pekka Enberg
> However, from VM point of view, both have the exact same functionality: d=
etect when we reach low memory condition
> (for some configurable threshold) and notify userspace or kernel subsyste=
m about it.

Well, I cannot say that SIGKILL is a notification. From kernel side maybe. =
But Android OOM uses different memory=20
tracking rules. From my opinion OOM killer should be as reliable as default=
 is but functionality Android OOM killer=20
does should be done in user space by some "smart killer" which closes appli=
cation correct way (save data, notify user etc.).
It heavily depends from product design.

1.2. Pekka Enberg
> That's the part I'd like to see implemented in mm/notify.c or similar.
> I really don't care what Android or any other folks use it for exactly as=
 long as the generic code is light-weight, > clean, and we can reasonably a=
ssume that distros can actually enable it.

I will try to do memnotify.c but due to I am not sure it will be well enoug=
h done to be accepted it will be in drivers.

1.3. Rik van Riel
> Also, the low memory notification that Kosaki-san has worked on, and whic=
h Minchan is looking at now.
Finally I found only patches from 2009 which are not look for me good from =
user space point of view.
For example I do not understand how to specify application limit(s).

1.4. Mel Gorman
> I haven't looked at the alternatives but there has been some vague discus=
sion recently on reviving the concept of
> a low memory notifier, somehow making the existing memcg oom notifier glo=
bal or maybe the andro lowmem killer=20
> can be adapted to your needs.

Most likely not. The memcg OOM handling can but idea is to not have memcg/p=
artitions.

1.5. David Rientjes
> If you can accept the overhead of the memory controller (increase in
> kernel text size and amount of metadata for page_cgroup), then you can
> already do this with a combination of memory thresholds with
> cgroup.event_control and disabling of the oom killer entirely with
> memory.oom_control.=20
already done in libmemnotifyqt used in n9


1.6. David Rientjes
> Agreed.  This came up recently when another lowmem killer was proposed an=
d the suggestion was to enable the memory > controller to be able to have t=
he memory threshold notifications with eventfd(2) and cgroup.event_control.=
 =20

already done in libmemnotifyqt used in n9

1.7. David Rientjes
> This is just a side-note but as this information is meant to be consumed =
by userspace you have the option of hooking
> into the mm_page_alloc tracepoint. You get the same information about how=
 many pages are allocated or freed. I accept
> that it will probably be a bit slower but on the plus side it'll be backw=
ards compatible and you don't need a kernel
> patch for it.

That is odd for sure, I have to use another kind of access to vm_stat.


2. How to hook MM
-----------------

2.1. Pekka Enberg
> Can we hook into mm/vmscan.c and mm/page-writeback.c for this?
Thanks for pointing. For vmscan I plan to use shrinker. But changes in page=
-writeback seems to be the same bad as page-alloc hooking.

2.2. Rik van Riel
> It may be possible to hijack memcg accounting to get lower usage threshol=
ds for earlier notification. =20
> That way the code can stay out of the true fast paths like alloc_pages

That is a case but memcg is not well suitable when processes migrating in-b=
etween cgroups e.g. forced to be swapped out
and device becomes slaggy or if process is big enough it cannot be injected=
 into cgroup and stays in root group without
any restrictions

2.3. Mel Gorman
> I'm going to chime in and say that hooks like this into the page allocato=
r are a no-go unless there really=20
> s absolutely no other option. There is too much scope for abuse.

Agree. The idea is based on vm_stat which is global, and to track it absolu=
tely do not necessary to hook in page_alloc


2.4. David Rientjes

> It would be very nice to have a generic lowmem notifier (like /dev/mem_no=
tify that has been reworked several times=20
> in the past) rather than tying it to a particular cgroup, especially when=
 that cgroup incurs a substantial overhead=20
> for embedded users.

Ok, will try to do more generic and re-use memnotify name. But due to high =
risk to be not accepted in mainline I will keep it as drivers/misc/memnotif=
y.c


3. What to track
----------------

3.1. Mel Gorman
> It also would have very poor information about memory pressure which is l=
ikely to be far more interesting and for that,
> awareness of what is happening in page reclaim is required.
Could to be added later, now I try to focus on vm_stat due to it is simpler=
.=20

3.2. KOSAKI Motohiro=20
> If you spent a few time to read past discuttion, you should have understa=
nd
> your fomula
> is broken and unacceptable. Think, mlocked (or pinning by other way) cach=
e
> can't be discarded.=20

NR_MLOCK will be added

3.3. KOSAKI Motohiro=20
> And, When system is under swap thrashing, userland notification is useles=
s.
Well, cgroups CPU shares and ionice seems to me better but as a quick solut=
ion extension with LRU_ACTIVE_ANON + LRU_ACTIVE_FILE could be done easily.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
