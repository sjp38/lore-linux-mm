Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC796B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 18:09:40 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so1914848eek.41
        for <linux-mm@kvack.org>; Wed, 21 May 2014 15:09:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id f5si11407625eeg.102.2014.05.21.15.09.37
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 15:09:38 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: ##freemail## Re: [PATCH] tools/vm/page-types.c: page-cache sniffing feature
Date: Wed, 21 May 2014 18:09:26 -0400
Message-Id: <537d2422.85670e0a.0c82.ffffeb7eSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <CALYGNiPeZsB0GSgtGOV04iMX8r1DM0anPoiKwFesfE=MBhtS1Q@mail.gmail.com>
References: <20140226075723.29820.26427.stgit@zurg> <537c0e29.89cbc20a.4dbb.62eeSMTPIN_ADDED_BROKEN@mx.google.com> <CALYGNiPeZsB0GSgtGOV04iMX8r1DM0anPoiKwFesfE=MBhtS1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>

On Wed, May 21, 2014 at 09:56:55AM +0400, Konstantin Khlebnikov wrote:
> On Wed, May 21, 2014 at 6:23 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > Hi Konstantin,
> >
> > This patch is already in upstream, but I have another idea of implementing
> > the similar feature. So let me review this now, and I'll post patches to
> > complement this patch.
> >
> > On Wed, Feb 26, 2014 at 11:57:23AM +0400, Konstantin Khlebnikov wrote:
> >> After this patch 'page-types' can walk on filesystem mappings and analize
> >> populated page cache pages mostly without disturbing its state.
> >>
> >> It maps chunk of file, marks VMA as MADV_RANDOM to turn off readahead,
> >> pokes VMA via mincore() to determine cached pages, triggers page-fault
> >> only for them, and finally gathers information via pagemap/kpageflags.
> >> Before unmap it marks VMA as MADV_SEQUENTIAL for ignoring reference bits.
> >
> > I think that with this patch page-types *does* disturb page cache (not only
> > of the target file) because it newly populates the pages not faulted in
> > when page-types starts, which rotates LRU list and adds memory pressure.
> > To minimize the measurement-disturbance, we need some help in the kernel side.
> 
> Yes, it racy and sometimes changes state of page-cache, I know that.
> Dcache state also under fire.
> [ Also it sometimes races with truncate and dies after SIGBUS, I
> already have patch for this ]
> But, I don't see reason why anyone needs this so badly to require this
> massive change in the kernel.

I need this feature for kernel testing of memory error handling.
I like to know page cache tree's status.

> Also I don't quite like interface which you are proposend.
> I think ioctl would be better, like FIEMAP/BMAP but for pages.
> Hint: If you're inventing new interface at least make it non-racy and
> usable for more than one user at once. =)

This is interesting, I'll try to see this approach.

> My code has one huge advantage -- it don't need any changes in the
> kernel and works for old kernels.

Yes.

> If you're planning to change here something you should at least keep
> old code for backward compatibility.

page-types.c is a userspace tool, and this options was merged in the
latest merge window, so not distributed by any distros yet.
So "keep compatibility" rule is not strictly applied.

> 
> I've got another Idea. This mught be done in opposite direction: we
> could add interface which tells mapping and offset for each page.
> Finding all pages of particular mapping isn't big deal. What do you think?

Interesting but it doesn't access to page cache tree info which I need.
So ioctl approach sounds better to me.

> >
> >>
> >> usage: page-types -f <path>
> >>
> >> If <path> is directory it will analyse all files in all subdirectories.
> >
> > I think -f was reserved for "Walk file address space", so doing file tree
> > walk looks to me overkill. You can add "directory mode (-d) for this purpose,
> > although it seems to me that we can/should do this (for example) by combining
> > with find command. I can show you the example in my patch later.
> 
> It walks file address space, what's the problem?

No problem itself. It's a matter of taste, but I like UNIX philosophy of
"combining small tools."
But anyway if you really want, I don't object it.

> Removing recursive walk saves couple lines but either kills
> constuction of overall statistics our might hit the limit of argv
> size.
> 
> >
> >> Symlinks are not followed as well as mount points. Hardlinks aren't handled,
> >> they'll be dumbed as many times as they are found. Recursive walk brings all
> >> dentries into dcache and populates page cache of block-devices aka 'Buffers'.
> 
> I hope you have seen this two paraphes below. That was hint for future
> hackers =)
> 
> >>
> >> Probably it's worth to add ioctl for dumping file page cache as array of PFNs
> >> as a replacement for this hackish juggling with mmap/madvise/mincore/pagemap.
> >>
> >> Also recursive walk could be replaced with dumping cached inodes via some ioctl
> >> or debugfs interface followed by openning them via open_by_handle_at, this
> >> would fix hardlinks handling and unneeded population of dcache and buffers.
> >> This interface might be used as data source for constructing readahead plans
> >> and for background optimizations of actively used files.
> >>
> >> collateral changes:
> >> + fix 64-bit LFS: define _FILE_OFFSET_BITS instead of _LARGEFILE64_SOURCE
> >> + replace lseek + read with single pread
> >
> > Good, thanks.
> >
> >> + make show_page_range() reusable after flush
> >>
> >>
> >> usage example:
> >>
> >> ~/src/linux/tools/vm$ sudo ./page-types -L -f page-types
> >> foffset       offset  flags
> >> page-types    Inode: 2229277  Size: 89065 (22 pages)
> >> Modify: Tue Feb 25 12:00:59 2014 (162 seconds ago)
> >> Access: Tue Feb 25 12:01:00 2014 (161 seconds ago)
> >
> > I don't see why page-types needs to show these information.
> > We have many other tools to check file info, so this small program should
> > focus on page related things.
> 
> This tools helps to take snapshot of cached data and analyze why they are here.
> Pages appears in cache when someone reads files and becomes dirty when
> someone writes to them.

Originally this tool was introduced to get pages with a given set of
page flags, which was needed by stress testing for memory error handler.
That's a reason why it has some weired options -X/-x.

> This all about history and time, so when you inversigate what data is
> still in cache or
> still dirty you need to know how long they are here.
> This isn't precisely right, but reasonable enough and don't need any
> change in the kernel.

If you said you want to show access time of *each* page (I know it's
difficult/impossible,) it would be worth doing here.
But I don't think file metadata is useless to do in this specific tool.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
