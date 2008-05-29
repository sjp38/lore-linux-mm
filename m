Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m4TNuQHD005039
	for <linux-mm@kvack.org>; Thu, 29 May 2008 16:56:26 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K1N00E01MDZQU00@fe-sfbay-10.sun.com> (original mail from adilger@sun.com)
 for linux-mm@kvack.org; Thu, 29 May 2008 16:56:25 -0700 (PDT)
Date: Thu, 29 May 2008 17:56:07 -0600
From: Andreas Dilger <adilger@sun.com>
Subject: Re: [patch 22/23] fs: check for statfs overflow
In-reply-to: <20080528090257.GC2630@wotan.suse.de>
Message-id: <20080529235607.GO2985@webber.adilger.int>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Content-disposition: inline
References: <20080525142317.965503000@nick.local0.net>
 <20080525143454.453947000@nick.local0.net> <20080527171452.GJ20709@us.ibm.com>
 <483C42B9.7090102@linux.vnet.ibm.com> <20080528090257.GC2630@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On May 28, 2008  11:02 +0200, Nick Piggin wrote:
> fs: check for statfs overflow
> 
> Adds a check for an overflow in the filesystem size so if someone is
> checking with statfs() on a 16G hugetlbfs  in a 32bit binary that it
> will report back EOVERFLOW instead of a size of 0.
> 
> Are other places that need a similar check?  I had tried a similar
> check in put_compat_statfs64 too but it didn't seem to generate an
> EOVERFLOW in my test case.
> 
> Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> 
>  fs/compat.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> 
> Index: linux-2.6/fs/compat.c
> ===================================================================
> --- linux-2.6.orig/fs/compat.c
> +++ linux-2.6/fs/compat.c
> @@ -197,8 +197,8 @@ static int put_compat_statfs(struct comp
>  {
>  	
>  	if (sizeof ubuf->f_blocks == 4) {
> -		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail) &
> -		    0xffffffff00000000ULL)
> +		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail |
> +		     kbuf->f_bsize | kbuf->f_frsize) & 0xffffffff00000000ULL)
>  			return -EOVERFLOW;

Hmm, doesn't this check break every filesystem > 16TB on 4kB PAGE_SIZE
nodes?  It would be better, IMHO, to scale down f_blocks, f_bfree, and
f_bavail and correspondingly scale up f_bsize to fit into the 32-bit
statfs structure.

We did this for several years with Lustre, as the first installation was
already larger than 16TB on 32-bit clients at the time.  There was never
a problem with statfs returning a larger f_bsize, since applications
generally use the fstat() st_blocksize to determine IO size and not the
statfs() data.

Returning statfs data accurate to within a few kB is better than failing
the request outright, IMHO.

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
