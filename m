Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B88E66B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 09:00:51 -0400 (EDT)
Received: by bwz17 with SMTP id 17so2754724bwz.14
        for <linux-mm@kvack.org>; Fri, 03 Jun 2011 06:00:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DE8D50F.1090406@redhat.com>
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>
	<20110601123913.GC4266@tiehlicka.suse.cz>
	<4DE6399C.8070802@redhat.com>
	<20110601134149.GD4266@tiehlicka.suse.cz>
	<4DE64F0C.3050203@redhat.com>
	<20110601152039.GG4266@tiehlicka.suse.cz>
	<4DE66BEB.7040502@redhat.com>
	<BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
	<4DE8D50F.1090406@redhat.com>
Date: Fri, 3 Jun 2011 22:00:47 +0900
Message-ID: <BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node to world
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

2011/6/3 Igor Mammedov <imammedo@redhat.com>:
> On 06/02/2011 01:10 AM, Hiroyuki Kamezawa wrote:
>>>
>>> pc =3D list_entry(list->prev, struct page_cgroup, lru);
>>
>> Hmm, I disagree your patch is a fix for mainline. At least, a cgroup
>> before completion of
>> create() is not populated to userland and you never be able to rmdir()
>> it because you can't
>> find it.
>>
>>
>> =A0>26: =A0 e8 7d 12 30 00 =A0 =A0 =A0 =A0 =A0call =A0 0x3012a8
>> =A0>2b:* =A08b 73 08 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mov =A0 =A00x8(%ebx)=
,%esi<-- trapping
>> instruction
>> =A0>2e: =A0 8b 7c 24 24 =A0 =A0 =A0 =A0 =A0 =A0 mov =A0 =A00x24(%esp),%e=
di
>> =A0>32: =A0 8b 07 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mov =A0 =A0(%edi),=
%eax
>>
>> Hm, what is the call 0x3012a8 ?
>>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc =3D list_entry(list->prev, struct page_=
cgroup, lru);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (busy =3D=3D pc) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(&pc->lru, list);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0busy =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zo=
ne->lru_lock, flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lru_lock, fl=
ags); <---- is
> =A0call 0x3012a8
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_move_parent(pc, mem, GF=
P_KERNEL);
>
> and =A0mov 0x8(%ebx),%esi
> is dereferencing of 'pc' in inlined mem_cgroup_move_parent
>
Ah, thank you for input..then panicd at accessing pc->page and "pc"
was 0xfffffff4.
it means list->prev was NULL.

> I've looked at vmcore once more and indeed there isn't any parallel task
> that touches cgroups code path.
> Will investigate if it is xen to blame for incorrect data in place.
>
> Thanks very much for your opinion.

What curious to me is that the fact "list->prev" is NULL.
I can see why you doubt the initialization code ....the list pointer never
contains NULL once it's used....
it smells like memory corruption or some to me. If you have vmcore,
what the problematic mem_cgroup_per_zone(node) contains ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
