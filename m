Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9826B0005
	for <linux-mm@kvack.org>; Sun, 29 Apr 2018 17:05:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i11-v6so5130875wre.16
        for <linux-mm@kvack.org>; Sun, 29 Apr 2018 14:05:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z8-v6si6628958edq.292.2018.04.29.14.05.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 29 Apr 2018 14:05:26 -0700 (PDT)
Date: Sun, 29 Apr 2018 23:05:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180429210523.GA26305@dhcp22.suse.cz>
References: <20180413131632.1413-1-david@redhat.com>
 <20180413155917.GX17484@dhcp22.suse.cz>
 <b51ca7a1-c5ae-fbbb-8edf-e71f383da07e@redhat.com>
 <20180416140810.GR17484@dhcp22.suse.cz>
 <d39f5b5d-db9b-0729-e68b-b15c314ddd13@redhat.com>
 <20180419073323.GO17484@dhcp22.suse.cz>
 <493367d5-efbc-d9d6-3f32-3cd7e9a2b222@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <493367d5-efbc-d9d6-3f32-3cd7e9a2b222@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org

On Thu 26-04-18 17:30:47, David Hildenbrand wrote:
> On 19.04.2018 09:33, Michal Hocko wrote:
> > On Wed 18-04-18 17:46:25, David Hildenbrand wrote:
> > [...]
> >> BTW I was able to easily produce the case where do_migrate_range() would
> >> loop for ever (well at least for multiple minutes, but I assume this
> >> would have went on :) )
> > 
> > I am definitely interested to hear details.
> > 
> 
> migrate_pages() seems to be returning > 0 all the time. Seems to come
> from too many -EAGAIN from unmap_and_move().
> 
> This in return (did not go further down that road) can be as simple as
> trylock_page() failing.

Yes but we assume that nobody holds the lock for ever so sooner or later
we should be able to get the lock.

> Of course, we could have other permanent errors here (-ENOMEM).
> __offline_pages() ignores all errors coming from do_migrate_range(). So
> in theory, this can take forever - at least not what I want for my use
> case. I want it to fail fast. "if this block cannot be offlined, try
> another one".
> 
> I wonder if it is the right thing to do in __offline_pages() to ignore
> even permanent errors. Anyhow, I think I'll need some way of telling
> offline_pages "please don't retry forever".

Well, it would be really great to find a way to distinguish permanent
errors from temporary ones. But I am not sure this is very easy. Anyway,
we should be only looking at migratable pages at this stage of the
offline so the migration should eventually succeed. We have a bug if
this is not a case and we should address it. Find the page which fails
to migrate and see who keeps us from migrating it. This might be a page
pin abuser or something else. That is why I've said I am interested in
details.
-- 
Michal Hocko
SUSE Labs
