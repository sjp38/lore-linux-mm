Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB1LPPi9031287
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 16:25:25 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB1LPtox181148
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 16:25:55 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB1LPt8B023377
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 16:25:55 -0500
Subject: Re: [RFC v10][PATCH 08/13] Dump open file descriptors
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.LFD.2.00.0812011258390.3256@nehalem.linux-foundation.org>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	 <1227747884-14150-9-git-send-email-orenl@cs.columbia.edu>
	 <20081128101919.GO28946@ZenIV.linux.org.uk>
	 <1228153645.2971.36.camel@nimitz> <493447DD.7010102@cs.columbia.edu>
	 <1228164679.2971.91.camel@nimitz>
	 <alpine.LFD.2.00.0812011258390.3256@nehalem.linux-foundation.org>
Content-Type: text/plain
Date: Mon, 01 Dec 2008 13:25:45 -0800
Message-Id: <1228166745.2971.113.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-01 at 13:02 -0800, Linus Torvalds wrote:
> On Mon, 1 Dec 2008, Dave Hansen wrote:
> > 
> > Why is this done in two steps?  It first grabs a list of fd numbers
> > which needs to be validated, then goes back and turns those into 'struct
> > file's which it saves off.  Is there a problem with doing that
> > fd->'struct file' conversion under the files->file_lock?
> 
> Umm, why do we even worry about this?
> 
> Wouldn't it be much better to make sure that all other threads are 
> stopped before we snapshot, and if we cannot account for some thread (ie 
> there's some elevated count in the fs/files/mm structures that we cannot 
> see from the threads we've stopped), just refuse to dump.

My guess is that the mm is probably ok here, but we'll need some work on
the vfs structures, at least eventually.

The mm is nice that it has ->count separated from ->users.  We can
easily compare the sum of mm->users to the number of tasks we've frozen
since mm->users has nice defined behavior.

But, we've got suckers like proc_fd_info() that do a
get/put_files_struct().  So, somebody just doing lots of looks in /proc
could stop us from ever checkpointing.  Unfortunately, I know of a
number of "monitoring" programs that do just that. :)

I guess we can use the plain counts for now, and add something like
mm->users for the vfs structures in a bit.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
