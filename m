Date: Tue, 6 Feb 2007 06:49:05 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-ID: <20070206054905.GC16647@wotan.suse.de>
References: <20070204023055.2583fd65.akpm@linux-foundation.org> <20070204104609.GA29943@wotan.suse.de> <20070204025602.a5f8c53a.akpm@linux-foundation.org> <20070204110317.GA9034@wotan.suse.de> <20070204031549.203f7b47.akpm@linux-foundation.org> <20070204151051.GB12771@wotan.suse.de> <20070204103620.33c24cad.akpm@linux-foundation.org> <20070206022549.GB31476@wotan.suse.de> <20070206044146.GA11856@wotan.suse.de> <20070205213006.0ea2d918.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070205213006.0ea2d918.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 05, 2007 at 09:30:06PM -0800, Andrew Morton wrote:
> On Tue, 6 Feb 2007 05:41:46 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > 
> > > Not necessarily -- they could read from one part of a page and write to
> > > another. I see this as the biggest data corruption problem.
> 
> The kernel gets that sort of thing wrong anyway, and always has, because
> it uses memcpy()-style copying and not memmove()-style.
> 
> I can't imagine what sort of application you're envisaging here.  The
> problem was only ever observed from userspace by an artificial stress-test
> thing.

No, I'm not talking about writing into a page with memory from the same
page. I'm talking about one process writing to part of a file, and another
reading from that same file (different offset).

If they happen to be covered by the same page, then the reader can see
zeroes.

I'm not envisaging any sort of application, all I know is that there are
several (related) data corruption bugs and I'm trying to fix them (and
fix these deadlock problems without introducing more).

> > And in fact, it is not just transient errors either. This problem can
> > add permanent corruption into the pagecache and onto disk, and it doesn't
> > even require two processes to race.
> > 
> > After zeroing out the uncopied part of the page, and attempting to loop
> > again, we might bail out of the loop for any reason before completing the
> > rest of the copy, leaving the pagecache corrupted, which will soon go out
> > to disk.
> > 
> 
> Only because ->commit_write() went and incorrectly marked parts of the page
> as up-to-date.
> 
> Zeroing out the fag end of the copy_from_user() on fault is actually incorrect. 

Yes, I know.

> What we _should_ do is to bring those uncopyable, non-uptodate parts of the
> page uptodate rather than zeroing them.  ->readpage() does that.
> 
> So...  what happens if we do
> 
> 	lock_page()
> 	prepare_write()
> 	if (copy_from_user_atomic()) {
> 		readpage()
> 		wait_on_page()
> 		lock_page()
> 	}
> 	commit_write()
> 	unlock_page()
> 
> - If the page has no buffers then it is either fully uptodate or fully
>   not uptodate.  In the former case, don't call readpage at all.  In the
>   latter case, readpage() is the correct thing to do.
> 
> - If the page had buffers, then readpage() won't touch the uptodate ones
>   and will bring the non-uptodate ones up to date from disk.
> 
>   Some of the data which we copied from userspace may get overwritten
>   from backing store, but that's OK.
> 
> seems crazy, but it's close.  We do have the minor problem that readpage
> went and unlocked the page so we need to relock it.  I bet there are holes
> in there.

Yes, I tried doing this as well and there are holes in it. Even supposing
that we add a readpage_dontunlock, there is still the issue of breaking
the filesystem API from nesting readpage inside prepare_write. You also
do need to zero newly allocated blocks, for example.

> Idea #42: after we've locked the pagecache page, do an atomic get_user()
> against the source page(s) before attempting the copy_from_user().  If that
> faults, don't run prepare_write or anything else: drop the page lock and
> try again.
> 
> Because
> 
> - If the get_user() faults, it might be because the page we're copying
>   from and to is the same page, and someone went and unmapped it: deadlock.
> 
> - If the get_user() doesn't fault, and if we're copying from and to the
>   same page, we know that we've locked it, so nobody will be able to unmap
>   it while we're copying from it.
> 
> Close, but no cigar!  This is still vulnerable to Hugh's ab/ba deadlock
> scenario.

Yes I considered this too. Hard isn't it?

> btw, to fix the writev() performance problem we may need to go off and run
> get_user() against up to 1024 separate user pages before locking the
> pagecache page, which sounds fairly idiotic.  Are you doing that in the
> implemetnations which you've been working on?  I forget...

No, because in my fix it can do non-atomic usercopies for !uptodate pages.

For uptodate pages, yes there is a possibility that it may do a short copy
and have to retry, but it is probably safe to bet that the source data is
fairly recently accessed in most cases, so a short copy will be unlikely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
