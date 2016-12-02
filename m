Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC0C6B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 04:37:39 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xr1so43798610wjb.7
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 01:37:39 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id bt18si4380652wjb.137.2016.12.02.01.37.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 01:37:37 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id kp2so29479696wjc.0
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 01:37:37 -0800 (PST)
Date: Fri, 2 Dec 2016 10:37:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Message-ID: <20161202093734.GE6830@dhcp22.suse.cz>
References: <20161128105425.GY31360@linux.vnet.ibm.com>
 <3a4242cb-0198-0a3b-97ae-536fb5ff83ec@kernelpanic.ru>
 <20161128143435.GC3924@linux.vnet.ibm.com>
 <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
 <20161128150509.GG3924@linux.vnet.ibm.com>
 <66fd50e1-a922-846a-f427-7654795bd4b5@kernelpanic.ru>
 <20161130174802.GM18432@dhcp22.suse.cz>
 <fd34243c-2ebf-c14b-55e6-684a9dc614e7@kernelpanic.ru>
 <20161130182552.GN18432@dhcp22.suse.cz>
 <e50dcb85-4552-9249-c53e-017fefcaf80b@kernelpanic.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e50dcb85-4552-9249-c53e-017fefcaf80b@kernelpanic.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Zhmurov <bb@kernelpanic.ru>
Cc: paulmck@linux.vnet.ibm.com, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 01-12-16 21:10:01, Boris Zhmurov wrote:
> Michal Hocko 30/11/16 21:25:
> 
> >>> Do I get it right that s@cond_resched_rcu_qs@cond_resched@ didn't help?
> >>
> >> I didn't try that. I've tried 4 patches from Paul's linux-rcu tree.
> >> I can try another portion of patches, no problem :)
> > 
> > Replacing cond_resched_rcu_qs in shrink_node_memcg by cond_resched would
> > be really helpful to tell whether we are missing a real scheduling point
> > or whether something more serious is going on here.
> 
> Well, I can confirm, that replacing cond_resched_rcu_qs in
> shrink_node_memcg by cond_resched also makes dmesg clean from RCU CPU
> stall warnings.
> 
> I've attached patch (just modification of Paul's patch), that fixes RCU
> stall messages in situations, when all memory is used by
> couchbase/memcached + fs cache and linux starts to use swap.

OK, thanks for the confirmation! I will send a patch because it is true
that we do not have any scheduling point if no pages can be isolated
fromm the LRU. This might be what you are seeing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
