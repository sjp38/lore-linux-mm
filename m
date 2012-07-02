Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 66F706B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 00:49:30 -0400 (EDT)
Message-ID: <4FF1283E.3010704@redhat.com>
Date: Mon, 02 Jul 2012 00:49:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 31/40] autonuma: reset autonuma page data when pages are
 freed
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-32-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-32-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
> When pages are freed abort any pending migration. If knuma_migrated
> arrives first it will notice because get_page_unless_zero would fail.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> ---
>   mm/page_alloc.c |    4 ++++
>   1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48eabe9..841d964 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -615,6 +615,10 @@ static inline int free_pages_check(struct page *page)
>   		bad_page(page);
>   		return 1;
>   	}
> +	autonuma_migrate_page_remove(page);
> +#ifdef CONFIG_AUTONUMA
> +	page->autonuma_last_nid = -1;
> +#endif

Should these both be under the #ifdef ?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
