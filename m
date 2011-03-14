Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF098D003A
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 21:03:49 -0400 (EDT)
Received: by iwl42 with SMTP id 42so6237357iwl.14
        for <linux-mm@kvack.org>; Sun, 13 Mar 2011 18:03:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4D79BC60.1040106@gmail.com>
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>
	<20110305152056.GA1918@barrios-desktop>
	<4D72580D.4000208@gmail.com>
	<20110305155316.GB1918@barrios-desktop>
	<4D7267B6.6020406@gmail.com>
	<20110305170759.GC1918@barrios-desktop>
	<20110307135831.9e0d7eaa.akpm@linux-foundation.org>
	<AANLkTinDhorLusBju=Gn3bh1VsH1jrv0qixbU3SGWiqa@mail.gmail.com>
	<20110309143704.194e8ee1.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=q=YMrT7Uta+wGm47VZ5N6meybAQTgjKGsDWFw@mail.gmail.com>
	<20110311085833.874c6c0e.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=1695Wp9UheV_OKk5MixNUY2aHWfQ2WO1evSe2@mail.gmail.com>
	<4D79BC60.1040106@gmail.com>
Date: Mon, 14 Mar 2011 10:03:47 +0900
Message-ID: <AANLkTimVSu4Jr0wio7Vc0rJ3mM+SrrgyjUxJoZ1MSaiF@mail.gmail.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: avagin@gmail.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 11, 2011 at 3:08 PM, avagin@gmail.com <avagin@gmail.com> wrote:
> On 03/11/2011 03:18 AM, Minchan Kim wrote:
>>
>> On Fri, Mar 11, 2011 at 8:58 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> =C2=A0wrote:
>>>
>>> On Thu, 10 Mar 2011 15:58:29 +0900
>>> Minchan Kim<minchan.kim@gmail.com> =C2=A0wrote:
>>>
>>>> Hi Kame,
>>>>
>>>> Sorry for late response.
>>>> I had a time to test this issue shortly because these day I am very
>>>> busy.
>>>> This issue was interesting to me.
>>>> So I hope taking a time for enough testing when I have a time.
>>>> I should find out root cause of livelock.
>>>>
>>>
>>> Thanks. I and Kosaki-san reproduced the bug with swapless system.
>>> Now, Kosaki-san is digging and found some issue with scheduler boost at
>>> OOM
>>> and lack of enough "wait" in vmscan.c.
>>>
>>> I myself made patch like attached one. This works well for returning TR=
UE
>>> at
>>> all_unreclaimable() but livelock(deadlock?) still happens.
>>
>> I saw the deadlock.
>> It seems to happen by following code by my quick debug but not sure. I
>> need to investigate further but don't have a time now. :(
>>
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Note: th=
is may have a chance of deadlock if it gets
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* blocked =
waiting for another task which itself is
>> waiting
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* for memo=
ry. Is there a better alternative?
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (test_tsk_thr=
ead_flag(p, TIF_MEMDIE))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 return ERR_PTR(-1UL);
>> It would be wait to die the task forever without another victim selectio=
n.
>> If it's right, It's a known BUG and we have no choice until now. Hmm.
>
>
> I fixed this bug too and sent patch "mm: skip zombie in OOM-killer".
>
> http://groups.google.com/group/linux.kernel/browse_thread/thread/b9c6ddf3=
4d1671ab/2941e1877ca4f626?lnk=3Draot&pli=3D1
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (test_tsk_thread_fl=
ag(p, TIF_MEMDIE))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (test_tsk_thread_fl=
ag(p, TIF_MEMDIE) && p->mm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return ERR_PTR(-1UL);
>
> It is not committed yet, because Devid Rientjes and company think what to=
 do
> with "[patch] oom: prevent unnecessary oom kills or kernel panics.".

Thanks, Andrey.
The patch "mm: skip zombie in OOM-killer"  solves my livelock issue
but I didn't look effectiveness of "mm: check zone->all_unreclaimable
in all_unreclaimable". I have to look further.

But your patch  "mm: skip zombie in OOM-killer" is very controversial
because It breaks multi-thread case.
Since find_lock_task_mm is introduced, we have considered mt cases but
I think it doesn't cover completely all cases like discussing
TIF_MEMDIE now.

I will watch the discussion.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
