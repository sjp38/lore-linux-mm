Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 468A66B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 19:40:20 -0500 (EST)
Received: by pxi5 with SMTP id 5so430770pxi.12
        for <linux-mm@kvack.org>; Thu, 21 Jan 2010 16:40:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100122084856.600b2dd5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	 <1264087124.1818.15.camel@barrios-desktop>
	 <20100122084856.600b2dd5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 22 Jan 2010 09:40:17 +0900
Message-ID: <28c262361001211640w4ff6d61mdf682fa706ab61e@mail.gmail.com>
Subject: Re: [PATCH] oom-kill: add lowmem usage aware oom kill handling
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 22, 2010 at 8:48 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 22 Jan 2010 00:18:44 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi, Kame.
>>
>> On Thu, 2010-01-21 at 14:59 +0900, KAMEZAWA Hiroyuki wrote:
>> > A patch for avoiding oom-serial-killer at lowmem shortage.
>> > Patch is onto mmotm-2010/01/15 (depends on mm-count-lowmem-rss.patch)
>> > Tested on x86-64/SMP + debug module(to allocated lowmem), works well.
>> >
>> > =3D=3D
>> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >
>> > One cause of OOM-Killer is memory shortage in lower zones.
>> > (If memory is enough, lowmem_reserve_ratio works well. but..)
>> >
>> > In lowmem-shortage oom-kill, oom-killer choses a vicitim process
>> > on their vm size. But this kills a process which has lowmem memory
>> > only if it's lucky. At last, there will be an oom-serial-killer.
>> >
>> > Now, we have per-mm lowmem usage counter. We can make use of it
>> > to select a good? victim.
>> >
>> > This patch does
>> > =C2=A0 - add CONSTRAINT_LOWMEM to oom's constraint type.
>> > =C2=A0 - pass constraint to __badness()
>> > =C2=A0 - change calculation based on constraint. If CONSTRAINT_LOWMEM,
>> > =C2=A0 =C2=A0 use low_rss instead of vmsize.
>>
>> As far as low memory, it would be better to consider lowmem counter.
>> But as you know, {vmsize VS rss} is debatable topic.
>> Maybe someone doesn't like this idea.
>>
> About lowmem, vmsize never work well.
>

Tend to agree with you.
I am just worried about "vmsize lovers".

You removed considering vmsize totally.
In case of LOWMEM, lowcount considering make sense.
But never considering vmsize might be debatable.

So personllay, I thouhg we could add more weight lowcount
in case of LOWMEM. But I chaged my mind.
I think it make OOM heurisic more complated without big benefit.

Simple is best.

>> So don't we need any test result at least?
> My test result was very artificial, so I didn't attach the result.
>
> =C2=A0- Before this patch, sshd was killed at first.
> =C2=A0- After this patch, memory consumer of low-rss was killed.

Okay. You already anwsered my question by Balbir's reply.
I had a question it's real problem and how often it happens.

>
>> If we don't have this patch, it happens several innocent process
>> killing. but we can't prevent it by this patch.
>>
> I can't catch what you mean.

I just said your patch's benefit.

>> Sorry for bothering you.
>>
>
> Hmm, boot option or CONFIG ? (CONFIG_OOMKILLER_EXTENSION ?)
>
> I'm now writing fork-bomb detector again and want to remove current
> "gathering child's vm_size" heuristics. I'd like to put that under
> the same config, too.

Totally, I don't like CONFIG option for that.
But vmsize lovers also don't want to change current behavior.
So it's desirable until your fork-form detector become mature and
prove it's good.

One more questions about below.

+       if (constraint !=3D CONSTRAINT_LOWMEM) {
+               list_for_each_entry(child, &p->children, sibling) {
+                       task_lock(child);
+                       if (child->mm !=3D mm && child->mm)
+                               points +=3D child->mm->total_vm/2 + 1;
+                       task_unlock(child);
+               }

Why didn't you consider child's lowmem counter in case of LOWMEM?

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



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
