Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2826B0036
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 16:07:45 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id uz6so8981484obc.1
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 13:07:44 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id m4si22413754oel.126.2014.03.11.13.07.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 13:07:44 -0700 (PDT)
Message-ID: <1394568453.2786.28.camel@buesod1.americas.hpqcorp.net>
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 11 Mar 2014 13:07:33 -0700
In-Reply-To: <531F6689.60307@oracle.com>
References: <531F6689.60307@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2014-03-11 at 15:39 -0400, Sasha Levin wrote:
> Hi all,
> 
> I've ended up deleting the log file by mistake, but this bug does seem to be important
> so I'd rather not wait before the same issue is triggered again.
> 
> The call chain is:
> 
> 	mlock (mm/mlock.c:745)
> 		__mm_populate (mm/mlock.c:700)
> 			__mlock_vma_pages_range (mm/mlock.c:229)
> 				VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));

So __mm_populate() is only called by mlock(2) and this VM_BUG_ON seems
wrong as we call it without the lock held:

	up_write(&current->mm->mmap_sem);
	if (!error)
		error = __mm_populate(start, len, 0);
	return error;
}

> 
> It seems to be a rather simple trace triggered from userspace. The only recent patch
> in the area (that I've noticed) was "mm/mlock: prepare params outside critical region".
> I've reverted it and trying to testing without it.

Odd, this patch should definitely *not* cause this. In any case every
operation removed from the critical region is local to the function:

	lock_limit = rlimit(RLIMIT_MEMLOCK);
	lock_limit >>= PAGE_SHIFT;
	locked = len >> PAGE_SHIFT;

	down_write(&current->mm->mmap_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
