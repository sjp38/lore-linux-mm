Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id A11BA6B0085
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 12:50:43 -0400 (EDT)
Received: by mail-vc0-f177.google.com with SMTP id hq11so7781025vcb.36
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 09:50:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w18si15771917vdj.103.2014.10.14.09.50.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Oct 2014 09:50:42 -0700 (PDT)
Date: Tue, 14 Oct 2014 12:50:27 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] mm, debug: mm-introduce-vm_bug_on_mm-fix-fix.patch
Message-ID: <20141014165027.GA26886@redhat.com>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
 <1411464279-20158-1-git-send-email-mhocko@suse.cz>
 <20140923112848.GA10046@dhcp22.suse.cz>
 <20140923201204.GB4252@redhat.com>
 <20141013185156.GA1959@redhat.com>
 <20141014115554.GB8727@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141014115554.GB8727@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

On Tue, Oct 14, 2014 at 01:55:54PM +0200, Michal Hocko wrote:

 > > -#ifdef CONFIG_NUMA_BALANCING
 > > -		"numa_next_scan %lu numa_scan_offset %lu numa_scan_seq %d\n"
 > > -#endif
 > > -#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 > > -		"tlb_flush_pending %d\n"
 > > -#endif
 > > -		"%s",	/* This is here to hold the comma */
 > > +	char *p = dumpmm_buffer;
 > > +
 > > +	memset(dumpmm_buffer, 0, 4096);
 > 
 > I do not see any locking here. Previously we had internal printk log as
 > a natural synchronization. Now two threads are allowed to scribble over
 > their messages leaving an unusable output in a better case.

That's why I asked in the part of the mail you didn't quote whether
we cared if it wasn't reentrant.  Ok we do. That's 3 lines of change to
add a lock.

 > Besides that the %s with "" trick is not really that ugly and handles
 > the situation quite nicely. So do we really want to make it more
 > complicated?

That hack goes away entirely with this diff.  And by keeping the
parameters with the format string they're associated with, it should be
more maintainable should we decide to add more fields to be output in the future.
The number of ifdefs in the function are halved (which becomes even
bigger deal if we do add more output).

We saw how many times we had to go around to get it right this time.
In its current incarnation, it looks like a matter of time before
someone screws it up again due to missing some CONFIG combination.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
