Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id A333D28035A
	for <linux-mm@kvack.org>; Sun, 19 Jul 2015 05:58:31 -0400 (EDT)
Received: by lbbyj8 with SMTP id yj8so80618804lbb.0
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 02:58:31 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com. [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id r6si14728057lag.118.2015.07.19.02.58.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jul 2015 02:58:29 -0700 (PDT)
Received: by lbbqi7 with SMTP id qi7so189355lbb.3
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 02:58:28 -0700 (PDT)
Date: Sun, 19 Jul 2015 11:58:18 +0200
From: Marcin =?utf-8?Q?=C5=9Alusarz?= <marcin.slusarz@gmail.com>
Subject: Re: cpu_hotplug vs oom_notify_list: possible circular locking
 dependency detected
Message-ID: <20150719095818.GA7200@marcin-Inspiron-7720>
References: <20150712105634.GA11708@marcin-Inspiron-7720>
 <alpine.DEB.2.10.1507141508590.16182@chino.kir.corp.google.com>
 <20150714232943.GW3717@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1507141647531.16182@chino.kir.corp.google.com>
 <20150715222612.GP3717@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1507161401320.14938@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1507161401320.14938@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Jul 16, 2015 at 02:01:56PM -0700, David Rientjes wrote:
> On Wed, 15 Jul 2015, Paul E. McKenney wrote:
> 
> > On Tue, Jul 14, 2015 at 04:48:24PM -0700, David Rientjes wrote:
> > > On Tue, 14 Jul 2015, Paul E. McKenney wrote:
> > > 
> > > > commit a1992f2f3b8e174d740a8f764d0d51344bed2eed
> > > > Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > > Date:   Tue Jul 14 16:24:14 2015 -0700
> > > > 
> > > >     rcu: Don't disable CPU hotplug during OOM notifiers
> > > >     
> > > >     RCU's rcu_oom_notify() disables CPU hotplug in order to stabilize the
> > > >     list of online CPUs, which it traverses.  However, this is completely
> > > >     pointless because smp_call_function_single() will quietly fail if invoked
> > > >     on an offline CPU.  Because the count of requests is incremented in the
> > > >     rcu_oom_notify_cpu() function that is remotely invoked, everything works
> > > >     nicely even in the face of concurrent CPU-hotplug operations.
> > > >     
> > > >     Furthermore, in recent kernels, invoking get_online_cpus() from an OOM
> > > >     notifier can result in deadlock.  This commit therefore removes the
> > > >     call to get_online_cpus() and put_online_cpus() from rcu_oom_notify().
> > > >     
> > > >     Reported-by: Marcin A?lusarz <marcin.slusarz@gmail.com>
> > > >     Reported-by: David Rientjes <rientjes@google.com>
> > > >     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > 
> > > Acked-by: David Rientjes <rientjes@google.com>
> > 
> > Thank you!
> > 
> > Any news on whether or not it solves the problem?
> > 
> 
> Marcin, is your lockdep violation reproducible?  If so, does this patch 
> fix it?

I finally found enough time today to test it. I can reproduce it without
the above patch and can't with. So:
Tested-by: Marcin A?lusarz <marcin.slusarz@gmail.com>

Thanks,
Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
