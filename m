Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m53HHFpZ023534
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 10:17:15 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K1W00701D24P200@fe-sfbay-09.sun.com> (original mail from adilger@sun.com)
 for linux-mm@kvack.org; Tue, 03 Jun 2008 10:17:15 -0700 (PDT)
Date: Tue, 03 Jun 2008 11:17:01 -0600
From: Andreas Dilger <adilger@sun.com>
Subject: Re: [patch 22/23] fs: check for statfs overflow
In-reply-to: <20080603032715.GB17089@wotan.suse.de>
Message-id: <20080603171701.GX2961@webber.adilger.int>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Content-disposition: inline
References: <20080525142317.965503000@nick.local0.net>
 <20080525143454.453947000@nick.local0.net> <20080527171452.GJ20709@us.ibm.com>
 <483C42B9.7090102@linux.vnet.ibm.com> <20080528090257.GC2630@wotan.suse.de>
 <20080529235607.GO2985@webber.adilger.int>
 <20080530011408.GB11715@wotan.suse.de>
 <20080602031602.GA2961@webber.adilger.int>
 <20080603032715.GB17089@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Jun 03, 2008  05:27 +0200, Nick Piggin wrote:
> On Sun, Jun 01, 2008 at 09:16:02PM -0600, Andreas Dilger wrote:
> > On May 30, 2008  03:14 +0200, Nick Piggin wrote:
> > > Oh? Hmm, from my reading, such filesystems will already overflow f_blocks
> > > check which is already there. Jon's patch only adds checks for f_bsize
> > > and f_frsize.
> > 
> > Sorry, you are right - I meant that the whole f_blocks check is broken
> > for filesystems > 16TB.  Scaling f_bsize is easy, and prevents gratuitous
> > breakage of old applications for a few kB of accuracy.
> 
> Oh... hmm OK but they do have stat64 I guess, although maybe they aren't
> coded for it.

Right - we had this problem with all of the tools with some older distros
being compiled against the old statfs syscall and we had to put the statfs
scaling inside Lustre to avoid the 16TB overflow.

The problem with the current kernel VFS interface is that the filesystem
doesn't know whether the 32-bit or 64-bit statfs interface is being called,
and rather than returning an error to an application we'd prefer to return
scaled statfs results (with some small amount of rounding error).  Even
for 20PB filesystems (the largest planned for this year) the free/used/avail
space would only be rounded to 4MB sizes, which isn't so bad.

> Anyway, point is noted, but I'm not the person (nor is this the patchset)
> to make such changes.

Right...

> Do you agree that if we have these checks in coimpat_statfs, then we
> should put the same ones in the non-compat as well as the 64 bit
> versions?

If it only affects hugetlbfs then I'm not too concerned.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
