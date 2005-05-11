Date: Wed, 11 May 2005 09:24:57 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6.12-rc3 4/8] mm: manual page migration-rc2 -- add-sys_migrate_pages-rc2.patch
Message-ID: <20050511082457.GA24134@infradead.org>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043821.10876.47127.71762@jackhammer.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050511043821.10876.47127.71762@jackhammer.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> +#ifdef CONFIG_MEMORY_MIGRATE
> +	data8 sys_migrate_pages			// 1279
> +#else
> +	data8 sys_ni_syscall			// 1279
> +#endif

never ifdef syscall slots like this, use cond_syscall instead.

> +	if (nr_busy > 0) {
> +		pass++;
> +		if (pass > 10)
> +			return -EAGAIN;
> +		/* wait until some I/O completes and try again */
> +		blk_congestion_wait(WRITE, HZ/10);
> +		goto retry;

this is a layering violation.  How to wait is up to the implementor
of the address_space

> +asmlinkage long
> +sys_migrate_pages(const pid_t pid, const int count,
> +	caddr_t old_nodes, caddr_t new_nodes)

please avoid const quilifiers in syscall prototypes, they're rather
pointless anyway.  Also don't use caddr_t but rather pointers to what's
actually pointed to.  Here that would be shorts which is rather uncommon
in kernel interface.  Please use explicitly sized types (__u16 if you
want to keep it as-is or maybe __u32).

> +	struct mm_struct *mm = 0;

Please use NULL as the null pointer.  if you ran your code through sparse
it would have cought it.

> +	for(i = 0; i < count; i++)

please follow documented kernel style.

> +	atomic_dec(&mm->mm_users);

shouldn't this be an mmput()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
