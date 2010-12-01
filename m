Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D47EB6B00A5
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 14:29:39 -0500 (EST)
Date: Wed, 1 Dec 2010 14:29:35 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1330724443.975931291231775834.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <919384632.877731291171499343.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: oom is broken in mmotm 2010-11-09-15-31 tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>


> Hi, just a head-up. When testing oom for this tree, my workstation is
> immediately having no response to ssh, Desktop actions and so on apart
> from ping. I am trying to bisect but looks like git public server is
> having problem.
> 
> # git pull
> fatal: read error: Connection reset by peer
> 
> # git clone git://zen-kernel.org/kernel/mmotm.git
> Cloning into mmotm...
> fatal: read error: Connection reset by peer
This turned out that it was introduced by,

  d065bd810b6deb67d4897a14bfe21f8eb526ba99
  mm: retry page fault when blocking on disk transfer

It was reproduced by:
1) ssh to the test box.
2) try to trigger oom a few times using a malloc program there.

Then, the test box will be unable to process any oom to kill the memory allocation program. If switch VCs for the test box and hit a few ENTER keys locally manually, it may process further oom. After roll-back this one commit, it had no problem to cope the above reproducers and always correctly killed the allocation programs.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
