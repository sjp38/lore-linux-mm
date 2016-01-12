Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE234403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 06:31:35 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id h5so88701563igh.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 03:31:35 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id e1si32698063igl.65.2016.01.12.03.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 03:31:33 -0800 (PST)
Received: by mail-ig0-x235.google.com with SMTP id z14so141131404igp.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 03:31:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com>
	<alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
Date: Tue, 12 Jan 2016 17:01:33 +0530
Message-ID: <CAPub148SiOaVQbnA0AHRRDme7nyfeDKjYHEom5kLstqaE8ibZA@mail.gmail.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
From: Shiraz Hashim <shiraz.linux.kernel@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Dec 21, 2015 at 6:38 PM, Christoph Lameter <cl@linux.com> wrote:
> Index: linux/mm/vmstat.c
> ===================================================================
> --- linux.orig/mm/vmstat.c
> +++ linux/mm/vmstat.c
> @@ -1419,11 +1419,9 @@ void quiet_vmstat(void)
>         if (system_state != SYSTEM_RUNNING)
>                 return;
>
> -       do {
> -               if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
> -                       cancel_delayed_work(this_cpu_ptr(&vmstat_work));
> -
> -       } while (refresh_cpu_vm_stats(false));
> +       refresh_cpu_vm_stats(false);
> +       cancel_delayed_work(this_cpu_ptr(&vmstat_work));
>

shouldn't this be cancel_delayed_work_sync ?

> +       cpumask_set_cpu(smp_processor_id(), cpu_stat_off);
>

else ongoing vmstat_update can again encounter cpu_stat_off set ?

>  }
>

-- 
regards
Shiraz Hashim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
