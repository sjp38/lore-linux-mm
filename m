Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 56D776B0169
	for <linux-mm@kvack.org>; Sun, 21 Aug 2011 15:30:52 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p7LJUjFr012358
	for <linux-mm@kvack.org>; Sun, 21 Aug 2011 12:30:45 -0700
Received: from iye16 (iye16.prod.google.com [10.241.50.16])
	by hpaq1.eem.corp.google.com with ESMTP id p7LJUVXb018487
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 21 Aug 2011 12:30:43 -0700
Received: by iye16 with SMTP id 16so9052478iye.1
        for <linux-mm@kvack.org>; Sun, 21 Aug 2011 12:30:43 -0700 (PDT)
Date: Sun, 21 Aug 2011 12:29:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Host where KSM appears to save a negative amount of memory
In-Reply-To: <20110821085614.GA3957@arachsys.com>
Message-ID: <alpine.LSU.2.00.1108211155300.1252@sister.anvils>
References: <20110821085614.GA3957@arachsys.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Webb <chris@arachsys.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org

On Sun, 21 Aug 2011, Chris Webb wrote:

> We're running KSM on kernel 2.6.39.2 with hosts running a number qemu-kvm
> virtual machines, and it has consistently been saving us a useful amount of
> RAM.
> 
> To monitor the effective amount of memory saved, I've been looking at the
> difference between /sys/kernel/mm/ksm/pages_sharing and pages_shared. On a
> typical 32GB host, this has been coming out as at least a hundred thousand
> or so, which is presumably half to one gigabyte worth of 4k pages.
> 
> However, this morning we've spotted something odd - a host where
> pages_sharing is smaller than pages_shared, giving a negative saving by the
> above calculation:
> 
>   # cat /sys/kernel/mm/ksm/pages_sharing
>   1099994
>   # cat /sys/kernel/mm/ksm/pages_shared
>   1761313
> 
> I think this means my interpretation of these values must be wrong, as I
> presumably can't have more pages being shared than instances of their use!
> Can anyone shed any light on what might be going on here for me? Am I
> misinterpreting these values, or does this look like it might be an
> accounting bug? (If the latter, what useful debug info can I extract from
> the system to help identify it?)

Your interpretation happens to be wrong, it is expected behaviour,
but I agree it's a little odd.

KSM chooses to show the numbers pages_shared and pages_sharing as
exclusive counts: pages_sharing indicates the saving being made.  So it
would be perfectly reasonable to add those two numbers together to get
the "total" number of pages sharing, the number you expected it to show;
but it doesn't make sense to subtract shared from sharing.

(I think Documentation/vm/ksm.txt does make that clear.)

But you'd be right to question further, how come pages_sharing is less
than pages_shared: what is a shared page if it's not being shared with
anything else?  (And, at the extreme, it might be that all those 1099994
pages_sharing are actually sharing the same one of the pages_shared.)

It's a page that was shared with (at least one) others before, but all
but one of these instances have got freed since, and we've left this
page in the "shared tree", so that it can be more quickly matched up
with duplicates in future when they appear, as seems quite likely.

We don't actively do anything to move them out of the shared state:
some effort was needed to get them there, and no disadvantage in leaving
them like that; but yes, it is misleading to describe them as "shared".

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
