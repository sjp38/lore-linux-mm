Date: Fri, 15 Oct 1999 15:04:33 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
In-Reply-To: <199910152139.OAA57321@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9910151459320.852-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: manfreds@colorfullife.com, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 15 Oct 1999, Kanoj Sarcar wrote:
> 
> This basically means that you are overloading the page_table_lock to do 
> the work of the vmlist_lock in my patch. Thus vmlist_modify_lock/
> vmlist_access_lock in my patch could be changed in mm.h to grab the 
> page_table_lock. As I mentioned before, moving to a spinlock to 
> protect the vma chain will need some changes to the vmscan.c code.

Agreed. 

> The reason I think most people suggested a different lock, namely vmlist_lock,
> is to reduce contention on the page_table_lock, so that all the other
> paths like mprotect/mlock/mmap/munmap do not end up grabbing the
> page_table_lock which is grabbed in the fault path.

There can be no contention on the page_table_lock in the absense of the
page stealer. The reason is simple: every single thing that gets the page
table lock has already gotten the mm lock beforehand, and as such
contention is never an issue.

Contention _only_ occurs for the specific case when somebody is scanning
the page tables in order to free up pages. And at that point it's not
contention any more, at that point it is the thing that protects us from
bad things happening.

As such, the hold time of the spinlock is entirely immaterial, and
coalescing the page table lock and the vmlist lock does not increase
contention, it only decreases the number of locks you have to get. At
least as far as I can see.

> Let me know how you want me to rework the patch. Imo, we should keep
> the macros vmlist_modify_lock/vmlist_access_lock, even if we do
> decide to overload the page table lock.

Don't think of it as overloading the page table lock. Notice how the page
table lock really isn't a page table lock - it really is just "protection
against vmscan", and it's misnamed mainly because the only part we
protected was the page tables (which isn't enough). 

So think of it as a fix to the current protection, and as that fix makes
it protect more than just the page tables (makes it protect everything
that is required), the name should also change.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
