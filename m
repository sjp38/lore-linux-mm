Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA11339
	for <linux-mm@kvack.org>; Tue, 26 May 1998 16:24:48 -0400
Date: Tue, 26 May 1998 19:00:25 +0100
Message-Id: <199805261800.TAA01935@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: patch for 2.1.102 swap code
In-Reply-To: <199805251342.GAA03658@dm.cobaltmicro.com>
References: <356478F0.FE1C378F@star.net>
	<199805241728.SAA02816@dax.dcs.ed.ac.uk>
	<3569699E.6C552C74@star.net>
	<199805251342.GAA03658@dm.cobaltmicro.com>
Sender: owner-linux-mm@kvack.org
To: "David S. Miller" <davem@dm.cobaltmicro.com>
Cc: whawes@star.net, sct@dcs.ed.ac.uk, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com, linux-mm@kvack.org, number6@the-village.bc.nu
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 25 May 1998 06:42:53 -0700, "David S. Miller"
<davem@dm.cobaltmicro.com> said:

> Alas, I thought about this some more.  And one piece of code needs to
> be fixed for this invariant about the semaphore being held in the
> fault processing code paths to be true everywhere... ptrace()...

Yep --- I was just about to reply to your last mail with this point when
I got your follow-up.  I've also had one report that the writable cached
page reports started when debugging an electric-fenced binary under
gdb.  Has anyody seen these vm messages who has definitely NOT been
running gdb?

There's also the point that the whole swapout code munges page tables
without ever taking the mm semaphore, but that case ought to be
protected by the combination of (a) having the kernel spinlock and (b)
never stalling between starting a vma walk and modifying the pte.  (The
swapout code is pretty paranoid about this.)  However, I'm not
absolutely 100% sure that we don't have any unfortunate races left by
this exception.  (For example, do we ever protect a vma by the mm
semaphore without also doing a lock_kernel()?)

--Stephen
