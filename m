Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6778E8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 22:38:21 -0400 (EDT)
Received: by iwg8 with SMTP id 8so91151iwg.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 19:38:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110324105222.GA2625@barrios-desktop>
	<20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 25 Mar 2011 11:38:19 +0900
Message-ID: <BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
Subject: Re: [PATCH 0/4] forkbomb killer
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Fri, Mar 25, 2011 at 9:04 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 24 Mar 2011 19:52:22 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi Kame,
>>
> Hi.
>
>> On Thu, Mar 24, 2011 at 06:22:40PM +0900, KAMEZAWA Hiroyuki wrote:
>> >
>> > I tested with several forkbomb cases and this patch seems work fine.
>> >
>> > Maybe some more 'heuristics' can be added....but I think this simple
>> > one works enough. Any comments are welcome.
>>
>> Sorry for the late review. Recently I dont' have enough time to review p=
atches.
>> Even I didn't start to review this series but I want to review this seri=
es.
>> It's one of my interest features. :)
>>
>> But before digging in code, I would like to make a consensus to others t=
o
>> need this feature. Let's Cc others.
>>
>> What I think is that about "cost(frequent case) VS effectiveness(very ra=
re case)"
>> as you expected. :)
>>
>> 1. At least, I don't meet any fork-bomb case for a few years. My primary=
 linux usage
>> is just desktop and developement enviroment, NOT server. Only thing I ha=
ve seen is
>> just ltp or intentional fork-bomb test like hackbench. AFAIR, ltp case w=
as fixed
>> a few years ago. Although it happens suddenly, reboot in desktop isn't c=
ritical
>> as much as server's one.
>>
>
> Personally, I've met forkbombs several times by typing "make -j" .....by =
mistake.
>
> I met a forkbomb on production system by buggy script, once.
> That happens because
> =C2=A01. $PATH includes "."
> =C2=A02. a programmer write a scirpt "date" and call "date" in the script=
.
>
> Maybe this is a one of typical case of forkbomb. I needed to dig crashdum=
p to find
> fragile of page-caches and see what happens...But, I guess, if appearent =
forkbomb
> happens, the issue will not be sent to my team because we're 2nd line sup=
port team
> and 1st line should block it ;).
>
> So, I'm not sure how many forkbombs happens in server world in a year. Bu=
t I guess
> forkbomb still happens in many development systems because there is no gu=
ard
> against it.
>
>
>> 2. I don't know server enviroment but I think applications executing on =
server
>> are selected by admin carefully. So virus program like fork-bomb is unli=
kely in there.
>> (Maybe I am wrong. You know than me).
>> If some normal program becomes fork-bomb unexpectedly, it's critical.
>> Admin should select application with much testing very carefully. But I =
don't know
>> the reality. :(
>>
>
> Yes, admin selects applications carefully. There is no 100% protection by=
 human's hand.
>
>
>> Of course, although he did such efforts, he could meet OOM hang situatio=
n.
>> In the case, he can't avoid rebooting. Sad. But for helping him, should =
we pay cost
>> in normal situation?(Again said, I didn't start looking at your code so
>> I can't expect the cost but at least it's more than as-is).
>> It could help developing many virus program and to make careless admins.
>>
>> It's just my private opinion.
>> I don't have enough experience so I hope listen other's opinions
>> about generic fork-bomb killer, not memcg.
>>
>> I don't intend to ignore your effort but justify your and my effort righ=
tly.
>>
>
> To me, the fact "the system _can_ be broken by a normal user program" is =
the most
> terrible thing. With Andrey's case or make -j, a user doesn't need to be =
an admin.
> I believe it's worth to pay costs.
> (and I made this function configurable and can be turned off by sysfs.)
>
> And while testing Andrey's case, I used KVM finaly becasue cost of reboot=
ing was small.
> My development server is on other building and I need to push server's bu=
tton
> to reboot it when forkbomb happens ;)
> In some environement, cost of rebooting is not small even if it's a devel=
opment system.
>

Forkbomb is very rare case in normal situation but if it happens, the
cost like reboot would be big. So we need the such facility. I agree.
(But I don't know why others don't have a interest if it is important
task. Maybe they are so busy due to rc1)
Just a concern is cost.
The approach is we can enhance your approach to minimize the cost but
apparently it would have a limitation.

Other approach is we can provide new rescue facility.
What I have thought is new sysrq about killing fork-bomb.

If we execute the new sysrq, the kernel freezes all tasks so forkbomb
can't execute any more and kernel ready to receive the command to show
the system state. Admin can investigate which is fork-bomb and then he
kill the tasks. At last, admin restarts all processes with new sysrq
and processes which received SIGKILL start to die.

This approach offloads kernel's heuristic forkbomb detection to admin
and avoid runtime cost in normal situation.
I don't have any code to implement above the concept so it might be ridicul=
ous.

What do you think about it?

>
> Thanks,
> -Kame
>
>
>
>
>
>
>
>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
