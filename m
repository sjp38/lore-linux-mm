Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 363D36B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 16:36:01 -0400 (EDT)
Received: by mail-yk0-f173.google.com with SMTP id 10so24494691ykt.4
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 13:36:01 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q45si38200426yhb.95.2014.03.11.13.36.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 13:36:00 -0700 (PDT)
Message-ID: <531F73AB.5060402@oracle.com>
Date: Tue, 11 Mar 2014 16:35:55 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
References: <531F6689.60307@oracle.com>	<1394568453.2786.28.camel@buesod1.americas.hpqcorp.net> <20140311133051.bf5ca716ef189746ebcff431@linux-foundation.org>
In-Reply-To: <20140311133051.bf5ca716ef189746ebcff431@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/11/2014 04:30 PM, Andrew Morton wrote:
> I worry about what happens if __get_user_pages decides to do
>
> 				if (ret & VM_FAULT_RETRY) {
> 					if (nonblocking)
> 						*nonblocking = 0;
> 					return i;
> 				}
>
> uh-oh, that just cleared __mm_populate()'s `locked' variable and we'll
> forget to undo mmap_sem.  That won't explain this result, but it's a
> potential problem.

That's actually seems right because if 'ret & VM_FAULT_RETRY' is true it means that
lock_page_or_retry() was supposed to release mmap_sem for us.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
