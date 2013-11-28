Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 020626B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 06:42:17 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ey16so717406wid.6
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 03:42:17 -0800 (PST)
Received: from mail-ea0-x22f.google.com (mail-ea0-x22f.google.com [2a00:1450:4013:c01::22f])
        by mx.google.com with ESMTPS id a5si23065747wjb.32.2013.11.28.03.42.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 03:42:17 -0800 (PST)
Received: by mail-ea0-f175.google.com with SMTP id z10so5604690ead.6
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 03:42:17 -0800 (PST)
Date: Thu, 28 Nov 2013 12:42:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: user defined OOM policies
Message-ID: <20131128114214.GJ2761@dhcp22.suse.cz>
References: <20131119131400.GC20655@dhcp22.suse.cz>
 <20131119134007.GD20655@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com>
 <20131120152251.GA18809@dhcp22.suse.cz>
 <CAA25o9S5EQBvyk=HP3obdCaXKjoUVtzeb4QsNmoLMq6NnOYifA@mail.gmail.com>
 <alpine.DEB.2.02.1311201933420.7167@chino.kir.corp.google.com>
 <CAA25o9Q64eK5LHhrRyVn73kFz=Z7Jji=rYWS=9jWL_4y9ZGbQA@mail.gmail.com>
 <alpine.DEB.2.02.1311251717370.27270@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311251717370.27270@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Mon 25-11-13 17:29:20, David Rientjes wrote:
> On Wed, 20 Nov 2013, Luigi Semenzato wrote:
> 
> > Yes, I agree that we can't always prevent OOM situations, and in fact
> > we tolerate OOM kills, although they have a worse impact on the users
> > than controlled freeing does.
> > 
> 
> If the controlled freeing is able to actually free memory in time before 
> hitting an oom condition, it should work pretty well.  That ability is 
> seems to be highly dependent on sane thresholds for indvidual applications 
> and I'm afraid we can never positively ensure that we wakeup and are able 
> to free memory in time to avoid the oom condition.
> 
> > Well OK here it goes.  I hate to be a party-pooper, but the notion of
> > a user-level OOM-handler scares me a bit for various reasons.
> > 
> > 1. Our custom notifier sends low-memory warnings well ahead of memory
> > depletion.  If we don't have enough time to free memory then, what can
> > the last-minute OOM handler do?
> > 
> 
> The userspace oom handler doesn't necessarily guarantee that you can do 
> memory freeing, our usecase wants to do a priority-based oom killing that 
> is different from the kernel oom killer based on rss.  To do that, you 
> only really need to read certain proc files and you can do killing based 
> on uptime, for example.  You can also do a hierarchical traversal of 
> memcgs based on a priority.
> 
> We already have hooks in the kernel oom killer, things like 
> /proc/sys/vm/oom_kill_allocating_task

How would you implement oom_kill_allocating_task in userspace? You do
not have any context on who is currently allocating or would you rely on
reading /proc/*/stack to grep for allocation functions?

> and /proc/sys/vm/panic_on_oom that 
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
