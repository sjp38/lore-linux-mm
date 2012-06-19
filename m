Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 3072D6B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 02:04:08 -0400 (EDT)
Received: by ggm4 with SMTP id 4so5434362ggm.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 23:04:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com>
 <4FDFDCA7.8060607@jp.fujitsu.com> <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 19 Jun 2012 02:03:44 -0400
Message-ID: <CAHGf_=pq_UJfr22kYC=vCyEDRKx75zt5eZ27+VcqFZFqc-KHTw@mail.gmail.com>
Subject: Re: [patch v2] mm, oom: do not schedule if current has been killed
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

On Mon, Jun 18, 2012 at 10:31 PM, David Rientjes <rientjes@google.com> wrot=
e:
> The oom killer currently schedules away from current in an
> uninterruptible sleep if it does not have access to memory reserves.
> It's possible that current was killed because it shares memory with the
> oom killed thread or because it was killed by the user in the interim,
> however.
>
> This patch only schedules away from current if it does not have a pending
> kill, i.e. if it does not share memory with the oom killed thread, or is
> already exiting. =A0It's possible that it will immediately retry its memo=
ry
> allocation and fail, but it will immediately be given access to memory
> reserves if it calls the oom killer again.
>
> This prevents the delay of memory freeing when threads that share memory
> with the oom killed thread get unnecessarily scheduled.
>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
> =A0mm/oom_kill.c | =A0 =A07 ++++---
> =A01 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -746,10 +746,11 @@ out:
> =A0 =A0 =A0 =A0read_unlock(&tasklist_lock);
>
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* Give "p" a good chance of killing itself before we
> + =A0 =A0 =A0 =A0* Give "p" a good chance of exiting before we
> =A0 =A0 =A0 =A0 * retry to allocate memory unless "p" is current
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (killed && !test_thread_flag(TIF_MEMDIE))
> + =A0 =A0 =A0 if (killed && !fatal_signal_pending(current) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(current->flags & PF_EXITING))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0schedule_timeout_uninterruptible(1);
> =A0}

Why don't check gfp_flags? I think the rule is,

1) a thread of newly marked as TIF_MEMDIE
    -> now it has a capability to access reseve memory. let's immediately r=
etry.
2) allocation for GFP_HIGHUSER_MOVABLE
    -> we can fail to allocate it safely. let's immediately fail.
        (I suspect we need to change page allocator too)
3) GFP_KERNEL and PF_EXITING
    -> don't retry immediately. It shall fail again. let's wait until
killed process
        is exited.



> @@ -765,6 +766,6 @@ void pagefault_out_of_memory(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0out_of_memory(NULL, 0, 0, NULL, false);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clear_system_oom();
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 if (!test_thread_flag(TIF_MEMDIE))
> + =A0 =A0 =A0 if (!fatal_signal_pending(current) && !(current->flags & PF=
_EXITING))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0schedule_timeout_uninterruptible(1);

This makes sense to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
