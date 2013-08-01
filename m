Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 676946B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 04:57:13 -0400 (EDT)
Date: Thu, 1 Aug 2013 09:56:53 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Possible deadloop in direct reclaim?
Message-ID: <20130801085653.GD24642@n2100.arm.linux.org.uk>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com> <000001400d38469d-a121fb96-4483-483a-9d3e-fc552e413892-000000@email.amazonses.com> <89813612683626448B837EE5A0B6A7CB3B62F8F5C3@SC-VEXCH4.marvell.com> <CAHGf_=q8JZQ42R-3yzie7DXUEq8kU+TZXgcX9s=dn8nVigXv8g@mail.gmail.com> <89813612683626448B837EE5A0B6A7CB3B62F8FE33@SC-VEXCH4.marvell.com> <51F69BD7.2060407@gmail.com> <89813612683626448B837EE5A0B6A7CB3B630BDF99@SC-VEXCH4.marvell.com> <51F9CBC0.2020006@gmail.com> <89813612683626448B837EE5A0B6A7CB3B630BE028@SC-VEXCH4.marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B630BE028@SC-VEXCH4.marvell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>, Neil Zhang <zhangwm@marvell.com>

On Wed, Jul 31, 2013 at 10:19:53PM -0700, Lisa Du wrote:
> >fork alloc order-1 memory for stack. Where and why alloc order-2? If it is
> >arch specific code, please
> >contact arch maintainer.
> Yes arch do_fork allocate order-2 memory when copy_process. 
> Hi, Russel
> What's your opinion about this question?  
> If we really need order-2 memory for fork, then we'd better set
> CONFIG_COMPATION right?

Well, I gave up trying to read the original messages because the quoting
style is a total mess, so I don't have a full understanding of what the
issue is.

However, we have always required order-2 memory for fork, going back to
the 1.x kernel days - it's fundamental to ARM to have that.  The order-2
allocation os for the 1st level page table.  No order-2 allocation, no
page tables for the new thread.

Looking at this commit:

commit 05106e6a54aed321191b4bb5c9ee09538cbad3b1
Author: Rik van Riel <riel@redhat.com>
Date:   Mon Oct 8 16:33:03 2012 -0700

    mm: enable CONFIG_COMPACTION by default

    Now that lumpy reclaim has been removed, compaction is the only way left
    to free up contiguous memory areas.  It is time to just enable
    CONFIG_COMPACTION by default.

it seems to indicate that everyone should have this enabled - however,
the way the change has been done, anyone building from defconfigs before
that change will not have that option enabled.

So yes, this option should be turned on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
