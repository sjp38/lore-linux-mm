Date: Tue, 13 May 2003 16:11:39 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <20030513231139.GZ8978@holomorphy.com>
References: <154080000.1052858685@baldur.austin.ibm.com> <3EC15C6D.1040403@kolumbus.fi> <199610000.1052864784@baldur.austin.ibm.com> <20030513224929.GX8978@holomorphy.com> <220550000.1052866808@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <220550000.1052866808@baldur.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Mika Penttil? <mika.penttila@kolumbus.fi>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tuesday, May 13, 2003 15:49:29 -0700 William Lee Irwin III <wli@holomorphy.com> wrote:
>> That doesn't sound like it's going to help, there isn't a unique
>> mmap_sem to be taken and so we just get caught between acquisitions
>> with the same problem.

On Tue, May 13, 2003 at 06:00:08PM -0500, Dave McCracken wrote:
> Actually it does fix it.  I added code in vmtruncate_list() to do a
> down_write(&vma->vm_mm->mmap_sem) around the zap_page_range(), and the
> problem went away.  It serializes against any outstanding page faults on a
> particular page table.  New faults will see that the page is no longer in
> the file and fail with SIGBUS.  Andrew's test case stopped failing.
> I've attached the patch so you can see what I did.
> Can anyone think of any gotchas to this solution?

Okay, what's stopping filemap_nopage() from fetching the page from
pagecache after one of the mm->mmap_sem's is dropped but before
truncate_inode_pages() removes the page? The fault path is only locked
out for one mm during one part of the operation. I can see taking
->i_sem in do_no_page() fixing it, but not ->mmap_sem in vmtruncate()
(but of course that's _far_ too heavy-handed to merge at all).

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
