Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id E6BD46B0005
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 06:36:47 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id z14so148593593igp.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 03:36:47 -0800 (PST)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id l6si41017397igx.13.2016.01.13.03.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 03:36:47 -0800 (PST)
Received: by mail-ig0-x22c.google.com with SMTP id mw1so148078329igb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 03:36:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601120603250.4490@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com>
	<alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
	<CAPub148SiOaVQbnA0AHRRDme7nyfeDKjYHEom5kLstqaE8ibZA@mail.gmail.com>
	<alpine.DEB.2.20.1601120603250.4490@east.gentwo.org>
Date: Wed, 13 Jan 2016 17:06:47 +0530
Message-ID: <CAPub14_fh0vZDZ+dHP1Jihi1_x0k54p_rO4NL2TqXGXGia9qYA@mail.gmail.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
From: Shiraz Hashim <shiraz.linux.kernel@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Sasha,

On Tue, Jan 12, 2016 at 5:53 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 12 Jan 2016, Shiraz Hashim wrote:
>
>> > +       refresh_cpu_vm_stats(false);
>> > +       cancel_delayed_work(this_cpu_ptr(&vmstat_work));
>> >
>>
>> shouldn't this be cancel_delayed_work_sync ?
>
> Hmmm... This is executed with preemption off and the work is on the same
> cpu. If it would be able to run concurrently then we would need this.
>
> Ok but it could run from the timer interrupt if that is still on and
> occuring shortly before we go idle. Guess this needs to be similar to
> the code we execute on cpu down in the vmstat notifiers (see
> vmstat_cpuup_callback).
>
> Does this fix it? I have not been able to reproduce the issue so far.
>
> Patch against -next.
>
>
>
> Subject: vmstat: Use delayed work_sync and avoid loop.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
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
> +       cancel_delayed_work_sync(this_cpu_ptr(&vmstat_work));
> +       cpumask_set_cpu(smp_processor_id(), cpu_stat_off);
>  }
>
>  /*

Can you please give it a try, seems it is reproducing easily at your end.

-- 
regards
Shiraz Hashim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
