Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9HNDra9030826
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 19:13:53 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9HNFDhK495736
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 17:15:13 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9HNFCOJ007727
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 17:15:12 -0600
Subject: Re: [RFC] OVERCOMMIT_ALWAYS extension
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>
References: <1129570219.23632.34.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>
	 <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>
Content-Type: text/plain
Date: Mon, 17 Oct 2005 16:14:37 -0700
Message-Id: <1129590877.23632.44.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Chris Wright <chrisw@osdl.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-10-17 at 19:25 +0100, Hugh Dickins wrote:
> On Mon, 17 Oct 2005, Hugh Dickins wrote:
> > On Mon, 17 Oct 2005, Badari Pulavarty wrote:
> > > 
> > > I have been looking at possible ways to extend OVERCOMMIT_ALWAYS
> > > to avoid its abuse.
> > > 
> > > Few of the applications (database) would like to overcommit
> > > memory (by creating shared memory segments more than RAM+swap),
> > > but use only portion of it at any given time and get rid
> > > of portions of them through madvise(DONTNEED), when needed. 
> > > They want this, especially to handle hotplug memory situations 
> > > (where apps may not have clear idea on how much memory they have 
> > > in the system at the time of shared memory create). Currently, 
> > > they are using OVERCOMMIT_ALWAYS system wide to do this - but 
> > > they are affecting every other application on the system.
> > > 
> > > I am wondering, if there is a better way to do this. Simple solution
> > > would be to add IPC_OVERCOMMIT flag or add CAP_SYS_ADMIN to
> > > do the overcommit. This way only specific applications, requesting
> > > this would be able to overcommit. I am worried about, the over
> > > all affects it has on the system. But again, this can't be worse
> > > than system wide  OVERCOMMIT_ALWAYS. Isn't it ?
> > 
> > mmap has MAP_NORESERVE, without CAP_SYS_ADMIN or other restriction,
> > which exempts that mmap from security_vm_enough_memory checking -
> > unless current setting is OVERCOMMIT_NEVER, in which case
> > MAP_NORESERVE is ignored.
> 
> Having written that, it does seem rather odd that we have a flag
> anyone can set to evade that security_ checking.  It was okay when
> it was just vm_enough_memory, but now it's security_vm_enough_memory,
> I wonder if this is a significant oversight, and some CAP required.
> Might break things though.  CC'ed Chris.
> 
> Ah, there's a security_file_mmap earlier, which could reject the
> MAP_NORESERVE flag if it feels so inclined.  Perhaps you'll need
> to allow a similar opportunity for rejection in your approach.
> 
> Hugh
> 
> > So if you're content to move to the OVERCOMMIT_GUESS world, I
> > don't think you could be blamed for adding an IPC_NORESERVE which
> > behaves in the same way, without CAP_SYS_ADMIN restriction.
> > 
> > But if you want to move to OVERCOMMIT_NEVER, yet have a flag which
> > says overcommit now, you'll get into a tussle with NEVER-adherents.
> > 

I am perfectly happy with IPC_NORESERVE for OVERCOMMIT_GUESS (since its
the default) and fail or ignore IPC_NORESERVE for OVERCOMMIT_NEVER.

I will try to code this up and pass it by you.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
