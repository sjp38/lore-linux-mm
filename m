Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21EC36B000D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 14:49:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z9-v6so3557715pfe.23
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:49:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j131-v6sor1806288pgc.116.2018.06.22.11.49.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 11:49:16 -0700 (PDT)
Date: Fri, 22 Jun 2018 11:49:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <20180622142917.GB10465@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1806221147090.110785@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com> <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com> <20180615065541.GA24039@dhcp22.suse.cz> <alpine.DEB.2.21.1806151559360.49038@chino.kir.corp.google.com>
 <20180619083316.GB13685@dhcp22.suse.cz> <20180620130311.GM13685@dhcp22.suse.cz> <alpine.DEB.2.21.1806201325330.158126@chino.kir.corp.google.com> <20180621074537.GC10465@dhcp22.suse.cz> <alpine.DEB.2.21.1806211347050.213939@chino.kir.corp.google.com>
 <20180622074257.GQ10465@dhcp22.suse.cz> <20180622142917.GB10465@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 22 Jun 2018, Michal Hocko wrote:

> > > preempt_disable() is required because it calls kvm_kick_many_cpus() with 
> > > wait == true because KVM_REQ_APIC_PAGE_RELOAD sets KVM_REQUEST_WAIT and 
> > > thus the smp_call_function_many() is going to block until all cpus can run 
> > > ack_flush().
> > 
> > I will make sure to talk to the maintainer of the respective code to
> > do the nonblock case correctly.
> 
> I've just double checked this particular code and the wait path and this
> one is not a sleep. It is a busy wait for IPI to get handled. So this
> one should be OK AFAICS. Anyway I will send an RFC and involve
> respective maintainers to make sure I am not making any incorrect
> assumptions.

Do you believe that having the only potential source of memory freeing 
busy waiting for all other cpus on the system to run ack_flush() is 
particularly dangerous given the fact that they may be allocating 
themselves?
