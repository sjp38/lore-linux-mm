Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8BA1A6B0088
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 02:54:18 -0500 (EST)
Date: Fri, 3 Dec 2010 08:53:50 +0100
From: Michael Leun <lkml20101129@newton.leun.net>
Subject: Re: kernel BUG at mm/truncate.c:475!
Message-ID: <20101203085350.55f94057@xenia.leun.net>
In-Reply-To: <20101202115722.1c00afd5@xenia.leun.net>
References: <20101130194945.58962c44@xenia.leun.net>
	<alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
	<E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu>
	<20101201124528.6809c539@xenia.leun.net>
	<E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
	<20101202084159.6bff7355@xenia.leun.net>
	<20101202091552.4a63f717@xenia.leun.net>
	<E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu>
	<20101202115722.1c00afd5@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2 Dec 2010 11:57:22 +0100
Michael Leun <lkml20101129@newton.leun.net> wrote:

> > Can you please describe in detail the workload that's causing this
> > to happen?
> 
> Thats rather complicated, but I'll try. Basically it boils down to:
> 
> unshare -n -m /bin/bash
> unionfs -o
> cow,suid,allow_other,max_files=65536 /home/netenv/user1-union=RW:/=RO /home/netenv/user1
> mount -n -t proc none /home/netenv/user1/proc mount -n -t sysfs
> none /home/netenv/user1/sys mount -n -t devtmpfs
> devtmpfs /home/netenv/user1/dev mount -n -t devpts
> devpts /home/netenv/user1/dev/pts chroot /home/netenv/user1 /bin/su -
> user1
[...]
> In some of this setups two or more environments share the same
> writable branch, so the files in this environments changed against
> real root of the machine are the same, e.g.:
> 
> [...]
> unionfs -o
> cow,suid,allow_other,max_files=65536 /home/netenv/commondir=RW:/=RO /home/netenv/user1
> [...]
> 
> and another one
> 
> [...]
> unionfs -o
> cow,suid,allow_other,max_files=65536 /home/netenv/commondir=RW:/=RO /home/netenv/user2
> [...]

Additional note: Happens also WITHOUT that "two unionfs mounts use the
same branch dir" stuff.

Really seems to happen much more often in 2.6.36.1 than in 2.6.36.

> I observed that unionfs process takes much more cpu power than usual
> before fault happens.

This also happens without that "two unionfs mounts use the same branch
dir" stuff.

-- 
MfG,

Michael Leun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
