Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 72B856B0069
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 10:44:42 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id o8so719246qcw.38
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 07:44:41 -0800 (PST)
Received: from mail-qg0-x235.google.com (mail-qg0-x235.google.com. [2607:f8b0:400d:c04::235])
        by mx.google.com with ESMTPS id q2si6852732qaq.121.2014.11.05.07.44.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 07:44:41 -0800 (PST)
Received: by mail-qg0-f53.google.com with SMTP id z107so12171242qgd.26
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 07:44:39 -0800 (PST)
Date: Wed, 5 Nov 2014 10:44:36 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141105154436.GB14386@htj.dyndns.org>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
 <2156351.pWp6MNRoWm@vostro.rjw.lan>
 <20141021141159.GE9415@dhcp22.suse.cz>
 <4766859.KSKPTm3b0x@vostro.rjw.lan>
 <20141021142939.GG9415@dhcp22.suse.cz>
 <20141104192705.GA22163@htj.dyndns.org>
 <20141105124620.GB4527@dhcp22.suse.cz>
 <20141105130247.GA14386@htj.dyndns.org>
 <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105134219.GD4527@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wed, Nov 05, 2014 at 02:42:19PM +0100, Michal Hocko wrote:
> On Wed 05-11-14 14:31:00, Michal Hocko wrote:
> > On Wed 05-11-14 08:02:47, Tejun Heo wrote:
> [...]
> > > Also, why isn't this part of
> > > oom_killer_disable/enable()?  The way they're implemented is really
> > > silly now.  It just sets a flag and returns whether there's a
> > > currently running instance or not.  How were these even useful? 
> > > Why can't you just make disable/enable to what they were supposed to
> > > do from the beginning?
> > 
> > Because then we would block all the potential allocators coming from
> > workqueues or kernel threads which are not frozen yet rather than fail
> > the allocation.
> 
> After thinking about this more it would be doable by using trylock in
> the allocation oom path. I will respin the patch. The API will be
> cleaner this way.

In disable, block new invocations of OOM killer and then drain the
in-progress ones.  This is a common pattern, isn't it?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
