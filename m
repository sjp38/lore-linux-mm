Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF989280252
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 05:42:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so1656191wmg.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 02:42:55 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id s9si1497798wjv.17.2016.09.27.02.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 02:42:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 243EF1C18B2
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:42:54 +0100 (IST)
Date: Tue, 27 Sep 2016 10:42:49 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160927094249.GA3903@techsingularity.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927073055.GM2794@worktop>
 <20160927085412.GD2838@techsingularity.net>
 <20160927091117.GA23640@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160927091117.GA23640@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 27, 2016 at 12:11:17PM +0300, Kirill A. Shutemov wrote:
> On Tue, Sep 27, 2016 at 09:54:12AM +0100, Mel Gorman wrote:
> > On Tue, Sep 27, 2016 at 09:30:55AM +0200, Peter Zijlstra wrote:
> > > > Also, if those bitlock ops had a different bit that showed contention,
> > > > we could actually skip *all* of this, and just see that "oh, nobody is
> > > > waiting on this page anyway, so there's no point in looking up those
> > > > wait queues". We don't have that many "__wait_on_bit()" users, maybe
> > > > we could say that the bitlocks do have to haev *two* bits: one for the
> > > > lock bit itself, and one for "there is contention".
> > > 
> > > That would be fairly simple to implement, the difficulty would be
> > > actually getting a page-flag to use for this. We're running pretty low
> > > in available bits :/
> > 
> > Simple is relative unless I drastically overcomplicated things and it
> > wouldn't be the first time. 64-bit only side-steps the page flag issue
> > as long as we can live with that.
> 
> Looks like we don't ever lock slab pages. Unless I miss something.
> 

I don't think we do but direct PageSlab checks might be problematic if
it was a false-positive due to a locked page and we'd have to be very
careful about any races due to two bits being used.

While we shouldn't rule it out, I think it's important to first look at
that original patch and see if it's remotely acceptable and makes enough
difference to a real workload to matter. If so, then we could consider
additional complexity on top to make it work on 32-bit -- maybe separated
by one release as it took a long time to flush out subtle bugs with the
PG_waiters approach.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
