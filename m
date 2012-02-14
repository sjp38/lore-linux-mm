Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id D54996B13F2
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:21:54 -0500 (EST)
Received: by mail-vw0-f41.google.com with SMTP id p1so5286971vbi.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 23:21:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120214120756.0a42f065.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com> <20120214120756.0a42f065.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 13 Feb 2012 23:21:34 -0800
Message-ID: <CAHH2K0Ynh6o5fMXnkbaYOSwYYvJhc7F3f48TsJ34hki6WDJF6Q@mail.gmail.com>
Subject: Re: [PATCH 2/6 v4] memcg: simplify move_account() check
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

On Mon, Feb 13, 2012 at 7:07 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From 9cdb3b63dc8d08cc2220c54c80438c13433a0d12 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 2 Feb 2012 10:02:39 +0900
> Subject: [PATCH 2/6] memcg: simplify move_account() check.
>
> In memcg, for avoiding take-lock-irq-off at accessing page_cgroup,
> a logic, flag + rcu_read_lock(), is used. This works as following
>
> =A0 =A0 CPU-A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CPU-B
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock()
> =A0 =A0set flag
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(flag is set)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 take =
heavy lock
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do job.
> =A0 =A0synchronize_rcu() =A0 =A0 =A0 =A0rcu_read_unlock()

I assume that CPU-A will take heavy lock after synchronize_rcu() when
updating variables read by CPU-B.

> =A0memcontrol.c | =A0 65 ++++++++++++++++++++++--------------------------=
-----------
> =A01 file changed, 25 insertions(+), 40 deletions(-)
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Greg Thelen <gthelen@google.com>

> ---
> =A0mm/memcontrol.c | =A0 70 +++++++++++++++++++++++----------------------=
---------
> =A01 files changed, 30 insertions(+), 40 deletions(-)

> @@ -2089,11 +2082,8 @@ static int __cpuinit memcg_cpu_hotplug_callback(st=
ruct notifier_block *nb,
> =A0 =A0 =A0 =A0struct memcg_stock_pcp *stock;
> =A0 =A0 =A0 =A0struct mem_cgroup *iter;
>
> - =A0 =A0 =A0 if ((action =3D=3D CPU_ONLINE)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_mem_cgroup(iter)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 synchronize_mem_cgroup_on_m=
ove(iter, cpu);
> + =A0 =A0 =A0 if ((action =3D=3D CPU_ONLINE))

Extra parenthesis.  I recommend:
+ =A0 =A0 =A0 if (action =3D=3D CPU_ONLINE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
