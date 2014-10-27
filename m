Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id CEE006B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 23:17:00 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id p10so4730874pdj.5
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 20:17:00 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id x10si9185168pas.153.2014.10.26.20.16.58
        for <linux-mm@kvack.org>;
        Sun, 26 Oct 2014 20:16:59 -0700 (PDT)
Message-ID: <544DB873.1010207@intel.com>
Date: Mon, 27 Oct 2014 11:13:55 +0800
From: Ren Qiaowei <qiaowei.ren@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410241451280.5308@nanos>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On 10/24/2014 10:40 PM, Thomas Gleixner wrote:
> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
>> Since we are doing the freeing from munmap() (and other paths like it),
>> we hold mmap_sem for write. If we fault, the page fault handler will
>> attempt to acquire mmap_sem for read and we will deadlock. For now, to
>> avoid deadlock, we disable page faults while touching the bounds directory
>> entry. This keeps us from being able to free the tables in this case.
>> This deficiency will be addressed in later patches.
>
> This is wrong to begin with. You need a proper design for addressing
> this short coming in the first place. Retrofitting it into your
> current design will just not work at all or end up with some major
> mess.
>
> The problem to solve is, that the kernel needs to unmap the bounds
> table if the data mapping which it covers goes away.
>
> You decided to do that at the end of unmap with mmap_sem write
> held. As I explained last time, that's not an absolute requirement,
> it's just a random choice. And that choice is obvioulsy not a really
> good one as your own observation of the page fault issue proves.
>
> So perhaps we should look at it the other way round. We already know
> before the actual unmap happens what's the start and the end of the
> area.
>
> So we can be way smarter and do the following:
>
>     mpx_pre_unmap(from, len);
>
>     down_write(mmap_sem);
>     do_unmap(from, len);
>     up_write(mmap_sem);
>
>     mpx_post_unmap(mpx_unmap);
>
> int mpx_pre_unmap(...)
> {
>      down_write(mm->bd_sem);
>
>      down_read(mm->mmap_sem);
>
>      Here we do the following:
>
>      1) Invalidate the bounds table entries for the to be unmapped area in
>         the bounds directory. This can fault as we only hold mmap sem for
>         read.
>
>      2) Mark the corresponding VMAs which should be unmapped and
>         removed.  This can be done with mmap sem down read held as the
>         VMA chain cannot be changed and the 'Mark for removal" field is
>         protected by mm->bd_sem.
>
>         For each to be removed VMA we increment mm->bd_remove_vmas
>
>      Holding mm->bd_sem also prevents that a new bound table to be
>      inserted, if we do the whole protection thing right.
>
>      up_read(mm->mmap_sem);
> }
>
> void mpx_post_unmap(void)
> {
> 	if (mm->bd_remove_vmas) {
> 	   down_write(mm->mmap_sem);
>   	   cleanup_to_be_removed_vmas();		
> 	   up_write(mm->mmap_sem);
> 	}
>
> 	up_write(mm->bd_sem);
> }
>

If so, I guess that there are some questions needed to be considered:

1) Almost all palces which call do_munmap() will need to add 
mpx_pre_unmap/post_unmap calls, like vm_munmap(), mremap(), shmdt(), etc..

2) before mpx_post_unmap() call, it is possible for those bounds tables 
within mm->bd_remove_vmas to be re-used.

In this case, userspace may do new mapping and access one address which 
will cover one of those bounds tables. During this period, HW will check 
if one bounds table exist, if yes one fault won't be produced.

3) According to Dave, those bounds tables related to adjacent VMAs 
within the start and the end possibly don't have to be fully unmmaped, 
and we only need free the part of backing physical memory.

> The mpx_pre_unmap/post_unmap calls can be either added explicit to the
> relevant down_write/unmap/up_write code pathes or you hide it behind
> some wrapper function.
>
> Now you need to acquire mm->bd_sem for the fault handling code as well
> in order to serialize the creation of new bound table entries. In that
> case a down_read(mm->bd_sem) is sufficient as the cmpxchg() prevents
> the insertion of multiple tables for the same directory entries.
>
> So we'd end up with the following serialization scheme:
>
> prctl enable/disable management:  down_write(mm->bd_sem);
>
> bounds violation:    		  down_read(mm->bd_sem);
>
> directory entry allocation:	  down_read(mm->bd_sem);
>
> directory entry removal:	  down_write(mm->bd_sem);
>
> Now we need to check whether there is a potential deadlock lurking
> around the corner. We get the following nesting scenarios:
>
> - prctl enable/disable management:  down_write(mm->bd_sem);
>
>     No mmap_sem nesting at all
>
> - bounds violation:    	     down_read(mm->bd_sem);
>
>     Might nest down_read(mm->mmap_sem) if the copy code from user space
>     faults.
>
> - directory entry allocation:	     down_read(mm->bd_sem);
>
>     Nests down_write(mm->mmap_sem) for the VMA allocation.
>
>     Might nest down_read(mm->mmap_sem) if the cmpxchg() for the
>     directory entry faults
>
> - directory entry removal:	  down_write(mm->bd_sem);
>
>     Might nest down_read(mm->mmap_sem) if the invalidation of the
>     directory entry faults
>
> In other words here is the possible nesting:
>
>    #1 down_read(mm->bd_sem);  down_read(mm->mmap_sem);
>
>    #2 down_read(mm->bd_sem);  down_write(mm->mmap_sem);
>
>    #3 down_write(mm->bd_sem); down_read(mm->mmap_sem);
>
>    #4 down_write(mm->bd_sem); down_write(mm->mmap_sem);
>
> We never execute any of those nested on a single task. The bounds
> fault handler is never nested as it always comes from user space. So
> we should be safe.
>
> And this prevents all the nasty race conditions I discussed in
> Portland with Dave which happen when we try do to stuff outside of the
> mmap_sem write held region.
>
> Performance wise it's not an issue either. The prctl case is not a a
> hotpath anyway. The fault handlers get away with down_read() and the
> unmap code is heavyweight on mmap sem write held anyway.
>
> Thoughts?
>
> Thanks,
>
> 	tglx
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
