Date: Tue, 6 Feb 2007 05:41:46 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-ID: <20070206044146.GA11856@wotan.suse.de>
References: <20070204014445.88e6c8c7.akpm@linux-foundation.org> <20070204101529.GA22004@wotan.suse.de> <20070204023055.2583fd65.akpm@linux-foundation.org> <20070204104609.GA29943@wotan.suse.de> <20070204025602.a5f8c53a.akpm@linux-foundation.org> <20070204110317.GA9034@wotan.suse.de> <20070204031549.203f7b47.akpm@linux-foundation.org> <20070204151051.GB12771@wotan.suse.de> <20070204103620.33c24cad.akpm@linux-foundation.org> <20070206022549.GB31476@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070206022549.GB31476@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 06, 2007 at 03:25:49AM +0100, Nick Piggin wrote:
> On Sun, Feb 04, 2007 at 10:36:20AM -0800, Andrew Morton wrote:
> > On Sun, 4 Feb 2007 16:10:51 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > They're not likely to hit the deadlocks, either. Probability gets more
> > > likely after my patch to lock the page in the fault path. But practially,
> > > we could live without that too, because the data corruption it fixes is
> > > very rare as well. Which is exactly what we've been doing quite happily
> > > for most of 2.6, including all distro kernels (I think).
> > 
> > Thing is, an application which is relying on the contents of that page is
> > already unreliable (or really peculiar), because it can get indeterminate
> > results anyway.
> 
> Not necessarily -- they could read from one part of a page and write to
> another. I see this as the biggest data corruption problem.

And in fact, it is not just transient errors either. This problem can
add permanent corruption into the pagecache and onto disk, and it doesn't
even require two processes to race.

After zeroing out the uncopied part of the page, and attempting to loop
again, we might bail out of the loop for any reason before completing the
rest of the copy, leaving the pagecache corrupted, which will soon go out
to disk.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
