Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 0ECFC6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 12:30:34 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id l18so987446qak.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 09:30:34 -0700 (PDT)
Date: Fri, 9 Aug 2013 12:30:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 1/2] workqueue: add new schedule_on_cpu_mask() API
Message-ID: <20130809163029.GT20515@mtj.dyndns.org>
References: <5202CEAA.9040204@linux.vnet.ibm.com>
 <201308072335.r77NZJPA022490@farm-0012.internal.tilera.com>
 <20130809150257.GM20515@mtj.dyndns.org>
 <520514FB.8060502@tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520514FB.8060502@tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Hello, Chris.

On Fri, Aug 09, 2013 at 12:12:43PM -0400, Chris Metcalf wrote:
> I could certainly make schedule_on_cpu_mask() do sanity checking,
> perhaps via a WARN_ON_ONCE() if offline cpus were specified, and
> otherwise just have it create a local struct cpumask that it and's
> with cpu_online_mask, suitably wrapping with
> get_online_cpus()/put_online_cpus().  (I'm not sure how to test if a
> cpu has ever been online, vs whether it's online right now.)  I

I think you'll have to collect it from CPU_ONLINE of
workqueue_cpu_up_callback() and I think it probably wouldn't be a bad
idea to allow scheduling on CPUs which have been up but aren't
currently as that's the current rule for other interfaces anyway.

> don't want to unnecessarily slow down the existing
> schedule_on_each_cpu(), so perhaps the implementation should have a
> static schedule_on_cpu_mask_internal() function that is the same as
> my previous schedule_on_cpu_mask(), allowing schedule_on_each_cpu()
> to call it directly to bypass the checking.

Hmmm.... it's unlikely to make noticeable difference given that it's
gonna be bouncing multiple cachelines across all online CPUs.

> That said... I wonder if it might make sense to treat this API the
> same as other APIs that already take a cpu?  schedule_work_on(),
> schedule_delayed_work_on(), and queue_delayed_work_on() all take a
> cpu parameter without API comment or validity checking;
> queue_work_on() just says "the caller must ensure [the cpu] can't go
> away".  Does it make sense to just add a similar comment to
> schedule_on_cpu_mask() rather than make this API the first to
> actually do cpu validity checking?

Yeah, we've been lazy with the sanity check and I think it's a good
opportunity to add it.  Let's worry about other paths later.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
