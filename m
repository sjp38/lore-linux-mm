Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E1E736B0957
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 06:49:57 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b7so9491180eda.10
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:49:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s24-v6si2141327ejo.122.2018.11.16.03.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 03:49:56 -0800 (PST)
Date: Fri, 16 Nov 2018 12:49:55 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] Fix do_move_pages_to_node() error handling
Message-ID: <20181116114955.GJ14706@dhcp22.suse.cz>
References: <20181114004059.1287439-1-pjaroszynski@nvidia.com>
 <20181114073415.GD23419@dhcp22.suse.cz>
 <20181114112945.GQ23419@dhcp22.suse.cz>
 <ddf79812-7702-d513-3f83-70bba1b258db@nvidia.com>
 <20181114212224.GE23419@dhcp22.suse.cz>
 <33626151-aeea-004a-36f5-27ddf6ff9008@nvidia.com>
 <20181115084752.GF23831@dhcp22.suse.cz>
 <22b8c91d-1c65-eba2-214e-0696d0e771fb@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <22b8c91d-1c65-eba2-214e-0696d0e771fb@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Jaroszynski <pjaroszynski@nvidia.com>
Cc: p.jaroszynski@gmail.com, linux-mm@kvack.org, Jan Stancek <jstancek@redhat.com>, Christoph Hellwig <hch@lst.de>

On Thu 15-11-18 10:58:33, Piotr Jaroszynski wrote:
> On 11/15/18 12:47 AM, Michal Hocko wrote:
> > On Wed 14-11-18 17:04:37, Piotr Jaroszynski wrote:
[...]
> >> The proposed solution adds a new case to handle, but it will just tell
> >> us the page status is unusable and all we can do is just retry blindly.
> >> If it was possible to plumb through the migration status for each page
> >> accurately that would allow us to save redoing the call for pages that
> >> actually worked. Perhaps we would need a special status for pages
> >> skipped due to errors.
> > 
> > This would be possible but with this patch applied you should know how
> > many pages to skip from the tail of the array.
> 
> At least in our case the node target is the same for all the pages so we
> would just learn that all the pages failed to migrate as they would be
> all batched together to the do_move_pages_to_node() call.

Anyway, could you give this patch a try please? I would appreciate some
Tested-bys to push this forward ;)

> >> But maybe this is all a tiny corner case short of the bug I hit (see
> >> more below) and it's not worth thinking too much about.
> >>
> >>>>>> Just wondering, how have you found out? Is there any real application
> >>>>>> failing because of the change or this is a result of some test?
> >>>>
> >>>> I have a test that creates a tmp file, mmaps it as shared, memsets the
> >>>> memory and then attempts to move it to a different node. It used to
> >>>> work, but now fails. I suspect the filesystem's migratepage() callback
> >>>> regressed and will look into it next. So far I have only tested this on
> >>>> powerpc with the xfs filesystem.
> >>>
> >>> I would be surprise if the rewor changed the migration behavior.
> >>
> >> It didn't, I tracked it down to the new fs/iomap.c code used by xfs not
> >> being compatible with migrate_page_move_mapping() and prepared a perhaps
> >> naive fix in [1].
> > 
> > I am not familiar with iomap code much TBH so I cannot really judge your
> > fix.
> > 
> 
> Christoph reviewed it already (thanks!) so it should be good after all.
> But in its context, I wanted to ask about migrate_page_move_mapping()
> page count checks that it was hitting. Is it true that the count checks
> are to handle the case when a page might be temporarily pinned and hence
> have the count too high temporarily?

Yes. We cannot really migrate pinned pages.

> That would explain why it returns
> EAGAIN in this case. But should having the count too low (what the bug
> was hitting) be a fatal error with a WARN maybe? Or are there expected
> cases where the count is too low temporarily too?

Nope, page reference count too low is a bug.

> I could send a patch
> for that, but also just wanted to understand the expectations.

-- 
Michal Hocko
SUSE Labs
