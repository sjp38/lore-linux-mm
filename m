Subject: Re: Documentation/vm/locking: why not hold two PT locks?
From: Ed L Cashin <ecashin@uga.edu>
Date: Sun, 08 Feb 2004 16:47:13 -0500
In-Reply-To: <1076275778.5608.1.camel@localhost> (Robert Love's message of
 "Sun, 08 Feb 2004 16:29:38 -0500")
Message-ID: <87ekt5ckgu.fsf@cs.uga.edu>
References: <8765ehe0cu.fsf@uga.edu> <1076275778.5608.1.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@ximian.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Robert Love <rml@ximian.com> writes:

> On Sun, 2004-02-08 at 16:18 -0500, Ed L Cashin wrote:
>
>> Hi.  Documentation/vm/locking says one must not simultaneously hold
>> the page table lock on mm A and mm B.  Is that true?  Where is the
>> danger?
>
> There isn't a proscribed lock ordering hierarchy, so you can deadlock.
>
> Assume thread 1 obtains the lock on mm A.
>
> Assume thread 2 obtains the lock on mm B.
>
> Assume thread 1 now obtains the lock on mm B - it is taken, so spin
> waiting.
>
> Assume thread 2 now obtains the lock on mm A - it too is taken, so spin
> waiting.
>
> Boom..

If that's all there is to it, then in my case, I have imposed a
locking hierarchy on my own code, so that wouldn't happen in my code.
I have a semaphore "S" outside of mmap_sem and page_table_lock.  Every
call path that can get to my code takes S before getting the
mmap_sem.  

  T1 gets S
  T1 gets mm A's mmap_sem
  T2 sleeps trying for S
  T1 gets A's PT lock
  T1 gets B's PT lock
  T1 clears a PTE in B 
  (I'd like to also be able to safely copy a PTE from B to A here)

  T1 puts B's PT lock
  T1 puts A's PT lock
  T1 puts A's mmap_sem
  T1 puts S

So it looks like my code is safe but not so efficient, since T2 has to
sleep when it doesn't get the semaphore S.  Is there some other
complication I'm missing?

-- 
--Ed L Cashin     PGP public key: http://noserose.net/e/pgp/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
