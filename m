Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ABD416B028A
	for <linux-mm@kvack.org>; Wed,  5 May 2010 06:36:55 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o45AaqwK006020
	for <linux-mm@kvack.org>; Wed, 5 May 2010 03:36:52 -0700
Received: from pvg11 (pvg11.prod.google.com [10.241.210.139])
	by kpbe14.cbf.corp.google.com with ESMTP id o45AapCQ022605
	for <linux-mm@kvack.org>; Wed, 5 May 2010 03:36:51 -0700
Received: by pvg11 with SMTP id 11so1890528pvg.18
        for <linux-mm@kvack.org>; Wed, 05 May 2010 03:36:50 -0700 (PDT)
Date: Wed, 5 May 2010 03:36:46 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: rwsem: down_read_unfair() proposal
Message-ID: <20100505103646.GA32643@google.com>
References: <20100505032033.GA19232@google.com> <22933.1273053820@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <22933.1273053820@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 11:03:40AM +0100, David Howells wrote:
> If the system is as heavily loaded as you say, how do you prevent
> writer starvation?  Or do things just grind along until sufficient
> threads are queued waiting for a write lock?

Reader/Writer fairness is not disabled in the general case - it only is
for a few specific readers such as /proc/<pid>/maps. In particular, the
do_page_fault path, which holds a read lock on mmap_sem for potentially long
(~disk latency) periods of times, still uses a fair down_read() call.
In comparison, the /proc/<pid>/maps path which we made unfair does not
normally hold the mmap_sem for very long (it does not end up hitting disk);
so it's been working out well for us in practice.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
