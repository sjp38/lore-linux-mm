Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 44B356B0031
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 03:18:51 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so5626716wiv.1
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 00:18:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id se11si19157993wic.40.2014.07.16.00.18.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 00:18:49 -0700 (PDT)
Message-ID: <53C62757.9080501@suse.cz>
Date: Wed, 16 Jul 2014 09:18:47 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] shmem: fix faulting into a hole, not taking i_mutex
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <alpine.LSU.2.11.1407150329250.2584@eggly.anvils> <53C551A8.2040400@suse.cz> <alpine.LSU.2.11.1407151156110.3571@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407151156110.3571@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/15/2014 09:26 PM, Hugh Dickins wrote:
>> 
>> > @@ -760,7 +760,7 @@ static int shmem_writepage(struct page *
>> >   			spin_lock(&inode->i_lock);
>> >   			shmem_falloc = inode->i_private;
>> 
>> Without ACCESS_ONCE, can shmem_falloc potentially become an alias on
>> inode->i_private and later become re-read outside of the lock?
> 
> No, it could be re-read inside the locked section (which is okay since
> the locking ensures the same value would be re-read each time), but it
> cannot be re-read after the unlock.  The unlock guarantees that (whereas
> an assignment after the unlock might be moved up before the unlock).
> 
> I searched for a simple example (preferably not in code written by me!)
> to convince you.  I thought it would be easy to find an example of
> 
> 	spin_lock(&lock);
> 	thing_to_free = whatever;
> 	spin_unlock(&lock);
> 	if (thing_to_free)
> 		free(thing_to_free);
> 
> but everything I hit upon was actually a little more complicated than
> than that (e.g. involving whatever(), or setting whatever = NULL after),
> and therefore less convincing.  Please hunt around to convince yourself.

Yeah, I thought myself on the way home that this is probably the case. I guess
some recent bugs made me too paranoid. Sorry for the noise and time you spent
explaining this :/

>> 
>> > -		if (!shmem_falloc ||
>> > -		    shmem_falloc->mode != FALLOC_FL_PUNCH_HOLE ||
>> > -		    vmf->pgoff < shmem_falloc->start ||
>> > -		    vmf->pgoff >= shmem_falloc->next)
>> > -			shmem_falloc = NULL;
>> > -		spin_unlock(&inode->i_lock);
>> > -		/*
>> > -		 * i_lock has protected us from taking shmem_falloc seriously
>> > -		 * once return from shmem_fallocate() went back up that
>> > stack.
>> > -		 * i_lock does not serialize with i_mutex at all, but it does
>> > -		 * not matter if sometimes we wait unnecessarily, or
>> > sometimes
>> > -		 * miss out on waiting: we just need to make those cases
>> > rare.
>> > -		 */
>> > -		if (shmem_falloc) {
>> > +		if (shmem_falloc &&
>> > +		    shmem_falloc->waitq &&
>> 
>> Here it's operating outside of lock.
> 
> No, it's inside the lock: just easier to see from the patched source
> than from the patch itself.

Ah, right :/

> Hugh
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
