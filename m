Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id AB6486B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 05:04:03 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id gi9so651280lab.33
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 02:04:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si13533260lag.32.2014.10.15.02.04.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Oct 2014 02:04:01 -0700 (PDT)
Date: Wed, 15 Oct 2014 11:03:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, debug: mm-introduce-vm_bug_on_mm-fix-fix.patch
Message-ID: <20141015090359.GA23547@dhcp22.suse.cz>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
 <1411464279-20158-1-git-send-email-mhocko@suse.cz>
 <20140923112848.GA10046@dhcp22.suse.cz>
 <20140923201204.GB4252@redhat.com>
 <20141013185156.GA1959@redhat.com>
 <20141014115554.GB8727@dhcp22.suse.cz>
 <20141014165027.GA26886@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141014165027.GA26886@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

On Tue 14-10-14 12:50:27, Dave Jones wrote:
> On Tue, Oct 14, 2014 at 01:55:54PM +0200, Michal Hocko wrote:
> 
>  > > -#ifdef CONFIG_NUMA_BALANCING
>  > > -		"numa_next_scan %lu numa_scan_offset %lu numa_scan_seq %d\n"
>  > > -#endif
>  > > -#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
>  > > -		"tlb_flush_pending %d\n"
>  > > -#endif
>  > > -		"%s",	/* This is here to hold the comma */
>  > > +	char *p = dumpmm_buffer;
>  > > +
>  > > +	memset(dumpmm_buffer, 0, 4096);
>  > 
>  > I do not see any locking here. Previously we had internal printk log as
>  > a natural synchronization. Now two threads are allowed to scribble over
>  > their messages leaving an unusable output in a better case.
> 
> That's why I asked in the part of the mail you didn't quote whether
> we cared if it wasn't reentrant. 

Ups, missed that. Sorry!

> Ok we do. That's 3 lines of change to add a lock.
> 
>  > Besides that the %s with "" trick is not really that ugly and handles
>  > the situation quite nicely. So do we really want to make it more
>  > complicated?
> 
> That hack goes away entirely with this diff.  And by keeping the
> parameters with the format string they're associated with, it should be
> more maintainable should we decide to add more fields to be output in the future.
> The number of ifdefs in the function are halved (which becomes even
> bigger deal if we do add more output).
> 
> We saw how many times we had to go around to get it right this time.
> In its current incarnation, it looks like a matter of time before
> someone screws it up again due to missing some CONFIG combination.

I do not have a strong opinion. I find the hack sufficient but it is
true that we have to be careful to not lose it in "a cleanup" or when
somebody adds new conditional fields behind. On the other hand it is
easier to manage potential overflow within printk rather than relying
on separate sprintk-s (the current code already looks like it can
consume close to 1k - but I haven't measured that).

Up to Andrew I guess.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
