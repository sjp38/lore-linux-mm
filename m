Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EAE266B0012
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:51:19 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p3RNpGuk022701
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:51:16 -0700
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by wpaz37.hot.corp.google.com with ESMTP id p3RNooFo007413
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:51:10 -0700
Received: by pvg3 with SMTP id 3so1814627pvg.32
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:51:10 -0700 (PDT)
Date: Wed, 27 Apr 2011 16:51:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <1303846026.2816.117.camel@work-vm>
Message-ID: <alpine.DEB.2.00.1104271641350.25369@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104201317410.31768@chino.kir.corp.google.com> <1303331695.2796.159.camel@work-vm> <20110421103009.731B.A69D9226@jp.fujitsu.com> <1303846026.2816.117.camel@work-vm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john stultz <johnstul@us.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 26 Apr 2011, john stultz wrote:

> Sorry if this somehow got off on the wrong foot. Its just surprising to
> see such passion bubble up after almost two years of quiet since the
> proc patch went in.
> 

It hasn't been two years, it hasn't even been 18 months.

	$ git diff 4614a696bd1c.. | grep "^+.*current\->comm" | wc -l
	42

Apparently those dozens of new references directly to current->comm since 
the change also were unaware of the need to use get_task_comm() to avoid a 
racy writer.  I don't think there's any code in the kernel that is ok with 
corrupted task names being printed: those messages are usually important.

> So I'm not proposing comm be totally lock free (Dave Hansen might do
> that for me, we'll see :) but when the original patch was proposed, the
> idea that transient empty or incomplete comms would be possible was
> brought up and didn't seem to be a big enough issue at the time to block
> it from being merged.
> 

I'm not really interested in the discussion that happened at the time, I'm 
concerned about racy readers of any thread's comm that result in corrupted 
strings being printed or used in the kernel.

> Its just having a more specific case where these transient
> null/incomplete comms causes an issue would help prioritize the need for
> correctness.
> 

It doesn't seem like there was any due diligence to ensure other code 
wasn't broken.  When comm could only be changed by prctl(), we needed no 
protection for current->comm and so code naturally will reference it 
directly.  Since that's now changed, no audit was done to ensure the 300+ 
references throughout the tree doesn't require non-racy reads.

> In the meantime, I'll put some effort into trying to protect unlocked
> current->comm acccess using get_task_comm() where possible. Won't happen
> in a day, and help would be appreciated. 
> 

We need to stop protecting ->comm with ->alloc_lock since it is used for 
other members of task_struct that may or may not be held in a function 
that wants to read ->comm.  We should probably introduce a seqlock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
