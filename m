Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B03326B027A
	for <linux-mm@kvack.org>; Wed,  5 May 2010 07:10:09 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100505104807.GB32643@google.com>
References: <20100505104807.GB32643@google.com> <20100505032033.GA19232@google.com> <22994.1273054004@redhat.com>
Subject: Re: rwsem: down_read_unfair() proposal
Date: Wed, 05 May 2010 12:09:59 +0100
Message-ID: <23977.1273057799@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Michel Lespinasse <walken@google.com> wrote:

> I only said it was doable :) Not done with the implementation yet, but I can
> describe the general idea if that helps. The high part of the rwsem is
> decremented by two for each thread holding or trying to acquire a write
> lock;

That would mean you're reducing the capacity of the upper counter by one since
the high part must remain negative if we're to be able to check it for
non-zeroness by checking the sign flag.  That means a maximum of 2^14-1 writers
queued on a 32-bit box (16384), but we can have more threads than that (up to
~32767).

Currently, we can have a maximum of 32767 writers+readers queued as we only
decrement the upper counter by 1 each time.

On a 64-bit box, the limitations go away for all practical purposes.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
