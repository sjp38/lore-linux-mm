Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 26F8F6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 02:41:17 -0400 (EDT)
Message-ID: <4FF14275.2010403@redhat.com>
Date: Mon, 02 Jul 2012 02:40:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 39/40] autonuma: bugcheck page_autonuma fields on newly
 allocated pages
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-40-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-40-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
> Debug tweak.

> +static inline void autonuma_check_new_page(struct page *page)
> +{
> +	struct page_autonuma *page_autonuma;
> +	if (!autonuma_impossible()) {
> +		page_autonuma = lookup_page_autonuma(page);
> +		BUG_ON(page_autonuma->autonuma_migrate_nid != -1);
> +		BUG_ON(page_autonuma->autonuma_last_nid != -1);

At this point, BUG_ON is not likely to give us a useful backtrace
at all.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2d53a1f..5943ed2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -833,6 +833,7 @@ static inline int check_new_page(struct page *page)
>   		bad_page(page);
>   		return 1;
>   	}
> +	autonuma_check_new_page(page);
>   	return 0;
>   }

Why don't you hook into the return codes that
check_new_page uses?

They appear to be there for a reason.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
