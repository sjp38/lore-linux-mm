Message-Id: <47CFE1AA.6040002@mxp.nes.nec.co.jp>
Date: Thu, 06 Mar 2008 21:20:58 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] cgroup swap subsystem
References: <47CE36A9.3060204@mxp.nes.nec.co.jp> <6599ad830803042236x3e5fdf0dmaf4119997025ba40@mail.gmail.com>
In-Reply-To: <6599ad830803042236x3e5fdf0dmaf4119997025ba40@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: containers@lists.osdl.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi.

Paul Menage wrote:
>>  +       pc = page_get_page_cgroup(page);
>>  +       if (WARN_ON(!pc))
>>  +               mm = &init_mm;
>>  +       else
>>  +               mm = pc->pc_mm;
>>  +       BUG_ON(!mm);
> 
> Is this safe against races with the mem.force_empty operation?
> 
I've not considered yet about force_empty operation
of memory subsystem.
Thank you for pointing it out.

>>  +
>>  +       rcu_read_lock();
>>  +       swap = rcu_dereference(mm->swap_cgroup);
>>  +       rcu_read_unlock();
>>  +       BUG_ON(!swap);
> 
> Is it safe to do rcu_read_unlock() while you are still planning to
> operate on the value of "swap"?
> 
You are right.
I think I should css_get() before rcu_read_unlock() as
memory subsystem does.

>>  +
>>  +#ifdef CONFIG_CGROUP_SWAP_LIMIT
>>  +               p->swap_cgroup = vmalloc(maxpages * sizeof(*swap_cgroup));
>>  +               if (!(p->swap_cgroup)) {
>>  +                       error = -ENOMEM;
>>  +                       goto bad_swap;
>>  +               }
>>  +               memset(p->swap_cgroup, 0, maxpages * sizeof(*swap_cgroup));
>>  +#endif
> 
> It would be nice to only allocate these the first time the swap cgroup
> subsystem becomes active, to avoid the overhead for people not using
> it; even better if you can free it again if the swap subsystem becomes
> inactive again.
> 
Hmm.. good idea.
I think this is possible by adding a flag file, like "swap.enable_limit",
to the top of cgroup directory, and charging all the swap entries
which are used when the flag is enabled to the top cgroup.



Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
