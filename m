Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9KFBgpD029254
	for <linux-mm@kvack.org>; Thu, 20 Oct 2005 11:11:42 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9KFCatE550082
	for <linux-mm@kvack.org>; Thu, 20 Oct 2005 09:12:36 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9KFBftB008119
	for <linux-mm@kvack.org>; Thu, 20 Oct 2005 09:11:42 -0600
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051019204732.GA9922@localhost.localdomain>
References: <1129570219.23632.34.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>
	 <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>
	 <1129651502.23632.63.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com>
	 <1129747855.8716.12.camel@localhost.localdomain>
	 <20051019204732.GA9922@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 20 Oct 2005 08:11:05 -0700
Message-Id: <1129821065.16301.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, dvhltc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-19 at 16:47 -0400, Jeff Dike wrote:
> On Wed, Oct 19, 2005 at 11:50:55AM -0700, Badari Pulavarty wrote:
> > Darren Hart is working on patch to add madvise(DISCARD) to extend
> > the functionality of madvise(DONTNEED) to really drop those pages.
> > I was going to ask your opinion on that approach :) 
> > 
> > shmget(SHM_NORESERVE) + madvise(DISCARD) should do what I was
> > hoping for. (BTW, none of this has been tested with database stuff -
> > I am just concentrating on reasonable extensions.
> 
> madvise(DISCARD) has a promising name, but the implementation seems to be
> very differant from what the name says.
> 
> This would seem to throw out all pages in the file after offset, which
> makes the end parameter kind of pointless:
> 
> +               down(i_sem);
> +               truncate_inode_pages(vma->vm_file->f_mapping, offset);
> +               up(i_sem);
> 
> It will also fully truncate files which you have only partially
> mapped, which is somewhat counterintuitive.

Yes. I agree. We were just trying to re-use existing code to see if it
even works.

Initial plan was to use invalidate_inode_pages2_range(). But it didn't
really do what we wanted. So we ended up using truncate_inode_pages().
If it really works, then I plan to add truncate_inode_pages2_range()
to which works on a range of pages, instead of the whole file.
madvise(DONTNEED) followed by madvise(DISCARD) should be able to drop
all the pages in the given range.

Does this make sense ? Does this seem like right approach ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
