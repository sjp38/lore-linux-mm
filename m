Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B53B96B006E
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 09:30:12 -0500 (EST)
Date: Mon, 7 Nov 2011 15:30:10 +0100
From: Lennart Poettering <mzxreary@0pointer.de>
Subject: Re: [RFC PATCH] tmpfs: support user quotas
Message-ID: <20111107143010.GA3630@tango.0pointer.de>
References: <1320614101.3226.5.camel@offbook>
 <20111107112952.GB25130@tango.0pointer.de>
 <1320675607.2330.0.camel@offworld>
 <20111107135823.3a7cdc53@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111107135823.3a7cdc53@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Davidlohr Bueso <dave@gnu.org>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Kay Sievers <kay.sievers@vrfy.org>

On Mon, 07.11.11 13:58, Alan Cox (alan@lxorguk.ukuu.org.uk) wrote:

> 
> > Right, rlimit approach guarantees a simple way of dealing with users
> > across all tmpfs instances.
> 
> Which is almost certainly not what you want to happen. Think about direct
> rendering.

I don't see what direct rendering has to do with closing the security
hole that /dev/shm currently is.

> For simple stuff tmpfs already supports size/nr_blocks/nr_inodes mount
> options so you can mount private resource constrained tmpfs objects
> already without kernel changes. No rlimit hacks needed - and rlimit is
> the wrong API anyway.

Uh? I am pretty sure we don't want to mount a private tmpfs for each
user in /dev/shm and /tmp. If you have 500 users you'd have 500 tmpfs on
/tmp and on /dev/shm. Despite that without some ugly namespace hackery
you couldn't make them all appear in /tmp as /dev/shm without
subdirectories. Don't forget that /dev/shm and /tmp are an established
userspace API.

Resource limits are exactly the API that makes sense here, because:

a) we only want one tmpfs on /tmp, and one tmpfs on /dev/shm, not 500 on
each for each user

b) we cannot move /dev/shm, /tmp around without breaking userspace
massively

c) we want a global limit across all tmpfs file systems for each user

d) we don't want to have to upload the quota database into each tmpfs at
mount time.

And hence: a per user RLIMIT is exactly the minimal solution we want
here.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
