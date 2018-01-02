Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1366B029E
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 05:21:10 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 199so4530385pgc.11
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 02:21:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9si20160328pgb.632.2018.01.02.02.21.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Jan 2018 02:21:09 -0800 (PST)
Date: Tue, 2 Jan 2018 10:21:03 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -V4 -mm] mm, swap: Fix race between swapoff and some swap
 operations
Message-ID: <20180102102103.mpah2ehglufwhzle@suse.de>
References: <20171220012632.26840-1-ying.huang@intel.com>
 <20171221021619.GA27475@bbox>
 <871sjopllj.fsf@yhuang-dev.intel.com>
 <20171221235813.GA29033@bbox>
 <87r2rmj1d8.fsf@yhuang-dev.intel.com>
 <20171223013653.GB5279@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171223013653.GB5279@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, J???r???me Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Sat, Dec 23, 2017 at 10:36:53AM +0900, Minchan Kim wrote:
> > code path.  It appears that similar situation is possible for them too.
> > 
> > The file cache pages will be delete from file cache address_space before
> > address_space (embedded in inode) is freed.  But they will be deleted
> > from LRU list only when its refcount dropped to zero, please take a look
> > at put_page() and release_pages().  While address_space will be freed
> > after putting reference to all file cache pages.  If someone holds a
> > reference to a file cache page for quite long time, it is possible for a
> > file cache page to be in LRU list after the inode/address_space is
> > freed.
> > 
> > And I found inode/address_space is freed witch call_rcu().  I don't know
> > whether this is related to page_mapping().
> > 
> > This is just my understanding.
> 
> Hmm, it smells like a bug of __isolate_lru_page.
> 
> Ccing Mel:
> 
> What locks protects address_space destroying when race happens between
> inode trauncation and __isolate_lru_page?
> 

I'm just back online and have a lot of catching up to do so this is a rushed
answer and I didn't read the background of this. However the question is
somewhat ambiguous and the scope is broad as I'm not sure which race you
refer to. For file cache pages, I wouldnt' expect the address_space to be
destroyed specifically as long as the inode exists which is the structure
containing the address_space in this case. A page on the LRU being isolated
in __isolate_lru_page will have an elevated reference count which will
pin the inode until remove_mapping is called which holds the page lock
while inode truncation looking at a page for truncation also only checks
page_mapping under the page lock. Very broadly speaking, pages avoid being
added back to an inode being freed by checking the I_FREEING state.

Hopefully that helps while I go back to the TODO mountain.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
