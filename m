Received: from mail.ccr.net (ccr@alogconduit1an.ccr.net [208.130.159.14])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA11462
	for <linux-mm@kvack.org>; Wed, 30 Dec 1998 15:59:46 -0500
Subject: Re: Large-File support of 32-bit Linux v0.01 available!
References: <19981230162959Z92285-18654+43@mea.tmt.tele.fi>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 Dec 1998 14:04:58 -0600
In-Reply-To: Matti Aarnio's message of "Wed, 30 Dec 1998 18:29:53 +0200 (EET)"
Message-ID: <m14sqds8et.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Matti Aarnio <matti.aarnio@sonera.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "MA" == Matti Aarnio <matti.aarnio@sonera.fi> writes:

>> Yeah.  I actually found/made time to work on this.
>> This is my patch for allowing large files in the page cache.
>> vm_offset is no more.  I am currently running it.

MA> 	Yeah, well, I see the code, but I don't like all
MA> 	implications of what you did.    My patches (see URL
MA> 	via Linux-MM page, or below ) do handle page-cache
MA> 	in very much similar manner, but add an abstraction
MA> 	layer on top of the simple scalar type for debug purposes.
MA> 	You could have done that too, and perhaps found earlier
MA> 	the bugs that did nag you...

Possibly.
My patch started a lot longer ago, and that just hadn't occured to me.
Also changing the name gave about the same benefits as changing the type.

I wound up finding two bugs one (I think) in filemap_nopage,
and one generic_file_mmap.

And I didn't start testing until after I saw your patch.

The primary part where I prefer yours to mine is that in most places
I have avoided more 64bit arithmetic.

MA> 	Why unaligned data at the page-cache ?
MA> 	And why more than PAGE_SIZE * 4G for file sizes in 32-bit systems ?
MA> 	After all, that gives us 16 TB file sizes.

Unaligned access because there may be some special devices where it makes sense.
And deny the possibility at the VFS layer is close to evil.
I won't implement just make it possible.

Greater than 16 TB file sizes because there is no good reason to limit ourselves
to so little, if it doesn't affect the speed of the general case.

Because linux 2.4 will be aiming at the really big hardware, where they
already have drives (or at least tape libraries) in the TB range.

MA> 	I would like to wait a bit to hear, what Stephen has to say.

What I'm aiming at is flexibility.
Having a type (besides inode) allows a lot nice functionality etc, in the page cache.

Nothing may be misaligned with respect to a vmstore structure,
but if you need to you may have multiple stores.

This makes things like swap cache, totally legitate uses.
And soon I'm going to sit the buffer cache in the page cache as well.

My primary work is dirty data in the page cache, and providing a general mechanism
for handling it.  This should make caching network filesystems, and 
compressed filesystems much easier, to code.

As well as letting them use the same mechanism everything else in kernel uses for
that kind of caching.  That means those kinds of applications don't have to tune
the whole kernel, just because they have slight different caching requirements.

Further with that basic design it takes just a few extra lines of code to allow
for very very large filesystems, in the generic code, with out incuring any significant
overhead in the general case.

Anyhow judge it when you see it.

MA> 	All those are referenced at my LFS patch area.
MA> 	(See README) -- and some even copied there.
MA> 	( ftp://mea.ipv6.tmt.tele.fi/linux/LFS/ -- and for non-IPv6 users:
MA> 	  ftp://mea.tmt.tele.fi/linux/LFS/ )
Thanks.

MA> 	You sure did scramble the  *stat()  syscall family.

Agreed there.  I was just playing with that one.
The code is stable and functional, but not ready for kernel inclusion.

MA> 	I seem to have a cold/flu, which means I will have copious
MA> 	amounts of idle time at home, as I can't get to work for
MA> 	following few days :-/~ (nor much celebrate the new-year)


>> Now I'm off on vacation for the rest of this week.  And probably won't
>> have time until the first weekend in January to really work anymore on this.

And now I really leave.

Eric

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
