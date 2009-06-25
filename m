Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F23C6B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 11:03:19 -0400 (EDT)
Received: by gxk3 with SMTP id 3so1675146gxk.14
        for <linux-mm@kvack.org>; Thu, 25 Jun 2009 08:03:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1245941665.6459.18.camel@lts-notebook>
References: <20090625183616.23b55b24.minchan.kim@barrios-desktop>
	 <2f11576a0906250714o5d77db11wd32c1c7139753cb5@mail.gmail.com>
	 <28c262360906250744h5bf9f0a0w265d8c35e7d69335@mail.gmail.com>
	 <1245941665.6459.18.camel@lts-notebook>
Date: Fri, 26 Jun 2009 00:03:22 +0900
Message-ID: <28c262360906250803p31e72a2at73ff1af823615260@mail.gmail.com>
Subject: Re: [PATCH] prevent to reclaim anon page of lumpy reclaim for no swap
	space
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, Lee.

On Thu, Jun 25, 2009 at 11:54 PM, Lee
Schermerhorn<Lee.Schermerhorn@hp.com> wrote:
> On Thu, 2009-06-25 at 23:44 +0900, Minchan Kim wrote:
>> On Thu, Jun 25, 2009 at 11:14 PM, KOSAKI
>> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> This patch prevent to reclaim anon page in case of no swap space.
>> >> VM already prevent to reclaim anon page in various place.
>> >> But it doesnt't prevent it for lumpy reclaim.
>> >>
>> >> It shuffles lru list unnecessary so that it is pointless.
>> >
>> > NAK.
>> >
>> > 1. if system have no swap, add_to_swap() never get swap entry.
>> > =C2=A0 eary check don't improve performance so much.
>>
>> Hmm. I mean no swap space but not no swap device.
>> add_to_swap ? You mean Rik pointed me out ?
>> If system have swap device, Rik's pointing is right.
>> I will update his suggestion.
>>
>> > 2. __isolate_lru_page() is not only called lumpy reclaim case, but
>> > also be called
>> > =C2=A0 =C2=A0normal reclaim.
>>
>> You mean about performance degradation ?
>> I think most case have enough swap space and then one condition
>> variable(nr_swap_page) check is trivial. I think.
>> We can also use [un]likely but I am not sure it help us.
>>
>>
>> > 3. if system have no swap, anon pages shuffuling doesn't cause any mat=
ter.
>>
>> Again, I mean no swap space but no swap device system.
>> And I have a plan to remove anon_vma in no swap device system.
>>
>> As you point me out, it's pointless in no swap device system.
>> I don't like unnecessary structure memory footprint and locking overhead=
.
>> I think no swap device system is problem in server environment as well
>> as embedded. but I am not sure when I will do. :)
>>
>
> How will we walk the reverse map for try_to_unmap() for page migration
> or try_to_munlock() w/o anon_vma? =C2=A0Perhaps one can remove anon_vma w=
hen
> there is no swap device and migration and the unevictable lru are not
> configured--e.g., for embedded systems.

You're right. In addition, there are HWPoison and maybe KSM.
Also, unevictable lru list isn't option any more even embedded system.

Actually I considered it in embedded system as you said.
I think above enumerated cases are not needed in embedded system.
Memory footprint and unnecessary locking is more important in embedded
since small memory and realtime.

Anyway, I think it's not easy so now it's just plan.
Welcome to any comment to prevent my vain effort. :)

Thanks for valuable comment. Lee. :)

> Lee
>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
