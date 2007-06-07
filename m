Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JwE8q025546
	for <linux-mm@kvack.org>; Thu, 7 Jun 2007 15:58:14 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JwEAl208222
	for <linux-mm@kvack.org>; Thu, 7 Jun 2007 13:58:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JwDMA018214
	for <linux-mm@kvack.org>; Thu, 7 Jun 2007 13:58:14 -0600
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20070607124824.27e909fd.akpm@linux-foundation.org>
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	 <20070606204432.b670a7b1.akpm@linux-foundation.org>
	 <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	 <1181233393.9995.14.camel@dyn9047017100.beaverton.ibm.com>
	 <787b0d920706070943h6ac65b85nee5b01600905be08@mail.gmail.com>
	 <1181235997.9995.23.camel@dyn9047017100.beaverton.ibm.com>
	 <20070607124824.27e909fd.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 07 Jun 2007 12:59:23 -0700
Message-Id: <1181246363.9995.37.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Albert Cahalan <acahalan@gmail.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, ebiederm@xmission.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-07 at 12:48 -0700, Andrew Morton wrote:
> On Thu, 07 Jun 2007 10:06:37 -0700
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> 
> > On Thu, 2007-06-07 at 12:43 -0400, Albert Cahalan wrote:
> > > On 6/7/07, Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > > 
> > > > BTW, I agree with Eric that its would be nice to use shmid as part
> > > > of name instead of forcing to be as inode number. It should be
> > > > possible for pmap to workout shmid from "key" or name. Isn't it ?
> > > 
> > > It is not at all nice.
> > > 
> > > 1. it's incompatible ABI breakage
> > > 2. where will you put the key then, in the inode? :-)
> > 
> > Nope. Currently "key" is part of the name (but its not unique).
> > 
> > > 
> > > Changing to "SYSVID%d" is no good either. Look, people
> > > are ***parsing*** this stuff in /proc. The /proc filesystem
> > > is not some random sandbox to be playing in.
> > > 
> > > Before you go messing with it, note that the device number
> > > also matters. (it's per-boot dynamic, but that's OK)
> > > That's how one knows that /SYSV00000000 is not just
> > > a regular file; sadly these didn't get a non-/ prefix.
> > > (and no you can't fix that now; it's way too late)
> > > 
> > > Next time you feel like breaking an ABI, mind putting
> > > "LET'S BREAK AN ABI!" in the subject of your email?
> > 
> > I am not breaking ABI. Its already broken in the current
> > mainline. I am trying to fix it by putting back the ino#
> > as shmid. Eric had a suggestion that, instead of depending
> > on the inode# to be shmid, we could embed shmid into name
> > (instead of "key" which is currently not unique).
> > 
> > > BTW, I suspect this kind of thing also breaks:
> > > a. fuser, lsof, and other resource usage display tools
> > > b. various obscure emulators (similar to valgrind)
> > 
> > If you strongly feel that "old" behaviour needs to be retained, 
> 
> yup, we should put it back.  The change was, afaik, accidental.
> 
> > here is the patch I originally suggested.
> 
> Confused.  Will this one-liner fix all the userspace breakage to which
> Albert refers?

Yes. Albert, please correct me if I am wrong.

Thanks,
Badari


> > "ino#" in /proc/pid/maps used to match "ipcs -m" output for shared 
> > memory (shmid). It was useful in debugging, but its changed recently. 
> > This patch sets inode number to shared memory id to match /proc/pid/maps.
> > 
> > Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> > 
> > Index: linux-2.6.22-rc4/ipc/shm.c
> > ===================================================================
> > --- linux-2.6.22-rc4.orig/ipc/shm.c	2007-06-04 17:57:25.000000000 -0700
> > +++ linux-2.6.22-rc4/ipc/shm.c	2007-06-06 08:23:57.000000000 -0700
> > @@ -397,6 +397,7 @@ static int newseg (struct ipc_namespace 
> >  	shp->shm_nattch = 0;
> >  	shp->id = shm_buildid(ns, id, shp->shm_perm.seq);
> >  	shp->shm_file = file;
> > +	file->f_dentry->d_inode->i_ino = shp->id;
> >  
> >  	ns->shm_tot += numpages;
> >  	shm_unlock(shp);
> > 
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
