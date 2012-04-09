Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id AE3716B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 17:05:18 -0400 (EDT)
Received: by yenm8 with SMTP id m8so2665770yen.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 14:05:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120409200336.8368.63793.stgit@zurg>
References: <20120409200336.8368.63793.stgit@zurg>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 9 Apr 2012 17:04:56 -0400
Message-ID: <CAHGf_=oWj-hz-E5ht8-hUbQKdsZ1bzP80n987kGYnFm8BpXBVQ@mail.gmail.com>
Subject: Re: [PATCH] mm: sync rss-counters at the end of exit_mm()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Markus Trippelsdorf <markus@trippelsdorf.de>

On Mon, Apr 9, 2012 at 4:03 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> On task's exit do_exit() calls sync_mm_rss() but this is not enough,
> there can be page-faults after this point, for example exit_mm() ->
> mm_release() -> put_user() (for processing tsk->clear_child_tid).
> Thus there may be some rss-counters delta in current->rss_stat.

Seems reasonable. but I have another question. Do we have any reason to
keep sync_mm_rss() in do_exit()? I havn't seen any reason that thread exiti=
ng
makes rss consistency.


>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0kernel/exit.c | =A0 =A01 +
> =A01 file changed, 1 insertion(+)
>
> diff --git a/kernel/exit.c b/kernel/exit.c
> index d8bd3b42..8e09dbe 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -683,6 +683,7 @@ static void exit_mm(struct task_struct * tsk)
> =A0 =A0 =A0 =A0enter_lazy_tlb(mm, current);
> =A0 =A0 =A0 =A0task_unlock(tsk);
> =A0 =A0 =A0 =A0mm_update_next_owner(mm);
> + =A0 =A0 =A0 sync_mm_rss(mm);
> =A0 =A0 =A0 =A0mmput(mm);
> =A0}
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
