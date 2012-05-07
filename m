Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id CDEFC6B0044
	for <linux-mm@kvack.org>; Mon,  7 May 2012 11:29:21 -0400 (EDT)
Date: Mon, 7 May 2012 10:29:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v1 5/6] mm: make vmstat_update periodic run conditional
In-Reply-To: <1336056962-10465-6-git-send-email-gilad@benyossef.com>
Message-ID: <alpine.DEB.2.00.1205071024550.1060@router.home>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com> <1336056962-10465-6-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On Thu, 3 May 2012, Gilad Ben-Yossef wrote:

> vmstat_update runs every second from the work queue to update statistics
> and drain per cpu pages back into the global page allocator.

Looks good.

- vmstat_off_cpus is a bit strange. Could we have a cpumask that has a bit
set if vmstat is active? Rename to "vmstat_cpus"?

- Start out with vmstat_cpus cleared? Cpus only need vmstat if they do
something and if a cpu is idle on boot then it will not need vmstat
enabled until the cpu does something useful.

> @@ -1204,8 +1265,14 @@ static int __init setup_vmstat(void)
>
>  	register_cpu_notifier(&vmstat_notifier);
>
> +	INIT_DELAYED_WORK_DEFERRABLE(&vmstat_monitor_work,
> +				vmstat_update_monitor);
> +	queue_delayed_work(system_unbound_wq,
> +				&vmstat_monitor_work,
> +				round_jiffies_relative(HZ));
> +
>  	for_each_online_cpu(cpu)
> -		start_cpu_timer(cpu);
> +		setup_cpu_timer(cpu);
>  #endif
>  #ifdef CONFIG_PROC_FS
>  	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);

So the monitoring thread just bounces around the system? Hope that the
scheduler does the right thing to keep it on processors that do some other
work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
