Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 9A2F26B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 17:45:19 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2 v2] mm: print out information of file affected by memory error
Date: Tue,  6 Nov 2012 17:45:05 -0500
Message-Id: <1352241905-4657-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20121106121220.d14696ac.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Tue, Nov 06, 2012 at 12:12:20PM -0800, Andrew Morton wrote:
> On Tue,  6 Nov 2012 00:07:53 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > On Mon, Nov 05, 2012 at 02:01:54PM -0800, Andrew Morton wrote:
> > > On Fri,  2 Nov 2012 12:33:13 -0400
> > > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > > 
> > > > Printing out the information about which file can be affected by a
> > > > memory error in generic_error_remove_page() is helpful for user to
> > > > estimate the impact of the error.
> > > > 
> > > > Changelog v2:
> > > >   - dereference mapping->host after if (!mapping) check for robustness
> > > > 
> > > > ...
> > > >
> > > > --- v3.7-rc3.orig/mm/truncate.c
> > > > +++ v3.7-rc3/mm/truncate.c
> > > > @@ -151,14 +151,20 @@ int truncate_inode_page(struct address_space *mapping, struct page *page)
> > > >   */
> > > >  int generic_error_remove_page(struct address_space *mapping, struct page *page)
> > > >  {
> > > > +	struct inode *inode;
> > > > +
> > > >  	if (!mapping)
> > > >  		return -EINVAL;
> > > > +	inode = mapping->host;
> > > >  	/*
> > > >  	 * Only punch for normal data pages for now.
> > > >  	 * Handling other types like directories would need more auditing.
> > > >  	 */
> > > > -	if (!S_ISREG(mapping->host->i_mode))
> > > > +	if (!S_ISREG(inode->i_mode))
> > > >  		return -EIO;
> > > > +	pr_info("MCE %#lx: file info pgoff:%lu, inode:%lu, dev:%s\n",
> > > > +		page_to_pfn(page), page_index(page),
> > > > +		inode->i_ino, inode->i_sb->s_id);
> > > >  	return truncate_inode_page(mapping, page);
> > > >  }
> > > >  EXPORT_SYMBOL(generic_error_remove_page);
> > > 
> > > A couple of things.
> > > 
> > > - I worry that if a hardware error occurs, it might affect a large
> > >   amount of memory all at the same time.  For example, if a 4G memory
> > >   block goes bad, this message will be printed a million times?
> > 
> > If the error on 4G memory block triggered by SRAO MCE and these 1M pages
> > are all pagecache pages, the answer is yes.
> 
> Well that's bad.
> 
> > But I think that if it's a whole DIMM error, it should be reported by
> > another type of MCE than SRAO, so printing a million times seems to be
> > unlikely to happen.
> 
> "should be" and "unlikely" aren't very reassuring things to hear! 
> Emitting a million lines into syslog is pretty poor behaviour and
> should be reliably avoided.

So capping maximum lines of messages per some duration (a hour or a day)
is a possible option. BTW, even if we don't apply this patch, the kernel
can emit million lines of messages in the above-mentioned situation because
each memory error event emits a message like "MCE 0x3f57f4: dirty LRU page
recovery: Ignored" on syslog. If it's also bad, we need to do capping
also over existing printk()s, right?

> > > - hard-wiring "MCE" in here seems a bit of a layering violation? 
> > >   What right does the generic, core .error_remove_page() implementation
> > >   have to assume that it was called because of an MCE?
> > 
> > OK, we need not assume that. I change "MCE " prefix to more specific
> > one like "Memory error ".
> > 
> > > Many CPU types don't eveh have such a thing?
> > 
> > No. At least currently, only SRAO MCE triggers memory_failure() and
> > it's defined only on some newest highend models of Intel CPUs.
> 
> Again, your reply is full of assumptions about one particualar
> implementation on one particular CPU.  But this is generic,
> cross-architecture code!
> 
> Now, it's pretty harmless to make these assumptions at this time.  But
> this new code will need to redone if/when other CPU types come along,
> and because there's a printk in there, that rework will cause
> user-visible changes in kernel behaviour.  It would be best if we can
> just avoid the problem on day one.
> 
> Maybe move the printk into x86-specific code?  And just one printk
> please - not a million!

OK, we need some cleanup for this at first.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
