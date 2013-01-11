Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 642E46B005D
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 02:58:40 -0500 (EST)
Date: Fri, 11 Jan 2013 00:01:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Reproducible OOM with partial workaround
Message-Id: <20130111000119.8e9bdf5d.akpm@linux-foundation.org>
In-Reply-To: <201301110146.r0B1kF4T032208@como.maths.usyd.edu.au>
References: <50EF6A2C.7070606@linux.vnet.ibm.com>
	<201301110146.r0B1kF4T032208@como.maths.usyd.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: dave@linux.vnet.ibm.com, 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 Jan 2013 12:46:15 +1100 paul.szabo@sydney.edu.au wrote:

> > ... I don't believe 64GB of RAM has _ever_ been booted on a 32-bit
> > kernel without either violating the ABI (3GB/1GB split) or doing
> > something that never got merged upstream ...
> 
> Sorry to be so contradictory:
> 
> psz@como:~$ uname -a
> Linux como.maths.usyd.edu.au 3.2.32-pk06.10-t01-i386 #1 SMP Sat Jan 5 18:34:25 EST 2013 i686 GNU/Linux
> psz@como:~$ free -l
>              total       used       free     shared    buffers     cached
> Mem:      64446900    4729292   59717608          0      15972     480520
> Low:        375836     304400      71436
> High:     64071064    4424892   59646172
> -/+ buffers/cache:    4232800   60214100
> Swap:    134217724          0  134217724
> psz@como:~$ 
> 
> (though I would not know about violations).
> 
> But OK, I take your point that I should move with the times.

Check /proc/slabinfo, see if all your lowmem got eaten up by buffer_heads.

If so, you *may* be able to work around this by setting
/proc/sys/vm/dirty_ratio really low, so the system keeps a minimum
amount of dirty pagecache around.  Then, with luck, if we haven't
broken the buffer_heads_over_limit logic it in the past decade (we
probably have), the VM should be able to reclaim those buffer_heads.

Alternatively, use a filesystem which doesn't attach buffer_heads to
dirty pages.  xfs or btrfs, perhaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
