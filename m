Message-ID: <3ABA7851.AB080D44@redhat.com>
Date: Thu, 22 Mar 2001 17:10:25 -0500
From: Doug Ledford <dledford@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Prevent OOM from killing init
References: <E14gCYn-0003K3-00@the-village.bc.nu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Stephen Clouse <stephenc@theiqgroup.com>, Guest section DW <dwguest@win.tue.nl>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
> 
> > Really the whole oom_kill process seems bass-ackwards to me.  I can't in my mind
> > logically justify annihilating large-VM processes that have been running for
> > days or weeks instead of just returning ENOMEM to a process that just started
> > up.
> 
> How do you return an out of memory error to a C program that is out of memory
> due to a stack growth fault. There is actually not a language construct for it

Simple, you reclaim a few of those uptodate buffers.  My testing here has
resulting in more of my system daemons getting killed than anything else, and
it never once has solved the actual problem of simple memory pressure from
apps reading/writing to disk and disk cache not releasing buffers quick
enough.

> > It would be nice to give immunity to certain uids, or better yet, just turn the
> > damn thing off entirely.  I've already hacked that in...errr, out.
> 
> Eventually you have to kill something or the machine deadlocks. The oom killing
> doesnt kick in until that point. So its up to you how you like your errors.

I beg to differ.  If you tell me that a machine that looks like this:

[dledford@monster dledford]$ free
             total       used       free     shared    buffers     cached
Mem:       1017800    1014808       2992          0      73644     796392
-/+ buffers/cache:     144772     873028
Swap:            0          0          0
[dledford@monster dledford]$ 

is in need of killing sshd, I'll claim you are smoking some nice stuff ;-)

-- 

 Doug Ledford <dledford@redhat.com>  http://people.redhat.com/dledford
      Please check my web site for aic7xxx updates/answers before
                      e-mailing me about problems
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
