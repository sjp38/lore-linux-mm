Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6715B6B000A
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 05:04:38 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v19-v6so2141135eds.3
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 02:04:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q40-v6si6451917edd.134.2018.06.25.02.04.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jun 2018 02:04:36 -0700 (PDT)
Date: Mon, 25 Jun 2018 11:04:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional processes
Message-ID: <20180625090434.GE28965@dhcp22.suse.cz>
References: <20180615065541.GA24039@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806151559360.49038@chino.kir.corp.google.com>
 <20180619083316.GB13685@dhcp22.suse.cz>
 <20180620130311.GM13685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806201325330.158126@chino.kir.corp.google.com>
 <20180621074537.GC10465@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806211347050.213939@chino.kir.corp.google.com>
 <20180622074257.GQ10465@dhcp22.suse.cz>
 <20180622142917.GB10465@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806221147090.110785@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1806221147090.110785@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 22-06-18 11:49:14, David Rientjes wrote:
> On Fri, 22 Jun 2018, Michal Hocko wrote:
> 
> > > > preempt_disable() is required because it calls kvm_kick_many_cpus() with 
> > > > wait == true because KVM_REQ_APIC_PAGE_RELOAD sets KVM_REQUEST_WAIT and 
> > > > thus the smp_call_function_many() is going to block until all cpus can run 
> > > > ack_flush().
> > > 
> > > I will make sure to talk to the maintainer of the respective code to
> > > do the nonblock case correctly.
> > 
> > I've just double checked this particular code and the wait path and this
> > one is not a sleep. It is a busy wait for IPI to get handled. So this
> > one should be OK AFAICS. Anyway I will send an RFC and involve
> > respective maintainers to make sure I am not making any incorrect
> > assumptions.
> 
> Do you believe that having the only potential source of memory freeing 
> busy waiting for all other cpus on the system to run ack_flush() is 
> particularly dangerous given the fact that they may be allocating 
> themselves?

These are IPIs. How could they depend on a memory allocation? In other
words we do rely on the very same mechanism for TLB flushing so this is
any different.

Maybe I am missing something here though.

-- 
Michal Hocko
SUSE Labs
