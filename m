Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6FA6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 23:10:24 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so671470pdj.26
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 20:10:24 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id c4si408849pdk.312.2014.07.29.20.10.22
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 20:10:23 -0700 (PDT)
Message-ID: <53D8626E.5060900@cn.fujitsu.com>
Date: Wed, 30 Jul 2014 11:11:42 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: vmstat: On demand vmstat workers V8
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <53D31101.8000107@oracle.com> <alpine.DEB.2.11.1407281353450.15405@gentwo.org> <20140729075637.GA19379@twins.programming.kicks-ass.net> <20140729120525.GA28366@mtj.dyndns.org> <20140729122303.GA3935@laptop> <20140729131226.GS7462@htj.dyndns.org> <alpine.DEB.2.11.1407291009320.21102@gentwo.org> <20140729151415.GF4791@htj.dyndns.org> <alpine.DEB.2.11.1407291038160.21390@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1407291038160.21390@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org

On 07/29/2014 11:39 PM, Christoph Lameter wrote:
> On Tue, 29 Jul 2014, Tejun Heo wrote:
> 
>> Hmmm, well, then it's something else.  Either a bug in workqueue or in
>> the caller.  Given the track record, the latter is more likely.
>> e.g. it looks kinda suspicious that the work func is cleared after
>> cancel_delayed_work_sync() is called.  What happens if somebody tries
>> to schedule it inbetween?
> 
> Here is yet another patch to also address this idea:
> 
> Subject: vmstat: Clear the work.func before cancelling delayed work
> 
> Looks strange to me but Tejun thinks this could do some good.
> If this really is the right thing to do then cancel_delayed_work should
> zap the work func itselt I think.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> 
> Index: linux/mm/vmstat.c
> ===================================================================
> --- linux.orig/mm/vmstat.c	2014-07-29 10:22:45.073884943 -0500
> +++ linux/mm/vmstat.c	2014-07-29 10:34:45.083369228 -0500
> @@ -1277,8 +1277,8 @@ static int vmstat_cpuup_callback(struct
>  		break;
>  	case CPU_DOWN_PREPARE:
>  	case CPU_DOWN_PREPARE_FROZEN:
> -		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
>  		per_cpu(vmstat_work, cpu).work.func = NULL;
> +		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));

I think we should just remove "per_cpu(vmstat_work, cpu).work.func = NULL;"

>  		break;
>  	case CPU_DOWN_FAILED:
>  	case CPU_DOWN_FAILED_FROZEN:
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
