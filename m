Message-ID: <45285CEA.1070104@yahoo.com.au>
Date: Sun, 08 Oct 2006 12:05:30 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2/3] mm: fault vs invalidate/truncate race fix
References: <20061007105758.14024.70048.sendpatchset@linux.site>	<20061007105842.14024.85533.sendpatchset@linux.site> <20061007134401.a28b7735.akpm@osdl.org>
In-Reply-To: <20061007134401.a28b7735.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>On Sat,  7 Oct 2006 15:06:21 +0200 (CEST)
>Nick Piggin <npiggin@suse.de> wrote:
>
>
>>Fix the race between invalidate_inode_pages and do_no_page.
>>
>
>- In do_no_page() there's a `goto retry' where we appear to have
>  forgotten to (conditionally) unlock the page.
>

Hmm, the retry should be gone - it was only there for the
seqlock-ish truncate race code.

>- In do_no_page() the COW-break code seem to have forgotten to
>  (conditionally) unlock the page which it just COWed?
>

It keeps the 'nopage_page' around and unlocks it at the end.
Last time I looked, this is required because truncate wants to
unmap 'even_cows', so we must hold the pagecache page locked
while instantiating the mapping on the cow page.

>- In do_no_page(), the unlock_page() which _is_ there doesn't test
>  VM_CAN_INVALIDATE before deciding to unlock the page.
>

It does a conditional lock if !VM_CAN_INVALIDATE based on a
suggestion from Hugh. I don't disagree with that, but it can
go away in the next patch as we won't be calling into
->page_mkwrite (if that callback can be implemented with ->fault).

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
