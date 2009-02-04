Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 17C8D6B003D
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 23:58:07 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id j3so1256410tid.8
        for <linux-mm@kvack.org>; Tue, 03 Feb 2009 20:58:04 -0800 (PST)
Date: Wed, 4 Feb 2009 13:57:45 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v2] fix mlocked page counter mistmatch
Message-ID: <20090204045745.GC6212@barrios-desktop>
References: <20090204103648.ECAF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090204024447.GB6212@barrios-desktop> <20090204115047.ECB5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090204115047.ECB5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 04, 2009 at 11:51:43AM +0900, KOSAKI Motohiro wrote:
> > > Could you please teach me why this issue doesn't happend on munlockall()?
> > > your scenario seems to don't depend on exit_mmap().
> > 
> > 
> > Good question.
> > It's a different issue.
> > It is related to mmap_sem locking issue. 
> > 
> > Actually, I am about to make a patch.
> > But, I can't understand that Why try_do_mlock_page should downgrade mm_sem ?
> > Is it necessary ? 
> > 
> > In munlockall path, mmap_sem already is holding in write-mode of mmap_sem.
> > so, try_to_mlock_page always fail to downgrade mmap_sem.
> > It's why it looks like working well about mlocked counter. 
> 
> lastest linus tree don't have downgrade mmap_sem.
> (recently it was removed)

Thnaks for information.

what is 'latest linus tree' ?
You mean '29-rc3-git5'?


With '29-rc3-git5', I found,

static int try_to_mlock_page(struct page *page, struct vm_area_struct *vma)
{
  int mlocked = 0; 

  if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
    if (vma->vm_flags & VM_LOCKED) {
      mlock_vma_page(page);
      mlocked++;  /* really mlocked the page */
    }    
    up_read(&vma->vm_mm->mmap_sem);
  }
  return mlocked;
}

It still try to downgrade mmap_sem.
Do I miss something ?

> 
> please see it.
> 

-- 
Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
