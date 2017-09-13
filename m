Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D64206B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 08:10:07 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 97so32891wrb.1
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 05:10:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a141si1011169wme.119.2017.09.13.05.10.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 05:10:05 -0700 (PDT)
Date: Wed, 13 Sep 2017 14:10:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
Message-ID: <20170913121001.k3a5tkvunmncc5uj@dhcp22.suse.cz>
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-2-mhocko@kernel.org>
 <eb5bf356-f498-b430-1ae8-4ff1ad15ad7f@suse.cz>
 <20170911081714.4zc33r7wlj2nnbho@dhcp22.suse.cz>
 <9fad7246-c634-18bb-78f9-b95376c009da@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9fad7246-c634-18bb-78f9-b95376c009da@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 13-09-17 13:41:20, Vlastimil Babka wrote:
> On 09/11/2017 10:17 AM, Michal Hocko wrote:
[...]
> > Yes, we should be able to distinguish the two and hopefully we can teach
> > the migration code to distinguish between EBUSY (likely permanent) and
> > EGAIN (temporal) failure. This sound like something we should aim for
> > longterm I guess. Anyway as I've said in other email. If somebody really
> > wants to have a guaratee of a bounded retry then it is trivial to set up
> > an alarm and send a signal itself to bail out.
> 
> Sure, I would just be careful about not breaking existing userspace
> (udev?) when offline triggered via ACPI from some management interface
> (or whatever the exact mechanism is).

The thing is that there is absolutely no timing guarantee even with
retry limit in place. We are doing allocations, potentially bouncing on
locks which can be taken elsewhere etc... So if somebody really depend
on this then it is pretty much broken already.

> > Do you think that the changelog should be more clear about this?
> 
> It certainly wouldn't hurt :)

So what do you think about the following wording:

commit 23c4ded55c2ba880165a9f5b8a67694361fb6bc7
Author: Michal Hocko <mhocko@suse.com>
Date:   Mon Aug 28 13:13:06 2017 +0200

    mm, memory_hotplug: remove timeout from __offline_memory
    
    We have a hardcoded 120s timeout after which the memory offline fails
    basically since the hot remove has been introduced. This is essentially
    a policy implemented in the kernel. Moreover there is no way to adjust
    the timeout and so we are sometimes facing memory offline failures if
    the system is under a heavy memory pressure or very intensive CPU
    workload on large machines.
    
    It is not very clear what purpose the timeout actually serves. The
    offline operation is interruptible by a signal so if userspace wants
    some timeout based termination this can be done trivially by sending a
    signal.
    
    If there is a strong usecase to do this from the kernel then we should
    do it properly and have a it tunable from the userspace with the timeout
    disabled by default along with the explanation who uses it and for what
    purporse.
    
    Acked-by: Vlastimil Babka <vbabka@suse.cz>
    Signed-off-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
