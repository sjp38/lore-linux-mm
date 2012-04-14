Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id E14896B004A
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 07:44:48 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so3700411vcb.14
        for <linux-mm@kvack.org>; Sat, 14 Apr 2012 04:44:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334356721-9009-1-git-send-email-yinghan@google.com>
References: <1334356721-9009-1-git-send-email-yinghan@google.com>
Date: Sat, 14 Apr 2012 19:44:47 +0800
Message-ID: <CAJd=RBCNDaHeFakcQGGA5jop8-9YtZtG7B4pdPyyYvgnOoiRKA@mail.gmail.com>
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, Apr 14, 2012 at 6:38 AM, Ying Han <yinghan@google.com> wrote:
> The mmu_shrink() is heavy by itself by iterating all kvms and holding
> the kvm_lock. spotted the code w/ Rik during LSF, and it turns out we
> don't need to call the shrinker if nothing to shrink.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =C2=A0arch/x86/kvm/mmu.c | =C2=A0 10 +++++++++-
> =C2=A01 files changed, 9 insertions(+), 1 deletions(-)
>
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 4cb1642..7025736 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -188,6 +188,11 @@ static u64 __read_mostly shadow_mmio_mask;
>
> =C2=A0static void mmu_spte_set(u64 *sptep, u64 spte);
>
> +static inline int get_kvm_total_used_mmu_pages()
> +{
> + =C2=A0 =C2=A0 =C2=A0 return percpu_counter_read_positive(&kvm_total_use=
d_mmu_pages);
> +}
> +
> =C2=A0void kvm_mmu_set_mmio_spte_mask(u64 mmio_mask)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0shadow_mmio_mask =3D mmio_mask;
> @@ -3900,6 +3905,9 @@ static int mmu_shrink(struct shrinker *shrink, stru=
ct shrink_control *sc)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nr_to_scan =3D=3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
>
> + =C2=A0 =C2=A0 =C2=A0 if (!get_kvm_total_used_mmu_pages())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0raw_spin_lock(&kvm_lock);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry(kvm, &vm_list, vm_list) {
> @@ -3926,7 +3934,7 @@ static int mmu_shrink(struct shrinker *shrink, stru=
ct shrink_control *sc)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0raw_spin_unlock(&kvm_lock);
>
> =C2=A0out:
> - =C2=A0 =C2=A0 =C2=A0 return percpu_counter_read_positive(&kvm_total_use=
d_mmu_pages);
> + =C2=A0 =C2=A0 =C2=A0 return get_kvm_total_used_mmu_pages();
> =C2=A0}
>
Just nitpick.
If new helper not created, there is only one hunk needed.

btw, make sense to check nr_to_scan while scanning vm_list, and bail out
if it hits zero?

Good Weekend
-hd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
