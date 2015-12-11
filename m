Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 126DA6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 20:41:11 -0500 (EST)
Received: by ioir85 with SMTP id r85so112398097ioi.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 17:41:10 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id u4si1742197igr.88.2015.12.10.17.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 10 Dec 2015 17:41:09 -0800 (PST)
Date: Thu, 10 Dec 2015 19:41:08 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat: make vmstat_updater deferrable again and shut down on
 idle
In-Reply-To: <20151210153118.4f39d6a4f04c96189ce015c9@linux-foundation.org>
Message-ID: <alpine.DEB.2.20.1512101940230.21007@east.gentwo.org>
References: <alpine.DEB.2.20.1512101441140.19122@east.gentwo.org> <20151210153118.4f39d6a4f04c96189ce015c9@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp

On Thu, 10 Dec 2015, Andrew Morton wrote:

> >  /*
> > + * Switch off vmstat processing and then fold all the remaining differentials
> > + * until the diffs stay at zero. The function is used by NOHZ and can only be
> > + * invoked when tick processing is not active.
> > + */
> > +void quiet_vmstat(void)
> > +{
> > +	do {
> > +		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
> > +			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
> > +
> > +	} while (refresh_cpu_vm_stats(false));
> > +}
>
> How do we know this will terminate in a reasonable amount of time if
> other CPUs are pounding away?

This is only dealing with the differentials of the local cpu. Other cpus
do not matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
