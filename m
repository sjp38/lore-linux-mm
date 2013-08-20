Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 7DF146B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 19:04:21 -0400 (EDT)
Date: Tue, 20 Aug 2013 16:04:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/4] mm/pgtable: Fix continue to preallocate pmds
 even if failure occurrence
Message-Id: <20130820160418.5639c4f9975b84dc8dede014@linux-foundation.org>
In-Reply-To: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 20 Aug 2013 14:54:53 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:

> preallocate_pmds will continue to preallocate pmds even if failure
> occurrence, and then free all the preallocate pmds if there is
> failure, this patch fix it by stop preallocate if failure occurrence
> and go to free path.
>
> ...
>
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -196,21 +196,18 @@ static void free_pmds(pmd_t *pmds[])
>  static int preallocate_pmds(pmd_t *pmds[])
>  {
>  	int i;
> -	bool failed = false;
>  
>  	for(i = 0; i < PREALLOCATED_PMDS; i++) {
>  		pmd_t *pmd = (pmd_t *)__get_free_page(PGALLOC_GFP);
>  		if (pmd == NULL)
> -			failed = true;
> +			goto err;
>  		pmds[i] = pmd;
>  	}
>  
> -	if (failed) {
> -		free_pmds(pmds);
> -		return -ENOMEM;
> -	}
> -
>  	return 0;
> +err:
> +	free_pmds(pmds);
> +	return -ENOMEM;
>  }

Nope.  If the error path is taken, free_pmds() will free uninitialised
items from pmds[], which is a local in pgd_alloc() and contains random
stack junk.  The kernel will crash.

You could pass an nr_pmds argument to free_pmds(), or zero out the
remaining items on the error path.  However, although the current code
is a bit kooky, I don't see that it is harmful in any way.

> Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>

Ahem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
