From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200010131819.LAA39874@google.engr.sgi.com>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
Date: Fri, 13 Oct 2000 11:19:06 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.10010122203410.14174-100000@penguin.transmeta.com> from "Linus Torvalds" at Oct 12, 2000 10:05:19 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "David S. Miller" <davem@redhat.com>, saw@saw.sw.com.sg, davej@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tytso@mit.edu
List-ID: <linux-mm.kvack.org>

> 
> 
> On Thu, 12 Oct 2000, David S. Miller wrote:
> > 
> >    page_table_lock is supposed to protect normal page table activity (like
> >    what's done in page fault handler) from swapping out.
> >    However, grabbing this lock in swap-out code is completely missing!
> > 
> > Audrey, vmlist_access_{un,}lock == unlocking/locking page_table_lock.
> 
> Yeah, it's an easy mistake to make.
> 
> I've made it myself - grepping for page_table_lock and coming up empty in
> places where I expected it to be.
> 
> In fact, if somebody sends me patches to remove the "vmlist_access_lock()"
> stuff completely, and replace them with explicit page_table_lock things,
> I'll apply it pretty much immediately. I don't like information hiding,
> and right now that's the only thing that the vmlist_access_lock() stuff is
> doing.

Linus,

I came up with the vmlist_access_lock/vmlist_modify_lock names early in 
2.3. The reasoning behind that was that in most places where the "vmlist
lock" was being taken was to protect the vmlist chain, vma_t fields or
mm_struct fields. The fact that implementation wise this lock could be
the same as page_table_lock was a good idea that you suggested. 

Nevertheless, the name was chosen to indicate what type of things it was
guarding. For example, in the future, you might actually have a different
(possibly sleeping) lock to guard the vmachain etc, but still have a 
spin lock for the page_table_lock (No, I don't want to be drawn into a 
discussion of why this might be needed right now). Some of this is 
mentioned in Documentation/vm/locking.

Just thought I would mention, in case you don't recollect some of this
history. Of course, I understand the "information hiding" part.

Kanoj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
