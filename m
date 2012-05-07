Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id F20846B0044
	for <linux-mm@kvack.org>; Mon,  7 May 2012 15:34:02 -0400 (EDT)
Received: by yenm8 with SMTP id m8so6377987yen.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 12:34:02 -0700 (PDT)
Message-ID: <4FA823A7.9000801@gmail.com>
Date: Mon, 07 May 2012 15:33:59 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 5/6] mm: make vmstat_update periodic run conditional
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com> <1336056962-10465-6-git-send-email-gilad@benyossef.com> <alpine.DEB.2.00.1205071024550.1060@router.home>
In-Reply-To: <alpine.DEB.2.00.1205071024550.1060@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, kosaki.motohiro@gmail.com

>> @@ -1204,8 +1265,14 @@ static int __init setup_vmstat(void)
>>
>>   	register_cpu_notifier(&vmstat_notifier);
>>
>> +	INIT_DELAYED_WORK_DEFERRABLE(&vmstat_monitor_work,
>> +				vmstat_update_monitor);
>> +	queue_delayed_work(system_unbound_wq,
>> +				&vmstat_monitor_work,
>> +				round_jiffies_relative(HZ));
>> +
>>   	for_each_online_cpu(cpu)
>> -		start_cpu_timer(cpu);
>> +		setup_cpu_timer(cpu);
>>   #endif
>>   #ifdef CONFIG_PROC_FS
>>   	proc_create("buddyinfo", S_IRUGO, NULL,&fragmentation_file_operations);
>
> So the monitoring thread just bounces around the system? Hope that the
> scheduler does the right thing to keep it on processors that do some other
> work.

Good point. Usually, all cpus have update items and monitor worker only makes
new noise. I think this feature is only useful some hpc case.  So I wonder if
this vmstat improvemnt can integrate Frederic's Nohz cpusets activity. I.e.
vmstat-update integrate timer house keeping and automatically stop when stopping
hz house keeping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
