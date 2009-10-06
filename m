Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 99D486B004F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 18:59:16 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n96MxCc5027110
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 15:59:13 -0700
Received: from iwn26 (iwn26.prod.google.com [10.241.68.90])
	by spaceape11.eur.corp.google.com with ESMTP id n96Mwswb016544
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 15:59:10 -0700
Received: by iwn26 with SMTP id 26so2536613iwn.5
        for <linux-mm@kvack.org>; Tue, 06 Oct 2009 15:59:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20091006114052.5FAA.A69D9226@jp.fujitsu.com>
References: <20091006112803.5FA5.A69D9226@jp.fujitsu.com>
	 <20091006114052.5FAA.A69D9226@jp.fujitsu.com>
Date: Tue, 6 Oct 2009 15:59:09 -0700
Message-ID: <604427e00910061559v34590d49x4cdd01b16df6fb1e@mail.gmail.com>
Subject: Re: [PATCH 2/2] mlock use lru_add_drain_all_async()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello=A0KOSAKI-san,

Few questions on the lru_add_drain_all_async(). If i understand
correctly, the reason that we have lru_add_drain_all() in the mlock()
call is to isolate mlocked pages into the separate LRU in case they
are sitting in pagevec.

And I also understand the RT use cases you put in the patch
description, now my questions is that do we have race after applying
the patch? For example that if the RT task not giving up the cpu by
the time mlock returns, you have pages left in the pagevec which not
being drained back to the lru list. Do we have problem with that?

--Ying

On Mon, Oct 5, 2009 at 7:41 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> Recently, Peter Zijlstra reported RT-task can lead to prevent mlock
> very long time.
>
> =A0Suppose you have 2 cpus, cpu1 is busy doing a SCHED_FIFO-99 while(1),
> =A0cpu0 does mlock()->lru_add_drain_all(), which does
> =A0schedule_on_each_cpu(), which then waits for all cpus to complete the
> =A0work. Except that cpu1, which is busy with the RT task, will never run
> =A0keventd until the RT load goes away.
>
> =A0This is not so much an actual deadlock as a serious starvation case.
>
> Actually, mlock() doesn't need to wait to finish lru_add_drain_all().
> Thus, this patch replace it with lru_add_drain_all_async().
>
> Cc: Oleg Nesterov <onestero@redhat.com>
> Reported-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> =A0mm/mlock.c | =A0 =A04 ++--
> =A01 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 22041aa..46a016f 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -458,7 +458,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, =
len)
> =A0 =A0 =A0 =A0if (!can_do_mlock())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
>
> - =A0 =A0 =A0 lru_add_drain_all(); =A0 =A0/* flush pagevec */
> + =A0 =A0 =A0 lru_add_drain_all_async(); =A0 =A0 =A0/* flush pagevec */
>
> =A0 =A0 =A0 =A0down_write(&current->mm->mmap_sem);
> =A0 =A0 =A0 =A0len =3D PAGE_ALIGN(len + (start & ~PAGE_MASK));
> @@ -526,7 +526,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
> =A0 =A0 =A0 =A0if (!can_do_mlock())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> - =A0 =A0 =A0 lru_add_drain_all(); =A0 =A0/* flush pagevec */
> + =A0 =A0 =A0 lru_add_drain_all_async(); =A0 =A0 =A0/* flush pagevec */
>
> =A0 =A0 =A0 =A0down_write(&current->mm->mmap_sem);
>
> --
> 1.6.2.5
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
