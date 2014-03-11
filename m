Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6E71B6B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 18:07:33 -0400 (EDT)
Received: by mail-ea0-f182.google.com with SMTP id b10so4629077eae.27
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 15:07:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id p44si44039749eeu.5.2014.03.11.15.07.30
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 15:07:31 -0700 (PDT)
Date: Tue, 11 Mar 2014 16:57:01 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
Message-ID: <20140311205701.GA16658@redhat.com>
References: <531F6689.60307@oracle.com>
 <1394568453.2786.28.camel@buesod1.americas.hpqcorp.net>
 <20140311133051.bf5ca716ef189746ebcff431@linux-foundation.org>
 <531F75D1.3060909@oracle.com>
 <1394570844.2786.42.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394570844.2786.42.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 11, 2014 at 01:47:24PM -0700, Davidlohr Bueso wrote:
 > On Tue, 2014-03-11 at 16:45 -0400, Sasha Levin wrote:
 > > On 03/11/2014 04:30 PM, Andrew Morton wrote:
 > > > All I can think is that find_vma() went and returned a vma from a
 > > > different mm, which would be odd.  How about I toss this in there?
 > > >
 > > > --- a/mm/vmacache.c~a
 > > > +++ a/mm/vmacache.c
 > > > @@ -72,8 +72,10 @@ struct vm_area_struct *vmacache_find(str
 > > >   	for (i = 0; i < VMACACHE_SIZE; i++) {
 > > >   		struct vm_area_struct *vma = current->vmacache[i];
 > > >
 > > > -		if (vma && vma->vm_start <= addr && vma->vm_end > addr)
 > > > +		if (vma && vma->vm_start <= addr && vma->vm_end > addr) {
 > > > +			BUG_ON(vma->vm_mm != mm);
 > > >   			return vma;
 > > > +		}
 > > >   	}
 > > 
 > > [  243.565794] kernel BUG at mm/vmacache.c:76!
 > 
 > and this is also part of the DEBUG_PAGEALLOC + trinity combo! I suspect
 > the root cause it the same as Fengguang's report.

btw, I added a (ugly) script to trinity.git this afternoon:
https://github.com/kernelslacker/trinity/commit/b6cfe63ea5b205a34bc6c5698e5b766dfcddad1d
which should make reproducing VM related bugs happen a lot faster.

While chasing one particular issue, that script has hit 2-3 others in my
testing so far today (All already known).

It would be really good if people other than me & Sasha started running stuff like this occasionally
to try and get some of the more annoying things fixed up faster. Though it's only really
useful with debug kernels, and I know from past experience that asking people to try running things
with debug options enabled is like pulling teeth..

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
