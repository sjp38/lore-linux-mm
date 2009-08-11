Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E64C66B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 03:17:53 -0400 (EDT)
Date: Tue, 11 Aug 2009 09:17:56 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for
	migration aware file systems
Message-ID: <20090811071756.GC14368@basil.fritz.box>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org> <4A7FBFD1.2010208@hitachi.com> <20090810074421.GA6838@basil.fritz.box> <4A80EAA3.7040107@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A80EAA3.7040107@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, tytso@mit.edu, hch@infradead.org, mfasheh@suse.com, aia21@cantab.net, hugh.dickins@tiscali.co.uk, swhiteho@redhat.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 11, 2009 at 12:50:59PM +0900, Hidehiro Kawai wrote:
> > And application
> > that doesn't handle current IO errors correctly will also
> > not necessarily handle hwpoison correctly (it's not better and not worse)
> 
> This is my main concern.  I'd like to prevent re-corruption even if
> applications don't have good manners.

I don't think there's much we can do if the application doesn't
check for IO errors properly. What would you do if it doesn't
check for IO errors at all? If it checks for IO errors it simply
has to check for them on all IO operations -- if they do 
they will detect hwpoison errors correctly too.

> As for usual I/O error, ext3/4 can now do it by using data=ordered and
> data_err=abort mount options.  Moreover, if you mount the ext3/4
> filesystem with the additional errors=panic option, kernel gets
> panic on write error instead of read-only remount.  Customers
> who regard data integrity is very important require these features.

Well they can also set vm.memory_failure_recovery = 0 then if they don't
care about their uptime. 

> That is why I suggested this:
> >>(2) merge this patch with new panic_on_dirty_page_cache_corruption

You probably mean panic_on_non_anonymous_dirty_page_cache
Normally anonymous memory is dirty.

> >>    sysctl

It's unclear to me this special mode is really desirable.
Does it bring enough value to the user to justify the complexity
of another exotic option?  The case is relatively exotic,
as in dirty write cache that is mapped to a file.

Try to explain it in documentation and you see how ridiculous it sounds; u
it simply doesn't have clean semantics

("In case you have applications with broken error IO handling on
your mission critical system ...") 

> > I'm sure other enhancements for IO errors could be done too.
> > Some of the file systems also handle them still quite poorly (e.g. btrfs)
> > 
> > But again I don't think it's a blocker for hwpoison.
> 
> Unfortunately, it can be a blocker.  As I stated, we can block the
> possible re-corruption caused by transient IO errors on ext3/4
> filesystems.  But applying this patch (PATCH 16/19), re-corruption
> can happen even if we use data=ordered, data_err=abort and
> errors=panic mount options.

We don't corrupt data on disk. Applications
that don't check for IO errors correctly may see stale data
from the same file on disk though.

This can happen in all the cases you listed above except for panic-on-error.

If you want panic-on-error behaviour simply set vm.memory_failure_recovery = 0


> > (4) accept that hwpoison error handling is not better and not worse than normal
> > IO error handling.
> > 
> > We opted for (4).
> 
> Could you consider adopting (2) or (3)?  Fengguang's sticky EIO
> approach (http://lkml.org/lkml/2009/6/11/294) is also OK.

I believe redesigned IO error handling does not belong in the 
core hwpoison patchkit. It's big enough as it is and I consider it frozen
unless fatal bugs are found -- and frankly this is not a fatal 
error in my estimation.

If you want to have improved IO error handling feel free to
submit it separately. I agree this area could use some work.
But it probably needs more design work first.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
