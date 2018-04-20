Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2426B6B0003
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:57:45 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b11-v6so5542430pla.19
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 12:57:45 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m77si6057895pfk.56.2018.04.20.12.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 12:57:43 -0700 (PDT)
Subject: Re: [RFC PATCH 00/79] Generic page write protection and a solution to
 page waitqueue
References: <20180404191831.5378-1-jglisse@redhat.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <6f6e3602-c8a6-ae81-3ef0-9fe18e43c841@linux.intel.com>
Date: Fri, 20 Apr 2018 12:57:41 -0700
MIME-Version: 1.0
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

On 04/04/2018 12:17 PM, jglisse@redhat.com wrote:
> From: JA(C)rA'me Glisse <jglisse@redhat.com>
> 
> https://cgit.freedesktop.org/~glisse/linux/log/?h=generic-write-protection-rfc
> 
> This is an RFC for LSF/MM discussions. It impacts the file subsystem,
> the block subsystem and the mm subsystem. Hence it would benefit from
> a cross sub-system discussion.
> 
> Patchset is not fully bake so take it with a graint of salt. I use it
> to illustrate the fact that it is doable and now that i did it once i
> believe i have a better and cleaner plan in my head on how to do this.
> I intend to share and discuss it at LSF/MM (i still need to write it
> down). That plan lead to quite different individual steps than this
> patchset takes and his also easier to split up in more manageable
> pieces.
> 
> I also want to apologize for the size and number of patches (and i am
> not even sending them all).
> 
> ----------------------------------------------------------------------
> The Why ?
> 
> I have two objectives: duplicate memory read only accross nodes and or
> devices and work around PCIE atomic limitations. More on each of those
> objective below. I also want to put forward that it can solve the page
> wait list issue ie having each page with its own wait list and thus
> avoiding long wait list traversale latency recently reported [1].
> 
> It does allow KSM for file back pages (truely generic KSM even between
> both anonymous and file back page). I am not sure how useful this can
> be, this was not an objective i did pursue, this is just a for free
> feature (see below).
> 
> [1] https://groups.google.com/forum/#!topic/linux.kernel/Iit1P5BNyX8
> 
> ----------------------------------------------------------------------
> Per page wait list, so long page_waitqueue() !
> 
> Not implemented in this RFC but below is the logic and pseudo code
> at bottom of this email.
> 
> When there is a contention on struct page lock bit, the caller which
> is trying to lock the page will add itself to a waitqueue. The issues
> here is that multiple pages share the same wait queue and on large
> system with a lot of ram this means we can quickly get to a long list
> of waiters for differents pages (or for the same page) on the same
> list [1].

Your approach seems useful if there are lots of locked pages sharing
the same wait queue.  

That said, in the original workload from our customer with the long wait queue
problem, there was a single super hot page getting migrated, and it
is being accessed by all threads which caused the big log jam while they wait for
the migration to get completed.  
With your approach, we will still likely end up with a long queue 
in that workload even if we have per page wait queue.

Thanks.

Tim
