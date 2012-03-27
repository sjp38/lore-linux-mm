Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id EA6876B007E
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 08:47:40 -0400 (EDT)
Date: Tue, 27 Mar 2012 13:47:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v3
Message-ID: <20120327124734.GH16573@suse.de>
References: <20120307180852.GE17697@suse.de>
 <1332759384.16159.92.camel@twins>
 <20120326155027.GF16573@suse.de>
 <1332778852.16159.138.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1332778852.16159.138.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 26, 2012 at 06:20:52PM +0200, Peter Zijlstra wrote:
> > <SNIP>
> > 
> > I think such a change would be better but should also rename the API.
> > If developers see a get_foo type call, they will expect to see a put_foo
> > call or assume it's a bug even though the implementation happens to be ok
> > with that. Any suggestion on what a good new name would be?
> > 
> > How about read_mems_allowed_begin() and read_mems_allowed_retry()?
> > 
> > read_mems_allowed_begin would be a rename of get_mems_allowed().  In an
> > error path, read_mems_allowed_retry() would documented to be *optionally*
> > called when deciding whether to retry the operation or not. In this scheme,
> > !put_mems_allowed would become read_mems_allowed_retry() which might be
> > a bit easier to read overall.
> 
> One:
> 
> git grep -l "\(get\|put\)_mems_allowed" | while read file; do sed -i -e
> 's/\<get_mems_allowed\>/read_mems_allowed_begin/g' -e
> 's/\<put_mems_allowed\>/read_mems_allowed_retry/g' $file; done
> 
> and a few edits later..
> 
> ---
>  include/linux/cpuset.h |   18 +++++++++---------
>  kernel/cpuset.c        |    2 +-
>  mm/filemap.c           |    4 ++--
>  mm/hugetlb.c           |    4 ++--
>  mm/mempolicy.c         |   14 +++++++-------
>  mm/page_alloc.c        |    8 ++++----
>  mm/slab.c              |    4 ++--
>  mm/slub.c              |   16 +++-------------
>  8 files changed, 30 insertions(+), 40 deletions(-)
> 
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index 7a7e5fd..d008b03 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -89,25 +89,25 @@ extern void rebuild_sched_domains(void);
>  extern void cpuset_print_task_mems_allowed(struct task_struct *p);
>  
>  /*
> - * get_mems_allowed is required when making decisions involving mems_allowed
> + * read_mems_allowed_begin is required when making decisions involving mems_allowed
>   * such as during page allocation. mems_allowed can be updated in parallel
>   * and depending on the new value an operation can fail potentially causing
> - * process failure. A retry loop with get_mems_allowed and put_mems_allowed
> + * process failure. A retry loop with read_mems_allowed_begin and read_mems_allowed_retry
>   * prevents these artificial failures.
>   */

Going over 80 columns there. This happens in other places in the patch
but the alternative in those cases is less readable.

> -static inline unsigned int get_mems_allowed(void)
> +static inline unsigned int read_mems_allowed_begin(void)
>  {
>  	return read_seqcount_begin(&current->mems_allowed_seq);
>  }
>  
>  /*
> - * If this returns false, the operation that took place after get_mems_allowed
> + * If this returns false, the operation that took place after read_mems_allowed_begin
>   * may have failed. It is up to the caller to retry the operation if
>   * appropriate.
>   */

80 cols again and it should be "returns true". Something like this?

/*
 * If this returns true, the operation that took place after 
 * read_mems_allowed_begin may have failed artifically due to a paralle
 * update of mems_allowed. It is up to the caller to retry the operation
 * if appropriate.
 */

Other than that, the changes looked good and I agree that it is better
overall.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
