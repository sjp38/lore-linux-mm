Message-ID: <420C4FEF.7040600@sgi.com>
Date: Fri, 11 Feb 2005 00:25:51 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: migration cache bug?
References: <420BB9E6.90303@sgi.com> <20050210164147.GA19877@logos.cnet>
In-Reply-To: <20050210164147.GA19877@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Marcelo,

Marcelo Tosatti wrote:

> 
> Thing is the PTE should have been remapped by touch_unmapped_address() at
> the end of generic_migrate_page() during the migration syscall.
>

It appears that get_user_pages() is returning -ENOMEM in 
touch_unmapped_address(), so I'm assuming the page is not remapped
by touch_umapped_address() for this reason.  My debug output looks like this
for the first page to be migrated:

touch_unmapped_address: mm=e00000b003de9b80 mm_users=3 addr=0x6000000000004000
touch_unmapped_address: find_vma() returned e00001b03a8d9210
do_swap_page: line 1369 file mm/memory.c returns VM_FAULT_OOM for pid 1995
      addr=0x6000000000004000
handle_pte_fault: line 1745 file mm/memory.c returns VM_FAULT_OOM for pid 1995
      addr=0x6000000000004000
get_user_pages: line 813 file mm/memory.c returns VM_FAULT_OOM for pid 1995
      addr=0x6000000000004000
touch_unmapped_address: get_user_pages() returned -12
generic_migrate_page: newpage=a0007fffffce74e0 is PageMigration 1
detach_from_migration_cache: page=a0007fffffce74e0
try_to_migrate_pages: pass: 0 1st try migrated page a0007ffeafdd75b0 to 
newpage a0007fffffce74e0 newnode 3
. . .

So I'm running into the same problem that will eventually cause the program
to be killed during the call to get_user_pages() from 
touch_unmapped_address().  (line 1369 in do_swap_page() is the same line
as the one I described in my previous email.)

> 
> Can you find you why is touch_unmapped_address() failing to work? 
>

As discussed above.

> To confirm this hypothesis, please comment the call to "detach_from_migration_cache(newpage)"
> at the end of generic_migrate_pages().
> 
> This should cause lookup_migration_cache() to succeed and remap the pte.
> 
Unfortunately, it doesn't matter whether we call detach_from_migration_cache()
or not.  The above trace does call it, but I've run it without that call as 
well and the result is the same.  That is, the calling program is still
getting killed after trying to touch the first migrated page after returning
from the system call that initiates all of this.

I'm starting to wonder if I am missing some crucial bit of code in the patches
that I have applied to my tree.  Could you take a quick look at the migration
cache patch that I sent you to see if it looks complete?  I'm guessing that
lookup_migration_cache() is failing for some reason.  I did verify that
add_to_migration_cache() is getting called and that it returns 0.

I'm going to be out of the office for a week starting early Sat morning, so
I may not be able to respond on this topic until the week of Feb 21st.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
