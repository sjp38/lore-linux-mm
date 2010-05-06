Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 721436B0214
	for <linux-mm@kvack.org>; Thu,  6 May 2010 19:27:01 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o46NQwc5017900
	for <linux-mm@kvack.org>; Thu, 6 May 2010 16:26:58 -0700
Received: from ywh39 (ywh39.prod.google.com [10.192.8.39])
	by hpaq5.eem.corp.google.com with ESMTP id o46NQt5G006045
	for <linux-mm@kvack.org>; Thu, 6 May 2010 16:26:57 -0700
Received: by ywh39 with SMTP id 39so321245ywh.21
        for <linux-mm@kvack.org>; Thu, 06 May 2010 16:26:55 -0700 (PDT)
Message-ID: <4BE3503A.2000309@google.com>
Date: Thu, 06 May 2010 16:26:50 -0700
From: Mike Waychison <mikew@google.com>
MIME-Version: 1.0
Subject: Re: rwsem: down_read_unfair() proposal
References: <20100505032033.GA19232@google.com> <22933.1273053820@redhat.com> <20100505103646.GA32643@google.com>
In-Reply-To: <20100505103646.GA32643@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Michel Lespinasse wrote:
> On Wed, May 05, 2010 at 11:03:40AM +0100, David Howells wrote:
>> If the system is as heavily loaded as you say, how do you prevent
>> writer starvation?  Or do things just grind along until sufficient
>> threads are queued waiting for a write lock?
> 
> Reader/Writer fairness is not disabled in the general case - it only is
> for a few specific readers such as /proc/<pid>/maps. In particular, the
> do_page_fault path, which holds a read lock on mmap_sem for potentially long
> (~disk latency) periods of times, still uses a fair down_read() call.
> In comparison, the /proc/<pid>/maps path which we made unfair does not
> normally hold the mmap_sem for very long (it does not end up hitting disk);
> so it's been working out well for us in practice.
> 

FWIW, these sorts of block-ups are usually really pronounce on machines 
with harddrives that take _forever_ to respond to SMART commands (which 
are done via PIO, and which can serialize many drives when they are 
hidden behind a port multiplier).  We've seen cases where hard faults 
can take unusually long on an otherwise non-busy machines (~10 seconds?).

The other case we have problems with mmap_sem from a cluster monitoring 
perspective occurs when we get blocked up behind a task that is having 
problems dying from oom.  We have a variety of hacks used internally to 
cover these cases, though I think we (David and I?) figured that it'd 
make more sense to fix the dependencies on down_read(&current->mmap_sem) 
in the do_exit() path.  For instance, it really makes no sense to 
coredump when we are being oom killed (and thus we should be able to 
skip the mmap_sem dependency there..).

Mike Waychison

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
