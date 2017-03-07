Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 492236B0398
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 16:48:45 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id f54so29827599uaa.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 13:48:45 -0800 (PST)
Received: from mail-ua0-x233.google.com (mail-ua0-x233.google.com. [2607:f8b0:400c:c08::233])
        by mx.google.com with ESMTPS id y184si592775vka.190.2017.03.07.13.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 13:48:44 -0800 (PST)
Received: by mail-ua0-x233.google.com with SMTP id u30so25517269uau.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 13:48:44 -0800 (PST)
Date: Tue, 7 Mar 2017 16:48:42 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
Message-ID: <20170307214842.GA7500@htj.duckdns.org>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
 <20170303133950.GD31582@dhcp22.suse.cz>
 <20170303232512.GI17542@dastard>
 <20170307121503.GJ28642@dhcp22.suse.cz>
 <20170307193659.GD31179@htj.duckdns.org>
 <20170307212132.GQ17542@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307212132.GQ17542@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

Hello,

On Wed, Mar 08, 2017 at 08:21:32AM +1100, Dave Chinner wrote:
> > I don't see how whether something is running off of a rescuer or not
> > matters here.  The only thing workqueue guarantees is that there's
> > gonna be at least one kworker thread executing work items from the
> > workqueue.  Running on a rescuer doesn't necessarily indicate memory
> > pressure condition.
> 
> That's news to me. In what situations do we run the rescuer thread
> other than memory allocation failure when queuing work?

It's a timeout based mechanism.  Whevever the delay might be coming
from, the rescuer kicks in if the workqueue fails to make forward
progress for a while.  The only thing which can induce delay there is
kthread creation path, which usually gets blocked on memory pressure
but it could easily be something else - severe cpu contention,
somebody holding some mutex for too long, whatever.

> > It's implementable for sure.  I'm just not sure how it'd help
> > anything.  It's not a relevant information on anything.
> 
> Except to enable us to get closer to the "rescuer must make forwards
> progress" guarantee. In this context, the rescuer is the only
> context we should allow to dip into memory reserves. I'm happy if we
> have to explicitly check for that and set PF_MEMALLOC ourselves 
> (we do that for XFS kernel threads involved in memory reclaim),
> but it's not something we should set automatically on every
> IO completion work item we run....

Ah, okay, that does make sense to me.  Yeah, providing that test
shouldn't be difficult at all.  Lemme cook up a patch.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
