Date: Sat, 3 Jun 2000 14:32:19 -0700 (PDT)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.3.x swap cache seems to be a big leak
In-Reply-To: <200004251203.FAA04709@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0006031428010.7928-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: sct@redhat.com, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, David S. Miller wrote:

>__delete_from_swap_cache depends upon remove_inode_page doing
>a put_page or similar to kill the reference of the swap cache
>itself

__delete_from_swap_cache must not decrease the reference count.

>We changed remove_inode_page during the page cache rewrite such
>that is no longer puts the page, the caller does.

shrink_mmap does in the made_inode_progress path (first release the swap
cache reference and then frees the page by issuing two put_page).

>So if I haven't missed something clever going on here, this would
>explain a lot of problems people have reported with swapping making
>their machines act weird and eventually run out of ram.

That's because the MM balancing is broken. Try to reproduce with the
classzone patch applied.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
