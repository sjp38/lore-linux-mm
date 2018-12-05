Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD4816B74E2
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 09:58:13 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id e137so2529226ybc.8
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 06:58:13 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g204sor3333668ywg.62.2018.12.05.06.58.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 06:58:12 -0800 (PST)
Date: Wed, 5 Dec 2018 09:58:10 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 4/4] mm: use the cached page for filemap_fault
Message-ID: <20181205145808.kzsro4a7vqaxx3cu@MacBook-Pro-91.local>
References: <20181130195812.19536-1-josef@toxicpanda.com>
 <20181130195812.19536-5-josef@toxicpanda.com>
 <20181204145034.4b69bdea36506be45946f8c9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204145034.4b69bdea36506be45946f8c9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josef Bacik <josef@toxicpanda.com>, kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Tue, Dec 04, 2018 at 02:50:34PM -0800, Andrew Morton wrote:
> On Fri, 30 Nov 2018 14:58:12 -0500 Josef Bacik <josef@toxicpanda.com> wrote:
> 
> > If we drop the mmap_sem we have to redo the vma lookup which requires
> > redoing the fault handler.  Chances are we will just come back to the
> > same page, so save this page in our vmf->cached_page and reuse it in the
> > next loop through the fault handler.
> > 
> 
> Is this really worthwhile?  Rerunning the fault handler is rare (we
> hope) and a single pagecache lookup is fast.
> 
> Some performance testing results would be helpful here.  It's
> practically obligatory when claiming a performance improvement.
> 
> 

Honestly the big thing is just not doing IO under the mmap_sem.  I had this
infrastructure originally for the mkwrite portion of these patches that I
dropped, because I was worried about the page being messed with after we did all
the mkwrite work.  However since I'm not doing that anymore there's less of a
need for it.  I have no performance numbers for this, just seemed like a good
idea since we are likely to just have the page again, and this keeps us from
evicting the page right away and causing more thrashing.

I'll try and set something up to see if there's a difference.  If there's no
difference do you want me to drop this?  Thanks,

Josef
