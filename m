Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 592BD6B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 08:37:46 -0500 (EST)
Message-ID: <50FFE7A5.9000708@uclinux.org>
Date: Wed, 23 Jan 2013 23:37:41 +1000
From: Greg Ungerer <gerg@uclinux.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] Avoid populating unbounded num of ptes with mmap_sem
 held
References: <1356050997-2688-1-git-send-email-walken@google.com> <CANN689Eeh-s_npXe5nuEb1ryAcU-7CzSZ=X_6SUpUjA2FGh4ag@mail.gmail.com>
In-Reply-To: <CANN689Eeh-s_npXe5nuEb1ryAcU-7CzSZ=X_6SUpUjA2FGh4ag@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Michael,

On 12/21/2012 08:46 PM, Michel Lespinasse wrote:
> I wanted to ask if you could check the sanity of the following patches
> in nommu configurations. My understanding is that these always
> populate mappings when they are created, so that MAP_POPULATE and
> MAP_LOCKED are actually no-ops. Is this an accurate description ?

Sorry, I have been very slow at getting around to this.

MAP_LOCKED and MAP_POPULATE are effectively no-ops, we don't deal
with them on the no-mmu mmap path.

I had a look over the patches and they look ok to me with regard
to no-mmu. So if you still want it:

Acked-by: Greg Ungerer <gerg@uclinux.org>

Regards
Greg



> On Thu, Dec 20, 2012 at 4:49 PM, Michel Lespinasse <walken@google.com> wrote:
>> We have many vma manipulation functions that are fast in the typical case,
>> but can optionally be instructed to populate an unbounded number of ptes
>> within the region they work on:
>> - mmap with MAP_POPULATE or MAP_LOCKED flags;
>> - remap_file_pages() with MAP_NONBLOCK not set or when working on a
>>   VM_LOCKED vma;
>> - mmap_region() and all its wrappers when mlock(MCL_FUTURE) is in effect;
>> - brk() when mlock(MCL_FUTURE) is in effect.
>>
>> Current code handles these pte operations locally, while the sourrounding
>> code has to hold the mmap_sem write side since it's manipulating vmas.
>> This means we're doing an unbounded amount of pte population work with
>> mmap_sem held, and this causes problems as Andy Lutomirski reported
>> (we've hit this at Google as well, though it's not entirely clear why
>> people keep trying to use mlock(MCL_FUTURE) in the first place).
>>
>> I propose introducing a new mm_populate() function to do this pte
>> population work after the mmap_sem has been released. mm_populate()
>> does need to acquire the mmap_sem read side, but critically, it
>> doesn't need to hold continuously for the entire duration of the
>> operation - it can drop it whenever things take too long (such as when
>> hitting disk for a file read) and re-acquire it later on.
>>
>> The following patches are against v3.7:
>>
>> - Patches 1-2 fix some issues I noticed while working on the existing code.
>>   If needed, they could potentially go in before the rest of the patches.
>>
>> - Patch 3 introduces the new mm_populate() function and changes
>>   mmap_region() call sites to use it after they drop mmap_sem. This is
>>   inspired from Andy Lutomirski's proposal and is built as an extension
>>   of the work I had previously done for mlock() and mlockall() around
>>   v2.6.38-rc1. I had tried doing something similar at the time but had
>>   given up as there were so many do_mmap() call sites; the recent cleanups
>>   by Linus and Viro are a tremendous help here.
>>
>> - Patches 4-6 convert some of the less-obvious places doing unbounded
>>   pte populates to the new mm_populate() mechanism.
>>
>> - Patches 7-8 are code cleanups that are made possible by the
>>   mm_populate() work. In particular, they remove more code than the
>>   entire patch series added, which should be a good thing :)
>>
>> - Patch 9 is optional to this entire series. It only helps to deal more
>>   nicely with racy userspace programs that might modify their mappings
>>   while we're trying to populate them. It adds a new VM_POPULATE flag
>>   on the mappings we do want to populate, so that if userspace replaces
>>   them with mappings it doesn't want populated, mm_populate() won't
>>   populate those replacement mappings.
>>
>> Michel Lespinasse (9):
>>   mm: make mlockall preserve flags other than VM_LOCKED in def_flags
>>   mm: remap_file_pages() fixes
>>   mm: introduce mm_populate() for populating new vmas
>>   mm: use mm_populate() for blocking remap_file_pages()
>>   mm: use mm_populate() when adjusting brk with MCL_FUTURE in effect.
>>   mm: use mm_populate() for mremap() of VM_LOCKED vmas
>>   mm: remove flags argument to mmap_region
>>   mm: directly use __mlock_vma_pages_range() in find_extend_vma()
>>   mm: introduce VM_POPULATE flag to better deal with racy userspace programs
>>
>>  arch/tile/mm/elf.c   |    1 -
>>  fs/aio.c             |    6 +++-
>>  include/linux/mm.h   |   23 +++++++++---
>>  include/linux/mman.h |    4 ++-
>>  ipc/shm.c            |   12 ++++---
>>  mm/fremap.c          |   51 ++++++++++++++-------------
>>  mm/internal.h        |    4 +-
>>  mm/memory.c          |   24 -------------
>>  mm/mlock.c           |   94 +++++++++++++------------------------------------
>>  mm/mmap.c            |   77 ++++++++++++++++++++++++----------------
>>  mm/mremap.c          |   25 +++++++------
>>  mm/nommu.c           |    5 ++-
>>  mm/util.c            |    6 +++-
>>  13 files changed, 154 insertions(+), 178 deletions(-)
>>
>> --
>> 1.7.7.3
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
