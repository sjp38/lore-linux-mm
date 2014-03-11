Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id CDFB66B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 17:59:48 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id x3so10501059qcv.11
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 14:59:48 -0700 (PDT)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id y69si11988545qgd.62.2014.03.11.14.59.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 14:59:48 -0700 (PDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so9016763qaj.7
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 14:59:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1394568453.2786.28.camel@buesod1.americas.hpqcorp.net>
References: <531F6689.60307@oracle.com>
	<1394568453.2786.28.camel@buesod1.americas.hpqcorp.net>
Date: Tue, 11 Mar 2014 14:59:47 -0700
Message-ID: <CANN689G2Mv+1zr0MgF17uA2GwKaCcEp-ckE=j5YzXHBxjP0tLA@mail.gmail.com>
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 11, 2014 at 1:07 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> On Tue, 2014-03-11 at 15:39 -0400, Sasha Levin wrote:

>> I've ended up deleting the log file by mistake, but this bug does seem to be important
>> so I'd rather not wait before the same issue is triggered again.
>>
>> The call chain is:
>>
>>       mlock (mm/mlock.c:745)
>>               __mm_populate (mm/mlock.c:700)
>>                       __mlock_vma_pages_range (mm/mlock.c:229)
>>                               VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
>
> So __mm_populate() is only called by mlock(2) and this VM_BUG_ON seems
> wrong as we call it without the lock held:

Not related to the bug, but please note that __mm_populate() is public
and has other call sites outside of mlock.c - namely, it is called
during mmap with MAP_POPULATE.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
