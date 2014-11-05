Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 283336B0099
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 12:01:17 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k15so794358qaq.15
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 09:01:16 -0800 (PST)
Received: from mail-qc0-x22e.google.com (mail-qc0-x22e.google.com. [2607:f8b0:400d:c01::22e])
        by mx.google.com with ESMTPS id s38si7293117qge.85.2014.11.05.09.01.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 09:01:15 -0800 (PST)
Received: by mail-qc0-f174.google.com with SMTP id r5so873776qcx.5
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 09:01:14 -0800 (PST)
Date: Wed, 5 Nov 2014 12:01:11 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141105170111.GG14386@htj.dyndns.org>
References: <20141104192705.GA22163@htj.dyndns.org>
 <20141105124620.GB4527@dhcp22.suse.cz>
 <20141105130247.GA14386@htj.dyndns.org>
 <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105165428.GF14386@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wed, Nov 05, 2014 at 11:54:28AM -0500, Tejun Heo wrote:
> > Still not following. How do you want to detect an on-going OOM without
> > any interface around out_of_memory?
> 
> I thought you were using oom_killer_allowed_start() outside OOM path.
> Ugh.... why is everything weirdly structured?  oom_killer_disabled
> implies that oom killer may fail, right?  Why is
> __alloc_pages_slowpath() checking it directly?  If whether oom killing
> failed or not is relevant to its users, make out_of_memory() return an
> error code.  There's no reason for the exclusion detail to leak out of
> the oom killer proper.  The only interface should be disable/enable
> and whether oom killing failed or not.

And what's implemented is wrong.  What happens if oom killing is
already in progress and then a task blocks trying to write-lock the
rwsem and then that task is selected as the OOM victim?  disable()
call must be able to fail.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
