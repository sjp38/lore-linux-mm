Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 623766B007B
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 02:00:59 -0500 (EST)
Received: by pwj10 with SMTP id 10so2107869pwj.6
        for <linux-mm@kvack.org>; Sun, 01 Nov 2009 23:00:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091102155543.E60E.A69D9226@jp.fujitsu.com>
References: <20091102005218.8352.A69D9226@jp.fujitsu.com>
	 <20091102135640.93de7c2a.minchan.kim@barrios-desktop>
	 <20091102155543.E60E.A69D9226@jp.fujitsu.com>
Date: Mon, 2 Nov 2009 16:00:57 +0900
Message-ID: <28c262360911012300h4535118ewd65238c746b91a52@mail.gmail.com>
Subject: Re: OOM killer, page fault
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Norbert Preining <preining@logic.at>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 2, 2009 at 3:59 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Mon, =A02 Nov 2009 13:24:06 +0900 (JST)
>> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>> > Hi,
>> >
>> > (Cc to linux-mm)
>> >
>> > Wow, this is very strange log.
>> >
>> > > Dear all,
>> > >
>> > > (please Cc)
>> > >
>> > > With 2.6.32-rc5 I got that one:
>> > > [13832.210068] Xorg invoked oom-killer: gfp_mask=3D0x0, order=3D0, o=
om_adj=3D0
>> >
>> > order =3D 0
>>
>> I think this problem results from 'gfp_mask =3D 0x0'.
>> Is it possible?
>>
>> If it isn't H/W problem, Who passes gfp_mask with 0x0?
>> It's culpit.
>>
>> Could you add BUG_ON(gfp_mask =3D=3D 0x0) in __alloc_pages_nodemask's he=
ad?
>
> No.
> In page fault case, gfp_mask show meaningless value. Please ignore it.
> pagefault_out_of_memory() always pass gfp_mask=3D=3D0 to oom.
>
>
> mm/oom_kill.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> void pagefault_out_of_memory(void)
> {
> =A0 =A0 =A0 =A0unsigned long freed =3D 0;
>
> =A0 =A0 =A0 =A0blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> =A0 =A0 =A0 =A0if (freed > 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Got some memory back in the last second=
. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * If this is from memcg, oom-killer is already invoked.
> =A0 =A0 =A0 =A0 * and not worth to go system-wide-oom.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (mem_cgroup_oom_called(current))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto rest_and_return;
>
> =A0 =A0 =A0 =A0if (sysctl_panic_on_oom)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0panic("out of memory from page fault. pani=
c_on_oom is selected.\n");
>
> =A0 =A0 =A0 =A0read_lock(&tasklist_lock);
> =A0 =A0 =A0 =A0__out_of_memory(0, 0); =A0 =A0 =A0 <---- here!
> =A0 =A0 =A0 =A0read_unlock(&tasklist_lock);
>
>

Yeb. Kame already noticed it. :)
Thanks for pointing me out, again.

I already suggested another patch.
What do you think about it?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
