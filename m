Date: Tue, 17 Oct 2000 14:53:46 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: Re: mapping user space buffer to kernel address space
Message-ID: <20001017145346.B20914@redhat.com>
References: <200010140918.LAA10416@cave.bitwizard.nl> <Pine.LNX.4.10.10010141916490.1642-100000@penguin.transmeta.com> <20001016000854.A27414@athlon.random> <20001016221401.A19951@redhat.com> <20001017001349.F17222@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001017001349.F17222@athlon.random>; from andrea@suse.de on Tue, Oct 17, 2000 at 12:13:49AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Stephen Tweedie <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rogier Wolff <R.E.Wolff@BitWizard.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Oct 17, 2000 at 12:13:49AM +0200, Andrea Arcangeli wrote:
> 
> Correct. But the problem is that the page won't stay in physical memory after
> we finished the I/O because swap cache with page count 1 will be freed by the
> VM.

Rik has been waiting for an excuse to get deferred swapout into the
mainline.  Sounds like we've got the excuse.

> And anyways from a design standpoint it looks much better to really pin the
> page in the pte too (just like kernel reserved pages are pinend after a
> remap_page_range).

Unfortunately, there is one common case where we want to do exactly
that.  "dd < /dev/zero > something_using_raw_io" maps a whole series
of identical readonly ZERO_PAGE pages into the kiobuf.  One of the
reasons I removed the automatic page locking was that otherwise we're
forced to special-case things like ZERO_PAGE in the locking code.

Even ignoring that, users _will_ submit multiple IOs in the same page.
Pinning the physical page with page->count is clean.  Doing the
locking with the page lock makes no sense if you have adjacent IOs or
if you want to maintain the kiobuf mapping for any length of time.
The point of kiobufs was to avoid VM hacks so that IO can be done at
physical page level.  Pinning ptes should not have anything to do with
the IO or we've lost that abstraction.

> Replacing the get_user/put_user with handle_mm_fault _after_ changing
> follow_page to check the dirty bit too in the write case should be ok.

Right.

> > Once I'm back in the UK I'll look at getting map_user_kiobuf() simply
> > to call the existing access_one_page() from ptrace.  You're right,
> 
> access_one_page is missing the pagetable lock too, but that seems the only
> problem. I'm not convinced mixing the internal of access_one_page and
> map_user_kiobuf is a good thing since they needs to do a very different thing
> in the critical section.

Not the whole of access_one_page, but the pagetable-locked
follow-page / handle_mm_fault loop should be common code.  That's
where we're having the problem, so let's avoid having to maintain it
in two places.

Cheers, 
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
