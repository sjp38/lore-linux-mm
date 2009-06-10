Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CFE0F6B004F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 05:17:38 -0400 (EDT)
Date: Wed, 10 Jun 2009 11:18:07 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [0/16] HWPOISON: Intro
Message-ID: <20090610091807.GA18582@wotan.suse.de>
References: <20090603846.816684333@firstfloor.org> <20090609102014.GG14820@wotan.suse.de> <20090610090703.GF6597@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090610090703.GF6597@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 05:07:03PM +0800, Wu Fengguang wrote:
> On Tue, Jun 09, 2009 at 06:20:14PM +0800, Nick Piggin wrote:
> > On Wed, Jun 03, 2009 at 08:46:31PM +0200, Andi Kleen wrote:
> > > Also I thought a bit about the fsync() error scenario. It's really
> > > a problem that can already happen even without hwpoison, e.g.
> > > when a page is dropped at the wrong time.
> > 
> > No, the page will never be "dropped" like that except with
> > this hwpoison. Errors, sure, might get dropped sometimes
> > due to implementation bugs, but this is adding semantics that
> > basically break fsync by-design.
> 
> You mean the non persistent EIO is undesirable?
> 
> In the other hand, sticky EIO that can only be explicitly cleared by
> user can also be annoying. How about auto clearing the EIO bit when
> the last active user closes the file?

Well the existing EIO semantics IMO are not great, but that
does not have a big bearing on this new situation. What you
are doing is deliberately throwing away the dirty data, and
giving EIO back in some cases. (but perhaps not others, a
subsequent read or write syscall is not going to get EIO is
it? only fsync).

So even if we did change existing EIO semantics then the
memory corruption case of throwing away dirty data is still
going to be "different" (wrong, I would say).

 
> > I really want to resolve the EIO issue because as I said, it
> > is a user-abi issue and too many of those just get shoved
> > through only for someone to care about fundamental breakage
> > after some years.
> 
> Yup.
> 
> > You say that SIGKILL is overkill for such pages, but in fact
> > this is exactly what you do with mapped pages anyway, so why
> > not with other pages as well? I think it is perfectly fine to
> > do so (and maybe a new error code can be introduced and that
> > can be delivered to processes that can handle it rather than
> > SIGKILL).
> 
> We can make it a user selectable policy.
 
Really? Does it need to be? Can the admin sanely make that
choice?


> They are different in that, mapped dirty pages are normally more vital
> (data structures etc.) for correct execution, while write() operates
> more often on normal data.

read and write, remember. That might be somewhat true, but
definitely there are exceptions both ways. How do you
quantify that or justify it? Just handwaving? Why not make
it more consistent overall and just do SIGKILL for everyone?
 

> > Last request: do you have a panic-on-memory-error option?
> > I think HA systems and ones with properly designed data
> > integrity at the application layer will much prefer to
> > halt the system than attempt ad-hoc recovery that does not
> > always work and might screw things up worse.
> 
> Good suggestion. We'll consider such an option. But unconditionally
> panic may be undesirable. For example, a corrupted free page or a
> clean unmapped file page can be simply isolated - they won't impact
> anything.

I thought you were worried about introducing races where the
data can be consumed when doing things such as lock_page and
wait_on_page_writeback. But if things can definitely be
discarded with no references or chances of being consumed, yes
you would not panic for that. But panic for dirty data or
corrupted kernel memory etc. makes a lot of sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
