Date: Tue, 13 May 2003 18:10:22 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-Id: <20030513181022.6dbc5418.akpm@digeo.com>
In-Reply-To: <220550000.1052866808@baldur.austin.ibm.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
	<3EC15C6D.1040403@kolumbus.fi>
	<199610000.1052864784@baldur.austin.ibm.com>
	<20030513224929.GX8978@holomorphy.com>
	<220550000.1052866808@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: wli@holomorphy.com, mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> Actually it does fix it.  I added code in vmtruncate_list() to do a
>  down_write(&vma->vm_mm->mmap_sem) around the zap_page_range(), and the
>  problem went away.  It serializes against any outstanding page faults on a
>  particular page table.  New faults will see that the page is no longer in
>  the file and fail with SIGBUS.  Andrew's test case stopped failing.
> 
>  I've attached the patch so you can see what I did.
> 
>  Can anyone think of any gotchas to this solution?

mmap_sem nests outside i_shared_sem.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
