Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DC8AB5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 05:36:57 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH 0/6] IO pinning(get_user_pages()) vs fork race fix
Date: Tue, 14 Apr 2009 19:37:21 +1000
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <200904141841.50397.nickpiggin@yahoo.com.au> <20090414175525.C67C.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090414175525.C67C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904141937.23584.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 14 April 2009 19:19:10 KOSAKI Motohiro wrote:

> > I don't see how it fixes vmsplice? vmsplice can get_user_pages pages from one
> > process's address space and put them into a pipe, and they are released by
> > another process after consuming the pages I think. So it's fairly hard to hold
> > a lock over this.
> 
> I recognize my explanation is poor.
> 
> firstly, pipe_to_user() via vmsplice_to_user use copy_to_user. then we don't need care
> receive side.
> secondly, get_iovec_page_array() via vmsplice_to_pipe() use gup(read).
> then we only need prevent to change the page.
> 
> I changed reuse_swap_page() at [1/6]. then if any process touch the page while
> the process isn't recived yet, it makes COW break and toucher get copyed page.
> then, Anybody can't change original page.
> 
> Thus, This patch series also fixes vmsplice issue, I think.
> Am I missing anything?

Ah thanks, I see now. No I don't think you're missing anything.


> > I guess apart from the vmsplice issue (unless I missed a clever fix), I guess
> > this *does* work. I can't see any races... I'd really still like to hear a good
> > reason why my proposed patch is so obviously crap.
> > 
> > Reasons proposed so far:
> > "No locking" (I think this is a good thing; no *bugs* have been pointed out)
> > "Too many page flags" (but it only uses 1 anon page flag, only fs pagecache
> > has a flags shortage so we can easily overload a pagecache flag)
> > "Diffstat too large" (seems comparable when you factor in the fixes to callers,
> > but has the advantage of being contained within VM subsystem)
> > "Horrible code" (I still don't see it. Of course the code will be nicer if we
> > don't fix the issue _at all_, but I don't see this is so much worse than having
> > to fix callers.)
> 
> Honestly, I don't dislike your.
> but I really hope to fix this bug. if someone nak your patch, I'll seek another way.

Yes, I appreciate you looking at alternatives, and you haven't been strongly
arguing against my patch. So this comment was not aimed at you :)


> > FWIW, I have attached my patch again (with simple function-movement hunks
> > moved into another patch so it is easier to see real impact of this patch).
> 
> OK. I try to test your patch too.

Well I split it out and it requires another patch to move functions around
(eg. zap_pte from fremap.c into memory.c). I just attached it here to
illustrate the core of my fix. If you would like to run any real tests, let
me know and I could send a proper rollup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
