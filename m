Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BC9956B01B9
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:12:07 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 39so1762411iwn.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 23:12:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100603144948.724D.A69D9226@jp.fujitsu.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com>
	<20100603144948.724D.A69D9226@jp.fujitsu.com>
Date: Thu, 3 Jun 2010 15:12:10 +0900
Message-ID: <AANLkTikF0EAmKsBx28-paTg7DUdOiHLz5KHJbzLW_OBS@mail.gmail.com>
Subject: Re: [PATCH 02/12] oom: introduce find_lock_task_mm() to fix !mm false
	positives
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 3, 2010 at 2:50 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> From: Oleg Nesterov <oleg@redhat.com>
>
> Almost all ->mm =3D=3D NUL checks in oom_kill.c are wrong.
>
> The current code assumes that the task without ->mm has already
> released its memory and ignores the process. However this is not
> necessarily true when this process is multithreaded, other live
> sub-threads can use this ->mm.
>
> - Remove the "if (!p->mm)" check in select_bad_process(), it is
> =C2=A0just wrong.
>
> - Add the new helper, find_lock_task_mm(), which finds the live
> =C2=A0thread which uses the memory and takes task_lock() to pin ->mm
>
> - change oom_badness() to use this helper instead of just checking
> =C2=A0->mm !=3D NULL.
>
> - As David pointed out, select_bad_process() must never choose the
> =C2=A0task without ->mm, but no matter what badness() returns the
> =C2=A0task can be chosen if nothing else has been found yet.
>
> Note! This patch is not enough, we need more changes.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- badness() was fixed, but oom_kill_task() sti=
ll ignores
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0the task without ->mm
>
> This will be addressed later.
>
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Could you see my previous comment?
http://lkml.org/lkml/2010/6/2/325
Anyway, I added my review sign

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
