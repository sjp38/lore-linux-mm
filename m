Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E20AF6B002A
	for <linux-mm@kvack.org>; Thu, 12 May 2011 00:17:15 -0400 (EDT)
Received: by qwa26 with SMTP id 26so867836qwa.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 21:17:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110512123942.4b641e2d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com>
	<20110510171335.16A7.A69D9226@jp.fujitsu.com>
	<20110510171641.16AF.A69D9226@jp.fujitsu.com>
	<20110512095243.c57e3e83.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=ya1rAqC+nMPHkBaMsoXpsCeHH=w@mail.gmail.com>
	<20110512105351.a57970d7.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimWOtKKj+Jq1vqHfOfQ2UvP7Xxa3g@mail.gmail.com>
	<20110512123942.4b641e2d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 12 May 2011 13:17:13 +0900
Message-ID: <BANLkTi=dvb5tXxzLwY+vgG8o4eYq5f_X8Q@mail.gmail.com>
Subject: Re: [PATCH 2/4] oom: kill younger process first
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Thu, May 12, 2011 at 12:39 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 12 May 2011 11:23:38 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Thu, May 12, 2011 at 10:53 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Thu, 12 May 2011 10:30:45 +0900
>> > Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> > As above implies, (B)->prev pointer is invalid pointer after list_del(=
).
>> > So, there will be race with list modification and for_each_list_revers=
e under
>> > rcu_read__lock()
>> >
>> > So, when you need to take atomic lock (as tasklist lock is) is...
>> >
>> > =C2=A01) You can't check 'entry' is valid or not...
>> > =C2=A0 =C2=A0In above for_each_list_rcu(), you may visit an object whi=
ch is under removing.
>> > =C2=A0 =C2=A0You need some flag or check to see the object is valid or=
 not.
>> >
>> > =C2=A02) you want to use list_for_each_safe().
>> > =C2=A0 =C2=A0You can't do list_del() an object which is under removing=
...
>> >
>> > =C2=A03) You want to walk the list in reverse.
>> >
>> > =C2=A03) Some other reasons. For example, you'll access an object poin=
ted by the
>> > =C2=A0 =C2=A0'entry' and the object is not rcu safe.
>> >
>> > make sense ?
>>
>> Yes. Thanks, Kame.
>> It seems It is caused by prev poisoning of list_del_rcu.
>> If we remove it, isn't it possible to traverse reverse without atomic lo=
ck?
>>
>
> IIUC, it's possible (Fix me if I'm wrong) but I don't like that because o=
f 2 reasons.
>
> 1. LIST_POISON is very important information at debug.

Indeed.
But if we can get a better something although we lost debug facility,
I think it would be okay.

>
> 2. If we don't clear prev pointer, ok, we'll allow 2 directional walk of =
list
> =C2=A0 under RCU.
> =C2=A0 But, in following case
> =C2=A0 1. you are now at (C). you'll visit (C)->next...(D)
> =C2=A0 2. you are now at (D). you want to go back to (C) via (D)->prev.
> =C2=A0 3. But (D)->prev points to (B)
>
> =C2=A0It's not a 2 directional list, something other or broken one.

Yes. but it shouldn't be a problem in RCU semantics.
If you need such consistency, you should use lock.

I recall old thread about it.
In http://lwn.net/Articles/262464/, mmutz and Paul already discussed
about it. :)

> =C2=A0Then, the rculist is 1 directional list in nature, I think.

Yes. But Why RCU become 1 directional list is we can't find a useful usecas=
es.

>
> So, without very very big reason, we should keep POISON.

Agree.
I don't insist on it as it's not a useful usecase for persuading Paul.
That's because it's not a hot path.

It's started from just out of curiosity.
Thanks for very much clarifying that, Kame!

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
