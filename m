From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14340.25292.109952.864869@dukat.scot.redhat.com>
Date: Wed, 13 Oct 1999 11:45:32 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <199910130125.SAA66579@google.engr.sgi.com>
References: <14338.25466.233239.59715@dukat.scot.redhat.com>
	<199910130125.SAA66579@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, manfreds@colorfullife.com, viro@math.psu.edu, andrea@suse.de, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 12 Oct 1999 18:25:42 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> This is a skeleton of the solution that prevents kswapd from walking
> down a vma chain without protections. I am trying to get comments on
> this approach before I try a full blown implementation.

> The rules:
> 1. To modify the vmlist (add/delete), you must hold mmap_sem to 
> guard against clones doing mmap/munmap/faults, (ie all vm system 
> calls and faults), and from ptrace, swapin due to swap deletion
> etc.
> 2. To modify the vmlist (add/delete), you must also hold
> vmlist_modify_lock, to guard against page stealers scanning the
> list.
> 3. To scan the vmlist, you must either 
> 	a. grab mmap_sem, which should be all cases except page stealer.
> or
> 	b. grab vmlist_access_lock, only done by page stealer.
> 4. While holding the vmlist_modify_lock, you must be able to guarantee
> that no code path will lead to page stealing.
> 5. You must be able to guarantee that while holding vmlist_modify_lock
> or vmlist_access_lock of mm A, you will not try to get either lock
> for mm B.

This looks like the same mechanism and set of rules that Al Viro
proposed, and it seems watertight.  I'd like the locking written down in
the source somewhere if anyone implements this, btw, as otherwise we'll
just be fixing it ourselves every time in the future when somebody who
doesn't understand them touches anything in the mmap paths...

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
