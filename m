Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m523G84E017052
	for <linux-mm@kvack.org>; Sun, 1 Jun 2008 20:16:08 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K1T00M01FLRDY00@fe-sfbay-09.sun.com> (original mail from adilger@sun.com)
 for linux-mm@kvack.org; Sun, 01 Jun 2008 20:16:08 -0700 (PDT)
Date: Sun, 01 Jun 2008 21:16:02 -0600
From: Andreas Dilger <adilger@sun.com>
Subject: Re: [patch 22/23] fs: check for statfs overflow
In-reply-to: <20080530011408.GB11715@wotan.suse.de>
Message-id: <20080602031602.GA2961@webber.adilger.int>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Content-disposition: inline
References: <20080525142317.965503000@nick.local0.net>
 <20080525143454.453947000@nick.local0.net> <20080527171452.GJ20709@us.ibm.com>
 <483C42B9.7090102@linux.vnet.ibm.com> <20080528090257.GC2630@wotan.suse.de>
 <20080529235607.GO2985@webber.adilger.int>
 <20080530011408.GB11715@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On May 30, 2008  03:14 +0200, Nick Piggin wrote:
> On Thu, May 29, 2008 at 05:56:07PM -0600, Andreas Dilger wrote:
> > On May 28, 2008  11:02 +0200, Nick Piggin wrote:
> > > @@ -197,8 +197,8 @@ static int put_compat_statfs(struct comp
> > >  	if (sizeof ubuf->f_blocks == 4) {
> > > +		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail |
> > > +		     kbuf->f_bsize | kbuf->f_frsize) & 0xffffffff00000000ULL)
> > >  			return -EOVERFLOW;
> > 
> > Hmm, doesn't this check break every filesystem > 16TB on 4kB PAGE_SIZE
> > nodes?  It would be better, IMHO, to scale down f_blocks, f_bfree, and
> > f_bavail and correspondingly scale up f_bsize to fit into the 32-bit
> > statfs structure.
> 
> Oh? Hmm, from my reading, such filesystems will already overflow f_blocks
> check which is already there. Jon's patch only adds checks for f_bsize
> and f_frsize.

Sorry, you are right - I meant that the whole f_blocks check is broken
for filesystems > 16TB.  Scaling f_bsize is easy, and prevents gratuitous
breakage of old applications for a few kB of accuracy.

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
