Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 5A7C66B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 22:24:33 -0400 (EDT)
From: Lisa Du <cldu@marvell.com>
Date: Wed, 31 Jul 2013 19:24:19 -0700
Subject: RE: Possible deadloop in direct reclaim?
Message-ID: <89813612683626448B837EE5A0B6A7CB3B630BDF99@SC-VEXCH4.marvell.com>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
 <000001400d38469d-a121fb96-4483-483a-9d3e-fc552e413892-000000@email.amazonses.com>
 <89813612683626448B837EE5A0B6A7CB3B62F8F5C3@SC-VEXCH4.marvell.com>
 <CAHGf_=q8JZQ42R-3yzie7DXUEq8kU+TZXgcX9s=dn8nVigXv8g@mail.gmail.com>
 <89813612683626448B837EE5A0B6A7CB3B62F8FE33@SC-VEXCH4.marvell.com>
 <51F69BD7.2060407@gmail.com>
In-Reply-To: <51F69BD7.2060407@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>

Dear Kosaki
   Would you please help to check my comment as below:
>(7/25/13 9:11 PM), Lisa Du wrote:
>> Dear KOSAKI
>>     In my test, I didn't set compaction. Maybe compaction is helpful to
>avoid this issue. I can have try later.
>>     In my mind CONFIG_COMPACTION is an optional configuration
>right?
>
>Right. But if you don't set it, application must NOT use >1 order allocati=
ons.
>It doesn't work and it is expected
>result.
>That's your application mistake.
Dear Kosaki, I have two questions on your explanation:
a) you said if don't set CONFIG_COMPATION, application must NOT use >1 orde=
r allocations, is there any documentation for this theory? =20
b) My order-2 allocation not comes from application, but from do_fork which=
 is in kernel space, in my mind when a parent process forks a child process=
, it need to allocate a order-2 memory, if a) is right, then CONFIG_COMPATI=
ON should be a MUST configuration for linux kernel but not optional?
>
>>     If we don't use, and met such an issue, how should we deal with
>such infinite loop?
>>
>>     I made a change in all_reclaimable() function, passed overnight test=
s,
>please help review, thanks in advance!
>> @@ -2353,7 +2353,9 @@ static bool all_unreclaimable(struct zonelist
>*zonelist,
>>                          continue;
>>                  if (!cpuset_zone_allowed_hardwall(zone,
>GFP_KERNEL))
>>                          continue;
>> -               if (!zone->all_unreclaimable)
>> +               if (zone->all_unreclaimable)
>> +                       continue;
>> +               if (zone_reclaimable(zone))
>>                          return false;
>
>Please tell me why you chaned here.
The original check is once found zone->all_unreclaimable is false, it will =
return false, then it will set did_some_progress non-zero. Then another loo=
p of direct_reclaimed performed. But I think zone->all_unreclaimable is not=
 always reliable such as in my case, kswapd go to sleep and no one will cha=
nge this flag. We should also check zone_reclaimalbe(zone) if zone->all_unr=
eclaimalbe =3D 0 to double confirm if a zone is reclaimable; This change al=
so avoid the issue you described in below commit:
commit 929bea7c714220fc76ce3f75bef9056477c28e74
Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date:   Thu Apr 14 15:22:12 2011 -0700
    vmscan: all_unreclaimable() use zone->all_unreclaimable as a name
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
