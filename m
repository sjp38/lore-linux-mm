Date: Thu, 17 Jun 1999 03:36:50 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: [patch] 2.2.10_andrea-VM6.gz
Message-ID: <Pine.LNX.4.10.9906170258120.313-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Juergen Vollmer <vollmer@cocolab.de>, oxymoron@waste.org
Cc: linux-kernel@vger.rutgers.edu, kernel@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I just released a 2.2.10_andrea-VM6. This new patch is still better in
detecting an OOM condition (VM5 was working fine here but I had a report
from Juergen that is still able to deadlock VM5 with the same stack-eater
that was just working fine here... but I think to have fixed the only bit
of code (*) that may have confused VM5 and so VM6 should definitely never
deadlock with an OOM, and it definitely works still better than VM5 here).

It will also improve drammatically swap/VM performances compared to a
clean 2.2.10 (try if you don't trust :). It will also avoid init(1) to be
killed during OOM.

(as usual there is the SCHED_YIELD fix from Ingo + my reschedule_idle
 partial rewrite)

I also changed how I choose the task to kill: when 2.2.10_andrea-VM6
reaches OOM, it sends a SIGKILL to all tasks that belongs to the bigger MM
in the system. I perfectly know it's far from being a perfect solution
(there isn't a perfect solution except asking the user what to kill in a
dialog window, but we can't do that since we can't wait for an user
feedback) but it's the simpler one that is likely to avoid us to kill
innocent daemons when an application become crazy (like in the DBMS CGI
query case for example). We may want to change the heuristic to something
of more complex of course but I know there are cases where this simple
heuristic is just enough (and _needed_) to do the right thing. (we may
also use a sysctl to change the oom behaviour)

I will appreciate any feedback/comment about the patch :). Many thanks.

You can donwload the VM patch against 2.2.10 from here:

	ftp://e-mind.com/pub/andrea/kernel-patches/2.2.10_andrea-VM6.gz

As usual you are suggested to download from the mirrors though 8^):

	ftp://ftp.suse.com/pub/people/andrea/kernel-patches/2.2.10_andrea-VM6.gz
	(USA, Thanks to SuSE -> http://www.suse.com/, large bandwith)

	ftp://ftp.linux.it/pub/People/andrea/kernel-patches/2.2.10_andrea-VM6.gz
	(Italy, Thanks to linux.it guys)

	ftp://master.softaplic.com.br/pub/andrea/kernel-patches/2.2.10_andrea-VM6.gz
	(Brazil, Thanks to Edesio Costa e Silva <edesio@acm.org>, 2MBits/sec)

Andrea Arcangeli

(*) I think the reason VM5 may get confused and deadlock (as clean 2.2.10
does), is that I was considering a progress the unmapping of a private
mmap or of a swap cache page. So I may go into an infinite loop of
pagein/unmap/pagein/unmap without never really go oom().

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
