Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 421908320D
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 18:03:36 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id f191so94955447qka.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 15:03:36 -0800 (PST)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id u57si4233636qtb.149.2017.03.08.15.03.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 15:03:29 -0800 (PST)
Received: by mail-qk0-x234.google.com with SMTP id p64so93488460qke.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 15:03:29 -0800 (PST)
Date: Wed, 8 Mar 2017 18:03:27 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
Message-ID: <20170308230327.GE21117@htj.duckdns.org>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
 <20170303133950.GD31582@dhcp22.suse.cz>
 <20170303232512.GI17542@dastard>
 <20170307121503.GJ28642@dhcp22.suse.cz>
 <20170307193659.GD31179@htj.duckdns.org>
 <20170307212132.GQ17542@dastard>
 <20170307214842.GA7500@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307214842.GA7500@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

Hello,

On Tue, Mar 07, 2017 at 04:48:42PM -0500, Tejun Heo wrote:
> > > It's implementable for sure.  I'm just not sure how it'd help
> > > anything.  It's not a relevant information on anything.
> > 
> > Except to enable us to get closer to the "rescuer must make forwards
> > progress" guarantee. In this context, the rescuer is the only
> > context we should allow to dip into memory reserves. I'm happy if we
> > have to explicitly check for that and set PF_MEMALLOC ourselves 
> > (we do that for XFS kernel threads involved in memory reclaim),
> > but it's not something we should set automatically on every
> > IO completion work item we run....
> 
> Ah, okay, that does make sense to me.  Yeah, providing that test
> shouldn't be difficult at all.  Lemme cook up a patch.

Turns out we already have this.  Writeback path already has a special
case handling for the rescuer.  You can just use
current_is_workqueue_rescuer().  The function can be called safely
from any task context.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
