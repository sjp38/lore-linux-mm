Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id CF2246B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 12:55:31 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id n8so865600qaq.5
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 09:55:31 -0800 (PST)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com. [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id v9si2224980qat.45.2014.11.05.09.55.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 09:55:30 -0800 (PST)
Received: by mail-qc0-f177.google.com with SMTP id l6so963095qcy.8
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 09:55:30 -0800 (PST)
Date: Wed, 5 Nov 2014 12:55:27 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141105175527.GH14386@htj.dyndns.org>
References: <20141105124620.GB4527@dhcp22.suse.cz>
 <20141105130247.GA14386@htj.dyndns.org>
 <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
 <20141105174609.GE28226@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105174609.GE28226@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wed, Nov 05, 2014 at 06:46:09PM +0100, Michal Hocko wrote:
> Because out_of_memory can be called from mutliple paths. And
> the only interesting one should be the page allocation path.
> pagefault_out_of_memory is not interesting because it cannot happen for
> the frozen task.

Hmmm.... wouldn't that be broken by definition tho?  So, if the oom
killer is invoked from somewhere else than page allocation path, it
would proceed ignoring the disabled setting and would race against PM
freeze path all the same.  Why are things broken at such basic levels?
Something named oom_killer_disable does a lame attempt at it and not
even that depending on who's calling.  There probably is a history
leading to the current situation but the level that things are broken
at is too basic and baffling.  :(

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
