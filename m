From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: Question: why hold source mm->mmap_sem write sem in dup_mmap()?
Date: Fri, 29 Sep 2006 18:02:16 -0700
Message-ID: <000301c6e42c$12a62490$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In the call chain of copy_page_range coming from do_fork(), dup_mmap holds
write semaphore on the oldmm.  I don't see copy_page_range() or dup_mmap
itself alter the source (oldmm)'s address space, what is the reason to hold
write semaphore on the source mm?  Won't a down_read(&oldmm->mmap_sem) be
sufficient?  Did I miss something there?


do_fork
  copy_process
    copy_mm
      dup_mm
        dup_mmap
          copy_page_range

static inline int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
{
        ...
        down_write(&oldmm->mmap_sem);
        flush_cache_mm(oldmm);
        down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
        ...
        for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
                ...
                retval = copy_page_range(mm, oldmm, mpnt);
        }
        ...

        up_write(&mm->mmap_sem);
        flush_tlb_mm(oldmm);
        up_write(&oldmm->mmap_sem);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
