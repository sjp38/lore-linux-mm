Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA05411
	for <linux-mm@kvack.org>; Sat, 18 Jul 1998 11:50:23 -0400
Subject: Re: Comments on shmfs-0.1.010
References: <87n2a9o3m3.fsf@atlas.CARNet.hr> <m167gwm17r.fsf@flinx.npwt.net>
	<87hg0ffh7t.fsf@atlas.CARNet.hr>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 18 Jul 1998 11:03:10 -0500
In-Reply-To: Zlatko Calusic's message of 18 Jul 1998 14:59:02 +0200
Message-ID: <m1r9zjjge9.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:

>> This is a normal case with no harm.  
>> I think normal 2.1.101 should cause it too.
>> It's simply a result of swapping adding swap.

ZC> Well, it looks like it's harmless. I don't know why. :)

In that case it is harmless because it is reading the first page of
swap onto the swap lock!  And since there are no races there the lock
isn't needed.

>> Are you creating really large files in shmfs?

ZC> Yes, I was creating very big file to test some things.

ZC> But after I applied my patch, I never saw those kmalloc messages?!

Currently all of pointers to file blocks are allocated just in kernel
memory.  So really big files might cause that.  I haven't seen them so
I haven't a clue.

ZC> Unfortunately not. Time for experimenting ran out. :(

Well that at least tells me which options were used to get those
performance marks.


ZC> Yesterday I tried to copy linux tree to /shm and got these errors:

ZC> Tree has around 4200 files (which is slightly more than inode limit on 
ZC> Linux!). Few last files didn't get copied.

The story is that I allocate a fixed number of inodes to shmfs at mount time.
And then when I need one I look through those structures for one that is unused.

That is fine for testing my kernel patch, but in the long run it is a problem.
The temporary work around is to due:
mount -t shmfs -o inodes=10240 none /tmp
Anything less than 65535 should be legal.

The raw development version has a fix for this and a few other things
that I allocate in kernel memory, but it isn't stable yet.  I'm using
the stable code to create my kernel patches.

Eric



--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
