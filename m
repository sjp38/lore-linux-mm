Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l56Hat7W005413
	for <linux-mm@kvack.org>; Wed, 6 Jun 2007 13:36:55 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l56HalG5047374
	for <linux-mm@kvack.org>; Wed, 6 Jun 2007 11:36:52 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l56Haln2023234
	for <linux-mm@kvack.org>; Wed, 6 Jun 2007 11:36:47 -0600
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <m1sl95t3r4.fsf@ebiederm.dsl.xmission.com>
References: <1181146045.9503.67.camel@dyn9047017100.beaverton.ibm.com>
	 <m1sl95t3r4.fsf@ebiederm.dsl.xmission.com>
Content-Type: text/plain
Date: Wed, 06 Jun 2007 10:37:55 -0700
Message-Id: <1181151475.9503.77.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-06 at 11:02 -0600, Eric W. Biederman wrote:
> Badari Pulavarty <pbadari@us.ibm.com> writes:
> 
> > Hi Eric,
> >
> > Your recent cleanup to shm code, namely
> >
> > [PATCH] shm: make sysv ipc shared memory use stacked files
> >
> > took away one of the debugging feature for shm segments.
> > Originally, shmid were forced to be the inode numbers and
> > they show up in /proc/pid/maps for the process which mapped
> > this shared memory segments (vma listing). That way, its easy
> > to find out who all mapped this shared memory segment. Your
> > patchset, took away the inode# setting. So, we can't easily
> > match the shmem segments to /proc/pid/maps easily. (It was
> > really useful in tracking down a customer problem recently). 
> > Is this done deliberately ? Anything wrong in setting this back ?
> >
> > Comments ?
> >
> > Thanks,
> > Badari
> >
> > Without patch:
> > --------------
> >
> > # ipcs -m
> >
> > ------ Shared Memory Segments --------
> > key        shmid      owner      perms      bytes      nattch     status
> > 0x00000000 884737     db2inst1  767        33554432   13
> >
> > # grep 884737 /proc/*/maps
> > #
> >
> > With patch:
> > -----------
> >
> > # ipcs -m
> >
> > ------ Shared Memory Segments --------
> > key        shmid      owner      perms      bytes      nattch     status
> > 0x00000000 884737     db2inst1  767        33554432   13
> >
> > # grep 884737 /proc/*/maps
> > /proc/11110/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11111/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11112/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11113/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11114/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11115/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11116/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11117/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11118/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11121/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11122/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11124/maps:4000389c000-4000589c000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> > /proc/11575/maps:40006724000-40008724000 rw-s 00000000 00:08 884737
> > /SYSV00000000 (deleted)
> >
> >
> >
> > Here is the patch.
> >
> > "ino#" in /proc/pid/maps used to match "ipcs -m" output for shared 
> > memory (shmid). It was useful in debugging, but its changed recently. 
> > This patch sets inode number to shared memory id to match /proc/pid/maps.
> 
> Theoretically it makes the stacked file concept more brittle, because
> it means the lower layers can't care about their inode number.
> 
> We do need something to tie these things together.
> 
> So I suspect what makes most sense is to simply rename the dentry
> SYSVID<segmentid>

Yep. Currently, we use part of "key" as the dentry name. For example,

# ipcs

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x083d0d74 851968     db2inst1  767        33554432   13

# grep 83d0d74 /proc/*/maps
/proc/11110/maps:40004724000-40006724000 rw-s 00000000 00:08 851968  /SYSV083d0d74 (deleted)
/proc/11111/maps:40004724000-40006724000 rw-s 00000000 00:08 851968  /SYSV083d0d74 (deleted)
/proc/11112/maps:40004724000-40006724000 rw-s 00000000 00:08 851968  /SYSV083d0d74 (deleted)
/proc/11113/maps:40004724000-40006724000 rw-s 00000000 00:08 851968  /SYSV083d0d74 (deleted)
..

The issue is with the ones with key = 0x0000000, like following:

# ipcs

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00000000 884737     db2inst1  767        33554432   13
0x00000000 950275     db2fenc1  701        23052288   13

There is no unique way to identify them easily :(

I guess, like you suggested, we can change the dentry name to use shmid
instead of the portions of the "key" to make it unique. I think, I can 
work out a patch for this.


> 
> That should give you the necessary information while not doing something
> that is a long term maintenance problem.
> 
> Do you think you can cook up a patch to that effect?
> Otherwise I will see if I can.
> 
> In practice I'm not really against your change, but I would prefer
> to leave the code in a state where someone can reimplement hugetlbfs
> or shmfs and we simply don't care.

Thanks for your suggestion.

Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
