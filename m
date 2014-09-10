Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id E1FE16B0038
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:08:05 -0400 (EDT)
Received: by mail-yk0-f178.google.com with SMTP id 20so1811120yks.37
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:08:05 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id k64si12124972yha.144.2014.09.10.07.08.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 07:08:05 -0700 (PDT)
Date: Wed, 10 Sep 2014 10:07:59 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
Message-ID: <20140910140759.GC31903@thunk.org>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
 <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
 <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>

On Wed, Sep 10, 2014 at 07:05:40AM +0200, Jiri Kosina wrote:
> > kfree() is quite a hot path to which this will add overhead.  And we
> > have (as far as we know) no code which will actually use this at
> > present.
> 
> We obviously don't, as such code will be causing explosions. This is meant 
> as a prevention of problems such as the one that has just been fixed in 
> ext4.

These sorts of things can happen a lot, unfortunately.  We had a
number of bugs in ext4 where ext4 would explode if a GFP_NOFS kmalloc
would fail.  These bugs have been around for a long time, and
apparently *none* of the RHEL/SLES/OUL enterprise linux
certification/QA efforts found them.

I only found them when an a Google-internal-only patch introduced an
mm behavioural change that caused GFP_NOFS allocations to fail under
extreme memory pressure.  And that's exactly the sort of thing that
would cause disasgters when you might have some function such as:

	ptr = function_that_does_an_kmalloc(...)
	if (IS_ERR(ptr)) {
		ret = PTR_ERR(ptr);
		goto cleanup);
	}
	bh = function_that_does_a_getblk(...)
	if (IS_ERR(bh)) {
		ret = PTR_ERR(bh);
		goto cleanup);
	}
	....

cleanup:
	if (bh)
		brelse(bh);
	if (ptr)
		kfree(ptr);


Normally, kfree and bh would be allocated, and so kfree() and brelse()
does the right thing.  But if something changes that causes functions
that in practice, never returned an allocation failure, suddenly
*does* start failing, then you get an explosion.  And/or, previous to
recent mainline patches, the kernel might BUG, and/or declare the file
system corrupt, forcing an fsck --- and when *large* number of systems
get stuck in an fsck at the same time, it tends to distress the system
administrators, far worse than if the kernel had merely exploded.  :-/

So I wouldn't be so sure that we don't have these sorts of bugs hiding
somewhere; and it's extremely easy for them to sneak in.  That being
said, I'm not in favor of making changes to kfree; I'd much rather
depending on better testing and static checkers to fix them, since
kfree *is* a hot path.

Cheers,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
