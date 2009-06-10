Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA896B004F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 07:15:17 -0400 (EDT)
Date: Wed, 10 Jun 2009 13:15:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [0/16] HWPOISON: Intro
Message-ID: <20090610111541.GC3876@wotan.suse.de>
References: <20090603846.816684333@firstfloor.org> <20090609102014.GG14820@wotan.suse.de> <20090610090703.GF6597@localhost> <20090610091807.GA18582@wotan.suse.de> <20090610094526.GB32584@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090610094526.GB32584@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 05:45:26PM +0800, Wu Fengguang wrote:
> On Wed, Jun 10, 2009 at 05:18:07PM +0800, Nick Piggin wrote:
> > On Wed, Jun 10, 2009 at 05:07:03PM +0800, Wu Fengguang wrote:
> > > On Tue, Jun 09, 2009 at 06:20:14PM +0800, Nick Piggin wrote:
> > > > On Wed, Jun 03, 2009 at 08:46:31PM +0200, Andi Kleen wrote:
> > > > > Also I thought a bit about the fsync() error scenario. It's really
> > > > > a problem that can already happen even without hwpoison, e.g.
> > > > > when a page is dropped at the wrong time.
> > > > 
> > > > No, the page will never be "dropped" like that except with
> > > > this hwpoison. Errors, sure, might get dropped sometimes
> > > > due to implementation bugs, but this is adding semantics that
> > > > basically break fsync by-design.
> > > 
> > > You mean the non persistent EIO is undesirable?
> > > 
> > > In the other hand, sticky EIO that can only be explicitly cleared by
> > > user can also be annoying. How about auto clearing the EIO bit when
> > > the last active user closes the file?
> > 
> > Well the existing EIO semantics IMO are not great, but that
> > does not have a big bearing on this new situation. What you
> 
> Nod.
> 
> > are doing is deliberately throwing away the dirty data, and
> > giving EIO back in some cases. (but perhaps not others, a
> > subsequent read or write syscall is not going to get EIO is
> > it? only fsync).
> 
> Right, only fsync/msync and close on nfs will report the error.
> 
> write() is normally cached, so obviously it cannot report the later IO
> error.
> 
> We can make read() IO succeed even if the relevant pages are corrupted
> - they can be isolated transparent to user space readers :-)

But if the page was dirty and you throw out the dirty data,
then next read will give inconsistent data.

 
> > So even if we did change existing EIO semantics then the
> > memory corruption case of throwing away dirty data is still
> > going to be "different" (wrong, I would say).
> 
> Oh well.

Well I just think SIGKILL is the much safer behaviour to
start with (and matches behaviour with mmapped pagecache
and anon), and does not introduce these different semantics.

 
> > > > I really want to resolve the EIO issue because as I said, it
> > > > is a user-abi issue and too many of those just get shoved
> > > > through only for someone to care about fundamental breakage
> > > > after some years.
> > > 
> > > Yup.
> > > 
> > > > You say that SIGKILL is overkill for such pages, but in fact
> > > > this is exactly what you do with mapped pages anyway, so why
> > > > not with other pages as well? I think it is perfectly fine to
> > > > do so (and maybe a new error code can be introduced and that
> > > > can be delivered to processes that can handle it rather than
> > > > SIGKILL).
> > > 
> > > We can make it a user selectable policy.
> >  
> > Really? Does it need to be? Can the admin sanely make that
> > choice?
> 
> I just recalled another fact. See below.
> 
> > > They are different in that, mapped dirty pages are normally more vital
> > > (data structures etc.) for correct execution, while write() operates
> > > more often on normal data.
> > 
> > read and write, remember. That might be somewhat true, but
> > definitely there are exceptions both ways. How do you
> > quantify that or justify it? Just handwaving? Why not make
> > it more consistent overall and just do SIGKILL for everyone?
> 
> 1) under read IO hwpoison pages can be hidden to user space

I mean for cases where the recovery cannot be transparent
(ie. error in dirty page).


> 2) under write IO hwpoison pages are normally committed by pdflush,
>    so cannot find the impacted application to kill at all.

Correct.

> 3) fsync() users can be caught though. But then the application
>    have the option to check its return code. If it doesn't do it,
>    it may well don't care. So why kill it?

Well if it does not check, then we cannot find it to kill
it anyway. If it does care (and hence check with fsync),
then we could kill it.

 
> Think about a multimedia server. Shall we kill the daemon if some IO
> page in the movie get corrupted?

My multimedia server is using mmap for data...

> And a mission critical server? 

Mission critical server should be killed too because it
likely does not understand this semantic of throwing out
dirty data page. It should be detected and restarted and
should recover or fail over to another server.


> Obviously the admin will want the right to choose.

I don't know if they are equipped to really know. Do they
know that their application will correctly handle these
semantics of throwing out dirty data? It is potentially
much more dangerous to do this exactly because it can confuse
the case where it matters most (ie. ones that care about
data integrity).

It just seems like killing is far less controversial and
simpler. Start with that and it should do the right thing
for most people anyway. We could discuss possible ways
to recover in another patch if you want to do this
EIO thing.

 
> > > > Last request: do you have a panic-on-memory-error option?
> > > > I think HA systems and ones with properly designed data
> > > > integrity at the application layer will much prefer to
> > > > halt the system than attempt ad-hoc recovery that does not
> > > > always work and might screw things up worse.
> > > 
> > > Good suggestion. We'll consider such an option. But unconditionally
> > > panic may be undesirable. For example, a corrupted free page or a
> > > clean unmapped file page can be simply isolated - they won't impact
> > > anything.
> > 
> > I thought you were worried about introducing races where the
> > data can be consumed when doing things such as lock_page and
> > wait_on_page_writeback. But if things can definitely be
> > discarded with no references or chances of being consumed, yes
> > you would not panic for that. But panic for dirty data or
> > corrupted kernel memory etc. makes a lot of sense.
> 
> OK. We can panic on dirty/writeback pages, and do try_lock to check
> for active users :)

That would be good. IMO panic should be the safest and sanest
option (admin knows exactly what it is and has very simple and
clear semantics).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
