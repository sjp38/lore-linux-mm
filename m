Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id B8CA56B0087
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 07:49:56 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id r20so1318523wiv.1
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 04:49:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si9734388wiy.55.2014.11.06.04.49.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 04:49:55 -0800 (PST)
Date: Thu, 6 Nov 2014 13:49:53 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141106124953.GD7202@dhcp22.suse.cz>
References: <20141105130247.GA14386@htj.dyndns.org>
 <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
 <20141105174609.GE28226@dhcp22.suse.cz>
 <20141105175527.GH14386@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105175527.GH14386@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wed 05-11-14 12:55:27, Tejun Heo wrote:
> On Wed, Nov 05, 2014 at 06:46:09PM +0100, Michal Hocko wrote:
> > Because out_of_memory can be called from mutliple paths. And
> > the only interesting one should be the page allocation path.
> > pagefault_out_of_memory is not interesting because it cannot happen for
> > the frozen task.
> 
> Hmmm.... wouldn't that be broken by definition tho?  So, if the oom
> killer is invoked from somewhere else than page allocation path, it
> would proceed ignoring the disabled setting and would race against PM
> freeze path all the same. 

Not really because try_to_freeze_tasks doesn't finish until _all_ tasks
are frozen and a task in the page fault path cannot be frozen, can it?

I mean there shouldn't be any problem to not invoke OOM killer under
from the page fault path as well but that might lead to looping in the
page fault path without any progress until freezer enables OOM killer on
the failure path because the said task cannot be frozen.

Is this preferable?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
