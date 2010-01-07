Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ECEF2600580
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 14:24:57 -0500 (EST)
Date: Thu, 7 Jan 2010 13:24:33 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.LFD.2.00.1001071031440.7821@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1001071308320.2981@router.home>
References: <20100104182429.833180340@chello.nl>  <20100104182813.753545361@chello.nl>  <20100105054536.44bf8002@infradead.org>  <alpine.DEB.2.00.1001050916300.1074@router.home>  <20100105192243.1d6b2213@infradead.org>  <alpine.DEB.2.00.1001071007210.901@router.home>
  <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain> <1262884960.4049.106.camel@laptop> <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain> <alpine.LFD.2.00.1001070937180.7821@localhost.localdomain>
 <alpine.LFD.2.00.1001071031440.7821@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Arjan van de Ven <arjan@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010, Linus Torvalds wrote:

> +	if (brk < cur_brk)
> +		goto slow_case;
> +	if (brk == cur_brk)
> +		goto out;
> +
> +	vma = ok_to_extend_brk(mm, cur_brk, brk);
> +	if (!vma)
> +		goto slow_case;
> +
> +	spin_lock(&mm->page_table_lock);


page_table_lock used to serialize multiple fast brks?

CONFIG_SPLIT_PTLOCK implies that code will not use this lock in fault
handling. So no serialization with faults.

Also the current code assumes vm_end and so on to be stable if mmap_sem is
held. F.e. find_vma() from do_fault is now running while vm_end may be changing
under it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
