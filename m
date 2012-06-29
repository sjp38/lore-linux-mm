Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id D99E56B0073
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 11:03:40 -0400 (EDT)
Message-ID: <4FEDC391.5030502@redhat.com>
Date: Fri, 29 Jun 2012 11:02:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/40] autonuma: x86 pte_numa() and pmd_numa()
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-7-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:55 AM, Andrea Arcangeli wrote:

>   static inline int pte_file(pte_t pte)
>   {
> -	return pte_flags(pte)&  _PAGE_FILE;
> +	return (pte_flags(pte)&  _PAGE_FILE) == _PAGE_FILE;
>   }

Wait, why is this change made?  Surely _PAGE_FILE is just
one single bit and this change is not useful?

If there is a reason for this change, please document it.

> @@ -405,7 +405,9 @@ static inline int pte_same(pte_t a, pte_t b)
>
>   static inline int pte_present(pte_t a)
>   {
> -	return pte_flags(a)&  (_PAGE_PRESENT | _PAGE_PROTNONE);
> +	/* _PAGE_NUMA includes _PAGE_PROTNONE */
> +	return pte_flags(a)&  (_PAGE_PRESENT | _PAGE_PROTNONE |
> +			       _PAGE_NUMA_PTE);
>   }
>
>   static inline int pte_hidden(pte_t pte)
> @@ -415,7 +417,46 @@ static inline int pte_hidden(pte_t pte)
>
>   static inline int pmd_present(pmd_t pmd)
>   {
> -	return pmd_flags(pmd)&  _PAGE_PRESENT;
> +	return pmd_flags(pmd)&  (_PAGE_PRESENT | _PAGE_PROTNONE |
> +				 _PAGE_NUMA_PMD);
> +}

Somewhat subtle. Better documentation in patch 5 will
help explain this.

> +#ifdef CONFIG_AUTONUMA
> +static inline int pte_numa(pte_t pte)
> +{
> +	return (pte_flags(pte)&
> +		(_PAGE_NUMA_PTE|_PAGE_PRESENT)) == _PAGE_NUMA_PTE;
> +}
> +
> +static inline int pmd_numa(pmd_t pmd)
> +{
> +	return (pmd_flags(pmd)&
> +		(_PAGE_NUMA_PMD|_PAGE_PRESENT)) == _PAGE_NUMA_PMD;
> +}
> +#endif

These could use a little explanation of how _PAGE_NUMA_* is
used and what the flags mean.

> +static inline pte_t pte_mknotnuma(pte_t pte)
> +{
> +	pte = pte_clear_flags(pte, _PAGE_NUMA_PTE);
> +	return pte_set_flags(pte, _PAGE_PRESENT|_PAGE_ACCESSED);
> +}
> +
> +static inline pmd_t pmd_mknotnuma(pmd_t pmd)
> +{
> +	pmd = pmd_clear_flags(pmd, _PAGE_NUMA_PMD);
> +	return pmd_set_flags(pmd, _PAGE_PRESENT|_PAGE_ACCESSED);
> +}
> +
> +static inline pte_t pte_mknuma(pte_t pte)
> +{
> +	pte = pte_set_flags(pte, _PAGE_NUMA_PTE);
> +	return pte_clear_flags(pte, _PAGE_PRESENT);
> +}
> +
> +static inline pmd_t pmd_mknuma(pmd_t pmd)
> +{
> +	pmd = pmd_set_flags(pmd, _PAGE_NUMA_PMD);
> +	return pmd_clear_flags(pmd, _PAGE_PRESENT);
>   }

These functions could use some explanation, too.

Why do the top ones set _PAGE_ACCESSED, while the bottom ones
leave _PAGE_ACCESSED alone?

I can guess the answer, but it should be documented so it is
also clear to people with less experience in the VM.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
