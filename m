Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f43.google.com (mail-vb0-f43.google.com [209.85.212.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0216B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 21:52:15 -0500 (EST)
Received: by mail-vb0-f43.google.com with SMTP id q12so5392191vbe.2
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 18:52:14 -0800 (PST)
Received: from mail-yh0-x231.google.com (mail-yh0-x231.google.com [2607:f8b0:4002:c01::231])
        by mx.google.com with ESMTPS id vi1si21171771vcb.19.2013.11.27.18.52.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 18:52:13 -0800 (PST)
Received: by mail-yh0-f49.google.com with SMTP id z20so5557839yhz.22
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 18:52:12 -0800 (PST)
Date: Wed, 27 Nov 2013 18:52:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131128022804.GJ3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311271839290.5120@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com> <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com> <20131118154115.GA3556@cmpxchg.org> <20131118165110.GE32623@dhcp22.suse.cz> <20131122165100.GN3556@cmpxchg.org>
 <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com> <20131127163435.GA3556@cmpxchg.org> <alpine.DEB.2.02.1311271343250.9222@chino.kir.corp.google.com> <20131127231931.GG3556@cmpxchg.org> <alpine.DEB.2.02.1311271613340.10617@chino.kir.corp.google.com>
 <20131128022804.GJ3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 27 Nov 2013, Johannes Weiner wrote:

> The long-standing, user-visible definition of the current line agrees
> with me.  You can't just redefine this, period.
> 
> I tried to explain to you how insane the motivation for this patch is,
> but it does not look like you are reading what I write.  But you don't
> get to change user-visible behavior just like that anyway, much less
> so without a sane reason, so this was a complete waste of time :-(
> 

If you would like to leave this to Andrew's decision, that's fine.  
Michal has already agreed with my patch and has acked it in -mm.

If userspace is going to handle oom conditions, which is possible today 
and will be extended in the future, then it should only wakeup as a last 
resort when there is no possibility of future memory freeing.  It would be 
stupid to have userspace wakeup to handle the oom condition and then 
require it determine if the kernel simply needed to give it access to 
memory reserves for the allocating task to exit and free memory so it 
doesn't actually need to do anything.

Section 10 of Documentation/cgroups/memory.txt defines the necessary 
actions for processes waiting on this notification to make forward 
progress, it doesn't expect a process is already going to exit and free 
memory on its own.  Waking up in such a condition would be absolutely 
ludicrous.

Furthermore, if you're looking for notification simply when the memcg oom 
limit has been reached, you can use memory thresholds.  If you're looking 
for notification simply when reclaim is suffering severe pressure, you can 
use VMPRESSURE_CRITICAL.

I've been patient in this thread, but at this point I think everything has 
been said and it's pointless to continue going in circles.  Thanks for 
your time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
