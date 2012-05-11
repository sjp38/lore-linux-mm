Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 991A58D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 17:31:03 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5267450pbb.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 14:31:02 -0700 (PDT)
Date: Fri, 11 May 2012 14:30:42 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Bug 43227] New: BUG: Bad page state in process
 wcg_gfam_6.11_i
In-Reply-To: <20120511125921.a888e12c.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1205111419060.1288@eggly.anvils>
References: <bug-43227-27@https.bugzilla.kernel.org/> <20120511125921.a888e12c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, sliedes@cc.hut.fi

On Fri, 11 May 2012, Andrew Morton wrote:
> > 
> > [67031.755786] BUG: Bad page state in process wcg_gfam_6.11_i  pfn:02519
> > [67031.755790] page:ffffea0000094640 count:0 mapcount:0 mapping:         
> > (null) index:0x7f1eb293b
> > [67031.755792] page flags: 0x4000000000000014(referenced|dirty)
> 
> AFAICT we got this warning because the page allocator found a free page
> with PG_referenced and PG_dirty set.
> 
> It would be a heck of a lot more useful if we'd been told about this
> when the page was freed, not when it was reused!  Can anyone think of a
> reason why PAGE_FLAGS_CHECK_AT_FREE doesn't include these flags (at
> least)?

Because those flags may validly be set when a page is freed (I do have an
old patch to change anon dirty handling to stop that, but it's not really
needed).  They are then immediately cleared, along with all other page
flags.  So if page allocation finds any page flags set, it happened while
the page was supposedly free.

The only thought I have on this report: what binutils was used to build
this kernel?  We had "Bad page" and isolate_lru_pages BUG reports at the
start of the month, and they were traced to buggy binutils 2.22.52.0.2

Hugh

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
