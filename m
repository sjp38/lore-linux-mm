Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85E878E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 11:08:56 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id v7so9026801ywv.1
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 08:08:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o13-v6sor6699023ybq.186.2018.12.11.08.08.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 08:08:55 -0800 (PST)
Date: Tue, 11 Dec 2018 11:08:53 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 3/4] filemap: drop the mmap_sem for all blocking
 operations
Message-ID: <20181211160851.hqezlvlded6zujrm@macbook-pro-91.dhcp.thefacebook.com>
References: <20181130195812.19536-1-josef@toxicpanda.com>
 <20181130195812.19536-4-josef@toxicpanda.com>
 <20181207110138.GE13008@quack2.suse.cz>
 <20181210184438.va7mdwjgwndgri4s@macbook-pro-91.dhcp.thefacebook.com>
 <20181211094034.GD17539@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211094034.GD17539@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <josef@toxicpanda.com>, kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com

On Tue, Dec 11, 2018 at 10:40:34AM +0100, Jan Kara wrote:
> On Mon 10-12-18 13:44:39, Josef Bacik wrote:
> > On Fri, Dec 07, 2018 at 12:01:38PM +0100, Jan Kara wrote:
> > > On Fri 30-11-18 14:58:11, Josef Bacik wrote:
> > > > @@ -2433,9 +2458,32 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
> > > >  			return vmf_error(-ENOMEM);
> > > >  	}
> > > >  
> > > > -	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
> > > > -		put_page(page);
> > > > -		return ret | VM_FAULT_RETRY;
> > > > +	/*
> > > > +	 * We are open-coding lock_page_or_retry here because we want to do the
> > > > +	 * readpage if necessary while the mmap_sem is dropped.  If there
> > > > +	 * happens to be a lock on the page but it wasn't being faulted in we'd
> > > > +	 * come back around without ALLOW_RETRY set and then have to do the IO
> > > > +	 * under the mmap_sem, which would be a bummer.
> > > > +	 */
> > > 
> > > Hum, lock_page_or_retry() has two callers and you've just killed one. I
> > > think it would be better to modify the function to suit both callers rather
> > > than opencoding? Maybe something like lock_page_maybe_drop_mmap() which
> > > would unconditionally acquire the lock and return whether it has dropped
> > > mmap sem or not? Callers can then decide what to do.
> > > 
> > 
> > I tried this, but it ends up being convoluted, since swap doesn't have a file to
> > pin we have to add extra cases for that, and then change the return value to
> > indicate wether we locked the page _and_ dropped the mmap sem, or just locked
> > the page, etc.  It didn't seem the extra complication, so I just broke the open
> > coding out into its own helper.
> 
> OK. Thanks for looking into this!
> 
> > > BTW I'm not sure this complication is really worth it. The "drop mmap_sem
> > > for IO" is never going to be 100% thing if nothing else because only one
> > > retry is allowed in do_user_addr_fault(). So the second time we get to
> > > filemap_fault(), we will not have FAULT_FLAG_ALLOW_RETRY set and thus do
> > > blocking locking. So I think your code needs to catch common cases you
> > > observe in practice but not those super-rare corner cases...
> > 
> > I had counters in all of these paths because I was sure some things weren't
> > getting hit at all, but it turns out each of these cases gets hit with
> > surprisingly high regularity. 
> 
> Cool! Could you share these counters? I'd be curious and they'd be actually
> nice as a motivation in the changelog of this patch to show the benefit.
> 

Hmm I can't seem to find anything other than the scratch txt file I had to keep
track of stuff, but the un-labeled numbers are 18953 and 879.  I assume the
largest number is the times we went through the readpage path where we weren't
doing any mmap_sem dropping and the 879 was for the lock_page path, but I have
no way of knowing at this point.

> > The lock_page_or_retry() case in particular gets hit a lot with
> > multi-threaded applications that got paged out because of heavy memory
> > pressure.  By no means is it as high as just the normal readpage or
> > readahead cases, but it's not 0, so I'd rather have the extra helper here
> > to make sure we're never getting screwed.
> 
> Do you mean the case where we the page is locked in filemap_fault() (so
> that lock_page_or_retry() bails after waiting) and when the page becomes
> unlocked it is not uptodate? Because that is the reason why you opencode
> lock_page_or_retry(), right? I'm not aware of any normal code path that
> would create page in page cache and not try to fill it with data before
> unlocking it so that's why I'm really trying to make sure we understand
> each other.

Uhh so that's embarressing.  We have an internal patchset that I thought was
upstream but hasn't come along yet.  Basically before this patchset the way we
dealt with this problem was to short-circuit readahead IO's by checking to see
if the blkcg was congested (or if there was a fatal signal pending) and doing 
bio_wouldblock_error on the bio.  So this very case came up a lot, readahead
would go through because it got in before we were congested, but would then get
throttled, and then once the throttling was over would get aborted.  Other
threads would run into these pages that had been locked, but they are never read
in which means they waited for the lock to be dropped, did the VM_FAULT_RETRY,
came back unable to drop the mmap_sem and did the actual readpage() and would
get throttled.

This means this particular part of the patch isn't helpful for upstream at the
moment, but now that I know these patches aren't upstream yet that'll be my next
project, so I'd like to keep this bit here as it is.  Thanks,

Josef
