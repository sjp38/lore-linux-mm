Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7346B0265
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 14:34:22 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so89162629igb.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 11:34:22 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id 200si17324678iof.67.2015.07.20.11.34.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jul 2015 11:34:21 -0700 (PDT)
Received: by iebmu5 with SMTP id mu5so123771103ieb.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 11:34:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e4ab6e8be3f9f94fe9814219c4a9a19c375a5835.1437303956.git.vdavydov@parallels.com>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<e4ab6e8be3f9f94fe9814219c4a9a19c375a5835.1437303956.git.vdavydov@parallels.com>
Date: Mon, 20 Jul 2015 11:34:21 -0700
Message-ID: <CAJu=L5_q=xWfANDBX2-Z3=uudof+ifKS56zEtAR372VqDWOj2Q@mail.gmail.com>
Subject: Re: [PATCH -mm v9 5/8] mmu-notifier: add clear_young callback
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: multipart/alternative; boundary=001a1140f33a44d7b2051b52c90a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

--001a1140f33a44d7b2051b52c90a
Content-Type: text/plain; charset=UTF-8

On Sun, Jul 19, 2015 at 5:31 AM, Vladimir Davydov <vdavydov@parallels.com>
wrote:

> In the scope of the idle memory tracking feature, which is introduced by
> the following patch, we need to clear the referenced/accessed bit not
> only in primary, but also in secondary ptes. The latter is required in
> order to estimate wss of KVM VMs. At the same time we want to avoid
> flushing tlb, because it is quite expensive and it won't really affect
> the final result.
>
> Currently, there is no function for clearing pte young bit that would
> meet our requirements, so this patch introduces one. To achieve that we
> have to add a new mmu-notifier callback, clear_young, since there is no
> method for testing-and-clearing a secondary pte w/o flushing tlb. The
> new method is not mandatory and currently only implemented by KVM.
>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Reviewed-by: Andres Lagar-Cavilla <andreslc@google.com>
> Acked-by: Paolo Bonzini <pbonzini@redhat.com>
> ---
>  include/linux/mmu_notifier.h | 44
> ++++++++++++++++++++++++++++++++++++++++++++
>  mm/mmu_notifier.c            | 17 +++++++++++++++++
>  virt/kvm/kvm_main.c          | 18 ++++++++++++++++++
>  3 files changed, 79 insertions(+)
>
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 61cd67f4d788..a5b17137c683 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -66,6 +66,16 @@ struct mmu_notifier_ops {
>                                  unsigned long end);
>
>         /*
> +        * clear_young is a lightweight version of clear_flush_young. Like
> the
> +        * latter, it is supposed to test-and-clear the young/accessed
> bitflag
> +        * in the secondary pte, but it may omit flushing the secondary
> tlb.
> +        */
> +       int (*clear_young)(struct mmu_notifier *mn,
> +                          struct mm_struct *mm,
> +                          unsigned long start,
> +                          unsigned long end);
> +
> +       /*
>          * test_young is called to check the young/accessed bitflag in
>          * the secondary pte. This is used to know if the page is
>          * frequently used without actually clearing the flag or tearing
> @@ -203,6 +213,9 @@ extern void __mmu_notifier_release(struct mm_struct
> *mm);
>  extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
>                                           unsigned long start,
>                                           unsigned long end);
> +extern int __mmu_notifier_clear_young(struct mm_struct *mm,
> +                                     unsigned long start,
> +                                     unsigned long end);
>  extern int __mmu_notifier_test_young(struct mm_struct *mm,
>                                      unsigned long address);
>  extern void __mmu_notifier_change_pte(struct mm_struct *mm,
> @@ -231,6 +244,15 @@ static inline int
> mmu_notifier_clear_flush_young(struct mm_struct *mm,
>         return 0;
>  }
>
> +static inline int mmu_notifier_clear_young(struct mm_struct *mm,
> +                                          unsigned long start,
> +                                          unsigned long end)
> +{
> +       if (mm_has_notifiers(mm))
> +               return __mmu_notifier_clear_young(mm, start, end);
> +       return 0;
> +}
> +
>  static inline int mmu_notifier_test_young(struct mm_struct *mm,
>                                           unsigned long address)
>  {
> @@ -311,6 +333,28 @@ static inline void mmu_notifier_mm_destroy(struct
> mm_struct *mm)
>         __young;                                                        \
>  })
>
> +#define ptep_clear_young_notify(__vma, __address, __ptep)              \
> +({                                                                     \
> +       int __young;                                                    \
> +       struct vm_area_struct *___vma = __vma;                          \
> +       unsigned long ___address = __address;                           \
> +       __young = ptep_test_and_clear_young(___vma, ___address, __ptep);\
> +       __young |= mmu_notifier_clear_young(___vma->vm_mm, ___address,  \
> +                                           ___address + PAGE_SIZE);    \
> +       __young;                                                        \
> +})
> +
> +#define pmdp_clear_young_notify(__vma, __address, __pmdp)              \
> +({                                                                     \
> +       int __young;                                                    \
> +       struct vm_area_struct *___vma = __vma;                          \
> +       unsigned long ___address = __address;                           \
> +       __young = pmdp_test_and_clear_young(___vma, ___address, __pmdp);\
> +       __young |= mmu_notifier_clear_young(___vma->vm_mm, ___address,  \
> +                                           ___address + PMD_SIZE);     \
> +       __young;                                                        \
> +})
> +
>  #define        ptep_clear_flush_notify(__vma, __address, __ptep)
>      \
>  ({                                                                     \
>         unsigned long ___addr = __address & PAGE_MASK;                  \
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 3b9b3d0741b2..5fbdd367bbed 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -123,6 +123,23 @@ int __mmu_notifier_clear_flush_young(struct mm_struct
> *mm,
>         return young;
>  }
>
> +int __mmu_notifier_clear_young(struct mm_struct *mm,
> +                              unsigned long start,
> +                              unsigned long end)
> +{
> +       struct mmu_notifier *mn;
> +       int young = 0, id;
> +
> +       id = srcu_read_lock(&srcu);
> +       hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
> +               if (mn->ops->clear_young)
> +                       young |= mn->ops->clear_young(mn, mm, start, end);
> +       }
> +       srcu_read_unlock(&srcu, id);
> +
> +       return young;
> +}
> +
>  int __mmu_notifier_test_young(struct mm_struct *mm,
>                               unsigned long address)
>  {
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 8b8a44453670..ff4173ce6924 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -387,6 +387,23 @@ static int kvm_mmu_notifier_clear_flush_young(struct
> mmu_notifier *mn,
>         return young;
>  }
>
> +static int kvm_mmu_notifier_clear_young(struct mmu_notifier *mn,
> +                                       struct mm_struct *mm,
> +                                       unsigned long start,
> +                                       unsigned long end)
> +{
> +       struct kvm *kvm = mmu_notifier_to_kvm(mn);
> +       int young, idx;
> +
>
If you need to cut out another version please add comments as to the two
issues raised:
- This doesn't proactively flush TLBs -- not obvious if it should.
- This adversely affects performance in Pre_haswell Intel EPT.

Thanks
Andres

> +       idx = srcu_read_lock(&kvm->srcu);
> +       spin_lock(&kvm->mmu_lock);
> +       young = kvm_age_hva(kvm, start, end);
> +       spin_unlock(&kvm->mmu_lock);
> +       srcu_read_unlock(&kvm->srcu, idx);
> +
> +       return young;
> +}
> +
>  static int kvm_mmu_notifier_test_young(struct mmu_notifier *mn,
>                                        struct mm_struct *mm,
>                                        unsigned long address)
> @@ -419,6 +436,7 @@ static const struct mmu_notifier_ops
> kvm_mmu_notifier_ops = {
>         .invalidate_range_start = kvm_mmu_notifier_invalidate_range_start,
>         .invalidate_range_end   = kvm_mmu_notifier_invalidate_range_end,
>         .clear_flush_young      = kvm_mmu_notifier_clear_flush_young,
> +       .clear_young            = kvm_mmu_notifier_clear_young,
>         .test_young             = kvm_mmu_notifier_test_young,
>         .change_pte             = kvm_mmu_notifier_change_pte,
>         .release                = kvm_mmu_notifier_release,
> --
> 2.1.4
>
>


-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--001a1140f33a44d7b2051b52c90a
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64

PGRpdiBkaXI9Imx0ciI+PGJyPjxkaXYgY2xhc3M9ImdtYWlsX2V4dHJhIj48YnI+PGRpdiBjbGFz
cz0iZ21haWxfcXVvdGUiPk9uIFN1biwgSnVsIDE5LCAyMDE1IGF0IDU6MzEgQU0sIFZsYWRpbWly
IERhdnlkb3YgPHNwYW4gZGlyPSJsdHIiPiZsdDs8YSBocmVmPSJtYWlsdG86dmRhdnlkb3ZAcGFy
YWxsZWxzLmNvbSIgdGFyZ2V0PSJfYmxhbmsiPnZkYXZ5ZG92QHBhcmFsbGVscy5jb208L2E+Jmd0
Ozwvc3Bhbj4gd3JvdGU6PGJyPjxibG9ja3F1b3RlIGNsYXNzPSJnbWFpbF9xdW90ZSIgc3R5bGU9
Im1hcmdpbjowIDAgMCAuOGV4O2JvcmRlci1sZWZ0OjFweCAjY2NjIHNvbGlkO3BhZGRpbmctbGVm
dDoxZXgiPkluIHRoZSBzY29wZSBvZiB0aGUgaWRsZSBtZW1vcnkgdHJhY2tpbmcgZmVhdHVyZSwg
d2hpY2ggaXMgaW50cm9kdWNlZCBieTxicj4NCnRoZSBmb2xsb3dpbmcgcGF0Y2gsIHdlIG5lZWQg
dG8gY2xlYXIgdGhlIHJlZmVyZW5jZWQvYWNjZXNzZWQgYml0IG5vdDxicj4NCm9ubHkgaW4gcHJp
bWFyeSwgYnV0IGFsc28gaW4gc2Vjb25kYXJ5IHB0ZXMuIFRoZSBsYXR0ZXIgaXMgcmVxdWlyZWQg
aW48YnI+DQpvcmRlciB0byBlc3RpbWF0ZSB3c3Mgb2YgS1ZNIFZNcy4gQXQgdGhlIHNhbWUgdGlt
ZSB3ZSB3YW50IHRvIGF2b2lkPGJyPg0KZmx1c2hpbmcgdGxiLCBiZWNhdXNlIGl0IGlzIHF1aXRl
IGV4cGVuc2l2ZSBhbmQgaXQgd29uJiMzOTt0IHJlYWxseSBhZmZlY3Q8YnI+DQp0aGUgZmluYWwg
cmVzdWx0Ljxicj4NCjxicj4NCkN1cnJlbnRseSwgdGhlcmUgaXMgbm8gZnVuY3Rpb24gZm9yIGNs
ZWFyaW5nIHB0ZSB5b3VuZyBiaXQgdGhhdCB3b3VsZDxicj4NCm1lZXQgb3VyIHJlcXVpcmVtZW50
cywgc28gdGhpcyBwYXRjaCBpbnRyb2R1Y2VzIG9uZS4gVG8gYWNoaWV2ZSB0aGF0IHdlPGJyPg0K
aGF2ZSB0byBhZGQgYSBuZXcgbW11LW5vdGlmaWVyIGNhbGxiYWNrLCBjbGVhcl95b3VuZywgc2lu
Y2UgdGhlcmUgaXMgbm88YnI+DQptZXRob2QgZm9yIHRlc3RpbmctYW5kLWNsZWFyaW5nIGEgc2Vj
b25kYXJ5IHB0ZSB3L28gZmx1c2hpbmcgdGxiLiBUaGU8YnI+DQpuZXcgbWV0aG9kIGlzIG5vdCBt
YW5kYXRvcnkgYW5kIGN1cnJlbnRseSBvbmx5IGltcGxlbWVudGVkIGJ5IEtWTS48YnI+DQo8YnI+
DQpTaWduZWQtb2ZmLWJ5OiBWbGFkaW1pciBEYXZ5ZG92ICZsdDs8YSBocmVmPSJtYWlsdG86dmRh
dnlkb3ZAcGFyYWxsZWxzLmNvbSI+dmRhdnlkb3ZAcGFyYWxsZWxzLmNvbTwvYT4mZ3Q7PGJyPg0K
UmV2aWV3ZWQtYnk6IEFuZHJlcyBMYWdhci1DYXZpbGxhICZsdDs8YSBocmVmPSJtYWlsdG86YW5k
cmVzbGNAZ29vZ2xlLmNvbSI+YW5kcmVzbGNAZ29vZ2xlLmNvbTwvYT4mZ3Q7PGJyPg0KQWNrZWQt
Ynk6IFBhb2xvIEJvbnppbmkgJmx0OzxhIGhyZWY9Im1haWx0bzpwYm9uemluaUByZWRoYXQuY29t
Ij5wYm9uemluaUByZWRoYXQuY29tPC9hPiZndDs8YnI+DQotLS08YnI+DQrCoGluY2x1ZGUvbGlu
dXgvbW11X25vdGlmaWVyLmggfCA0NCArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKzxicj4NCsKgbW0vbW11X25vdGlmaWVyLmPCoCDCoCDCoCDCoCDCoCDCoCB8IDE3
ICsrKysrKysrKysrKysrKysrPGJyPg0KwqB2aXJ0L2t2bS9rdm1fbWFpbi5jwqAgwqAgwqAgwqAg
wqAgfCAxOCArKysrKysrKysrKysrKysrKys8YnI+DQrCoDMgZmlsZXMgY2hhbmdlZCwgNzkgaW5z
ZXJ0aW9ucygrKTxicj4NCjxicj4NCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L21tdV9ub3Rp
Zmllci5oIGIvaW5jbHVkZS9saW51eC9tbXVfbm90aWZpZXIuaDxicj4NCmluZGV4IDYxY2Q2N2Y0
ZDc4OC4uYTViMTcxMzdjNjgzIDEwMDY0NDxicj4NCi0tLSBhL2luY2x1ZGUvbGludXgvbW11X25v
dGlmaWVyLmg8YnI+DQorKysgYi9pbmNsdWRlL2xpbnV4L21tdV9ub3RpZmllci5oPGJyPg0KQEAg
LTY2LDYgKzY2LDE2IEBAIHN0cnVjdCBtbXVfbm90aWZpZXJfb3BzIHs8YnI+DQrCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHVuc2lnbmVkIGxvbmcgZW5k
KTs8YnI+DQo8YnI+DQrCoCDCoCDCoCDCoCAvKjxicj4NCivCoCDCoCDCoCDCoCAqIGNsZWFyX3lv
dW5nIGlzIGEgbGlnaHR3ZWlnaHQgdmVyc2lvbiBvZiBjbGVhcl9mbHVzaF95b3VuZy4gTGlrZSB0
aGU8YnI+DQorwqAgwqAgwqAgwqAgKiBsYXR0ZXIsIGl0IGlzIHN1cHBvc2VkIHRvIHRlc3QtYW5k
LWNsZWFyIHRoZSB5b3VuZy9hY2Nlc3NlZCBiaXRmbGFnPGJyPg0KK8KgIMKgIMKgIMKgICogaW4g
dGhlIHNlY29uZGFyeSBwdGUsIGJ1dCBpdCBtYXkgb21pdCBmbHVzaGluZyB0aGUgc2Vjb25kYXJ5
IHRsYi48YnI+DQorwqAgwqAgwqAgwqAgKi88YnI+DQorwqAgwqAgwqAgwqBpbnQgKCpjbGVhcl95
b3VuZykoc3RydWN0IG1tdV9ub3RpZmllciAqbW4sPGJyPg0KK8KgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLDxicj4NCivCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB1bnNpZ25lZCBsb25nIHN0YXJ0LDxicj4NCivC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB1bnNpZ25lZCBsb25nIGVuZCk7
PGJyPg0KKzxicj4NCivCoCDCoCDCoCDCoC8qPGJyPg0KwqAgwqAgwqAgwqAgwqAqIHRlc3RfeW91
bmcgaXMgY2FsbGVkIHRvIGNoZWNrIHRoZSB5b3VuZy9hY2Nlc3NlZCBiaXRmbGFnIGluPGJyPg0K
wqAgwqAgwqAgwqAgwqAqIHRoZSBzZWNvbmRhcnkgcHRlLiBUaGlzIGlzIHVzZWQgdG8ga25vdyBp
ZiB0aGUgcGFnZSBpczxicj4NCsKgIMKgIMKgIMKgIMKgKiBmcmVxdWVudGx5IHVzZWQgd2l0aG91
dCBhY3R1YWxseSBjbGVhcmluZyB0aGUgZmxhZyBvciB0ZWFyaW5nPGJyPg0KQEAgLTIwMyw2ICsy
MTMsOSBAQCBleHRlcm4gdm9pZCBfX21tdV9ub3RpZmllcl9yZWxlYXNlKHN0cnVjdCBtbV9zdHJ1
Y3QgKm1tKTs8YnI+DQrCoGV4dGVybiBpbnQgX19tbXVfbm90aWZpZXJfY2xlYXJfZmx1c2hfeW91
bmcoc3RydWN0IG1tX3N0cnVjdCAqbW0sPGJyPg0KwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgdW5zaWduZWQgbG9uZyBzdGFydCw8
YnI+DQrCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCB1bnNpZ25lZCBsb25nIGVuZCk7PGJyPg0KK2V4dGVybiBpbnQgX19tbXVfbm90
aWZpZXJfY2xlYXJfeW91bmcoc3RydWN0IG1tX3N0cnVjdCAqbW0sPGJyPg0KK8KgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgdW5zaWduZWQgbG9u
ZyBzdGFydCw8YnI+DQorwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqB1bnNpZ25lZCBsb25nIGVuZCk7PGJyPg0KwqBleHRlcm4gaW50IF9fbW11
X25vdGlmaWVyX3Rlc3RfeW91bmcoc3RydWN0IG1tX3N0cnVjdCAqbW0sPGJyPg0KwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB1bnNpZ25lZCBs
b25nIGFkZHJlc3MpOzxicj4NCsKgZXh0ZXJuIHZvaWQgX19tbXVfbm90aWZpZXJfY2hhbmdlX3B0
ZShzdHJ1Y3QgbW1fc3RydWN0ICptbSw8YnI+DQpAQCAtMjMxLDYgKzI0NCwxNSBAQCBzdGF0aWMg
aW5saW5lIGludCBtbXVfbm90aWZpZXJfY2xlYXJfZmx1c2hfeW91bmcoc3RydWN0IG1tX3N0cnVj
dCAqbW0sPGJyPg0KwqAgwqAgwqAgwqAgcmV0dXJuIDA7PGJyPg0KwqB9PGJyPg0KPGJyPg0KK3N0
YXRpYyBpbmxpbmUgaW50IG1tdV9ub3RpZmllcl9jbGVhcl95b3VuZyhzdHJ1Y3QgbW1fc3RydWN0
ICptbSw8YnI+DQorwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgdW5zaWduZWQgbG9uZyBzdGFydCw8YnI+DQorwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgdW5zaWdu
ZWQgbG9uZyBlbmQpPGJyPg0KK3s8YnI+DQorwqAgwqAgwqAgwqBpZiAobW1faGFzX25vdGlmaWVy
cyhtbSkpPGJyPg0KK8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgcmV0dXJuIF9fbW11X25vdGlmaWVy
X2NsZWFyX3lvdW5nKG1tLCBzdGFydCwgZW5kKTs8YnI+DQorwqAgwqAgwqAgwqByZXR1cm4gMDs8
YnI+DQorfTxicj4NCis8YnI+DQrCoHN0YXRpYyBpbmxpbmUgaW50IG1tdV9ub3RpZmllcl90ZXN0
X3lvdW5nKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLDxicj4NCsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHVuc2lnbmVkIGxvbmcgYWRk
cmVzcyk8YnI+DQrCoHs8YnI+DQpAQCAtMzExLDYgKzMzMywyOCBAQCBzdGF0aWMgaW5saW5lIHZv
aWQgbW11X25vdGlmaWVyX21tX2Rlc3Ryb3koc3RydWN0IG1tX3N0cnVjdCAqbW0pPGJyPg0KwqAg
wqAgwqAgwqAgX195b3VuZzvCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBcPGJyPg0KwqB9KTxi
cj4NCjxicj4NCisjZGVmaW5lIHB0ZXBfY2xlYXJfeW91bmdfbm90aWZ5KF9fdm1hLCBfX2FkZHJl
c3MsIF9fcHRlcCnCoCDCoCDCoCDCoCDCoCDCoCDCoCBcPGJyPg0KKyh7wqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBcPGJyPg0KK8KgIMKgIMKgIMKgaW50IF9f
eW91bmc7wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgXDxicj4NCivCoCDCoCDCoCDCoHN0cnVjdCB2bV9h
cmVhX3N0cnVjdCAqX19fdm1hID0gX192bWE7wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgXDxicj4NCivCoCDCoCDCoCDCoHVuc2lnbmVkIGxvbmcgX19fYWRkcmVzcyA9IF9f
YWRkcmVzczvCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoFw8YnI+DQor
wqAgwqAgwqAgwqBfX3lvdW5nID0gcHRlcF90ZXN0X2FuZF9jbGVhcl95b3VuZyhfX192bWEsIF9f
X2FkZHJlc3MsIF9fcHRlcCk7XDxicj4NCivCoCDCoCDCoCDCoF9feW91bmcgfD0gbW11X25vdGlm
aWVyX2NsZWFyX3lvdW5nKF9fX3ZtYS0mZ3Q7dm1fbW0sIF9fX2FkZHJlc3MswqAgXDxicj4NCivC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoF9fX2FkZHJlc3MgKyBQQUdFX1NJWkUpO8KgIMKgIFw8YnI+DQorwqAgwqAgwqAgwqBf
X3lvdW5nO8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIFw8YnI+DQorfSk8YnI+DQorPGJyPg0K
KyNkZWZpbmUgcG1kcF9jbGVhcl95b3VuZ19ub3RpZnkoX192bWEsIF9fYWRkcmVzcywgX19wbWRw
KcKgIMKgIMKgIMKgIMKgIMKgIMKgIFw8YnI+DQorKHvCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoFw8YnI+DQorwqAgwqAgwqAgwqBpbnQgX195b3VuZzvCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCBcPGJyPg0KK8KgIMKgIMKgIMKgc3RydWN0IHZtX2FyZWFfc3RydWN0
ICpfX192bWEgPSBfX3ZtYTvCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBc
PGJyPg0KK8KgIMKgIMKgIMKgdW5zaWduZWQgbG9uZyBfX19hZGRyZXNzID0gX19hZGRyZXNzO8Kg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgXDxicj4NCivCoCDCoCDCoCDC
oF9feW91bmcgPSBwbWRwX3Rlc3RfYW5kX2NsZWFyX3lvdW5nKF9fX3ZtYSwgX19fYWRkcmVzcywg
X19wbWRwKTtcPGJyPg0KK8KgIMKgIMKgIMKgX195b3VuZyB8PSBtbXVfbm90aWZpZXJfY2xlYXJf
eW91bmcoX19fdm1hLSZndDt2bV9tbSwgX19fYWRkcmVzcyzCoCBcPGJyPg0KK8KgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgX19f
YWRkcmVzcyArIFBNRF9TSVpFKTvCoCDCoCDCoFw8YnI+DQorwqAgwqAgwqAgwqBfX3lvdW5nO8Kg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIFw8YnI+DQorfSk8YnI+DQorPGJyPg0KwqAjZGVmaW5l
wqAgwqAgwqAgwqAgcHRlcF9jbGVhcl9mbHVzaF9ub3RpZnkoX192bWEsIF9fYWRkcmVzcywgX19w
dGVwKcKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgXDxicj4NCsKgKHvCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoFw8YnI+DQrCoCDCoCDCoCDCoCB1bnNpZ25lZCBs
b25nIF9fX2FkZHIgPSBfX2FkZHJlc3MgJmFtcDsgUEFHRV9NQVNLO8KgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIFw8YnI+DQpkaWZmIC0tZ2l0IGEvbW0vbW11X25vdGlmaWVyLmMgYi9tbS9tbXVf
bm90aWZpZXIuYzxicj4NCmluZGV4IDNiOWIzZDA3NDFiMi4uNWZiZGQzNjdiYmVkIDEwMDY0NDxi
cj4NCi0tLSBhL21tL21tdV9ub3RpZmllci5jPGJyPg0KKysrIGIvbW0vbW11X25vdGlmaWVyLmM8
YnI+DQpAQCAtMTIzLDYgKzEyMywyMyBAQCBpbnQgX19tbXVfbm90aWZpZXJfY2xlYXJfZmx1c2hf
eW91bmcoc3RydWN0IG1tX3N0cnVjdCAqbW0sPGJyPg0KwqAgwqAgwqAgwqAgcmV0dXJuIHlvdW5n
Ozxicj4NCsKgfTxicj4NCjxicj4NCitpbnQgX19tbXVfbm90aWZpZXJfY2xlYXJfeW91bmcoc3Ry
dWN0IG1tX3N0cnVjdCAqbW0sPGJyPg0KK8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIHVuc2lnbmVkIGxvbmcgc3RhcnQsPGJyPg0KK8KgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHVuc2lnbmVkIGxvbmcgZW5kKTxicj4NCit7PGJy
Pg0KK8KgIMKgIMKgIMKgc3RydWN0IG1tdV9ub3RpZmllciAqbW47PGJyPg0KK8KgIMKgIMKgIMKg
aW50IHlvdW5nID0gMCwgaWQ7PGJyPg0KKzxicj4NCivCoCDCoCDCoCDCoGlkID0gc3JjdV9yZWFk
X2xvY2soJmFtcDtzcmN1KTs8YnI+DQorwqAgwqAgwqAgwqBobGlzdF9mb3JfZWFjaF9lbnRyeV9y
Y3UobW4sICZhbXA7bW0tJmd0O21tdV9ub3RpZmllcl9tbS0mZ3Q7bGlzdCwgaGxpc3QpIHs8YnI+
DQorwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBpZiAobW4tJmd0O29wcy0mZ3Q7Y2xlYXJfeW91bmcp
PGJyPg0KK8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgeW91bmcgfD0gbW4tJmd0
O29wcy0mZ3Q7Y2xlYXJfeW91bmcobW4sIG1tLCBzdGFydCwgZW5kKTs8YnI+DQorwqAgwqAgwqAg
wqB9PGJyPg0KK8KgIMKgIMKgIMKgc3JjdV9yZWFkX3VubG9jaygmYW1wO3NyY3UsIGlkKTs8YnI+
DQorPGJyPg0KK8KgIMKgIMKgIMKgcmV0dXJuIHlvdW5nOzxicj4NCit9PGJyPg0KKzxicj4NCsKg
aW50IF9fbW11X25vdGlmaWVyX3Rlc3RfeW91bmcoc3RydWN0IG1tX3N0cnVjdCAqbW0sPGJyPg0K
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgdW5zaWduZWQgbG9u
ZyBhZGRyZXNzKTxicj4NCsKgezxicj4NCmRpZmYgLS1naXQgYS92aXJ0L2t2bS9rdm1fbWFpbi5j
IGIvdmlydC9rdm0va3ZtX21haW4uYzxicj4NCmluZGV4IDhiOGE0NDQ1MzY3MC4uZmY0MTczY2U2
OTI0IDEwMDY0NDxicj4NCi0tLSBhL3ZpcnQva3ZtL2t2bV9tYWluLmM8YnI+DQorKysgYi92aXJ0
L2t2bS9rdm1fbWFpbi5jPGJyPg0KQEAgLTM4Nyw2ICszODcsMjMgQEAgc3RhdGljIGludCBrdm1f
bW11X25vdGlmaWVyX2NsZWFyX2ZsdXNoX3lvdW5nKHN0cnVjdCBtbXVfbm90aWZpZXIgKm1uLDxi
cj4NCsKgIMKgIMKgIMKgIHJldHVybiB5b3VuZzs8YnI+DQrCoH08YnI+DQo8YnI+DQorc3RhdGlj
IGludCBrdm1fbW11X25vdGlmaWVyX2NsZWFyX3lvdW5nKHN0cnVjdCBtbXVfbm90aWZpZXIgKm1u
LDxicj4NCivCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLDxicj4NCivCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHVuc2lnbmVkIGxvbmcgc3Rh
cnQsPGJyPg0KK8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgdW5zaWduZWQgbG9uZyBlbmQpPGJyPg0KK3s8YnI+DQorwqAgwqAgwqAgwqBz
dHJ1Y3Qga3ZtICprdm0gPSBtbXVfbm90aWZpZXJfdG9fa3ZtKG1uKTs8YnI+DQorwqAgwqAgwqAg
wqBpbnQgeW91bmcsIGlkeDs8YnI+DQorPGJyPjwvYmxvY2txdW90ZT48ZGl2PklmIHlvdSBuZWVk
IHRvIGN1dCBvdXQgYW5vdGhlciB2ZXJzaW9uIHBsZWFzZSBhZGQgY29tbWVudHMgYXMgdG8gdGhl
IHR3byBpc3N1ZXMgcmFpc2VkOjwvZGl2PjxkaXY+LSBUaGlzIGRvZXNuJiMzOTt0IHByb2FjdGl2
ZWx5IGZsdXNoIFRMQnMgLS0gbm90IG9idmlvdXMgaWYgaXQgc2hvdWxkLjwvZGl2PjxkaXY+LSBU
aGlzIGFkdmVyc2VseSBhZmZlY3RzIHBlcmZvcm1hbmNlIGluIFByZV9oYXN3ZWxsIEludGVsIEVQ
VC48L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2PlRoYW5rczwvZGl2PjxkaXY+QW5kcmVzwqA8L2Rp
dj48YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhl
eDtib3JkZXItbGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4NCivCoCDCoCDC
oCDCoGlkeCA9IHNyY3VfcmVhZF9sb2NrKCZhbXA7a3ZtLSZndDtzcmN1KTs8YnI+DQorwqAgwqAg
wqAgwqBzcGluX2xvY2soJmFtcDtrdm0tJmd0O21tdV9sb2NrKTs8YnI+DQorwqAgwqAgwqAgwqB5
b3VuZyA9IGt2bV9hZ2VfaHZhKGt2bSwgc3RhcnQsIGVuZCk7PGJyPg0KK8KgIMKgIMKgIMKgc3Bp
bl91bmxvY2soJmFtcDtrdm0tJmd0O21tdV9sb2NrKTs8YnI+DQorwqAgwqAgwqAgwqBzcmN1X3Jl
YWRfdW5sb2NrKCZhbXA7a3ZtLSZndDtzcmN1LCBpZHgpOzxicj4NCis8YnI+DQorwqAgwqAgwqAg
wqByZXR1cm4geW91bmc7PGJyPg0KK308YnI+DQorPGJyPg0KwqBzdGF0aWMgaW50IGt2bV9tbXVf
bm90aWZpZXJfdGVzdF95b3VuZyhzdHJ1Y3QgbW11X25vdGlmaWVyICptbiw8YnI+DQrCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHN0cnVj
dCBtbV9zdHJ1Y3QgKm1tLDxicj4NCsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgdW5zaWduZWQgbG9uZyBhZGRyZXNzKTxicj4NCkBAIC00
MTksNiArNDM2LDcgQEAgc3RhdGljIGNvbnN0IHN0cnVjdCBtbXVfbm90aWZpZXJfb3BzIGt2bV9t
bXVfbm90aWZpZXJfb3BzID0gezxicj4NCsKgIMKgIMKgIMKgIC5pbnZhbGlkYXRlX3JhbmdlX3N0
YXJ0ID0ga3ZtX21tdV9ub3RpZmllcl9pbnZhbGlkYXRlX3JhbmdlX3N0YXJ0LDxicj4NCsKgIMKg
IMKgIMKgIC5pbnZhbGlkYXRlX3JhbmdlX2VuZMKgIMKgPSBrdm1fbW11X25vdGlmaWVyX2ludmFs
aWRhdGVfcmFuZ2VfZW5kLDxicj4NCsKgIMKgIMKgIMKgIC5jbGVhcl9mbHVzaF95b3VuZ8KgIMKg
IMKgID0ga3ZtX21tdV9ub3RpZmllcl9jbGVhcl9mbHVzaF95b3VuZyw8YnI+DQorwqAgwqAgwqAg
wqAuY2xlYXJfeW91bmfCoCDCoCDCoCDCoCDCoCDCoCA9IGt2bV9tbXVfbm90aWZpZXJfY2xlYXJf
eW91bmcsPGJyPg0KwqAgwqAgwqAgwqAgLnRlc3RfeW91bmfCoCDCoCDCoCDCoCDCoCDCoCDCoD0g
a3ZtX21tdV9ub3RpZmllcl90ZXN0X3lvdW5nLDxicj4NCsKgIMKgIMKgIMKgIC5jaGFuZ2VfcHRl
wqAgwqAgwqAgwqAgwqAgwqAgwqA9IGt2bV9tbXVfbm90aWZpZXJfY2hhbmdlX3B0ZSw8YnI+DQrC
oCDCoCDCoCDCoCAucmVsZWFzZcKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgID0ga3ZtX21tdV9ub3Rp
Zmllcl9yZWxlYXNlLDxicj4NCjxzcGFuIGNsYXNzPSJIT0VuWmIiPjxmb250IGNvbG9yPSIjODg4
ODg4Ij4tLTxicj4NCjIuMS40PGJyPg0KPGJyPg0KPC9mb250Pjwvc3Bhbj48L2Jsb2NrcXVvdGU+
PC9kaXY+PGJyPjxiciBjbGVhcj0iYWxsIj48ZGl2Pjxicj48L2Rpdj4tLSA8YnI+PGRpdiBjbGFz
cz0iZ21haWxfc2lnbmF0dXJlIj48ZGl2IGRpcj0ibHRyIj48c3BhbiBzdHlsZT0iY29sb3I6cmdi
KDg1LDg1LDg1KTtmb250LWZhbWlseTpzYW5zLXNlcmlmO2ZvbnQtc2l6ZTpzbWFsbDtsaW5lLWhl
aWdodDoxOS41cHg7Ym9yZGVyLXdpZHRoOjJweCAwcHggMHB4O2JvcmRlci1zdHlsZTpzb2xpZDti
b3JkZXItY29sb3I6cmdiKDIxMywxNSwzNyk7cGFkZGluZy10b3A6MnB4O21hcmdpbi10b3A6MnB4
Ij5BbmRyZXMgTGFnYXItQ2F2aWxsYcKgfDwvc3Bhbj48c3BhbiBzdHlsZT0iY29sb3I6cmdiKDg1
LDg1LDg1KTtmb250LWZhbWlseTpzYW5zLXNlcmlmO2ZvbnQtc2l6ZTpzbWFsbDtsaW5lLWhlaWdo
dDoxOS41cHg7Ym9yZGVyLXdpZHRoOjJweCAwcHggMHB4O2JvcmRlci1zdHlsZTpzb2xpZDtib3Jk
ZXItY29sb3I6cmdiKDUxLDEwNSwyMzIpO3BhZGRpbmctdG9wOjJweDttYXJnaW4tdG9wOjJweCI+
wqBHb29nbGUgS2VybmVsIFRlYW0gfDwvc3Bhbj48c3BhbiBzdHlsZT0iY29sb3I6cmdiKDg1LDg1
LDg1KTtmb250LWZhbWlseTpzYW5zLXNlcmlmO2ZvbnQtc2l6ZTpzbWFsbDtsaW5lLWhlaWdodDox
OS41cHg7Ym9yZGVyLXdpZHRoOjJweCAwcHggMHB4O2JvcmRlci1zdHlsZTpzb2xpZDtib3JkZXIt
Y29sb3I6cmdiKDAsMTUzLDU3KTtwYWRkaW5nLXRvcDoycHg7bWFyZ2luLXRvcDoycHgiPsKgPGEg
aHJlZj0ibWFpbHRvOmFuZHJlc2xjQGdvb2dsZS5jb20iIHRhcmdldD0iX2JsYW5rIj5hbmRyZXNs
Y0Bnb29nbGUuY29tPC9hPsKgPC9zcGFuPjxicj48L2Rpdj48L2Rpdj4NCjwvZGl2PjwvZGl2Pg0K
--001a1140f33a44d7b2051b52c90a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
