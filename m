Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40B146B0010
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:48:00 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s71so3827446pfi.22
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:48:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w8si14030633pgm.467.2018.11.15.00.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 00:47:59 -0800 (PST)
Date: Thu, 15 Nov 2018 09:47:52 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] Fix do_move_pages_to_node() error handling
Message-ID: <20181115084752.GF23831@dhcp22.suse.cz>
References: <20181114004059.1287439-1-pjaroszynski@nvidia.com>
 <20181114073415.GD23419@dhcp22.suse.cz>
 <20181114112945.GQ23419@dhcp22.suse.cz>
 <ddf79812-7702-d513-3f83-70bba1b258db@nvidia.com>
 <20181114212224.GE23419@dhcp22.suse.cz>
 <33626151-aeea-004a-36f5-27ddf6ff9008@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <33626151-aeea-004a-36f5-27ddf6ff9008@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Jaroszynski <pjaroszynski@nvidia.com>
Cc: p.jaroszynski@gmail.com, linux-mm@kvack.org, Jan Stancek <jstancek@redhat.com>

On Wed 14-11-18 17:04:37, Piotr Jaroszynski wrote:
> On 11/14/18 1:22 PM, Michal Hocko wrote:
> > On Wed 14-11-18 10:04:45, Piotr Jaroszynski wrote:
> >> On 11/14/18 3:29 AM, Michal Hocko wrote:
> >>> On Wed 14-11-18 08:34:15, Michal Hocko wrote:
> >>>> On Tue 13-11-18 16:40:59, p.jaroszynski@gmail.com wrote:
> >>>>> From: Piotr Jaroszynski <pjaroszynski@nvidia.com>
> >>>>>
> >>>>> migrate_pages() can return the number of pages that failed to migrate
> >>>>> instead of 0 or an error code. If that happens, the positive return is
> >>>>> treated as an error all the way up through the stack leading to the
> >>>>> move_pages() syscall returning a positive number. I believe this
> >>>>> regressed with commit a49bd4d71637 ("mm, numa: rework do_pages_move")
> >>>>> that refactored a lot of this code.
> >>>>
> >>>> Yes this is correct.
> >>>>
> >>>>> Fix this by treating positive returns as success in
> >>>>> do_move_pages_to_node() as that seems to most closely follow the
> >>>>> previous code. This still leaves the question whether silently
> >>>>> considering this case a success is the right thing to do as even the
> >>>>> status of the pages will be set as if they were successfully migrated,
> >>>>> but that seems to have been the case before as well.
> >>>>
> >>>> Yes, I believe the previous semantic was just wrong and we want to fix
> >>>> it. Jan has already brought this up [1]. I believe we want to update the
> >>>> documentation rather than restore the previous hazy semantic.
> >>
> >> That's probably fair although at least some code we have will have to be
> >> updated as it just checks for non-zero returns from move_pages() and
> >> assumes errno is set when that happens.
> > 
> > Can you tell me more about your usecase plase? I definitely do not want
> > to break any existing userspace. Making the syscall return code more
> > reasonable is still attractive. So if this new semantic can work better
> > for you it would be one argument more to keep it this way.
> >  
> 
> One of our APIs exposes a way to move a VA range to a GPU NUMA node or one of
> the CPU NUMA nodes. The code keeps retrying move_pages() and relies on
> the reported page status to decide whether each page is done, needs a
> retry (EAGAIN or EBUSY) or possibly needs a fallback (EMEM).
> 
> With the previous behaviour we would get a success, but the page status
> would be reported incorrectly. That's bad as we skip the migration
> without knowing about it.

Exactly.

> With the current code we get what we interpret as success as errno is 0,
> but the page status is gargabe/untouched. That's also bad.

Agreed.

> The proposed solution adds a new case to handle, but it will just tell
> us the page status is unusable and all we can do is just retry blindly.
> If it was possible to plumb through the migration status for each page
> accurately that would allow us to save redoing the call for pages that
> actually worked. Perhaps we would need a special status for pages
> skipped due to errors.

This would be possible but with this patch applied you should know how
many pages to skip from the tail of the array.

> But maybe this is all a tiny corner case short of the bug I hit (see
> more below) and it's not worth thinking too much about.
> 
> >>>> Just wondering, how have you found out? Is there any real application
> >>>> failing because of the change or this is a result of some test?
> >>
> >> I have a test that creates a tmp file, mmaps it as shared, memsets the
> >> memory and then attempts to move it to a different node. It used to
> >> work, but now fails. I suspect the filesystem's migratepage() callback
> >> regressed and will look into it next. So far I have only tested this on
> >> powerpc with the xfs filesystem.
> > 
> > I would be surprise if the rewor changed the migration behavior.
> 
> It didn't, I tracked it down to the new fs/iomap.c code used by xfs not
> being compatible with migrate_page_move_mapping() and prepared a perhaps
> naive fix in [1].

I am not familiar with iomap code much TBH so I cannot really judge your
fix.
-- 
Michal Hocko
SUSE Labs
