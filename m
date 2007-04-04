Date: Wed, 4 Apr 2007 17:44:21 +0300
From: Dan Aloni <da-x@monatomic.org>
Subject: Re: [rfc] no ZERO_PAGE?
Message-ID: <20070404144421.GA13762@localdomain>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704041023040.17341@blonde.wat.veritas.com> <20070404102407.GA529@wotan.suse.de> <20070404122701.GB19587@v2.random> <20070404135530.GA29026@localdomain> <20070404141457.GF19587@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070404141457.GF19587@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 04:14:57PM +0200, Andrea Arcangeli wrote:
> On Wed, Apr 04, 2007 at 04:55:32PM +0300, Dan Aloni wrote:
> > How about applications that perform mmap() and R/W random-access on 
> > large *sparse* files? (e.g. a scientific app that uses a large sparse 
> > file as a big database look-up table). As I see it, these apps would
> > need to keep track of what's sparse and what's not...
> 
> That's not anonymous memory if those are read page faults on
> _files_. I'm only talking about anonymous memory and
> do_anonymous_page, i.e. no file data at all. In more clear words, the
> only thing we're discussing here is char = malloc(1); *char.
>
> Your example _already_ allocates zeroed pagecache instead of the zero
> page, so your example (random access over sparse files with mmap, be
> it MAP_PRIVATE or MAP_SHARED no difference for reads) has never had
> anything to do with the zero page. If something we could optimize your
> example to _start_ using for the first time ever the ZERO_PAGE, it
> would make more sense to use it to be mapped where the lowlevel fs
> finds holes. ZERO_PAGE in do_anonymous_page instead doesn't make much
> sense to me, but it has always been there as far as I can
> remember. The thing is that it never hurted until the huge systems
> with nightmare cacheline bouncing reported heavy stalls on some
> testcase, which make it look like a DoS because of the ZERO_PAGE,
> hence now that it hurts I guess it can go.

Oh, right. Thanks for clarifing. I should have figured it out before 
I sent that mail.

To refine that example, you could replace the file with a large anonymous 
memory pool and a lot of swap space committed to it. In that case - with 
no ZERO_PAGE, would the kernel needlessly swap-out the zeroed pages? 
Perhaps it's an example too far-fetched to worth considering...

-- 
Dan Aloni
XIV LTD, http://www.xivstorage.com
da-x (at) monatomic.org, dan (at) xiv.co.il

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
