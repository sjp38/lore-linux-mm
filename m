Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7E16F6B0047
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 17:14:57 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o14MEsHM031356
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 14:14:54 -0800
Received: from pxi30 (pxi30.prod.google.com [10.243.27.30])
	by wpaz9.hot.corp.google.com with ESMTP id o14MEhsI026878
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 14:14:53 -0800
Received: by pxi30 with SMTP id 30so3016639pxi.14
        for <linux-mm@kvack.org>; Thu, 04 Feb 2010 14:14:53 -0800 (PST)
Date: Thu, 4 Feb 2010 14:14:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <4B6B4500.3010603@redhat.com>
Message-ID: <alpine.DEB.2.00.1002041410300.16391@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com> <201002032355.01260.l.lunak@suse.cz> <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
 <4B6A1241.60009@redhat.com> <alpine.DEB.2.00.1002041339220.6071@chino.kir.corp.google.com> <4B6B4500.3010603@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Feb 2010, Rik van Riel wrote:

> > Keep in mind that we're in the oom killer here, though.  So we're out of
> > memory and we need to kill something; should Apache, Oracle, and postgres
> > not be penalized for their cost of running by factoring in something like
> > this?
> 
> No, they should not.
> 
> The goal of the OOM killer is to kill some process, so the
> system can continue running and automatically become available
> again for whatever workload the system was running.
> 
> Killing the parent process of one of the system daemons does
> not achieve that goal, because you now caused a service to no
> longer be available.
> 

The system daemon wouldn't be killed, though.  You're right that this 
heuristic would prefer the system daemon slightly more as a result of the 
forkbomb penalty, but the oom killer always attempts to sacrifice a child 
with a seperate mm before killing the selected task.  Since the forkbomb 
heuristic only adds up those children with seperate mms, we're guaranteed 
to not kill the daemon itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
