Date: Tue, 3 Jun 2008 05:27:15 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 22/23] fs: check for statfs overflow
Message-ID: <20080603032715.GB17089@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143454.453947000@nick.local0.net> <20080527171452.GJ20709@us.ibm.com> <483C42B9.7090102@linux.vnet.ibm.com> <20080528090257.GC2630@wotan.suse.de> <20080529235607.GO2985@webber.adilger.int> <20080530011408.GB11715@wotan.suse.de> <20080602031602.GA2961@webber.adilger.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080602031602.GA2961@webber.adilger.int>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Dilger <adilger@sun.com>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 01, 2008 at 09:16:02PM -0600, Andreas Dilger wrote:
> On May 30, 2008  03:14 +0200, Nick Piggin wrote:
> > On Thu, May 29, 2008 at 05:56:07PM -0600, Andreas Dilger wrote:
> > > On May 28, 2008  11:02 +0200, Nick Piggin wrote:
> > > > @@ -197,8 +197,8 @@ static int put_compat_statfs(struct comp
> > > >  	if (sizeof ubuf->f_blocks == 4) {
> > > > +		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail |
> > > > +		     kbuf->f_bsize | kbuf->f_frsize) & 0xffffffff00000000ULL)
> > > >  			return -EOVERFLOW;
> > > 
> > > Hmm, doesn't this check break every filesystem > 16TB on 4kB PAGE_SIZE
> > > nodes?  It would be better, IMHO, to scale down f_blocks, f_bfree, and
> > > f_bavail and correspondingly scale up f_bsize to fit into the 32-bit
> > > statfs structure.
> > 
> > Oh? Hmm, from my reading, such filesystems will already overflow f_blocks
> > check which is already there. Jon's patch only adds checks for f_bsize
> > and f_frsize.
> 
> Sorry, you are right - I meant that the whole f_blocks check is broken
> for filesystems > 16TB.  Scaling f_bsize is easy, and prevents gratuitous
> breakage of old applications for a few kB of accuracy.

Oh... hmm OK but they do have stat64 I guess, although maybe they aren't
coded for it.

Anyway, point is noted, but I'm not the person (nor is this the patchset)
to make such changes.

Do you agree that if we have these checks in coimpat_statfs, then we
should put the same ones in the non-compat as well as the 64 bit
versions?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
