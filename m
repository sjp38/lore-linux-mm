Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A107B6B02E1
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 02:59:47 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y16so23417597wmd.6
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 23:59:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q126si17928696wme.18.2016.12.19.23.59.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Dec 2016 23:59:45 -0800 (PST)
Date: Tue, 20 Dec 2016 08:59:42 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/6 v3] dax: Page invalidation fixes
Message-ID: <20161220075942.GB496@quack2.suse.cz>
References: <20161212164708.23244-1-jack@suse.cz>
 <20161213115209.GG15362@quack2.suse.cz>
 <CAPcyv4giLyY8pWP09V5BmUM+sfGO-VJCtkfV6L-RFS+0XQsT9Q@mail.gmail.com>
 <CAPcyv4jqN+GkO7pL0QE0vM50MmqPZ1aD2G3YmziKvp+4+oh5gQ@mail.gmail.com>
 <20161219095623.GE17598@quack2.suse.cz>
 <CAPcyv4jjLg=Nyxusz5Hp8OaJ9fi0Xf6LHW37jgVbxKoOYHjNQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jjLg=Nyxusz5Hp8OaJ9fi0Xf6LHW37jgVbxKoOYHjNQw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Mon 19-12-16 13:51:53, Dan Williams wrote:
> On Mon, Dec 19, 2016 at 1:56 AM, Jan Kara <jack@suse.cz> wrote:
> > On Fri 16-12-16 17:35:35, Dan Williams wrote:
> >> On Tue, Dec 13, 2016 at 10:57 AM, Dan Williams <dan.j.williams@intel.com> wrote:
> >> > On Tue, Dec 13, 2016 at 3:52 AM, Jan Kara <jack@suse.cz> wrote:
> >> >> On Mon 12-12-16 17:47:02, Jan Kara wrote:
> >> >>> Hello,
> >> >>>
> >> >>> this is the third revision of my fixes of races when invalidating hole pages in
> >> >>> DAX mappings. See changelogs for details. The series is based on my patches to
> >> >>> write-protect DAX PTEs which are currently carried in mm tree. This is a hard
> >> >>> dependency because we really need to closely track dirtiness (and cleanness!)
> >> >>> of radix tree entries in DAX mappings in order to avoid discarding valid dirty
> >> >>> bits leading to missed cache flushes on fsync(2).
> >> >>>
> >> >>> The tests have passed xfstests for xfs and ext4 in DAX and non-DAX mode.
> >> >>>
> >> >>> Johannes, are you OK with patch 2/6 in its current form? I'd like to push these
> >> >>> patches to some tree once DAX write-protection patches are merged.  I'm hoping
> >> >>> to get at least first three patches merged for 4.10-rc2... Thanks!
> >> >>
> >> >> OK, with the final ack from Johannes and since this is mostly DAX stuff,
> >> >> can we take this through NVDIMM tree and push to Linus either late in the
> >> >> merge window or for -rc2? These patches require my DAX patches sitting in mm
> >> >> tree so they can be included in any git tree only once those patches land
> >> >> in Linus' tree (which may happen only once Dave and Ted push out their
> >> >> stuff - this is the most convoluted merge window I'd ever to deal with ;-)...
> >> >> Dan?
> >> >>
> >> >
> >> > I like the -rc2 plan better than sending a pull request based on some
> >> > random point in the middle of the merge window. I can give Linus a
> >> > heads up in my initial nvdimm pull request for -rc1 that for
> >> > coordination purposes we'll be sending this set of follow-on DAX
> >> > cleanups for -rc2.
> >>
> >> So what's still pending for -rc2? I want to be explicit about what I'm
> >> requesting Linus be prepared to receive after -rc1. The libnvdimm pull
> >> request is very light this time around since I ended up deferring the
> >> device-dax-subdivision topic until 4.11 and sub-section memory hotplug
> >> didn't make the cutoff for -mm. We can spend some of that goodwill on
> >> your patches ;-).
> >
> > ;-) So I'd like all these 6 patches to go for rc2. The first three patches
> > fix invalidation of exceptional DAX entries (a bug which is there for a
> > long time) - without these patches data loss can occur on power failure
> > even though user called fsync(2). The other three patches change locking of
> > DAX faults so that ->iomap_begin() is called in a more relaxed locking
> > context and we are safe to start a transaction there for ext4.
> >
> >> I can roll them into libnvdimm-for-next now for the integration
> >> testing coverage, rebase to -rc1 when it's out, wait for your thumbs
> >> up on the testing and send a pull request on the 23rd.
> >
> > Yup, all prerequisites are merged now so you can pick these patches up.
> > Thanks! Note that I'll be on vacation on Dec 23 - Jan 1.
> 
> Sounds good, the contents are now out on libnvdimm-pending awaiting
> 0day-run before moving them over to libnvdimm-for-next, also it's down
> to 5 patches since it seems that the "dax: Fix sleep in atomic contex
> in grab_mapping_entry()" change went upstream already.

Yes, but I've accounted for that. Checking the libnvdimm-pending branch I
see you missed "ext2: Return BH_New buffers for zeroed blocks" which was
the first patch in the series. The subject is a slight misnomer since it is
about setting IOMAP_F_NEW flag instead these days but still it is needed...
Otherwise the DAX invalidation code would not propely invalidate zero pages
in the radix tree in response to writes for ext2.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
