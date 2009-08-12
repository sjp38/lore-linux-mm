Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C2E256B005A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 04:05:41 -0400 (EDT)
Date: Wed, 12 Aug 2009 10:05:40 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for migration aware file systems
Message-ID: <20090812080540.GA32342@wotan.suse.de>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org> <4A7FBFD1.2010208@hitachi.com> <20090810074421.GA6838@basil.fritz.box> <4A80EAA3.7040107@hitachi.com> <20090811071756.GC14368@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090811071756.GC14368@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>, tytso@mit.edu, hch@infradead.org, mfasheh@suse.com, aia21@cantab.net, hugh.dickins@tiscali.co.uk, swhiteho@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 11, 2009 at 09:17:56AM +0200, Andi Kleen wrote:
> On Tue, Aug 11, 2009 at 12:50:59PM +0900, Hidehiro Kawai wrote:
> > > And application
> > > that doesn't handle current IO errors correctly will also
> > > not necessarily handle hwpoison correctly (it's not better and not worse)
> > 
> > This is my main concern.  I'd like to prevent re-corruption even if
> > applications don't have good manners.
> 
> I don't think there's much we can do if the application doesn't
> check for IO errors properly. What would you do if it doesn't
> check for IO errors at all? If it checks for IO errors it simply
> has to check for them on all IO operations -- if they do 
> they will detect hwpoison errors correctly too.

But will quite possibly do the wrong thing: ie. try to re-sync the
same page again, or try to write the page to a new location, etc.

This is the whole problem with -EIO semantics I brought up.
 

> > That is why I suggested this:
> > >>(2) merge this patch with new panic_on_dirty_page_cache_corruption
> 
> You probably mean panic_on_non_anonymous_dirty_page_cache
> Normally anonymous memory is dirty.
> 
> > >>    sysctl
> 
> It's unclear to me this special mode is really desirable.
> Does it bring enough value to the user to justify the complexity
> of another exotic option?  The case is relatively exotic,
> as in dirty write cache that is mapped to a file.
> 
> Try to explain it in documentation and you see how ridiculous it sounds; u
> it simply doesn't have clean semantics
> 
> ("In case you have applications with broken error IO handling on
> your mission critical system ...") 

Not broken error handling. It is very simple: if the application is
assuming EIO is an error with dirty data being sent to disk, rather
than an error with the data itself (which I think may be a common
assumption). Then it could have a problem.

If a database for example tries to write the data to another location
in response to EIO and then record it in a list of failed IOs before
halting the database. Then if it restarts it might try to again try
writing out these failed IOs (eg. give the administrator a chance to
fix IO devices). Completely made up scenario but it is not outlandish
and it would cause bad data corruption.

A mission critical server will *definitely* want to panic on dirty
page corruption, IMO, because by definition they should be able to
tolerate panic. But if they do not know about this change to -EIO
semantics, then it is quite possible to cause problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
