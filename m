Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 895386B00A5
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:17:57 -0400 (EDT)
Received: by iwn1 with SMTP id 1so1974436iwn.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 18:17:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1287448784-25684-5-git-send-email-gthelen@google.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-5-git-send-email-gthelen@google.com>
Date: Tue, 19 Oct 2010 10:17:55 +0900
Message-ID: <AANLkTikoV=ximPhT+XsKQahNYQBOpW5Tji5bme6pqZST@mail.gmail.com>
Subject: Re: [PATCH v3 04/11] memcg: add lock to synchronize page accounting
 and migration
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 9:39 AM, Greg Thelen <gthelen@google.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Introduce a new bit spin lock, PCG_MOVE_LOCK, to synchronize
> the page accounting and migration code. =A0This reworks the
> locking scheme of _update_stat() and _move_account() by
> adding new lock bit PCG_MOVE_LOCK, which is always taken
> under IRQ disable.
>
> 1. If pages are being migrated from a memcg, then updates to
> =A0 that memcg page statistics are protected by grabbing
> =A0 PCG_MOVE_LOCK using move_lock_page_cgroup(). =A0In an
> =A0 upcoming commit, memcg dirty page accounting will be
> =A0 updating memcg page accounting (specifically: num
> =A0 writeback pages) from IRQ context (softirq). =A0Avoid a
> =A0 deadlocking nested spin lock attempt by disabling irq on
> =A0 the local processor when grabbing the PCG_MOVE_LOCK.
>
> 2. lock for update_page_stat is used only for avoiding race
> =A0 with move_account(). =A0So, IRQ awareness of
> =A0 lock_page_cgroup() itself is not a problem. =A0The problem
> =A0 is between mem_cgroup_update_page_stat() and
> =A0 mem_cgroup_move_account_page().
>
> Trade-off:
> =A0* Changing lock_page_cgroup() to always disable IRQ (or
> =A0 =A0local_bh) has some impacts on performance and I think
> =A0 =A0it's bad to disable IRQ when it's not necessary.
> =A0* adding a new lock makes move_account() slower. =A0Score is
> =A0 =A0here.
>
> Performance Impact: moving a 8G anon process.
>
> Before:
> =A0 =A0 =A0 =A0real =A0 =A00m0.792s
> =A0 =A0 =A0 =A0user =A0 =A00m0.000s
> =A0 =A0 =A0 =A0sys =A0 =A0 0m0.780s
>
> After:
> =A0 =A0 =A0 =A0real =A0 =A00m0.854s
> =A0 =A0 =A0 =A0user =A0 =A00m0.000s
> =A0 =A0 =A0 =A0sys =A0 =A0 0m0.842s
>
> This score is bad but planned patches for optimization can reduce
> this impact.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
