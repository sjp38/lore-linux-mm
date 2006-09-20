Subject: Re: [RFC] page fault retry with NOPAGE_RETRY
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20060919165906.3d641236.akpm@osdl.org>
References: <1158274508.14473.88.camel@localhost.localdomain>
	 <20060915001151.75f9a71b.akpm@osdl.org> <45107ECE.5040603@google.com>
	 <1158709835.6002.203.camel@localhost.localdomain>
	 <20060919165906.3d641236.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 20 Sep 2006 10:06:46 +1000
Message-Id: <1158710807.6002.219.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mike Waychison <mikew@google.com>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-09-19 at 16:59 -0700, Andrew Morton wrote:
> On Wed, 20 Sep 2006 09:50:35 +1000
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > On Tue, 2006-09-19 at 16:35 -0700, Mike Waychison wrote:
> > > Patch attached.
> > > 
> > > As Andrew points out, the logic is a bit hacky and using a flag in 
> > > current->flags to determine whether we have done the retry or not already.
> > > 
> > > I too think the right approach to being able to handle these kinds of 
> > > retries in a more general fashion is to introduce a struct 
> > > pagefault_args along the page faulting path.  Within it, we could 
> > > introduce a reason for the retry so the higher levels would be able to 
> > > better understand what to do.
> > 
> >  .../...
> > 
> > I need to re-read your mail and Andrew as at this point, I don't quite
> > see why we need that args and/or that current->flags bit instead of
> > always returning all the way to userland and let the faulting
> > instruction happen again (which means you don't block in the kernel, can
> > take signals etc...
> 
> That would amount to a busy wait, waiting for the disk IO to complete.
> 
> So we need to go to sleep somewhere (in D state, because we _are_ waiting
> for disk IO).  Returning all the way to userspace and immediately retaking
> the fault is unneeded extra work.

No, I'm not saying immediately... you do the wait thing in filemap.c.
Anyway, see my other message.

> > thus do you actually need to prevent multiple
> > retries ?)
> 
> I expect there are livelock scenarios.  For example, process A could spin
> on posix_fadvise(some libc text page, POSIX_FADV_DONTNEED), perhaps causing
> other applications to get permanently stuck in the kernel.

Unless you add a way to handle signals.. see my other mail.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
