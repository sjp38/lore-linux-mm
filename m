Message-ID: <20030820080504.66222.qmail@web14301.mail.yahoo.com>
Date: Wed, 20 Aug 2003 01:05:04 -0700 (PDT)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: bug in Documentation/vm/locking?
In-Reply-To: <87wud94v94.fsf@uga.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed L Cashin <ecashin@uga.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- Ed L Cashin <ecashin@uga.edu> wrote:
> Hi.  There is a strange sentence in
> Documentation/vm/locking, a very
> helpful summary of locking in the VM subsystem.  
> 
> Rule number five of the rules for using
> page_table_lock and mmap_sem
> says "page_table_lock or page_table_lock".  That's a
> funny thing to
> say, leading me to suspect that either it really
> should say
> "page_table_lock or mmap_sem" or just
> "page_table_lock" alone.
> 
> Here is the list of five rules.  Rule number five is
> the one I'm
> talking about:
> 
>   The rules are:
>   1. To scan the vmlist (look but don't touch) you
> must hold the
>      mmap_sem with read bias, i.e.
> down_read(&mm->mmap_sem)
>   2. To modify the vmlist you need to hold the
> mmap_sem with
>      read&write bias, i.e. down_write(&mm->mmap_sem)
>  *AND*
>      you need to take the page_table_lock.
>   3. The swapper takes _just_ the page_table_lock,
> this is done
>      because the mmap_sem can be an extremely long
> lived lock
>      and the swapper just cannot sleep on that.
>   4. The exception to this rule is expand_stack,
> which just
>      takes the read lock and the page_table_lock,
> this is ok
>      because it doesn't really modify fields anybody
> relies on.
>   5. You must be able to guarantee that while
> holding page_table_lock
>      or page_table_lock of mm A, you will not try to
> get either lock
>      for mm B.

Hi,

I can tell you that when I had sent the patch to
add this "locking" writeup to Linus, rule 5 used to
read:

5. You must be able to guarantee that while holding 
vmlist_modify_lock or vmlist_access_lock of mm A, you 
will not try to get either lock for mm B.

This was probably updated later on, as the kernel 
was changed. Hopefully, whoever updated it will
fix the typo.


> 
> So what should the rule say?  If you hold
> A->mm->mmap_sem is it OK to
> take B->mm->mmap_sem and B->mm->mmap_sem as long as
> you can guarantee
> that B won't try to get either of those locks in A?

The problem is in making that guarantee. At some
point in the past, it used to be that A or B or
any process could execute page stealer code, so 
there was a chance that deadlocks could happen;
unless that has changed, or you can smartly 
determine that A is holding B's lock, so B should
not try to get A's, this rule probably still applies
to the relevant locks.

THanks.

Kanoj

> 
> -- 
> --Ed L Cashin            |   PGP public key:
>   ecashin@uga.edu        |  
> http://noserose.net/e/pgp/
> 
> --
> To unsubscribe, send a message with 'unsubscribe
> linux-mm' in
> the body to majordomo@kvack.org.  For more info on
> Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org">
> aart@kvack.org </a>


__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free, easy-to-use web site design software
http://sitebuilder.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
