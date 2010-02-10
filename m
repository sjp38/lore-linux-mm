Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C6AC26B0078
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 23:01:27 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Wed, 10 Feb 2010 21:54:43 +0100
References: <201002012302.37380.l.lunak@suse.cz> <4B6B4500.3010603@redhat.com> <alpine.DEB.2.00.1002041410300.16391@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002041410300.16391@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002102154.43231.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Thursday 04 of February 2010, David Rientjes wrote:
> On Thu, 4 Feb 2010, Rik van Riel wrote:
> > The goal of the OOM killer is to kill some process, so the
> > system can continue running and automatically become available
> > again for whatever workload the system was running.
> >
> > Killing the parent process of one of the system daemons does
> > not achieve that goal, because you now caused a service to no
> > longer be available.
>
> The system daemon wouldn't be killed, though.  You're right that this
> heuristic would prefer the system daemon slightly more as a result of the
> forkbomb penalty, but the oom killer always attempts to sacrifice a child
> with a seperate mm before killing the selected task.  Since the forkbomb
> heuristic only adds up those children with seperate mms, we're guaranteed
> to not kill the daemon itself.

 Which however can mean that not killing this system daemon will be traded for 
DoS-ing the whole system, if the daemon keeps spawning new children as soon 
as the OOM killer frees up resources for them.

 This looks like wrong solution to me, it's like trying to save a target by 
shooting all incoming bombs instead of shooting the bomber. If the OOM 
situation is caused by one or a limited number of its children, or if the 
system daemon is not reponsible for the forkbomb (e.g. it's only a subtree of 
its children), then it won't be selected for killing anyway. If it is 
responsible for the forkbomb, the OOM killer can trying killing the bombs 
forever to no avail.

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
