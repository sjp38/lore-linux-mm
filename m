Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D89126B0011
	for <linux-mm@kvack.org>; Tue,  3 May 2011 21:39:06 -0400 (EDT)
Date: Tue, 3 May 2011 21:38:39 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1593977838.225469.1304473119444.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <4D72580D.4000208@gmail.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable()
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_225468_1867416694.1304473119443"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: avagin@gmail.com
Cc: Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>

------=_Part_225468_1867416694.1304473119443
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit



----- Original Message -----
> On 03/05/2011 06:20 PM, Minchan Kim wrote:
> > On Sat, Mar 05, 2011 at 02:44:16PM +0300, Andrey Vagin wrote:
> >> Check zone->all_unreclaimable in all_unreclaimable(), otherwise the
> >> kernel may hang up, because shrink_zones() will do nothing, but
> >> all_unreclaimable() will say, that zone has reclaimable pages.
> >>
> >> do_try_to_free_pages()
> >> 	shrink_zones()
> >> 		 for_each_zone
> >> 			if (zone->all_unreclaimable)
> >> 				continue
> >> 	if !all_unreclaimable(zonelist, sc)
> >> 		return 1
> >>
> >> __alloc_pages_slowpath()
> >> retry:
> >> 	did_some_progress = do_try_to_free_pages(page)
> >> 	...
> >> 	if (!page&& did_some_progress)
> >> 		retry;
> >>
> >> Signed-off-by: Andrey Vagin<avagin@openvz.org>
> >> ---
> >>   mm/vmscan.c | 2 ++
> >>   1 files changed, 2 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 6771ea7..1c056f7 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -2002,6 +2002,8 @@ static bool all_unreclaimable(struct zonelist
> >> *zonelist,
> >>
> >>   	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> >>   			gfp_zone(sc->gfp_mask), sc->nodemask) {
> >> + if (zone->all_unreclaimable)
> >> + continue;
> >>   		if (!populated_zone(zone))
> >>   			continue;
> >>   		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> >
> > zone_reclaimable checks it. Isn't it enough?
> I sent one more patch [PATCH] mm: skip zombie in OOM-killer.
> This two patches are enough.
> > Does the hang up really happen or see it by code review?
> Yes. You can reproduce it for help the attached python program. It's
> not
> very clever:)
> It make the following actions in loop:
> 1. fork
> 2. mmap
> 3. touch memory
> 4. read memory
> 5. munmmap
> 
> >> --
> >> 1.7.1
I have tested this for the latest mainline kernel using the reproducer
attached, the system just hung or deadlock after oom. The whole oom
trace is here.
http://people.redhat.com/qcai/oom.log

Did I miss anything?
------=_Part_225468_1867416694.1304473119443
Content-Type: text/plain; name=memeater.py
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=memeater.py

aW1wb3J0IHN5cywgdGltZSwgbW1hcCwgb3MNCmZyb20gc3VicHJvY2VzcyBpbXBvcnQgUG9wZW4s
IFBJUEUNCmltcG9ydCByYW5kb20NCg0KZ2xvYmFsIG1lbV9zaXplDQoNCmRlZiBpbmZvKG1zZyk6
DQoJcGlkID0gb3MuZ2V0cGlkKCkNCglwcmludCA+PiBzeXMuc3RkZXJyLCAiJXM6ICVzIiAlIChw
aWQsIG1zZykNCglzeXMuc3RkZXJyLmZsdXNoKCkNCg0KDQoNCmRlZiBtZW1vcnlfbG9vcChjbWQg
PSAiYSIpOg0KCSIiIg0KCWNtZCBtYXkgYmU6DQoJCWM6IGNoZWNrIG1lbW9yeQ0KCQllbHNlOiB0
b3VjaCBtZW1vcnkNCgkiIiINCgljID0gMA0KCWZvciBqIGluIHhyYW5nZSgwLCBtZW1fc2l6ZSk6
DQoJCWlmIGNtZCA9PSAiYyI6DQoJCQlpZiBmW2o8PDEyXSAhPSBjaHIoaiAlIDI1NSk6DQoJCQkJ
aW5mbygiRGF0YSBjb3JydXB0aW9uIikNCgkJCQlzeXMuZXhpdCgxKQ0KCQllbHNlOg0KCQkJZltq
PDwxMl0gPSBjaHIoaiAlIDI1NSkNCg0Kd2hpbGUgVHJ1ZToNCglwaWQgPSBvcy5mb3JrKCkNCglp
ZiAocGlkICE9IDApOg0KCQltZW1fc2l6ZSA9IHJhbmRvbS5yYW5kaW50KDAsIDU2ICogNDA5NikN
CgkJZiA9IG1tYXAubW1hcCgtMSwgbWVtX3NpemUgPDwgMTIsIG1tYXAuTUFQX0FOT05ZTU9VU3xt
bWFwLk1BUF9QUklWQVRFKQ0KCQltZW1vcnlfbG9vcCgpDQoJCW1lbW9yeV9sb29wKCJjIikNCgkJ
Zi5jbG9zZSgpDQo=
------=_Part_225468_1867416694.1304473119443--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
