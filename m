Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA386B1B60
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 11:46:21 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so1717092edt.23
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:46:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f14si4166252edw.282.2018.11.19.08.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 08:46:19 -0800 (PST)
Date: Mon, 19 Nov 2018 17:46:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181119164618.GQ22247@dhcp22.suse.cz>
References: <20181115131927.GT23831@dhcp22.suse.cz>
 <20181115133840.GR2653@MiWiFi-R3L-srv>
 <20181115143204.GV23831@dhcp22.suse.cz>
 <20181116012433.GU2653@MiWiFi-R3L-srv>
 <20181116091409.GD14706@dhcp22.suse.cz>
 <20181119105202.GE18471@MiWiFi-R3L-srv>
 <20181119124033.GJ22247@dhcp22.suse.cz>
 <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz>
 <eb979e1e-e0fc-b1a3-b6cc-70b503a74a20@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eb979e1e-e0fc-b1a3-b6cc-70b503a74a20@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Baoquan He <bhe@redhat.com>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Mon 19-11-18 17:36:21, Vlastimil Babka wrote:
> On 11/19/18 3:10 PM, Michal Hocko wrote:
> > On Mon 19-11-18 13:51:21, Michal Hocko wrote:
> >> On Mon 19-11-18 13:40:33, Michal Hocko wrote:
> >>> How are
> >>> we supposed to converge when the swapin code waits for the migration to
> >>> finish with the reference count elevated?
> 
> Indeed this looks wrong. How comes we only found this out now? I guess
> the race window where refcounts matter is only a part of the whole
> migration, where we update the mapping (migrate_page_move_mapping()).
> That's before copying contents, flags etc.

I guess we simply never found out because most migration callers simply
fail after few attempts. The notable exception is memory offline which
tries retries until it suceeds or the caller terminates the process by a
fatal signal

> >> Just to clarify. This is not only about swapin obviously. Any caller of
> >> __migration_entry_wait is affected the same way AFAICS.
> > 
> > In other words. Why cannot we do the following?
> > 
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
> 
> So what protects us from locking a page whose refcount dropped to zero?
> and is being freed? The checks in freeing path won't be happy about a
> stray lock.

Nothing really prevents that. But does it matter. The worst that might
happen is that we lock a freed or reused page. Who would complain?

-- 
Michal Hocko
SUSE Labs
