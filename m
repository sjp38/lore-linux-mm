Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f173.google.com (mail-ve0-f173.google.com [209.85.128.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2869A6B0036
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 17:51:42 -0500 (EST)
Received: by mail-ve0-f173.google.com with SMTP id oz11so9275234veb.4
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 14:51:41 -0800 (PST)
Received: from mail-yh0-x233.google.com (mail-yh0-x233.google.com [2607:f8b0:4002:c01::233])
        by mx.google.com with ESMTPS id at4si30280671ved.37.2013.12.02.14.51.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 14:51:41 -0800 (PST)
Received: by mail-yh0-f51.google.com with SMTP id c41so7951726yho.10
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 14:51:40 -0800 (PST)
Date: Mon, 2 Dec 2013 14:51:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [merged] mm-memcg-handle-non-error-oom-situations-more-gracefully.patch
 removed from -mm tree
In-Reply-To: <20131202131238.GB18838@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1312021443590.13465@chino.kir.corp.google.com>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org> <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com> <20131127233353.GH3556@cmpxchg.org> <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com> <20131128021809.GI3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com> <20131128031313.GK3556@cmpxchg.org> <alpine.DEB.2.02.1311271914460.5120@chino.kir.corp.google.com> <20131128100213.GE2761@dhcp22.suse.cz> <alpine.DEB.2.02.1311291600290.22413@chino.kir.corp.google.com>
 <20131202131238.GB18838@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, azurit@pobox.sk, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2 Dec 2013, Michal Hocko wrote:

> I guess we need to know how much is significantly less.
> oom_scan_process_thread already aborts on exiting tasks so we do not
> kill anything and then the charge (whole page fault actually) is retried
> when we check for the OOM again so my intuition would say that we gave
> the exiting task quite a lot of time.
> 

That isn't the race, though.  The race occurs when the oom killed process 
exits prior to the process iteration so it's not detected and yet its 
memory has already been freed and the memcg is no longer oom.  In other 
words, a process that has called mem_cgroup_oom_synchronize() at the same 
time that an oom killed process has freed its memory.  The result is an 
unnecessary oom killing and erroneous spam in the kernel log.

We all agree that this race cannot be completely closed (at least without 
synchronization in the uncharge path that we obviously don't want to add).  
We don't know if an oom killed process, or any process, will free its 
memory immediately after the kernel sends the SIGKILL.  However, there's 
absolutely no reason to not have a final check immediately before sending 
the SIGKILL to prevent that unnecessary oom kill.

I'm going to send the patch for review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
