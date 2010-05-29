Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A24BC6B01B4
	for <linux-mm@kvack.org>; Fri, 28 May 2010 23:59:14 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4T3xBRf002910
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 29 May 2010 12:59:11 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2139645DE55
	for <linux-mm@kvack.org>; Sat, 29 May 2010 12:59:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 006BA45DE4E
	for <linux-mm@kvack.org>; Sat, 29 May 2010 12:59:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E02BD1DB803E
	for <linux-mm@kvack.org>; Sat, 29 May 2010 12:59:10 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 99B8F1DB8038
	for <linux-mm@kvack.org>; Sat, 29 May 2010 12:59:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <20100528164826.GJ11364@uudg.org>
References: <20100528154549.GC12035@barrios-desktop> <20100528164826.GJ11364@uudg.org>
Message-Id: <20100529125136.62CA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Sat, 29 May 2010 12:59:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

Hi

> oom-killer: give the dying task rt priority (v3)
>=20
> Give the dying task RT priority so that it can be scheduled quickly and d=
ie,
> freeing needed memory.
>=20
> Signed-off-by: Luis Claudio R. Gon=E7alves <lgoncalv@redhat.com>

Almostly acceptable to me. but I have two requests,=20

- need 1) force_sig() 2)sched_setscheduler() order as Oleg mentioned
- don't boost priority if it's in mem_cgroup_out_of_memory()

Can you accept this? if not, can you please explain the reason?

Thanks.

>=20
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 84bbba2..2b0204f 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -266,6 +266,8 @@ static struct task_struct *select_bad_process(unsigne=
d long *ppoints)
>   */
>  static void __oom_kill_task(struct task_struct *p, int verbose)
>  {
> +	struct sched_param param;
> +
>  	if (is_global_init(p)) {
>  		WARN_ON(1);
>  		printk(KERN_WARNING "tried to kill init!\n");
> @@ -288,6 +290,8 @@ static void __oom_kill_task(struct task_struct *p, in=
t verbose)
>  	 * exit() and clear out its resources quickly...
>  	 */
>  	p->time_slice =3D HZ;
> +	param.sched_priority =3D MAX_RT_PRIO-10;
> +	sched_setscheduler(p, SCHED_FIFO, &param);
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
> =20
>  	force_sig(SIGKILL, p);
> --=20
> [ Luis Claudio R. Goncalves                    Bass - Gospel - RT ]
> [ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]
>=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
