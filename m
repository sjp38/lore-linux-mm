Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 154186B01B2
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 02:34:49 -0400 (EDT)
Received: by pxi17 with SMTP id 17so4049852pxi.14
        for <linux-mm@kvack.org>; Mon, 28 Jun 2010 23:34:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTinuas0MPFvZk9nOd91PuHXtaluHkkcWjGKYPZOl@mail.gmail.com>
References: <AANLkTilJDrpoFGyTSrKg3Hg59u9TvBLbxk4HAVKBvjxQ@mail.gmail.com>
	<1277733320.3561.50.camel@laptop>
	<AANLkTinuas0MPFvZk9nOd91PuHXtaluHkkcWjGKYPZOl@mail.gmail.com>
Date: Tue, 29 Jun 2010 14:34:48 +0800
Message-ID: <AANLkTin8xnr1Vp1lXiOpWcMLHSlbwpPiRrkzZVMChOus@mail.gmail.com>
Subject: Re: [PATCH] avoid return NULL on root rb_node in rb_next/rb_prev in
	lib/rbtree.c
From: shenghui <crosslonelyover@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

2010/6/29 shenghui <crosslonelyover@gmail.com>:
> 2010/6/28 Peter Zijlstra <peterz@infradead.org>:
>> So if ->rb_leftmost is NULL, then the if (!left) check in
>> __pick_next_entity() would return null.
>>
>> As to the NULL deref in in pick_next_task_fair()->set_next_entity() that
>> should never happen because pick_next_task_fair() will bail
>> on !->nr_running.
>>
>> Furthermore, you've failed to mention what kernel version you're looking
>> at.
>>
>
> The kernel version is 2.6.35-rc3, and 2.6.34 has the same code.
>
> For nr->running, if current is the only process in the run queue, then
> nr->running would not be zero.
> 1784 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cfs_rq->nr_running)
> 1785 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
> pick_next_task_fair() could pass above check and run to following:
> 1787 =C2=A0 =C2=A0 =C2=A0 =C2=A0do {
> 1788 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0se =3D pick_n=
ext_entity(cfs_rq);
> 1789 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_next_enti=
ty(cfs_rq, se);
> 1790 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cfs_rq =3D gr=
oup_cfs_rq(se);
> 1791 =C2=A0 =C2=A0 =C2=A0 =C2=A0} while (cfs_rq);
>
> Then pick_next_entity will get NULL for current is the root rb_node.
> Then set_next_entity would fail on NULL deference.
>

Sorry, I misunderstood the code. I'll put forward one new patch to
avoid the NULL condition


--=20


Thanks and Best Regards,
shenghui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
