Date: Fri, 2 Jul 2004 14:42:47 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bug 2995] New: madvise runs sucessfully for non-file mapped
 pages
Message-Id: <20040702144247.21233498.akpm@osdl.org>
In-Reply-To: <200407011338.i61DcD1B011203@fire-2.osdl.org>
References: <200407011338.i61DcD1B011203@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: susharma@in.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Unless this is very new behaviour, I don't think we can fix this until 2.7.  Changing
madvise's behaviour against anonymous memory addresses could break existing
applications.

bugme-daemon@osdl.org wrote:
>
> http://bugme.osdl.org/show_bug.cgi?id=2995
> 
>            Summary: madvise runs sucessfully for non-file mapped pages.
>     Kernel Version: 2.6.5-7.81
>             Status: NEW
>           Severity: high
>              Owner: akpm@digeo.com
>          Submitter: susharma@in.ibm.com
> 
> 
> Distribution: SLES-9 [RC-2] 
> Hardware Environment: x330, 2-Way, 1.0 GHz, 1.2 GB RAM 
> Software Environment: SLES-9 [RC-2], Kernel - 2.6.5-7.81 
> Problem Description: When you call madvise for a memory mapped area (allocated using 
> malloc) which is not part of any file, it gets PASSED without giving EBADF error. 
>  
> Steps to reproduce: 
> 1. Write a small program, in which allocate some memory (eg. 5 pages) like this :- 
>  
> 	char *ptr=NULL; 
> 	ptr = (char *) malloc(5 * PAGE_SIZE); 
>  
>   Now, call madvise for this malloced memory area (which is a part of any file) :- 
>  
> 	ptr = (char *)(((int) ptr + PAGE_SIZE-1) & ~(PAGE_SIZE-1)); // Alignment 
> 	if (madvise(ptr, 5 * PAGE_SIZE, MADV_NORMAL) < 0) 
> 	{ 
> 		perror("madvise failed"); 
> 	} 
> 	else 
> 	{ 
> 		printf("madvise passed\n"); 
> 	} 
>  
> Here, if you run this code you will find that madvise is getting PASSED even when you have 
> passed a memory area which is nowhere a part of file-mapped area. Actually, it should give 
> error with error code EBADF. 
>  
> Additional Information : Please refer to the manpage of madvise for the condition when EBADF 
> error code should be generated.
> 
> ------- You are receiving this mail because: -------
> You are the assignee for the bug, or are watching the assignee.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
