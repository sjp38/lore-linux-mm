Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3947B6B005A
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:23:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j65-v6so1062515oih.20
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:23:28 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c128-v6si843029oib.511.2018.03.28.03.23.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 03:23:26 -0700 (PDT)
Subject: Re: [PATCH] mm: Introduce i_mmap_lock_write_killable().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1522149570-4517-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180327145220.GJ5652@dhcp22.suse.cz>
In-Reply-To: <20180327145220.GJ5652@dhcp22.suse.cz>
Message-Id: <201803281923.EFF26009.OFOtJSMFHQFLVO@I-love.SAKURA.ne.jp>
Date: Wed, 28 Mar 2018 19:23:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com

Michal Hocko wrote:
> On Tue 27-03-18 20:19:30, Tetsuo Handa wrote:
> > If the OOM victim is holding mm->mmap_sem held for write, and if the OOM
> > victim can interrupt operations which need mm->mmap_sem held for write,
> > we can downgrade mm->mmap_sem upon SIGKILL and the OOM reaper will be
> > able to reap the OOM victim's memory.
> 
> This really begs for much better explanation. Why is it safe?

Basic idea is

  bool downgraded = false;
  down_write(mmap_sem);
  for (something_1_that_might_depend_mmap_sem_held_for_write;
       something_2_that_might_depend_mmap_sem_held_for_write;
       something_3_that_might_depend_mmap_sem_held_for_write) {
     something_4_that_might_depend_mmap_sem_held_for_write();
     if (fatal_signal_pending(current)) {
        downgrade_write(mmap_sem);
        downgraded = true;
        break;
     }
     something_5_that_might_depend_mmap_sem_held_for_write();
  }
  if (!downgraded)
    up_write(mmap_sem);
  else
    up_read(mmap_sem);

. That is, try to interrupt critical sections at locations where it is
known to be safe and consistent.

>                                                               Are you
> assuming that the killed task will not perform any changes on the
> address space?

If somebody drops mmap_sem held for write is not safe, how can the OOM
reaper work safely?

The OOM reaper is assuming that the thread who got mmap_sem held for write
is responsible to complete critical sections before dropping mmap_sem held
for write, isn't it?

Then, how an attempt to perform changes on the address space can become a
problem given that the thread who got mmap_sem held for write is responsible
to complete critical sections before dropping mmap_sem held for write?

>                What about ongoing page faults or other operations deeper
> in the call chain.

Even if there are ongoing page faults or other operations deeper in the call
chain, there should be no problem as long as the thread who got mmap_sem
held for write is responsible to complete critical sections before dropping
mmap_sem held for write.

>                    Why they are safe to change things for the child
> during the copy?

In this patch, the current thread who got mmap_sem held for write (which is
likely an OOM victim thread) downgrades mmap_sem, with an assumption that
current thread no longer accesses memory which might depend on mmap_sem held
for write.

dup_mmap() duplicates current->mm and to-be-duplicated mm is not visible yet.
If dup_mmap() failed, to-be-duplicated incomplete mm is discarded via mmput()
in dup_mm() rather than assigned to the child. Thus, this patch should not
change things which are visible to the child during the copy.

What we need to be careful is making changes to current->mm.
I'm assuming that current->mm->mmap_sem held for read is enough for
i_mmap_lock_write()/flush_dcache_mmap_lock()/vma_interval_tree_insert_after()/
flush_dcache_mmap_unlock()/i_mmap_unlock_write()/is_vm_hugetlb_page()/
reset_vma_resv_huge_pages()/__vma_link_rb(). But I'm not sure.

> 
> I am not saying this is wrong, I would have to think about that much
> more because mmap_sem tends to be used on many surprising places and the
> write lock just hide them all.

Then, an alternative approach which interrupts without downgrading is shown
below. But I'm not sure.

diff --git a/include/linux/fs.h b/include/linux/fs.h
index bb45c48..2f11c55 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -468,6 +468,11 @@ static inline void i_mmap_lock_write(struct address_space *mapping)
 	down_write(&mapping->i_mmap_rwsem);
 }
 
+static inline int i_mmap_lock_write_killable(struct address_space *mapping)
+{
+	return down_write_killable(&mapping->i_mmap_rwsem);
+}
+
 static inline void i_mmap_unlock_write(struct address_space *mapping)
 {
 	up_write(&mapping->i_mmap_rwsem);
diff --git a/kernel/fork.c b/kernel/fork.c
index 1e8c9a7..c9c141d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -473,10 +473,21 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 			struct inode *inode = file_inode(file);
 			struct address_space *mapping = file->f_mapping;
 
+			if (i_mmap_lock_write_killable(mapping)) {
+				/*
+				 * Pretend that this is not a file mapping, for
+				 * dup_mm() will after all discard this mm due
+				 * to fatal_signal_pending() check below. But
+				 * make sure not to call open()/close() hook
+				 * which might expect tmp->vm_file != NULL.
+				 */
+				tmp->vm_file = NULL;
+				tmp->vm_ops = NULL;
+				goto skip_file;
+			}
 			get_file(file);
 			if (tmp->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
-			i_mmap_lock_write(mapping);
 			if (tmp->vm_flags & VM_SHARED)
 				atomic_inc(&mapping->i_mmap_writable);
 			flush_dcache_mmap_lock(mapping);
@@ -486,6 +497,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 			flush_dcache_mmap_unlock(mapping);
 			i_mmap_unlock_write(mapping);
 		}
+skip_file:
 
 		/*
 		 * Clear hugetlb-related page reserves for children. This only
@@ -508,7 +520,13 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		if (!(tmp->vm_flags & VM_WIPEONFORK))
+		/*
+		 * Bail out as soon as possible, for dup_mm() will after all
+		 * discard this mm by returning an error.
+		 */
+		if (fatal_signal_pending(current))
+			retval = -EINTR;
+		else if (!(tmp->vm_flags & VM_WIPEONFORK))
 			retval = copy_page_range(mm, oldmm, mpnt);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
