Date: Mon, 5 Feb 2007 21:30:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-Id: <20070205213006.0ea2d918.akpm@linux-foundation.org>
In-Reply-To: <20070206044146.GA11856@wotan.suse.de>
References: <20070204014445.88e6c8c7.akpm@linux-foundation.org>
	<20070204101529.GA22004@wotan.suse.de>
	<20070204023055.2583fd65.akpm@linux-foundation.org>
	<20070204104609.GA29943@wotan.suse.de>
	<20070204025602.a5f8c53a.akpm@linux-foundation.org>
	<20070204110317.GA9034@wotan.suse.de>
	<20070204031549.203f7b47.akpm@linux-foundation.org>
	<20070204151051.GB12771@wotan.suse.de>
	<20070204103620.33c24cad.akpm@linux-foundation.org>
	<20070206022549.GB31476@wotan.suse.de>
	<20070206044146.GA11856@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Feb 2007 05:41:46 +0100 Nick Piggin <npiggin@suse.de> wrote:

> On Tue, Feb 06, 2007 at 03:25:49AM +0100, Nick Piggin wrote:
> > On Sun, Feb 04, 2007 at 10:36:20AM -0800, Andrew Morton wrote:
> > > On Sun, 4 Feb 2007 16:10:51 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > 
> > > > They're not likely to hit the deadlocks, either. Probability gets more
> > > > likely after my patch to lock the page in the fault path. But practially,
> > > > we could live without that too, because the data corruption it fixes is
> > > > very rare as well. Which is exactly what we've been doing quite happily
> > > > for most of 2.6, including all distro kernels (I think).
> > > 
> > > Thing is, an application which is relying on the contents of that page is
> > > already unreliable (or really peculiar), because it can get indeterminate
> > > results anyway.
> > 
> > Not necessarily -- they could read from one part of a page and write to
> > another. I see this as the biggest data corruption problem.

The kernel gets that sort of thing wrong anyway, and always has, because
it uses memcpy()-style copying and not memmove()-style.

I can't imagine what sort of application you're envisaging here.  The
problem was only ever observed from userspace by an artificial stress-test
thing.

> And in fact, it is not just transient errors either. This problem can
> add permanent corruption into the pagecache and onto disk, and it doesn't
> even require two processes to race.
> 
> After zeroing out the uncopied part of the page, and attempting to loop
> again, we might bail out of the loop for any reason before completing the
> rest of the copy, leaving the pagecache corrupted, which will soon go out
> to disk.
> 

Only because ->commit_write() went and incorrectly marked parts of the page
as up-to-date.

Zeroing out the fag end of the copy_from_user() on fault is actually incorrect. 
What we _should_ do is to bring those uncopyable, non-uptodate parts of the
page uptodate rather than zeroing them.  ->readpage() does that.

So...  what happens if we do

	lock_page()
	prepare_write()
	if (copy_from_user_atomic()) {
		readpage()
		wait_on_page()
		lock_page()
	}
	commit_write()
	unlock_page()

- If the page has no buffers then it is either fully uptodate or fully
  not uptodate.  In the former case, don't call readpage at all.  In the
  latter case, readpage() is the correct thing to do.

- If the page had buffers, then readpage() won't touch the uptodate ones
  and will bring the non-uptodate ones up to date from disk.

  Some of the data which we copied from userspace may get overwritten
  from backing store, but that's OK.

seems crazy, but it's close.  We do have the minor problem that readpage
went and unlocked the page so we need to relock it.  I bet there are holes
in there.




Idea #42: after we've locked the pagecache page, do an atomic get_user()
against the source page(s) before attempting the copy_from_user().  If that
faults, don't run prepare_write or anything else: drop the page lock and
try again.

Because

- If the get_user() faults, it might be because the page we're copying
  from and to is the same page, and someone went and unmapped it: deadlock.

- If the get_user() doesn't fault, and if we're copying from and to the
  same page, we know that we've locked it, so nobody will be able to unmap
  it while we're copying from it.

Close, but no cigar!  This is still vulnerable to Hugh's ab/ba deadlock
scenario.


btw, to fix the writev() performance problem we may need to go off and run
get_user() against up to 1024 separate user pages before locking the
pagecache page, which sounds fairly idiotic.  Are you doing that in the
implemetnations which you've been working on?  I forget...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
