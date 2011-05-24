Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8006B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:32:45 -0400 (EDT)
Received: by qwa26 with SMTP id 26so4486946qwa.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 18:32:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DDB0669.6040409@jp.fujitsu.com>
References: <4DD61F80.1020505@jp.fujitsu.com>
	<4DD6204D.5020109@jp.fujitsu.com>
	<BANLkTim2-uncnzoHwdG+4+uCv+Ht4YH3Qw@mail.gmail.com>
	<4DDB0669.6040409@jp.fujitsu.com>
Date: Tue, 24 May 2011 10:32:43 +0900
Message-ID: <BANLkTinb3Yuvrz5b-dyGYv0_HMB9+ax3yA@mail.gmail.com>
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram internally
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

On Tue, May 24, 2011 at 10:14 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>
>>> @@ -476,14 +476,17 @@ static const struct file_operations
>>> proc_lstats_operations =3D {
>>>
>>> =C2=A0static int proc_oom_score(struct task_struct *task, char *buffer)
>>> =C2=A0{
>>> - =C2=A0 =C2=A0 =C2=A0 unsigned long points =3D 0;
>>> + =C2=A0 =C2=A0 =C2=A0 unsigned long points;
>>> + =C2=A0 =C2=A0 =C2=A0 unsigned long ratio =3D 0;
>>> + =C2=A0 =C2=A0 =C2=A0 unsigned long totalpages =3D totalram_pages + to=
tal_swap_pages + 1;
>>
>> Does we need +1?
>> oom_badness does have the check.
>
> "ratio =3D points * 1000 / totalpages;" need to avoid zero divide.
>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Root processes get 3% bonus, just like th=
e __vm_enough_memory()
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * implementation used by LSMs.
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* XXX: Too large bonus, example, if the sy=
stem have tera-bytes
>>> memory..
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>>> - =C2=A0 =C2=A0 =C2=A0 if (has_capability_noaudit(p, CAP_SYS_ADMIN))
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 points -=3D 30;
>>> + =C2=A0 =C2=A0 =C2=A0 if (has_capability_noaudit(p, CAP_SYS_ADMIN)) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (points>=3D total=
pages / 32)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 points -=3D totalpages / 32;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 points =3D 0;
>>
>> Odd. Why do we initialize points with 0?
>>
>> I think the idea is good.
>
> The points is unsigned. It's common technique to avoid underflow.
>

Thanks for explanation, KOSAKI.
I need sleeping. :(



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
