Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 869596B0290
	for <linux-mm@kvack.org>; Wed,  5 May 2010 06:48:21 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o45AmDMC029395
	for <linux-mm@kvack.org>; Wed, 5 May 2010 03:48:14 -0700
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by wpaz17.hot.corp.google.com with ESMTP id o45AmC6N003833
	for <linux-mm@kvack.org>; Wed, 5 May 2010 03:48:12 -0700
Received: by pxi1 with SMTP id 1so2346437pxi.22
        for <linux-mm@kvack.org>; Wed, 05 May 2010 03:48:11 -0700 (PDT)
Date: Wed, 5 May 2010 03:48:07 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: rwsem: down_read_unfair() proposal
Message-ID: <20100505104807.GB32643@google.com>
References: <20100505032033.GA19232@google.com> <22994.1273054004@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <22994.1273054004@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 11:06:44AM +0100, David Howells wrote:
> Michel Lespinasse <walken@google.com> wrote:
> 
> > and looks like it's doable with the x86 rwsem implementation as well in a
> > way that would only involve changes to the rwsem spinlock-protected slow
> > paths in lib/rwsem.c .
> 
> It's not as easy as it seems.  Once an XADD-based rwsem is contended, you
> cannot necessarily tell without looking at the queue whether the rwsem is
> currently write-locked or read-locked.

I only said it was doable :) Not done with the implementation yet, but I can
describe the general idea if that helps. The high part of the rwsem is
decremented by two for each thread holding or trying to acquire a write lock;
additionally the high part of the rwsem is decremented by one for the first
thread getting queued. Since queuing is done under a spinlock, it is easy
to decrement only for the first blocked thread there. In down_read_unfair(),
the rwsem value is compared with RWSEM_WAITING_BIAS (== -1 << 16 or 32);
if it's smaller then the rwsem might be write owned and we have to block;
otherwise it only has waiters which we can decide to ignore. This is the
idea in a nutshell.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
