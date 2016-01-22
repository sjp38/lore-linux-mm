Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id A57AE6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 06:00:23 -0500 (EST)
Received: by mail-io0-f176.google.com with SMTP id q21so84573700iod.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 03:00:23 -0800 (PST)
Received: from mail-ig0-x241.google.com (mail-ig0-x241.google.com. [2607:f8b0:4001:c05::241])
        by mx.google.com with ESMTPS id b66si11571181ioe.8.2016.01.22.03.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 03:00:22 -0800 (PST)
Received: by mail-ig0-x241.google.com with SMTP id h5so6822559igh.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 03:00:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601211130580.7741@east.gentwo.org>
References: <20160120143719.GF14187@dhcp22.suse.cz>
	<569FA01A.4070200@oracle.com>
	<20160120151007.GG14187@dhcp22.suse.cz>
	<alpine.DEB.2.20.1601200919520.21490@east.gentwo.org>
	<569FAC90.5030407@oracle.com>
	<alpine.DEB.2.20.1601200954420.23983@east.gentwo.org>
	<20160120212806.GA26965@dhcp22.suse.cz>
	<alpine.DEB.2.20.1601201552590.26496@east.gentwo.org>
	<20160121082402.GA29520@dhcp22.suse.cz>
	<alpine.DEB.2.20.1601210941540.7063@east.gentwo.org>
	<20160121165148.GF29520@dhcp22.suse.cz>
	<alpine.DEB.2.20.1601211130580.7741@east.gentwo.org>
Date: Fri, 22 Jan 2016 16:30:22 +0530
Message-ID: <CAPub149DrtF8tVPauiZttAa9FBVqjJvsi=JXx=UosUtsWcyNDg@mail.gmail.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
From: Shiraz Hashim <shiraz.linux.kernel@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jan 21, 2016 at 11:08 PM, Christoph Lameter <cl@linux.com> wrote:
> Subject: vmstat: Queue work before clearing cpu_stat_off
>
> There is a race between vmstat_shepherd and quiet_vmstat() because
> the responsibility for checking for counter updates changes depending
> on the state of teh bit in cpu_stat_off. So queue the work before
> changing state of the bit in vmstat_shepherd. That way quiet_vmstat
> is guaranteed to remove the work request when clearing the bit and the
> bug in vmstat_update wont trigger anymore.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Index: linux/mm/vmstat.c
> ===================================================================
> --- linux.orig/mm/vmstat.c
> +++ linux/mm/vmstat.c
> @@ -1480,12 +1480,14 @@ static void vmstat_shepherd(struct work_
>         get_online_cpus();
>         /* Check processors whose vmstat worker threads have been disabled */
>         for_each_cpu(cpu, cpu_stat_off)
> -               if (need_update(cpu) &&
> -                       cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
> +               if (need_update(cpu)) {
>
>                         queue_delayed_work_on(cpu, vmstat_wq,
>                                 &per_cpu(vmstat_work, cpu), 0);
>
> +                       cpumask_clear_cpu(smp_processor_id(), cpu_stat_off);
> +               }
> +
>         put_online_cpus();
>
>         schedule_delayed_work(&shepherd,


This can alternatively lead to following where vmstat may not be
scheduled for cpu  when it is back from idle.

CPU0:                                            CPU1:
                                                       vmstat_shepherd
<enter idle>                                    queue_delayed_work_on(CPU0)
quiet_vmstat
  cancel_delayed_work
  cpumask_test_and_set_cpu (0->1)

cpumask_clear_cpu(CPU0) (1->0)

-- 
regards
Shiraz Hashim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
