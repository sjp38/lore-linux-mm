Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id kAULXR6p014112
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 21:33:27 GMT
Received: from ug-out-1314.google.com (uga22.prod.google.com [10.66.1.22])
	by spaceape14.eur.corp.google.com with ESMTP id kAULWP5W025062
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 21:33:18 GMT
Received: by ug-out-1314.google.com with SMTP id 22so2167501uga
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 13:33:18 -0800 (PST)
Message-ID: <6599ad830611301333v48f2da03g747c088ed3b4ad60@mail.gmail.com>
Date: Thu, 30 Nov 2006 13:33:18 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <Pine.LNX.4.64.0611301211270.24331@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <Pine.LNX.4.64.0611301027340.23649@schroedinger.engr.sgi.com>
	 <6599ad830611301035u36a111dfye8c9414d257ebe07@mail.gmail.com>
	 <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
	 <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
	 <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
	 <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
	 <Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
	 <6599ad830611301207q4e4ab485lb0d3c99680db5a2a@mail.gmail.com>
	 <Pine.LNX.4.64.0611301211270.24331@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On 11/30/06, Christoph Lameter <clameter@sgi.com> wrote:
>
> Hmmm.. Well talk to Hugh Dickins about that. anon_vmas are very
> performance sensitive things.

>
> > When gathering pages for migration, we use page_lock_anon_vma() to get
> > the anon_vma; if it returns NULL or has an empty vma list we skip the
> > page, else we bump migration count (and mapcount?) by 1 and unlock.
> > That will guarantee that the anon_vma sticks around until the end of
> > the migration.
>
> You cannot use page_lock_anon_vma since the mapcount is of the page is
> zero.

Let me clarify my proposal:

1) When gathering pages we find an anon page

2) We call page_lock_anon_vma(); if it returns NULL we ignore the page

3) If the anon_vma has an empty vma list, we ignore the page

4) We increment page_mapcount(); if this crosses the boundary from
unmapped to mapped, we know that we're racing with someone else;
either ignore the page or start again

5) If page->mapping no longer refers to our anon_vma, we know we're
racing; drop page_mapcount and ignore the page or start again

6) We increment anon_vma->migration_count to pin the anon_vma

At this point we know that the vma isn't going to go away since it's
pinned via the migration count, and any new users of the page will use
the pinned anon_vma since page_mapcount() is positive.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
