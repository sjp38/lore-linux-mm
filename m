Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id A6E906B003A
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 10:21:41 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id t60so1288931wes.34
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:21:41 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.202])
        by mx.google.com with ESMTP id p7si5253473wic.43.2014.07.23.07.21.06
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 07:21:07 -0700 (PDT)
Date: Wed, 23 Jul 2014 17:20:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v8 05/22] Add vm_replace_mixed()
Message-ID: <20140723142048.GA11963@node.dhcp.inet.fi>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <b1052af08b49965fd0e6b87b6733b89294c8cc1e.1406058387.git.matthew.r.wilcox@intel.com>
 <20140723114540.GD10317@node.dhcp.inet.fi>
 <20140723135221.GA6754@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140723135221.GA6754@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 23, 2014 at 09:52:22AM -0400, Matthew Wilcox wrote:
> On Wed, Jul 23, 2014 at 02:45:40PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Jul 22, 2014 at 03:47:53PM -0400, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <willy@linux.intel.com>
> > > 
> > > vm_insert_mixed() will fail if there is already a valid PTE at that
> > > location.  The DAX code would rather replace the previous value with
> > > the new PTE.
> 
> > > @@ -1492,8 +1492,12 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
> > >  	if (!pte)
> > >  		goto out;
> > >  	retval = -EBUSY;
> > > -	if (!pte_none(*pte))
> > > -		goto out_unlock;
> > > +	if (!pte_none(*pte)) {
> > > +		if (!replace)
> > > +			goto out_unlock;
> > > +		VM_BUG_ON(!mutex_is_locked(&vma->vm_file->f_mapping->i_mmap_mutex));
> > > +		zap_page_range_single(vma, addr, PAGE_SIZE, NULL);
> > 
> > zap_page_range_single() takes ptl by itself in zap_pte_range(). It's not
> > going to work.
> 
> I have a test program that exercises this path ... it seems to work!
> Following the code, I don't understand why it does.  Maybe it's not
> exercising this path after all?  I've attached the program (so that I
> have an "oh, duh" moment about 5 seconds after sending the email).

See below.

> 
> > And zap_page_range*() is pretty heavy weapon to shoot down one pte, which
> > we already have pointer to. Why?
> 
> I'd love to use a lighter-weight weapon!  What would you recommend using,
> zap_pte_range()?

The most straight-forward way: extract body of pte cycle from
zap_pte_range() to separate function -- zap_pte() -- and use it.

> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <sys/types.h>
> #include <sys/mman.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <errno.h>
> 
> int
> main(int argc, char *argv[])
> {
> 	int fd;
> 	void *addr;
> 	char buf[4096];
> 
> 	if (argc != 2) {
> 		fprintf(stderr, "usage: %s filename\n", argv[0]);
> 		exit(1);
> 	}
> 
> 	if ((fd = open(argv[1], O_CREAT|O_RDWR, 0666)) < 0) {
> 		perror(argv[1]);
> 		exit(1);
> 	}
> 
> 	if (ftruncate(fd, 4096) < 0) {

Shouldn't this be ftruncate(fd, 0)? Otherwise the memcpy() below will
fault in page from backing storage, not hole and write will not replace
anything.

> 		perror("ftruncate");
> 		exit(1);
> 	}
> 
> 	if ((addr = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED,
> 					fd, 0)) == MAP_FAILED) {
> 		perror("mmap");
> 		exit(1);
> 	}
> 
> 	close(fd);
> 
> 	/* first read */
> 	memcpy(buf, addr, 4096);
> 
> 	/* now write a bit */
> 	memcpy(addr, buf, 8);
> 
> 	printf("%s: test passed.\n", argv[0]);
> 	exit(0);
> }


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
