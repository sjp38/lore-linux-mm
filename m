Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 0FF2A6B00FF
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 12:43:56 -0400 (EDT)
Received: by lbbgp10 with SMTP id gp10so2014834lbb.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 09:43:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBCNDaHeFakcQGGA5jop8-9YtZtG7B4pdPyyYvgnOoiRKA@mail.gmail.com>
References: <1334356721-9009-1-git-send-email-yinghan@google.com>
	<CAJd=RBCNDaHeFakcQGGA5jop8-9YtZtG7B4pdPyyYvgnOoiRKA@mail.gmail.com>
Date: Mon, 16 Apr 2012 09:43:53 -0700
Message-ID: <CALWz4iw879XbRSGK5VPM64DOR8Rx4KjdFdumvn1ppMJuUoXhvw@mail.gmail.com>
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, Apr 14, 2012 at 4:44 AM, Hillf Danton <dhillf@gmail.com> wrote:
> On Sat, Apr 14, 2012 at 6:38 AM, Ying Han <yinghan@google.com> wrote:
>> The mmu_shrink() is heavy by itself by iterating all kvms and holding
>> the kvm_lock. spotted the code w/ Rik during LSF, and it turns out we
>> don't need to call the shrinker if nothing to shrink.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0arch/x86/kvm/mmu.c | =A0 10 +++++++++-
>> =A01 files changed, 9 insertions(+), 1 deletions(-)
>>
>> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
>> index 4cb1642..7025736 100644
>> --- a/arch/x86/kvm/mmu.c
>> +++ b/arch/x86/kvm/mmu.c
>> @@ -188,6 +188,11 @@ static u64 __read_mostly shadow_mmio_mask;
>>
>> =A0static void mmu_spte_set(u64 *sptep, u64 spte);
>>
>> +static inline int get_kvm_total_used_mmu_pages()
>> +{
>> + =A0 =A0 =A0 return percpu_counter_read_positive(&kvm_total_used_mmu_pa=
ges);
>> +}
>> +
>> =A0void kvm_mmu_set_mmio_spte_mask(u64 mmio_mask)
>> =A0{
>> =A0 =A0 =A0 =A0shadow_mmio_mask =3D mmio_mask;
>> @@ -3900,6 +3905,9 @@ static int mmu_shrink(struct shrinker *shrink, str=
uct shrink_control *sc)
>> =A0 =A0 =A0 =A0if (nr_to_scan =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>>
>> + =A0 =A0 =A0 if (!get_kvm_total_used_mmu_pages())
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +
>> =A0 =A0 =A0 =A0raw_spin_lock(&kvm_lock);
>>
>> =A0 =A0 =A0 =A0list_for_each_entry(kvm, &vm_list, vm_list) {
>> @@ -3926,7 +3934,7 @@ static int mmu_shrink(struct shrinker *shrink, str=
uct shrink_control *sc)
>> =A0 =A0 =A0 =A0raw_spin_unlock(&kvm_lock);
>>
>> =A0out:
>> - =A0 =A0 =A0 return percpu_counter_read_positive(&kvm_total_used_mmu_pa=
ges);
>> + =A0 =A0 =A0 return get_kvm_total_used_mmu_pages();
>> =A0}
>>
> Just nitpick.
> If new helper not created, there is only one hunk needed.

Hmm, thought it looks nicer with the helpful function instead of long
percpu_counter_read_positive() in the if block.

>
> btw, make sense to check nr_to_scan while scanning vm_list, and bail out
> if it hits zero?

Not totally understand the nr_to_scan in that function, but we could
do a separate patch if that is needed.

--Ying
>
> Good Weekend
> -hd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
