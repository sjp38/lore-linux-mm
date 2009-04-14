Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6756A5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 12:01:55 -0400 (EDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC][PATCH v3 4/6] aio: Don't inherit aio ring memory at fork
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
	<20090414151924.C653.A69D9226@jp.fujitsu.com>
Date: Tue, 14 Apr 2009 12:01:50 -0400
In-Reply-To: <20090414151924.C653.A69D9226@jp.fujitsu.com> (KOSAKI Motohiro's
	message of "Tue, 14 Apr 2009 15:20:20 +0900 (JST)")
Message-ID: <x49iql7z0k1.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Zach Brown <zach.brown@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-api@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:

> AIO folks, Am I missing anything?
>
> ===============
> Subject: [RFC][PATCH] aio: Don't inherit aio ring memory at fork
>
> Currently, mm_struct::ioctx_list member isn't copyed at fork. IOW aio context don't inherit at fork.
> but only ring memory inherited. that's strange.
>
> This patch mark DONTFORK to ring-memory too.

Well, given that clearly nobody relies on io contexts being copied to
the child, I think it's okay to make this change.  I think the current
behaviour violates the principal of least surprise, but I'm having a
hard time getting upset about that.  ;)

> In addition, This patch has good side effect. it also fix
> "get_user_pages() vs fork" problem.

Hmm, I don't follow you, here.  As I understand it, the get_user_pages
vs. fork problem has to do with the pages used for the actual I/O, not
the pages used to store the completion data.  So, could you elaborate a
bit on what you mean by the above statement?

> I think "man fork" also sould be changed. it only say
>
>        *  The child does not inherit outstanding asynchronous I/O operations from
>           its parent (aio_read(3), aio_write(3)).
> but aio_context_t (return value of io_setup(2)) also don't inherit in current implementaion.

I can certainly make that change, as I have other changes I need to push
to Michael, anyway.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
