Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4U0CXEF026750
	for <linux-mm@kvack.org>; Thu, 29 May 2008 20:12:33 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4U0CX3O137976
	for <linux-mm@kvack.org>; Thu, 29 May 2008 20:12:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4U0CXJT023431
	for <linux-mm@kvack.org>; Thu, 29 May 2008 20:12:33 -0400
Date: Thu, 29 May 2008 17:12:31 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 22/23] fs: check for statfs overflow
Message-ID: <20080530001231.GD9846@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143454.453947000@nick.local0.net> <20080527171452.GJ20709@us.ibm.com> <483C42B9.7090102@linux.vnet.ibm.com> <20080528090257.GC2630@wotan.suse.de> <20080529235607.GO2985@webber.adilger.int>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080529235607.GO2985@webber.adilger.int>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Dilger <adilger@sun.com>
Cc: Nick Piggin <npiggin@suse.de>, Jon Tollefson <kniht@linux.vnet.ibm.com>, linux-mm@kvack.org, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 29.05.2008 [17:56:07 -0600], Andreas Dilger wrote:
> On May 28, 2008  11:02 +0200, Nick Piggin wrote:
> > fs: check for statfs overflow
> > 
> > Adds a check for an overflow in the filesystem size so if someone is
> > checking with statfs() on a 16G hugetlbfs  in a 32bit binary that it
> > will report back EOVERFLOW instead of a size of 0.
> > 
> > Are other places that need a similar check?  I had tried a similar
> > check in put_compat_statfs64 too but it didn't seem to generate an
> > EOVERFLOW in my test case.
> > 
> > Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> > 
> >  fs/compat.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > 
> > Index: linux-2.6/fs/compat.c
> > ===================================================================
> > --- linux-2.6.orig/fs/compat.c
> > +++ linux-2.6/fs/compat.c
> > @@ -197,8 +197,8 @@ static int put_compat_statfs(struct comp
> >  {
> >  	
> >  	if (sizeof ubuf->f_blocks == 4) {
> > -		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail) &
> > -		    0xffffffff00000000ULL)
> > +		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail |
> > +		     kbuf->f_bsize | kbuf->f_frsize) & 0xffffffff00000000ULL)
> >  			return -EOVERFLOW;
> 
> Hmm, doesn't this check break every filesystem > 16TB on 4kB PAGE_SIZE
> nodes?  It would be better, IMHO, to scale down f_blocks, f_bfree, and
> f_bavail and correspondingly scale up f_bsize to fit into the 32-bit
> statfs structure.

Being a FS newbie, I'm not entirely sure I follow, could you say that
again in patch-form? :) Seriously, it might make it clear to me.

> We did this for several years with Lustre, as the first installation
> was already larger than 16TB on 32-bit clients at the time.  There was
> never a problem with statfs returning a larger f_bsize, since
> applications generally use the fstat() st_blocksize to determine IO
> size and not the statfs() data.

I'm not sure that's a good reason to give bad data back to userspace...
We have both interfaces and both should work?

> Returning statfs data accurate to within a few kB is better than
> failing the request outright, IMHO.

Well, currently (iirc), we see statfs() give bad values for 16gb
hugetlbfs mountpoints. That's not good, and is inconsistent with the
other hugetlbfs mountpoints. We actually do want to indicate EOVERFLOW
there, as the 32-bit binary, or some kind of error, although the binary
will notice it can't use the pages from that mountpoint when mmap()
fails :)

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
