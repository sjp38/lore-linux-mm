Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9FC476B0071
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 19:07:38 -0400 (EDT)
Received: by iwn39 with SMTP id 39so3591467iwn.14
        for <linux-mm@kvack.org>; Tue, 22 Jun 2010 16:07:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100622213301.GA26285@cmpxchg.org>
References: <20100622112416.B554.A69D9226@jp.fujitsu.com>
	<AANLkTilN3EcYq400ajA2-rf3Xs4MhD-sKCg44fjzKlX1@mail.gmail.com>
	<20100622114739.B563.A69D9226@jp.fujitsu.com>
	<AANLkTimleJIOdYquPwJvgGK3Dj_JDijoNjCQh4dfXxAY@mail.gmail.com>
	<20100622213301.GA26285@cmpxchg.org>
Date: Wed, 23 Jun 2010 08:07:34 +0900
Message-ID: <AANLkTin-dYU245QH3WJWzLAx713o0pJLYozRO6tin3rq@mail.gmail.com>
Subject: Re: [Patch] Call cond_resched() at bottom of main look in
	balance_pgdat()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 23, 2010 at 6:33 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Tue, Jun 22, 2010 at 01:29:17PM +0900, Minchan Kim wrote:
>> On Tue, Jun 22, 2010 at 12:23 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> >> Kosaki's patch's goal is that kswap doesn't yield cpu if the zone =
doesn't meet its
>> >> >> min watermark to avoid failing atomic allocation.
>> >> >> But this patch could yield kswapd's time slice at any time.
>> >> >> Doesn't the patch break your goal in bb3ab59683?
>> >> >
>> >> > No. it don't break.
>> >> >
>> >> > Typically, kswapd periodically call shrink_page_list() and it call
>> >> > cond_resched() even if bb3ab59683 case.
>> >>
>> >> Hmm. If it is, bb3ab59683 is effective really?
>> >>
>> >> The bb3ab59683's goal is prevent CPU yield in case of free < min_wate=
rmark.
>> >> But shrink_page_list can yield cpu from kswapd at any time.
>> >> So I am not sure what is bb3ab59683's benefit.
>> >> Did you have any number about bb3ab59683's effectiveness?
>> >> (Of course, I know it's very hard. Just out of curiosity)
>> >>
>> >> As a matter of fact, when I saw this Larry's patch, I thought it woul=
d
>> >> be better to revert bb3ab59683. Then congestion_wait could yield CPU
>> >> to other process.
>> >>
>> >> What do you think about?
>> >
>> > No. The goal is not prevent CPU yield. The goal is avoid unnecessary
>> > _long_ sleep (i.e. congestion_wait(BLK_RW_ASYNC, HZ/10)).
>>
>> I meant it.
>>
>> > Anyway we can't refuse CPU yield on UP. it lead to hangup ;)
>> >
>> > What do you mean the number? If it mean how much reduce congestion_wai=
t(),
>> > it was posted a lot of time. If it mean how much reduce page allocatio=
n
>> > failure bug report, I think it has been observable reduced since half
>> > years ago.
>>
>> I meant second.
>> Hmm. I doubt it's observable since at that time, Mel had posted many
>> patches to reduce page allocation fail. bb3ab59683 was just one of
>> them.
>>
>> >
>> > If you have specific worried concern, can you please share it?
>> >
>>
>> My concern is that I don't want to add new band-aid on uncertain
>> feature to solve
>> regression of uncertain feature.(Sorry for calling Larry's patch as band=
-aid.).
>> If we revert bb3ab59683, congestion_wait in balance_pgdat could yield
>> cpu from kswapd.
>>
>> If you insist on bb3ab59683's effective and have proved it at past, I
>> am not against it.
>>
>> And If it's regression of bb3ab59683, Doesn't it make sense following as=
?
>> It could restore old behavior.
>>
>> ---
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* OK, kswa=
pd is getting into trouble. =C2=A0Take a nap, then take
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* another =
pass across the zones.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (total_scanne=
d && (priority < DEF_PRIORITY - 2)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 if (has_under_min_watermark_zone) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count_vm_event(KSWAPD_SKIP_CONGES=
TION_WAIT);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* allowing CPU yield to go on
>> watchdog or OOMed task */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cond_resched();
>
> We have two things here: one is waiting for some IO to complete, which
> we skip if we are in a hurry. =C2=A0The other thing is that we have a
> potentially long-running loop with no garuanteed rescheduling point in
> it. =C2=A0I would rather not mix up those two and let this cond_resched()
> for #2 stand on it's own and be self-explanatory.
>
> So,
>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>
> to Larry's patch (or KOSAKI-san's version of it for that matter).
>

Okay. As I hear Kosaki and Hannes opinions, I was paranoid.
Thanks for good comment!, Kosaki and Hannes.
Feel free to add my sign to Kosaki's version(I like detailed description :)=
 )

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
