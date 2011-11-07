Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0076B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 06:29:56 -0500 (EST)
Date: Mon, 7 Nov 2011 12:29:52 +0100
From: Lennart Poettering <mzxreary@0pointer.de>
Subject: Re: [RFC PATCH] tmpfs: support user quotas
Message-ID: <20111107112952.GB25130@tango.0pointer.de>
References: <1320614101.3226.5.camel@offbook>
 <20111107073127.GA7410@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111107073127.GA7410@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Davidlohr Bueso <dave@gnu.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Kay Sievers <kay.sievers@vrfy.org>

On Mon, 07.11.11 02:31, Christoph Hellwig (hch@infradead.org) wrote:

>
> On Sun, Nov 06, 2011 at 06:15:01PM -0300, Davidlohr Bueso wrote:
> > From: Davidlohr Bueso <dave@gnu.org>
> >
> > This patch adds a new RLIMIT_TMPFSQUOTA resource limit to restrict an individual user's quota across all mounted tmpfs filesystems.
> > It's well known that a user can easily fill up commonly used directories (like /tmp, /dev/shm) causing programs to break through DoS.
>
> Please jyst implement the normal user/group quota interfaces we use for other
> filesystem.

Please don't.

tmpfs by its very nature is volatile, which means that we'd have to
upload the quota data explicitly each time we mount a tmpfs, which means
we'd have to add quite some userspace infrastructure to make tmpfs work
with quota. Either every time a tmpfs is mounted we'd have to apply a
quota for every configured user and every future user to it (which is
simply not realistic) or on every user logging in we'd have to go
through all tmpfs mount points and apply a user-specific quota setting
to it -- which isn't much less ugly and complex. Just using a
user-specific RLIMIT is much much simpler and beautiful there, and
requires almost no changes to userspace.

On top of that I think a global quota over all tmpfs is actually
preferable than a per-tmpfs quota, because what you want to enforce is
that clients cannot drain the pool that tmpfs is backed from but how
they distribute their share of that pool on the various tmpfs mounted
doesn't really matter in order to avoid DoS vulnerabilities.

In short: a resource limit for tmpfs quota looks like the best solution
here, which does exactly what userspace wants.

Lennart

--
Lennart Poettering - Red Hat, Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
