Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABACC6B1C32
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 15:34:20 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id m16so4721327pgd.0
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 12:34:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f68sor18951244pfh.22.2018.11.19.12.34.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 12:34:19 -0800 (PST)
Date: Mon, 19 Nov 2018 12:34:09 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Memory hotplug softlock issue
In-Reply-To: <20181119173312.GV22247@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1811191215290.15640@eggly.anvils>
References: <20181115131211.GP2653@MiWiFi-R3L-srv> <20181115131927.GT23831@dhcp22.suse.cz> <20181115133840.GR2653@MiWiFi-R3L-srv> <20181115143204.GV23831@dhcp22.suse.cz> <20181116012433.GU2653@MiWiFi-R3L-srv> <20181116091409.GD14706@dhcp22.suse.cz>
 <20181119105202.GE18471@MiWiFi-R3L-srv> <20181119124033.GJ22247@dhcp22.suse.cz> <20181119125121.GK22247@dhcp22.suse.cz> <20181119141016.GO22247@dhcp22.suse.cz> <20181119173312.GV22247@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Baoquan He <bhe@redhat.com>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>

On Mon, 19 Nov 2018, Michal Hocko wrote:
> On Mon 19-11-18 15:10:16, Michal Hocko wrote:
> [...]
> > In other words. Why cannot we do the following?
> 
> Baoquan, this is certainly not the right fix but I would be really
> curious whether it makes the problem go away.
> 
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index f7e4bfdc13b7..7ccab29bcf9a 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -324,19 +324,9 @@ void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
> >  		goto out;
> >  
> >  	page = migration_entry_to_page(entry);
> > -
> > -	/*
> > -	 * Once page cache replacement of page migration started, page_count
> > -	 * *must* be zero. And, we don't want to call wait_on_page_locked()
> > -	 * against a page without get_page().
> > -	 * So, we use get_page_unless_zero(), here. Even failed, page fault
> > -	 * will occur again.
> > -	 */
> > -	if (!get_page_unless_zero(page))
> > -		goto out;
> >  	pte_unmap_unlock(ptep, ptl);
> > -	wait_on_page_locked(page);
> > -	put_page(page);
> > +	page_lock(page);
> > +	page_unlock(page);
> >  	return;
> >  out:
> >  	pte_unmap_unlock(ptep, ptl);

Thanks for Cc'ing me. I did mention precisely this issue two or three
times at LSF/MM this year, and claimed then that I would post the fix.

I'm glad that I delayed, what I had then (migration_waitqueue instead
of using page_waitqueue) was not wrong, but what I've been using the
last couple of months is rather better (and can be put to use to solve
similar problems in collapsing pages on huge tmpfs. but we don't need
to get into that at this time): put_and_wait_on_page_locked().

What I have not yet done is verify it on latest kernel, and research
the interested Cc list (Linus and Tim Chen come immediately to mind),
and write the commit comment. I have some testing to do on the latest
kernel today, so I'll throw put_and_wait_on_page_locked() in too,
and post tomorrow I hope.

Hugh
