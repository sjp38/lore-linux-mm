Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 7F3926B0072
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 17:56:37 -0400 (EDT)
Date: Tue, 23 Oct 2012 14:56:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
Message-Id: <20121023145636.0a9b9a3e.akpm@linux-foundation.org>
In-Reply-To: <20121023102153.GD3064@quack.suse.cz>
References: <1350918406-11369-1-git-send-email-jack@suse.cz>
	<20121022123852.a4bd5f2a.akpm@linux-foundation.org>
	<20121023102153.GD3064@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Tue, 23 Oct 2012 12:21:53 +0200
Jan Kara <jack@suse.cz> wrote:

> > That seems a fairly serious problem.  To which kernel version(s) should
> > we apply the fix?
>   Well, XFS will crash starting from 2.6.36 kernel where the assertion was
> added. Previously XFS just silently added buffers (as other filesystems do
> it) and wrote / redirtied the page (unnecessarily). So looking into
> maintained -stable branches I think pushing the patch to -stable from 3.0
> on should be enough.

OK, thanks, I made it so.

> > > diff --git a/mm/rmap.c b/mm/rmap.c
> > 
> > It's a bit surprising that none of the added comments mention the s390
> > pte-dirtying oddity.  I don't see an obvious place to mention this, but
> > I for one didn't know about this and it would be good if we could
> > capture the info _somewhere_?
>   As Hugh says, the comment before page_test_and_clear_dirty() is somewhat
> updated. But do you mean recording somewhere the catch that s390 HW dirty
> bit gets set also whenever we write to a page from kernel?

Yes, this.  It's surprising behaviour which we may trip over again, so
how do we inform developers about it?

> I guess we could
> add that also to the comment before page_test_and_clear_dirty() in
> page_remove_rmap() and also before definition of
> page_test_and_clear_dirty(). So most people that will add / remove these
> calls will be warned. OK?

Sounds good, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
