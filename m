Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 3861E6B0275
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 19:03:16 -0400 (EDT)
Received: by ggm4 with SMTP id 4so2464924ggm.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 16:03:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206221443210.23486@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206221443210.23486@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 22 Jun 2012 19:02:55 -0400
Message-ID: <CAHGf_=qyj25z2fair3J+BSTeFQpFVSv9DGoXQUpZHxRZp-ySgA@mail.gmail.com>
Subject: Re: [patch 3.5-rc3] mm, oom: fix potential killing of thread that is
 disabled from oom killing
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 22, 2012 at 5:44 PM, David Rientjes <rientjes@google.com> wrote=
:
> /proc/sys/vm/oom_kill_allocating_task will immediately kill current when
> the oom killer is called to avoid a potentially expensive tasklist scan
> for large systems.
>
> Currently, however, it is not checking current's oom_score_adj value
> which may be OOM_SCORE_ADJ_MIN, meaning that it has been disabled from
> oom killing.
>
> This patch avoids killing current in such a condition and simply falls
> back to the tasklist scan since memory still needs to be freed.
>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
> =A0mm/oom_kill.c | =A0 =A04 ++--
> =A01 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -720,9 +720,9 @@ void out_of_memory(struct zonelist *zonelist, gfp_t g=
fp_mask,
> =A0 =A0 =A0 =A0check_panic_on_oom(constraint, gfp_mask, order, mpol_mask)=
;
>
> =A0 =A0 =A0 =A0read_lock(&tasklist_lock);
> - =A0 =A0 =A0 if (sysctl_oom_kill_allocating_task &&
> + =A0 =A0 =A0 if (sysctl_oom_kill_allocating_task && current->mm &&
> =A0 =A0 =A0 =A0 =A0 =A0!oom_unkillable_task(current, NULL, nodemask) &&
> - =A0 =A0 =A0 =A0 =A0 current->mm) {
> + =A0 =A0 =A0 =A0 =A0 current->signal->oom_score_adj !=3D OOM_SCORE_ADJ_M=
IN) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0oom_kill_process(current, gfp_mask, order,=
 0, totalpages, NULL,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nodemask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Out of m=
emory (oom_kill_allocating_task)");

Seems straight forward and reasonable.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
