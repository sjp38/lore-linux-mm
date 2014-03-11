Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7AB6B0037
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 15:40:00 -0400 (EDT)
Received: by mail-yk0-f175.google.com with SMTP id 131so24361574ykp.6
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 12:40:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z48si37935598yhb.86.2014.03.11.12.39.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 12:39:59 -0700 (PDT)
Message-ID: <531F6689.60307@oracle.com>
Date: Tue, 11 Mar 2014 15:39:53 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Hi all,

I've ended up deleting the log file by mistake, but this bug does seem to be important
so I'd rather not wait before the same issue is triggered again.

The call chain is:

	mlock (mm/mlock.c:745)
		__mm_populate (mm/mlock.c:700)
			__mlock_vma_pages_range (mm/mlock.c:229)
				VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));

It seems to be a rather simple trace triggered from userspace. The only recent patch
in the area (that I've noticed) was "mm/mlock: prepare params outside critical region".
I've reverted it and trying to testing without it.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
