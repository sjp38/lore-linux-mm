Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id 477C16B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 16:47:26 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id j17so9289562oag.28
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 13:47:25 -0700 (PDT)
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com. [15.192.137.9])
        by mx.google.com with ESMTPS id uv2si25523900obb.19.2014.03.11.13.47.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 13:47:25 -0700 (PDT)
Message-ID: <1394570844.2786.42.camel@buesod1.americas.hpqcorp.net>
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 11 Mar 2014 13:47:24 -0700
In-Reply-To: <531F75D1.3060909@oracle.com>
References: <531F6689.60307@oracle.com>
		<1394568453.2786.28.camel@buesod1.americas.hpqcorp.net>
	 <20140311133051.bf5ca716ef189746ebcff431@linux-foundation.org>
	 <531F75D1.3060909@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2014-03-11 at 16:45 -0400, Sasha Levin wrote:
> On 03/11/2014 04:30 PM, Andrew Morton wrote:
> > All I can think is that find_vma() went and returned a vma from a
> > different mm, which would be odd.  How about I toss this in there?
> >
> > --- a/mm/vmacache.c~a
> > +++ a/mm/vmacache.c
> > @@ -72,8 +72,10 @@ struct vm_area_struct *vmacache_find(str
> >   	for (i = 0; i < VMACACHE_SIZE; i++) {
> >   		struct vm_area_struct *vma = current->vmacache[i];
> >
> > -		if (vma && vma->vm_start <= addr && vma->vm_end > addr)
> > +		if (vma && vma->vm_start <= addr && vma->vm_end > addr) {
> > +			BUG_ON(vma->vm_mm != mm);
> >   			return vma;
> > +		}
> >   	}
> >
> >   	return NULL;
> 
> Bingo! With the above patch:
> 
> [  243.565794] kernel BUG at mm/vmacache.c:76!
> [  243.566720] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  243.568048] Dumping ftrace buffer:
> [  243.568740]    (ftrace buffer empty)
> [  243.569481] Modules linked in:
> [  243.570203] CPU: 10 PID: 10073 Comm: trinity-c332 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00010-g1f812cb-dirty #143

and this is also part of the DEBUG_PAGEALLOC + trinity combo! I suspect
the root cause it the same as Fengguang's report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
