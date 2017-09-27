Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 807596B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 11:07:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r136so15014617wmf.4
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 08:07:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 192si3942229wmn.90.2017.09.27.08.07.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 08:07:51 -0700 (PDT)
Date: Wed, 27 Sep 2017 17:07:42 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/7] mm, fs: introduce file_operations->post_mmap()
Message-ID: <20170927150742.GB28407@quack2.suse.cz>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-7-ross.zwisler@linux.intel.com>
 <CAPcyv4jtO028KeZK7SdkOUsgMLGqgttLzBCYgH0M+RP3eAXf4A@mail.gmail.com>
 <20170926185751.GB31146@linux.intel.com>
 <CAPcyv4iVc9y8PE24ZvkiBYdp4Die0Q-K5S6QexW_6YQ_M0F4QA@mail.gmail.com>
 <20170926210645.GA7798@linux.intel.com>
 <CAPcyv4iDTNteQAt1bBHCGijwsk45rJWHfdr+e_rOwK39jpC2Og@mail.gmail.com>
 <20170927113527.GD25746@quack2.suse.cz>
 <CAPcyv4jwGCSaPt17FEbbvbfmurJp5c1S6hPj4K9i3uv_LRKoNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jwGCSaPt17FEbbvbfmurJp5c1S6hPj4K9i3uv_LRKoNg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org

On Wed 27-09-17 07:00:53, Dan Williams wrote:
> On Wed, Sep 27, 2017 at 4:35 AM, Jan Kara <jack@suse.cz> wrote:
> > On Tue 26-09-17 14:41:53, Dan Williams wrote:
> >> On Tue, Sep 26, 2017 at 2:06 PM, Ross Zwisler
> >> <ross.zwisler@linux.intel.com> wrote:
> >> > On Tue, Sep 26, 2017 at 12:19:21PM -0700, Dan Williams wrote:
> >> >> On Tue, Sep 26, 2017 at 11:57 AM, Ross Zwisler
> >> > <>
> >> >> > This decision can only be made (in this
> >> >> > proposed scheme) *after* the inode->i_mapping->i_mmap  tree has been
> >> >> > populated, which means we need another call into the filesystem after this
> >> >> > insertion has happened.
> >> >>
> >> >> I get that, but it seems over-engineered and something that can also
> >> >> be safely cleaned up after the fact by the code path that is disabling
> >> >> DAX.
> >> >
> >> > I don't think you can safely clean it up after the fact because some thread
> >> > might have already called ->mmap() to set up the vma->vm_flags for their new
> >> > mapping, but they haven't added it to inode->i_mapping->i_mmap.
> >>
> >> If madvise(MADV_NOHUGEPAGE) can dynamically change vm_flags, then the
> >> DAX disable path can as well. VM_MIXEDMAP looks to be a nop for normal
> >> memory mappings.
> >>
> >> > The inode->i_mapping->i_mmap tree is the only way (that I know of at least)
> >> > that the filesystem has any idea about about the mapping.  This is the method
> >> > by which we would try and clean up mapping flags, if we were to do so, and
> >> > it's the only way that the filesystem can know whether or not mappings exist.
> >> >
> >> > The only way that I could think of to make this safely work is to have the
> >> > insertion into the inode->i_mapping->i_mmap tree be our sync point.  After
> >> > that the filesystem and the mapping code can communicate on the state of DAX,
> >> > but before that I think it's basically indeterminate.
> >>
> >> If we lose the race and leak VM_HUGEPAGE to a non-DAX mapping what
> >> breaks? I'd rather be in favor of not setting VM_HUGEPAGE at all in
> >> the ->mmap() handler and let the default THP policy take over. In
> >> fact, see transparent_hugepage_enabled() we already auto-enable huge
> >> page support for dax mappings regardless of VM_HUGEPAGE.
> >
> > Hum, this is an interesting option. So do you suggest that filesystems
> > supporting DAX would always setup mappings with VM_MIXEDMAP and without
> > VM_HUGEPAGE and thus we'd get rid of dependency on S_DAX flag in ->mmap?
> > That could actually work. The only possible issue I can see is that
> > VM_MIXEDMAP is still slightly different from normal page mappings and it
> > could have some performance implications - e.g. copy_page_range() does more
> > work on VM_MIXEDMAP mappings but not on normal page mappings.
> 
> We can also get rid of VM_MIXEDMAP if we disable DAX in the
> !pfn_t_has_page() case.

Yeah, although it would be a pity to require struct page just to avoid
having to set VM_MIXEDMAP flag...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
