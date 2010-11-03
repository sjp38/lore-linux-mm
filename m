Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 717676B00D2
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 17:46:41 -0400 (EDT)
In-reply-to: <1288817005.4235.11393.camel@nimitz> (message from Dave Hansen on
	Wed, 03 Nov 2010 13:43:25 -0700)
Subject: Re: Deadlocks with transparent huge pages and userspace fs daemons
References: <1288817005.4235.11393.camel@nimitz>
Message-Id: <E1PDl9w-0003ea-7Z@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 03 Nov 2010 22:46:20 +0100
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: miklos@szeredi.hu, aarcange@redhat.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shenlinf@cn.ibm.com, volobuev@us.ibm.com, mel@linux.vnet.ibm.com, dingc@cn.ibm.com, lnxninja@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 03 Nov 2010, Dave Hansen wrote:
> Hey Miklos,
> 
> When testing with a transparent huge page kernel:
> 
> 	http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/andrea/aa.git;a=summary
> 
> some IBM testers ran into some deadlocks.  It appears that the
> khugepaged process is trying to migrate one of a filesystem daemon's
> pages while khugepaged holds the daemon's mmap_sem for write.
> 
> I think I've reproduced this issue in a slightly different form with
> FUSE.  In my case, I think the FUSE process actually deadlocks on itself
> instead of with khugepaged as in the IBM tester example that got me
> looking at this.
> 
> Andrea put it this way:
> > As long as page faults are needed to execute the I/O I doubt it's safe. But
> > I'll definitely change khugepaged not to allocate memory. If nothing else
> > because I don't want khugepaged to make easier to trigger issues like this. But
> > it's hard for me to consider this a bug of khugepaged from a theoretical
> > standpoint.
> 
> I tend to agree.  khugepaged makes the likelyhood of these things
> happening much higher, but I don't think it fundamentally creates the
> issue.

Yes, I agree too.
 
I think what is happening is that the fuse daemon is trying to read a
page.  While that is happening the page is locked.  If the daemon
blocks on a lock_page() for that same page, that is an obvious
deadlock.

This is not unique to fuse, for example NFS or any other network
filesystem is used over userspace tunneling (e.g. openvpn) then the
same thing can happen.

> Should we do something like make page compaction always non-blocking on
> lock_page()?

Yes, at least on !PageUptodate() pages.

Also blocking on page writeback has a similar effect.  Fuse is immune
to that because it does writeback in a special way.  But the network
fs over userspace tunneling case is not immune AFAICS.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
