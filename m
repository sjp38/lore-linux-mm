Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 835F56B026D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 16:22:27 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d41so2770642eda.12
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 13:22:27 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y20si1136151edb.128.2018.11.14.13.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 13:22:25 -0800 (PST)
Date: Wed, 14 Nov 2018 22:22:24 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] Fix do_move_pages_to_node() error handling
Message-ID: <20181114212224.GE23419@dhcp22.suse.cz>
References: <20181114004059.1287439-1-pjaroszynski@nvidia.com>
 <20181114073415.GD23419@dhcp22.suse.cz>
 <20181114112945.GQ23419@dhcp22.suse.cz>
 <ddf79812-7702-d513-3f83-70bba1b258db@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddf79812-7702-d513-3f83-70bba1b258db@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Jaroszynski <pjaroszynski@nvidia.com>
Cc: p.jaroszynski@gmail.com, linux-mm@kvack.org, Jan Stancek <jstancek@redhat.com>

On Wed 14-11-18 10:04:45, Piotr Jaroszynski wrote:
> On 11/14/18 3:29 AM, Michal Hocko wrote:
> > On Wed 14-11-18 08:34:15, Michal Hocko wrote:
> >> On Tue 13-11-18 16:40:59, p.jaroszynski@gmail.com wrote:
> >>> From: Piotr Jaroszynski <pjaroszynski@nvidia.com>
> >>>
> >>> migrate_pages() can return the number of pages that failed to migrate
> >>> instead of 0 or an error code. If that happens, the positive return is
> >>> treated as an error all the way up through the stack leading to the
> >>> move_pages() syscall returning a positive number. I believe this
> >>> regressed with commit a49bd4d71637 ("mm, numa: rework do_pages_move")
> >>> that refactored a lot of this code.
> >>
> >> Yes this is correct.
> >>
> >>> Fix this by treating positive returns as success in
> >>> do_move_pages_to_node() as that seems to most closely follow the
> >>> previous code. This still leaves the question whether silently
> >>> considering this case a success is the right thing to do as even the
> >>> status of the pages will be set as if they were successfully migrated,
> >>> but that seems to have been the case before as well.
> >>
> >> Yes, I believe the previous semantic was just wrong and we want to fix
> >> it. Jan has already brought this up [1]. I believe we want to update the
> >> documentation rather than restore the previous hazy semantic.
> 
> That's probably fair although at least some code we have will have to be
> updated as it just checks for non-zero returns from move_pages() and
> assumes errno is set when that happens.

Can you tell me more about your usecase plase? I definitely do not want
to break any existing userspace. Making the syscall return code more
reasonable is still attractive. So if this new semantic can work better
for you it would be one argument more to keep it this way.
 
> >> Just wondering, how have you found out? Is there any real application
> >> failing because of the change or this is a result of some test?
> 
> I have a test that creates a tmp file, mmaps it as shared, memsets the
> memory and then attempts to move it to a different node. It used to
> work, but now fails. I suspect the filesystem's migratepage() callback
> regressed and will look into it next. So far I have only tested this on
> powerpc with the xfs filesystem.

I would be surprise if the rewor changed the migration behavior.

[...]
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index f7e4bfdc13b7..aa53ebc523eb 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1615,8 +1615,16 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
> >  			goto out_flush;
> >  
> >  		err = do_move_pages_to_node(mm, &pagelist, current_node);
> > -		if (err)
> > +		if (err) {
> > +			/*
> > +			 * Possitive err means the number of failed pages to
> > +			 * migrate. Make sure to report the rest of the
> > +			 * nr_pages is not migrated as well.
> > +			 */
> > +			if (err > 0)
> > +				err += nr_pages - i - 1;
> >  			goto out;
> 
> Ok, so we give up after the first failure to migrate everything. That
> probably makes sense although I don't have a good idea about how
> frequent it is for the migration to give up in such a manner (short of
> the issue I'm seeing that I suspect is a separate bug). In this case,
> should the status of each page be updated to something instead of being
> left undefined? Or should it be specified that page status is only valid
> for the first N - not migrated pages?

I believe this is consistent with the previous behavior. I do not
remember in detail but I believe we haven't set the status for the
remaining pages. With this patch it seems straightforward to skip over
exact number of pages that failed.

-- 
Michal Hocko
SUSE Labs
