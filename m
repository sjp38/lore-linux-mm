Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id BCD306B0009
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 05:07:18 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id c200so261315212wme.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 02:07:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id go14si2677675wjc.241.2016.02.24.02.07.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 02:07:17 -0800 (PST)
Date: Wed, 24 Feb 2016 11:07:16 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] vmstat: Get rid of the ugly cpu_stat_off variable
Message-ID: <20160224100715.GC20863@dhcp22.suse.cz>
References: <20160222181040.553533936@linux.com>
 <20160222181049.953663183@linux.com>
 <20160223162345.51f8494cb1484ad5cb7f8eab@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223162345.51f8494cb1484ad5cb7f8eab@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hannes@cmpxchg.org, mgorman@suse.de

On Tue 23-02-16 16:23:45, Andrew Morton wrote:
> On Mon, 22 Feb 2016 12:10:42 -0600 Christoph Lameter <cl@linux.com> wrote:
> 
> > The cpu_stat_off variable is unecessary since we can check if
> > a workqueue request is pending otherwise. This makes it pretty
> > easy for the shepherd to ensure that the proper things happen.
> > 
> > Removing the state also removes all races related to it.
> > Should a workqueue not be scheduled as needed for vmstat_update
> > then the shepherd will notice and schedule it as needed.
> > Should a workqueue be unecessarily scheduled then the vmstat
> > updater will disable it.
> > 
> > Thus vmstat_idle can also be simplified.
> 
> I'm getting rather a lot of rejects from this one.
> 
> >  
> > @@ -1436,11 +1426,8 @@ void quiet_vmstat(void)
> >  	if (system_state != SYSTEM_RUNNING)
> >  		return;
> >  
> > -	do {
> > -		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
> > -			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
> > -
> > -	} while (refresh_cpu_vm_stats(false));
> > +	refresh_cpu_vm_stats(false);
> > +	cancel_delayed_work(this_cpu_ptr(&vmstat_work));
> >  }
> 
> I can't find a quiet_vmstat() which looks like this.  What tree are you
> patching?

This seems to be pre f01f17d3705b ("mm, vmstat: make quiet_vmstat
lighter")

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
