Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8276A6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 10:06:02 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so88751862wms.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 07:06:02 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id y138si82177356wme.81.2017.01.05.07.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 07:06:01 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id m203so96898377wma.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 07:06:01 -0800 (PST)
Date: Thu, 5 Jan 2017 18:05:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Respect FOLL_FORCE/FOLL_COW for thp
Message-ID: <20170105150558.GE17319@node.shutemov.name>
References: <20170105053658.GA36383@juliacomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170105053658.GA36383@juliacomputing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keno Fischer <keno@juliacomputing.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, gthelen@google.com, npiggin@gmail.com, w@1wt.eu, oleg@redhat.com, keescook@chromium.org, luto@kernel.org, mhocko@suse.com, hughd@google.com

On Thu, Jan 05, 2017 at 12:36:58AM -0500, Keno Fischer wrote:
> In 19be0eaff ("mm: remove gup_flags FOLL_WRITE games from __get_user_pages()"),
> the mm code was changed from unsetting FOLL_WRITE after a COW was resolved to
> setting the (newly introduced) FOLL_COW instead. Simultaneously, the check in
> gup.c was updated to still allow writes with FOLL_FORCE set if FOLL_COW had
> also been set. However, a similar check in huge_memory.c was forgotten. As a
> result, remote memory writes to ro regions of memory backed by transparent huge
> pages cause an infinite loop in the kernel (handle_mm_fault sets FOLL_COW and
> returns 0 causing a retry, but follow_trans_huge_pmd bails out immidiately
> because `(flags & FOLL_WRITE) && !pmd_write(*pmd)` is true. While in this
> state, the process is stil SIGKILLable, but little else works (e.g. no ptrace
> attach, no other signals). This is easily reproduced with the following
> code (assuming thp are set to always):
> 
> ```
> #include <assert.h>
> #include <fcntl.h>
> #include <stdint.h>
> #include <stdio.h>
> #include <string.h>
> #include <sys/mman.h>
> #include <sys/stat.h>
> #include <sys/types.h>
> #include <sys/wait.h>
> #include <unistd.h>
> 
> #define TEST_SIZE 5 * 1024 * 1024
> 
> int main(void) {
>   int status;
>   pid_t child;
>   int fd = open("/proc/self/mem", O_RDWR);
>   void *addr =
>       mmap(NULL, TEST_SIZE, PROT_READ, MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
>   assert(addr != MAP_FAILED);
>   pid_t parent_pid = getpid();
>   if ((child = fork()) == 0) {
>     void *addr2 = mmap(NULL, TEST_SIZE, PROT_READ | PROT_WRITE,
>                        MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
>     assert(addr2 != MAP_FAILED);
>     memset(addr2, 'a', TEST_SIZE);
>     pwrite(fd, addr2, TEST_SIZE, (uintptr_t)addr);
>     return 0;
>   }
>   assert(child == waitpid(child, &status, 0));
>   assert(WIFEXITED(status) && WEXITSTATUS(status) == 0);
>   return 0;
> }
> ```
> 
> Fix this by updating the instances in huge_memory.c analogously to
> the update in gup.c in the original commit. The same pattern existed in
> follow_devmap_pmd, so I have changed that location as well. However,
> I do not have a test case that for that code path.
> 
> Signed-off-by: Keno Fischer <keno@juliacomputing.com>

Good catch.

> ---
>  mm/huge_memory.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 10eedbf..84497a8 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -773,6 +773,16 @@ static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
>  		update_mmu_cache_pmd(vma, addr, pmd);
>  }
>  
> +/*
> + * FOLL_FORCE can write to even unwritable pmd's, but only
> + * after we've gone through a COW cycle and they are dirty.
> + */
> +static inline bool can_follow_write_pmd(pmd_t pmd, unsigned int flags)
> +{
> +       return pmd_write(pmd) ||
> +               ((flags & FOLL_FORCE) && (flags & FOLL_COW) && pmd_dirty(pmd));
> +}
> +
>  struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
>  		pmd_t *pmd, int flags)
>  {
> @@ -783,7 +793,7 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
>  
>  	assert_spin_locked(pmd_lockptr(mm, pmd));
>  
> -	if (flags & FOLL_WRITE && !pmd_write(*pmd))
> +	if (flags & FOLL_WRITE && !can_follow_write_pmd(*pmd, flags))
>  		return NULL;

I don't think this part is needed: once we COW devmap PMD entry, we split
it into PTE table, so IIUC we never get here with PMD.

Maybe we should WARN_ONCE() if have FOLL_COW here.

>  
>  	if (pmd_present(*pmd) && pmd_devmap(*pmd))
> @@ -1137,7 +1147,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  
>  	assert_spin_locked(pmd_lockptr(mm, pmd));
>  
> -	if (flags & FOLL_WRITE && !pmd_write(*pmd))
> +	if (flags & FOLL_WRITE && !can_follow_write_pmd(*pmd, flags))
>  		goto out;
>  
>  	/* Avoid dumping huge zero page */
> -- 
> 2.9.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
