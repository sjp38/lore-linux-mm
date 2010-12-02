Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A8D186B0071
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 06:03:15 -0500 (EST)
Date: Thu, 2 Dec 2010 11:57:22 +0100
From: Michael Leun <lkml20101129@newton.leun.net>
Subject: Re: kernel BUG at mm/truncate.c:475!
Message-ID: <20101202115722.1c00afd5@xenia.leun.net>
In-Reply-To: <E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu>
References: <20101130194945.58962c44@xenia.leun.net>
	<alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
	<E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu>
	<20101201124528.6809c539@xenia.leun.net>
	<E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
	<20101202084159.6bff7355@xenia.leun.net>
	<20101202091552.4a63f717@xenia.leun.net>
	<E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 02 Dec 2010 10:42:51 +0100
Miklos Szeredi <miklos@szeredi.hu> wrote:

> On Thu, 2 Dec 2010, Michael Leun wrote:
> > > Kernel compile 2.6.36.1 with that .page_mkwrite commented out
> > > running now, will reboot really soon now (TM).
> > 
> > OK - that happened very fast again in 2.6.36.1.
> > 
> > Sorry for that tainted kernel, but cannot afford to additionally
> > have graphics lockups all the time - I've shown that it happens with
> > untainted kernel also (long run without fault yesterday also was
> > with nvidia.ko driver).
> > 
> > Until I've another suggestion what to try I'll swich back to 2.6.36
> > to see if it really happens less frequent there.
> 
> Can you please describe in detail the workload that's causing this to
> happen?

Thats rather complicated, but I'll try. Basically it boils down to:

unshare -n -m /bin/bash
unionfs -o cow,suid,allow_other,max_files=65536 /home/netenv/user1-union=RW:/=RO /home/netenv/user1
mount -n -t proc none /home/netenv/user1/proc
mount -n -t sysfs none /home/netenv/user1/sys
mount -n -t devtmpfs devtmpfs /home/netenv/user1/dev
mount -n -t devpts devpts /home/netenv/user1/dev/pts
chroot /home/netenv/user1 /bin/su - user1

Then run some shell-scripts in this shell running as user1.

Of course there is some more stuff as getting network connectivity in
this new namespace and so on, but I guess thats not important for the
fuse problem.

Then there are some (up to 6 at the moment) more setups like the above
one with different users (user2, user3 and so on) running concurrent.

In some of this setups two or more environments share the same writable
branch, so the files in this environments changed against real root of
the machine are the same, e.g.:

[...]
unionfs -o cow,suid,allow_other,max_files=65536 /home/netenv/commondir=RW:/=RO /home/netenv/user1
[...]

and another one

[...]
unionfs -o cow,suid,allow_other,max_files=65536 /home/netenv/commondir=RW:/=RO /home/netenv/user2
[...]

I observed that unionfs process takes much more cpu power than usual
before fault happens.

 elektra:~ # unionfs --version
unionfs-fuse version: 0.24
FUSE library version: 2.8.5
fusermount version: 2.8.5
using FUSE kernel interface version 7.12

-- 
MfG,

Michael Leun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
