Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 2CA8A6B004D
	for <linux-mm@kvack.org>; Sun, 22 Apr 2012 05:05:12 -0400 (EDT)
Message-ID: <4F93C9A3.40107@redhat.com>
Date: Sun, 22 Apr 2012 12:04:35 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
References: <1334356721-9009-1-git-send-email-yinghan@google.com> <20120420151143.433c514e.akpm@linux-foundation.org>
In-Reply-To: <20120420151143.433c514e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>

On 04/21/2012 01:11 AM, Andrew Morton wrote:
> On Fri, 13 Apr 2012 15:38:41 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > The mmu_shrink() is heavy by itself by iterating all kvms and holding
> > the kvm_lock. spotted the code w/ Rik during LSF, and it turns out we
> > don't need to call the shrinker if nothing to shrink.
> > 
>
> We should probably tell the kvm maintainers about this ;)
>
> > --- a/arch/x86/kvm/mmu.c
> > +++ b/arch/x86/kvm/mmu.c
> > @@ -188,6 +188,11 @@ static u64 __read_mostly shadow_mmio_mask;
> >  
> >  static void mmu_spte_set(u64 *sptep, u64 spte);
> >  
> > +static inline int get_kvm_total_used_mmu_pages()
> > +{
> > +	return percpu_counter_read_positive(&kvm_total_used_mmu_pages);
> > +}
> > +
> >  void kvm_mmu_set_mmio_spte_mask(u64 mmio_mask)
> >  {
> >  	shadow_mmio_mask = mmio_mask;
> > @@ -3900,6 +3905,9 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
> >  	if (nr_to_scan == 0)
> >  		goto out;
> >  
> > +	if (!get_kvm_total_used_mmu_pages())
> > +		return 0;
> > +
> >  	raw_spin_lock(&kvm_lock);
> >  
> >  	list_for_each_entry(kvm, &vm_list, vm_list) {
> > @@ -3926,7 +3934,7 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
> >  	raw_spin_unlock(&kvm_lock);
> >  
> >  out:
> > -	return percpu_counter_read_positive(&kvm_total_used_mmu_pages);
> > +	return get_kvm_total_used_mmu_pages();
> >  }
> >  
> >  static struct shrinker mmu_shrinker = {
>
> There's a small functional change: percpu_counter_read_positive() is an
> approximate thing, so there will be cases where there will be some
> pages which are accounted for only in the percpu_counter's per-cpu
> accumulators.  In that case mmu_shrink() will bale out when there are
> in fact some freeable pages available.  This is hopefully unimportant.
>
> Do we actually know that this patch helps anything?  Any measurements? Is
> kvm_total_used_mmu_pages==0 at all common?
>

It's very common - this corresponds to the case where the kvm module is
loaded but no virtual machines are present.  But in that case the
shrinker loop is not at all heavy - take a lock, iterate over an empty
list, release lock.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
