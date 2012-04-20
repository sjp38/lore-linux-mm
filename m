Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id D8B326B0112
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 18:11:50 -0400 (EDT)
Date: Fri, 20 Apr 2012 15:11:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
Message-Id: <20120420151143.433c514e.akpm@linux-foundation.org>
In-Reply-To: <1334356721-9009-1-git-send-email-yinghan@google.com>
References: <1334356721-9009-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>

On Fri, 13 Apr 2012 15:38:41 -0700
Ying Han <yinghan@google.com> wrote:

> The mmu_shrink() is heavy by itself by iterating all kvms and holding
> the kvm_lock. spotted the code w/ Rik during LSF, and it turns out we
> don't need to call the shrinker if nothing to shrink.
> 

We should probably tell the kvm maintainers about this ;)

> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -188,6 +188,11 @@ static u64 __read_mostly shadow_mmio_mask;
>  
>  static void mmu_spte_set(u64 *sptep, u64 spte);
>  
> +static inline int get_kvm_total_used_mmu_pages()
> +{
> +	return percpu_counter_read_positive(&kvm_total_used_mmu_pages);
> +}
> +
>  void kvm_mmu_set_mmio_spte_mask(u64 mmio_mask)
>  {
>  	shadow_mmio_mask = mmio_mask;
> @@ -3900,6 +3905,9 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  	if (nr_to_scan == 0)
>  		goto out;
>  
> +	if (!get_kvm_total_used_mmu_pages())
> +		return 0;
> +
>  	raw_spin_lock(&kvm_lock);
>  
>  	list_for_each_entry(kvm, &vm_list, vm_list) {
> @@ -3926,7 +3934,7 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  	raw_spin_unlock(&kvm_lock);
>  
>  out:
> -	return percpu_counter_read_positive(&kvm_total_used_mmu_pages);
> +	return get_kvm_total_used_mmu_pages();
>  }
>  
>  static struct shrinker mmu_shrinker = {

There's a small functional change: percpu_counter_read_positive() is an
approximate thing, so there will be cases where there will be some
pages which are accounted for only in the percpu_counter's per-cpu
accumulators.  In that case mmu_shrink() will bale out when there are
in fact some freeable pages available.  This is hopefully unimportant.

Do we actually know that this patch helps anything?  Any measurements? Is
kvm_total_used_mmu_pages==0 at all common?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
