Date: Thu, 1 Apr 2004 17:19:49 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: msync() behaviour broken for MS_ASYNC, revert patch?
Message-ID: <20040401161949.GC25502@mail.shareable.org>
References: <1080771361.1991.73.camel@sisko.scot.redhat.com> <Pine.LNX.4.58.0403311433240.1116@ppc970.osdl.org> <1080776487.1991.113.camel@sisko.scot.redhat.com> <Pine.LNX.4.58.0403311550040.1116@ppc970.osdl.org> <1080834032.2626.94.camel@sisko.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1080834032.2626.94.camel@sisko.scot.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@osdl.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ulrich Drepper <drepper@redhat.com>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> Yes, but we _used_ to have that choice --- call msync() with flags == 0,
> and you'd get the deferred kupdated writeback;

Is that not equivalent to MS_INVALIDATE?  It seems to be equivalent in
2.6.4.

The code in 2.6.4 ignores MS_INVALIDATE except for trivial error
checks, so msync() with flags == MS_INVALIDATE has the same effect as
msync() with flags == 0.

Some documentation I'm looking at says MS_INVALIDATE updates the
mapped page to contain the current contents of the file.  2.6.4 seems
to do the reverse: update the file to contain the current content of
the mapped page.  "man msync" agrees with the the latter.  (I can't
look at SUS right now).

On systems where the CPU caches are fully coherent, the only
difference is that the former is a no-op and the latter does the same
as the new behaviour of MS_ASYNC.

On systems where the CPU caches aren't coherent, some cache
synchronising or flushing operations are implied.

On either type of system, MS_INVALIDATE doesn't seem to be doing what
the documentation I'm looking at says it should do.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
