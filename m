From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14190.28416.483360.862142@dukat.scot.redhat.com>
Date: Mon, 21 Jun 1999 17:57:36 +0100 (BST)
Subject: Re: filecache/swapcache questions
In-Reply-To: <199906211646.JAA42546@google.engr.sgi.com>
References: <14190.8514.488478.168281@dukat.scot.redhat.com>
	<199906211646.JAA42546@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 21 Jun 1999 09:46:19 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> I don't agree with you about swapoff needing the mmap_sem. In my
> thinking, mmap_sem is needed to preserve the vma list, *if* you 
> go to sleep while scanning the list. Updates to the vma fields/
> chain are protected by kernel_lock and mmap_sem. 

No.  mmap_sem protects both the vma list and the page tables.  Page
faults hold the mmap semaphore both to protect the vma list and to
protect against concurrent pagins to the same page.  

The swapper is currently exempt from the mmap_sem, so the paging code
needs to check whether the current pte has disappeared if it ever
blocks, but it assumes that we never have concurrent pagein occurring
(think threads).  swapoff currently breaks that assumption.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
