Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E3EEA6B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 18:19:09 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n5-v6so7198885qtl.13
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:19:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i7si179843qke.44.2018.04.20.15.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 15:19:08 -0700 (PDT)
Date: Fri, 20 Apr 2018 18:19:05 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/79] Generic page write protection and a solution
 to page waitqueue
Message-ID: <20180420221905.GA4124@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
 <6f6e3602-c8a6-ae81-3ef0-9fe18e43c841@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6f6e3602-c8a6-ae81-3ef0-9fe18e43c841@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

On Fri, Apr 20, 2018 at 12:57:41PM -0700, Tim Chen wrote:
> On 04/04/2018 12:17 PM, jglisse@redhat.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=generic-write-protection-rfc
> > 
> > This is an RFC for LSF/MM discussions. It impacts the file subsystem,
> > the block subsystem and the mm subsystem. Hence it would benefit from
> > a cross sub-system discussion.
> > 
> > Patchset is not fully bake so take it with a graint of salt. I use it
> > to illustrate the fact that it is doable and now that i did it once i
> > believe i have a better and cleaner plan in my head on how to do this.
> > I intend to share and discuss it at LSF/MM (i still need to write it
> > down). That plan lead to quite different individual steps than this
> > patchset takes and his also easier to split up in more manageable
> > pieces.
> > 
> > I also want to apologize for the size and number of patches (and i am
> > not even sending them all).
> > 
> > ----------------------------------------------------------------------
> > The Why ?
> > 
> > I have two objectives: duplicate memory read only accross nodes and or
> > devices and work around PCIE atomic limitations. More on each of those
> > objective below. I also want to put forward that it can solve the page
> > wait list issue ie having each page with its own wait list and thus
> > avoiding long wait list traversale latency recently reported [1].
> > 
> > It does allow KSM for file back pages (truely generic KSM even between
> > both anonymous and file back page). I am not sure how useful this can
> > be, this was not an objective i did pursue, this is just a for free
> > feature (see below).
> > 
> > [1] https://groups.google.com/forum/#!topic/linux.kernel/Iit1P5BNyX8
> > 
> > ----------------------------------------------------------------------
> > Per page wait list, so long page_waitqueue() !
> > 
> > Not implemented in this RFC but below is the logic and pseudo code
> > at bottom of this email.
> > 
> > When there is a contention on struct page lock bit, the caller which
> > is trying to lock the page will add itself to a waitqueue. The issues
> > here is that multiple pages share the same wait queue and on large
> > system with a lot of ram this means we can quickly get to a long list
> > of waiters for differents pages (or for the same page) on the same
> > list [1].
> 
> Your approach seems useful if there are lots of locked pages sharing
> the same wait queue.  
> 
> That said, in the original workload from our customer with the long wait queue
> problem, there was a single super hot page getting migrated, and it
> is being accessed by all threads which caused the big log jam while they wait for
> the migration to get completed.  
> With your approach, we will still likely end up with a long queue 
> in that workload even if we have per page wait queue.
> 
> Thanks.

Ok so i re-read the thread, i was writting this cover letter from memory
and i had bad recollection of your issue, so sorry.

First, do you have a way to reproduce the issue ? Something easy would
be nice :)

So what i am proposing for per page wait queue would only marginaly help
you (it might not even be mesurable in your workload). It would certainly
make the code smaller and easier to understand i believe.

Now that i have look back at your issue i think there is 2 things we
should do. First keep migration page map read only, this would at least
avoid CPU read fault. In trace you captured i wasn't able to ascertain
if this were read or write fault.

Second idea i have is about NUMA, everytime we NUMA migrate a page we
could attach a temporary struct to the page (using page->mapping). So
if we scan that page again we can inspect information about previous
migration and see if we are not over migrating that page (ie bouncing
it all over). If so we can mark the page (maybe with a page flag if we
can find one) to protect it from further migration. That temporary
struct would be remove after a while, ie autonuma would preallocate a
bunch of those and keep an LRU of them and recycle the oldest when it
needs a new one to migrate another page.


LSF/MM slots:

Michal can i get 2 slots to talk about this ? MM only discussion, one
to talk about doing migration with page map read only but write
protected while migration is happening. The other one to talk about
attaching auto NUMA tracking struct to page.

Cheers,
Jerome
