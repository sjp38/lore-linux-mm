Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id F3B636B0044
	for <linux-mm@kvack.org>; Sat, 11 Aug 2012 17:14:54 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] HWPOISON: improve handling/reporting of memory error on dirty pagecache
Date: Sat, 11 Aug 2012 17:14:34 -0400
Message-Id: <1344719674-7267-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <m21ujdd6it.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Sat, Aug 11, 2012 at 04:15:06AM -0700, Andi Kleen wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
> I'm sceptical on the patch, but here's my review.

Thank you for taking your time for the review.

> >   - return -EHWPOISON when we access to the error-affected address with
> >     read(), partial-page write(), fsync(),
> 
> Note that a lot of user space does not like new errnos (nothing in
> strerror etc.). It's probably better to reuse some existing errno.

I'm OK to use EIO if user space can know that it comes from memory errors.
The reason why I thought that user space should distinguish it from IO errors
is that the possible responses of user space for memory errors are different
from those for IO errors, considering that we can recover from memory errors
with overwriting. OTOH what user space can do for IO errors is to wait for
IO devices to recover by itself and retry, to change the IO's target to
another device, or something like that.

> > @@ -270,6 +273,9 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
> >  	if (end_byte < start_byte)
> >  		return 0;
> >  
> > +	if (unlikely(hwpoison_file_range(mapping, start_byte, end_byte)))
> > +		return -EHWPOISON;
> > +
> 
> That function uses a global lock. fdatawait is quite common. This will
> likely cause performance problems in IO workloads.

OK, I should avoid it.

> You need to get that lock out of the hot path somehow.
> 
> Probably better to try to put the data into a existing data structure,
> or if you cannot do that you would need some way to localize the lock.

Yes, I have thought about adding some data like new pagecache tag or
new members in struct address_space, but it makes the size of heavily
used data structure larger so I'm not sure it's acceptable.
And localizing the lock is worth trying, I think.

> Or at least make it conditional of hwpoison errors being around. 

I'll try to do your suggestions, but I'm not sure your point of the
last one. Can you explain more about 'make it conditional' option?

> 
> 
> >  	pagevec_init(&pvec, 0);
> >  	while ((index <= end) &&
> >  			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
> > @@ -369,6 +375,16 @@ int filemap_write_and_wait_range(struct address_space *mapping,
> >  				err = err2;
> >  		}
> >  	}
> > +
> > +	/*
> > +	 * When AS_HWPOISON is set, dirty page with memory error is
> > +	 * removed from pagecache and mapping->nrpages is decreased by 1.
> > +	 * So in order to detect memory error on single page file, we need
> > +	 * to check AS_HWPOISON bit outside if(mapping->nrpages) block below.
> > +	 */
> > +	if (unlikely(hwpoison_file_range(mapping, lstart, lend)))
> > +		return -EHWPOISON;
> 
> Same here.
> >  					ra, filp, page,
> > @@ -2085,6 +2123,9 @@ inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, i
> >          if (unlikely(*pos < 0))
> >                  return -EINVAL;
> >  
> > +	if (unlikely(hwpoison_partial_write(file->f_mapping, *pos, *count)))
> > +		return -EHWPOISON;
> 
> Same here.
> > +
> > +		/*
> > +		 * Memory error is reported to userspace by AS_HWPOISON flags
> > +		 * in mapping->flags. The mechanism is similar to that of
> > +		 * AS_EIO, but we have separete flags because there'are two
> > +		 * differences between them:
> > +		 *  1. Expected userspace handling. When user processes get
> > +		 *     -EIO, they can retry writeback hoping the error in IO
> > +		 *     devices is temporary, switch to write to other devices,
> > +		 *     or do some other application-specific handling.
> > +		 *     For -EHWPOISON, we can clear the error by overwriting
> > +		 *     the corrupted page.
> > +		 *  2. When to clear. For -EIO, we can think that we recover
> > +		 *     from the error when writeback succeeds. For -EHWPOISON
> > +		 *     OTOH, we can see that things are back to normal when
> > +		 *     corrupted data are overwritten from user buffer.
> > +		 */
> > +		hwp = kmalloc(sizeof(struct hwp_dirty), GFP_ATOMIC);
> 
> You need to check the return value, especially for GFP_ATOMIC which is
> common to fail

OK, I'll fix it.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
