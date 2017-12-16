Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9805F6B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 09:45:53 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id h200so18245477itb.3
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 06:45:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p17si2426167ioo.331.2017.12.16.06.45.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 06:45:52 -0800 (PST)
Subject: Re: [patch v2 1/2] mm, mmu_notifier: annotate mmu notifiers with blockable invalidate callbacks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
	<20171215150429.f68862867392337f35a49848@linux-foundation.org>
	<cafa6cdb-886b-b010-753f-600ae86f5e71@I-love.SAKURA.ne.jp>
	<20171216113645.GG16951@dhcp22.suse.cz>
In-Reply-To: <20171216113645.GG16951@dhcp22.suse.cz>
Message-Id: <201712162345.BGD43248.FFOLJOFVQMHSOt@I-love.SAKURA.ne.jp>
Date: Sat, 16 Dec 2017 23:45:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, aarcange@redhat.com, benh@kernel.crashing.org, paulus@samba.org, oded.gabbay@gmail.com, alexander.deucher@amd.com, christian.koenig@amd.com, airlied@linux.ie, joro@8bytes.org, dledford@redhat.com, jani.nikula@linux.intel.com, mike.marciniszyn@intel.com, sean.hefty@intel.com, sivanich@sgi.com, boris.ostrovsky@oracle.com, jglisse@redhat.com, pbonzini@redhat.com, rkrcmar@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Sat 16-12-17 16:14:07, Tetsuo Handa wrote:
> > rwsem_is_locked() test isn't equivalent with __mutex_owner() == current test, is it?
> > If rwsem_is_locked() returns true because somebody else has locked it, there is
> > no guarantee that current thread has locked it before calling this function.
> > 
> > down_write_trylock() test isn't equivalent with __mutex_owner() == current test, is it?
> > What if somebody else held it for read or write (the worst case is registration path),
> > down_write_trylock() will return false even if current thread has not locked it for
> > read or write.
> > 
> > I think this WARN_ON_ONCE() can not detect incorrect call to this function.
> 
> Yes it cannot catch _all_ cases. This is an inherent problem of
> rwsem_is_locked because semaphores do not really have the owner concept.
> The core idea behind this, I guess, is to catch obviously incorrect
> usage and as such it gives us a reasonabe coverage. I could live without
> the annotation but rwsem_is_locked looks better than down_write_trylock
> to me.

I agree that rwsem_is_locked() is better than down_write_trylock() because
the former does not have side effect when nobody was holding the rwsem.

Looking at how rwsem_is_locked() is used in mm/ directory for sanity checks,
only VM_BUG_ON(), VM_BUG_ON_MM(), or VM_BUG_ON_VMA() are used. Therefore,
this WARN_ON_ONCE() usage might be irregular.

Also, regarding the problem that semaphores do not really have the owner
concept, we can add "struct task_struct *owner_of_mmap_sem_for_write" to
"struct mm_struct" and replace direct down_write_killable() etc. with
corresponding wrapper functions like

  int __must_check get_mmap_sem_write_killable(struct mm_struct *mm) {
      if (down_write_killable(&mm->mmap_sem))
          return -EINTR;
      mm->owner_of_mmap_sem_for_write = current;
      return 0;
  }

and make the rwsem_is_locked() test more robust by doing like

  bool mmap_sem_is_held_for_write_by_current(struct mm_struct *mm) {
      return mm->owner_of_mmap_sem_for_write == current;
  }

. If there is a guarantee that no thread is allowed to hold multiple
mmap_sem, wrapper functions which manipulate per "struct task_struct"
flag will work.

But the fundamental problem is that we are heavily relying on runtime
testing (e.g. lockdep / syzkaller). Since there are a lot of factors which
prevent sanity checks from being called (e.g. conditional calls based on
threshold check), we can not exercise all paths, and everybody is making
changes without understanding all the dependencies. Consider that nobody
noticed that relying on __GFP_DIRECT_RECLAIM with oom_lock held may cause
lockups. We are too easily introducing unsafe dependency. I think that we
need to describe all the dependencies without relying on runtime testing.

Back to MMU_INVALIDATE_DOES_NOT_BLOCK flag, I worry that we will fail to
notice when somebody in future makes changes with mmu notifier which
currently does not rely on __GFP_DIRECT_RECLAIM to by error rely on
__GFP_DIRECT_RECLAIM. Staying at "whether the callback might sleep"
granularity will help preventing such unnoticed dependency bugs from
being introduced.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
