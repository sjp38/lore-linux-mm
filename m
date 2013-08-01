Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 46CE66B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 01:24:26 -0400 (EDT)
From: Lisa Du <cldu@marvell.com>
Date: Wed, 31 Jul 2013 22:19:53 -0700
Subject: RE: Possible deadloop in direct reclaim?
Message-ID: <89813612683626448B837EE5A0B6A7CB3B630BE028@SC-VEXCH4.marvell.com>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
 <000001400d38469d-a121fb96-4483-483a-9d3e-fc552e413892-000000@email.amazonses.com>
 <89813612683626448B837EE5A0B6A7CB3B62F8F5C3@SC-VEXCH4.marvell.com>
 <CAHGf_=q8JZQ42R-3yzie7DXUEq8kU+TZXgcX9s=dn8nVigXv8g@mail.gmail.com>
 <89813612683626448B837EE5A0B6A7CB3B62F8FE33@SC-VEXCH4.marvell.com>
 <51F69BD7.2060407@gmail.com>
 <89813612683626448B837EE5A0B6A7CB3B630BDF99@SC-VEXCH4.marvell.com>
 <51F9CBC0.2020006@gmail.com>
In-Reply-To: <51F9CBC0.2020006@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>
Cc: Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>, Neil Zhang <zhangwm@marvell.com>

Loop in Russel King.
Would you please help to comment below questions Mr Motohiro asked about fo=
rk allocating order-2 memory? Thanks in advance!
>(7/31/13 10:24 PM), Lisa Du wrote:
>> Dear Kosaki
>>     Would you please help to check my comment as below:
>>> (7/25/13 9:11 PM), Lisa Du wrote:
>>>> Dear KOSAKI
>>>>      In my test, I didn't set compaction. Maybe compaction is helpful
>to
>>> avoid this issue. I can have try later.
>>>>      In my mind CONFIG_COMPACTION is an optional configuration
>>> right?
>>>
>>> Right. But if you don't set it, application must NOT use >1 order
>allocations.
>>> It doesn't work and it is expected
>>> result.
>>> That's your application mistake.
>> Dear Kosaki, I have two questions on your explanation:
>> a) you said if don't set CONFIG_COMPATION, application must NOT use >1
>order allocations, is there any documentation
>   for this theory?
>
>Sorry I don't understand what "this" mean. I mean, Even though you use
>desktop or server machine, no compaction kernel
>easily makes no order-2 situations.
>Then, our in-kernel subsystems don't use order-2 allocations as far as
>possible.
Thanks, now I got your point.=20
>
>
>> b) My order-2 allocation not comes from application, but from do_fork
>which is in kernel space,
>    in my mind when a parent process forks a child process, it need to
>allocate a order-2 memory,
>   if a) is right, then CONFIG_COMPATION should be a MUST configuration
>for linux kernel but not optional?
>
>???
>fork alloc order-1 memory for stack. Where and why alloc order-2? If it is
>arch specific code, please
>contact arch maintainer.
Yes arch do_fork allocate order-2 memory when copy_process.=20
Hi, Russel
What's your opinion about this question? =20
If we really need order-2 memory for fork, then we'd better set CONFIG_COMP=
ATION right?
>
>
>
>>>
>>>>      If we don't use, and met such an issue, how should we deal with
>>> such infinite loop?
>>>>
>>>>      I made a change in all_reclaimable() function, passed overnight
>tests,
>>> please help review, thanks in advance!
>>>> @@ -2353,7 +2353,9 @@ static bool all_unreclaimable(struct zonelist
>>> *zonelist,
>>>>                           continue;
>>>>                   if (!cpuset_zone_allowed_hardwall(zone,
>>> GFP_KERNEL))
>>>>                           continue;
>>>> -               if (!zone->all_unreclaimable)
>>>> +               if (zone->all_unreclaimable)
>>>> +                       continue;
>>>> +               if (zone_reclaimable(zone))
>>>>                           return false;
>>>
>>> Please tell me why you chaned here.
>> The original check is once found zone->all_unreclaimable is false, it wi=
ll
>return false, then
>>it will set did_some_progress non-zero. Then another loop of
>direct_reclaimed performed.
>>  But I think zone->all_unreclaimable is not always reliable such as in m=
y
>case, kswapd go to
>>  sleep and no one will change this flag. We should also check
>zone_reclaimalbe(zone) if
>>  zone->all_unreclaimalbe =3D 0 to double confirm if a zone is reclaimabl=
e;
>This change also
>>  avoid the issue you described in below commit:
>
>Please read more older code. Your pointed code is temporary change and I
>changed back for fixing
>bugs.
>If you look at the status in middle direct reclaim, we can't avoid race
>condition from multi direct
>reclaim issues. Moreover, if kswapd doesn't awaken, it is a problem. This =
is
>a reason why current code
>behave as you described.
>I agree we should fix your issue as far as possible. But I can't agree you=
r
>analysis.
I read the code you modified which check the zone->all_unreclaimable instea=
d of zone_reclaimable(zone);
(In the commit 929bea7c714 vmscan: all_unreclaimable() use zone->all_unrecl=
aimable as a name)
Your patch was trying to fix the issue of zone->all_unreclaimable =3D 1, bu=
t zone->pages_scanned =3D 0 which result all_unreclaimable() return false.
Is there anything else I missed or misunderstanding?
In my change, I'll first check zone->all_unreclaimable, if it was set 1, th=
en I wouldn't check zone->pages_scanned value.
My point is zone->all_unreclaimable =3D 0 doesn't mean this zone is always =
reclaimable. As zone->all_unreclaimable can only be set in kswapd.
And kswapd already fully scan all zones and still can't rebalance the syste=
m for high-order allocations.  Instead it recheck all watermarks at order-0=
, and watermarks ok will let kswapd back to sleep. Unfortunately, Kswapd do=
esn't awaken because long time no higher order allocation wake it up. But t=
his process continue direct reclaim again and again as zone->all_unreclaima=
ble remains 0.
So I also checked the zone->pages_scanned when zone->all_unreclaimable =3D =
0, if zone_reclaimable() return true, then it's really reclaimable for dire=
ct reclaimer. This change would break your bug fix right?

Thanks Bob's finding, I read through below thread, and the patch your are t=
rying to fix is the same issue as mine:
mm, vmscan: fix do_try_to_free_pages() livelock
https://lkml.org/lkml/2012/6/14/74
I have the same question as Bob, you already find this issue, why this patc=
h wasn't got merged?=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
