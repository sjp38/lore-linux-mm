Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 3B3B36B00FF
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 08:44:48 -0400 (EDT)
Message-ID: <1332593021.16159.27.camel@twins>
Subject: Re: [PATCH 01/10] cpu: Introduce clear_tasks_mm_cpumask() helper
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Sat, 24 Mar 2012 13:43:41 +0100
In-Reply-To: <20120324102751.GA29067@lizard>
References: <20120324102609.GA28356@lizard> <20120324102751.GA29067@lizard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

On Sat, 2012-03-24 at 14:27 +0400, Anton Vorontsov wrote:
> +void clear_tasks_mm_cpumask(int cpu)
> +{
> +       struct task_struct *p;
> +
> +       read_lock(&tasklist_lock);
> +       for_each_process(p) {
> +               struct task_struct *t;
> +
> +               t =3D find_lock_task_mm(p);
> +               if (!t)
> +                       continue;
> +               cpumask_clear_cpu(cpu, mm_cpumask(t->mm));
> +               task_unlock(t);
> +       }
> +       read_unlock(&tasklist_lock);
> +}=20

Why bother with the tasklist_lock at all anymore, afaict you could use
rcu_read_lock() here. This all is called after the cpu is taken down and
marked offline, so its not like new tasks will ever get this cpu set in
their mm mask.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
