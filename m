Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A95396B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 10:08:13 -0500 (EST)
Message-ID: <1326380884.2442.187.camel@twins>
Subject: Re: [PATCH 2/2] mm: page allocator: Do not drain per-cpu lists via
 IPI from page allocator context
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 12 Jan 2012 16:08:04 +0100
In-Reply-To: <CAOtvUMfmSrotCGn-51SC3eiQU=xK4C_Trh+8FEfTGOJcGUgVag@mail.gmail.com>
References: <1326276668-19932-1-git-send-email-mgorman@suse.de>
	 <1326276668-19932-3-git-send-email-mgorman@suse.de>
	 <CAOtvUMfmSrotCGn-51SC3eiQU=xK4C_Trh+8FEfTGOJcGUgVag@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Miklos Szeredi <mszeredi@novell.com>, "Eric
 W. Biederman" <ebiederm@xmission.com>, Greg KH <gregkh@suse.de>, Gong Chen <gong.chen@intel.com>

On Thu, 2012-01-12 at 16:51 +0200, Gilad Ben-Yossef wrote:
> What I can't figure out is why we don't need  get/put_online_cpus()
> pair around each and every call
> to on_each_cpu everywhere? and if we do, perhaps making it a part of
> on_each_cpu is the way to go?
>=20
> Something like:
>=20
> diff --git a/kernel/smp.c b/kernel/smp.c
> index f66a1b2..cfa3882 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -691,11 +691,15 @@ void on_each_cpu(void (*func) (void *info), void
> *info, int wait)
>  {
>         unsigned long flags;
>=20
> +       BUG_ON(in_atomic());
> +
> +       get_online_cpus();
>         preempt_disable();

Your preempt_disable() here serializes against hotplug..

>         smp_call_function(func, info, wait);
>         local_irq_save(flags);
>         func(info);
>         local_irq_restore(flags);
>         preempt_enable();
> +       put_online_cpus();
>  }
>  EXPORT_SYMBOL(on_each_cpu);=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
