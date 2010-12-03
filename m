Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 94BC76B0096
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 17:51:59 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id oB3MpuWf010543
	for <linux-mm@kvack.org>; Fri, 3 Dec 2010 14:51:57 -0800
Received: from qyk11 (qyk11.prod.google.com [10.241.83.139])
	by hpaq14.eem.corp.google.com with ESMTP id oB3MoGGh015735
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 3 Dec 2010 14:51:55 -0800
Received: by qyk11 with SMTP id 11so10587140qyk.3
        for <linux-mm@kvack.org>; Fri, 03 Dec 2010 14:51:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291416070.2032.92.camel@laptop>
References: <1291335412-16231-1-git-send-email-walken@google.com>
	<1291335412-16231-7-git-send-email-walken@google.com>
	<1291416070.2032.92.camel@laptop>
Date: Fri, 3 Dec 2010 14:51:50 -0800
Message-ID: <AANLkTikqTV3qD=BPb4ApAfbLOVDO9cCqoYCot9yTkb30@mail.gmail.com>
Subject: Re: [PATCH 6/6] x86 rwsem: more precise rwsem_is_contended() implementation
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 3, 2010 at 2:41 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, 2010-12-02 at 16:16 -0800, Michel Lespinasse wrote:
>> We would like rwsem_is_contended() to return true only once a contending
>> writer has had a chance to insert itself onto the rwsem wait queue.
>> To that end, we need to differenciate between active and queued writers.
>
> So you're only considering writer-writer contention? Not writer-reader
> and reader-writer contention?
>
> I'd argue rwsem_is_contended() should return true if there is _any_
> blocked task, be it a read or a writer.
>
> If you want something else call it something else, like
> rwsem_is_write_contended() (there's a pending writer), or
> rwsem_is_read_contended() (there's a pending reader).

I said 'a contending writer' because in my use case, the rwsem was
being held for read, and other readers would get admitted in (so they
don't count as contention).

The code as written will work in the more general case - it tells if
there is another thread queued waiting for the rwsem to be released.
It can't tell you however if that thread is a reader or a writer (but
if mmap_sem is already held for read, then the contending thread must
be a writer).

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
