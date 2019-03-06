Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5651DC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:43:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF90020684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:43:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ox0lB3IV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF90020684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6493A8E0003; Wed,  6 Mar 2019 18:43:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CE6F8E0002; Wed,  6 Mar 2019 18:43:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 470388E0003; Wed,  6 Mar 2019 18:43:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9ED8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 18:43:20 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id q141so7104787itc.2
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 15:43:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=tJLt5fGH+fMo09vxi7y7udIe4ykNXEN3DqyQaFpBPyo=;
        b=YtuHbTzy7O3uVN6/vUdSJiHZkHwZHizq1gS90ARK7IPR4BphMcP5WmZOVRVg9azLB4
         3ve2/aJ+5pXGtXRyyiZOrZ1FxldBK7RZ/7A3Qw49Iclh4r5vq9HqsW7P+FAiwfPJvqbf
         Sd1Hml8RoT3w81B5civKJpc0zh3lcA2ehCDyqgDjtSWlvelGovpke6fcKQPt0uoMfjWQ
         T1oJ3xMY36cBOVSDRtsyZqr74A15kncPoWrYkOjFO2x3JlPdTuClLXPh6vJ8mKM97TMK
         4jgs1HAqy44t8anc1jwAWdlp3K7z0FLF0Ydzj91FsUWF4kRN3hCiCEqxzrn5YLsEWyZb
         kq9g==
X-Gm-Message-State: APjAAAXOiUiKLjJnqEKRPJBGh7/7QeqSwBN4pdZYWjH5zmWZDJNtFxQt
	BpFfsODRhX233S0tzJiECCQPJhUxVgdizrzEFvm9DUN6QWG8dHamDXAJosQjiUd4Hz7jJPo2XAo
	Ls1/8lbSi8szR98XrDNoJATFYVoj17IhQic9+HIMWr9R5fOrM5GCsTKPmPFEYuXL+aqrSN74IPx
	iOhXvgKFbyQsPxrp/S5KATCXcT68rJvGxO7rREszS0SNH3mkQpQKWsugWzq265cWubf7wWSWl+S
	WcHNraDO/jKwXsq+YShyKKiPeSyePrZ0TZLUSDKLZBp+pngKfWjlIeQCVT6M2Hv9O/kYOJY2rHx
	Q0AHe1qfb1IPSCqE1Kykb4ywCOEQGu+75btpqEx5tPJ8p1OkWuqHAEawHVZsJ4B/dW58H/qhDYs
	n
X-Received: by 2002:a5e:de05:: with SMTP id e5mr5145174iok.111.1551915799830;
        Wed, 06 Mar 2019 15:43:19 -0800 (PST)
X-Received: by 2002:a5e:de05:: with SMTP id e5mr5145122iok.111.1551915798654;
        Wed, 06 Mar 2019 15:43:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551915798; cv=none;
        d=google.com; s=arc-20160816;
        b=zRCKirXKwCkO13lbQq8Mgj0JMQMj+hubP+gMwfVSoilHraJwk0GLtCSoWJBohQkHZe
         Y72xKm0nR6wAnV6rcpTnSuhla3QwICcLtJYfapmCvfImRmT1tjwstKfUh8n7A7zxg6zm
         yJZlECE7Y5kAK48boHf7Zi/MQ9/+k2mf3jNPT5auUNf0soARSnm8I2wOaq3IiJkS/Ykv
         Gg+OsDWMgEucoil0cDOXsdWuyGJKAW6g2PVA9giLFsmU32XlmcGp+IKq7MjycRXpkGEe
         0ZI94pA2xiVYVZe3gNrGf2lvbocRj95Sh30/q0bF0njJBWhlggC3UVPROnr8WnTMwGpm
         xajg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=tJLt5fGH+fMo09vxi7y7udIe4ykNXEN3DqyQaFpBPyo=;
        b=HVthjlgVrPnYf6y58Fj1BG19WMyuqmn+fBkaH7ikvSgLaf9HeQpfUJNi3cD6UGJlMe
         3GUY641m7Ew2Bj4Z+71whnDKnkSRk1BdBFrhpjTOUxe3Ot5voG311RXrekRhXF90P0RP
         awJHjYp8nhfpk06B5f+kLGw3W6X7goc/g3FoG/aB0/78qbirNCSYBx7ioVDwiSLrbs+x
         SZq/BTG26e3qSAMsCIzTmLM9lGi2nnQvI3msrL/j+PFjFyWDg1Q6rwv/rqAKIy13XOtw
         iDBpJwC9JUCK/Edld+yvOD6rOWRwdjec+W/Ujj4w3ugCkYuw43p5H3l+ioKAKDuT2ZUR
         k2Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ox0lB3IV;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c5sor5526972itd.34.2019.03.06.15.43.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 15:43:18 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ox0lB3IV;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=tJLt5fGH+fMo09vxi7y7udIe4ykNXEN3DqyQaFpBPyo=;
        b=ox0lB3IVckkPY/SCFfqiueux6rKnP1OCFlDt5TmKladTy6w9qhHGdP1DvSbolvIJXd
         1lS+cGMMdrgsxaGIYRb8AjAttD4S0LjzQv7LQQMkYj7slBWRzqccDCUog3lfTIuZhAS3
         EwOZKsC8y5k8esE8J7uhF+fPzJTO80UI9h+8tV04AGhydK+Qc4Y0NofWYhmKhBEj+PjD
         2VyQWT1TtjSjE5A6tE/v/SlmGz+ESVa7PTQUW/pgkGbI5XtvG0ZA/PhFzXfKnXvPSmOR
         304mPTJpXSorpeOP5eywqv5D9mPNhlflhxc8/3ek9h/8StrT/CghxUwCm/3Zk4efrjWm
         by6A==
X-Google-Smtp-Source: APXvYqzaPA+pSY7D+nDgztKY9BDgiNuuvkyc3qYqJrEd+9ryIw2MBE8qomVMamBxPAN83p3VYmH02hMit8lfA0Af0co=
X-Received: by 2002:a24:b643:: with SMTP id d3mr3816515itj.146.1551915798185;
 Wed, 06 Mar 2019 15:43:18 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306155048.12868-2-nitesh@redhat.com>
In-Reply-To: <20190306155048.12868-2-nitesh@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 6 Mar 2019 15:43:07 -0800
Message-ID: <CAKgT0Uf5ZAMbg8s3Shcs2ooMueajXvVNx+gKi3eUKchNBj1mrQ@mail.gmail.com>
Subject: Re: [RFC][Patch v9 1/6] KVM: Guest free page hinting support
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
> This patch adds the following:
> 1. Functional skeleton for the guest implementation. It enables the
> guest to maintain the PFN of head buddy free pages of order
> FREE_PAGE_HINTING_MIN_ORDER (currently defined as MAX_ORDER - 1)
> in a per-cpu array.
> Guest uses guest_free_page_enqueue() to enqueue the free pages post buddy
> merging to the above mentioned per-cpu array.
> guest_free_page_try_hinting() is used to initiate hinting operation once
> the collected entries of the per-cpu array reaches or exceeds
> HINTING_THRESHOLD (128). Having larger array size(MAX_FGPT_ENTRIES = 256)
> than HINTING_THRESHOLD allows us to capture more pages specifically when
> guest_free_page_enqueue() is called from free_pcppages_bulk().
> For now guest_free_page_hinting() just resets the array index to continue
> capturing of the freed pages.
> 2. Enables the support for x86 architecture.
>
> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> ---
>  arch/x86/Kbuild              |  2 +-
>  arch/x86/kvm/Kconfig         |  8 +++
>  arch/x86/kvm/Makefile        |  2 +
>  include/linux/page_hinting.h | 15 ++++++
>  mm/page_alloc.c              |  5 ++
>  virt/kvm/page_hinting.c      | 98 ++++++++++++++++++++++++++++++++++++
>  6 files changed, 129 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/page_hinting.h
>  create mode 100644 virt/kvm/page_hinting.c
>
> diff --git a/arch/x86/Kbuild b/arch/x86/Kbuild
> index c625f57472f7..3244df4ee311 100644
> --- a/arch/x86/Kbuild
> +++ b/arch/x86/Kbuild
> @@ -2,7 +2,7 @@ obj-y += entry/
>
>  obj-$(CONFIG_PERF_EVENTS) += events/
>
> -obj-$(CONFIG_KVM) += kvm/
> +obj-$(subst m,y,$(CONFIG_KVM)) += kvm/
>
>  # Xen paravirtualization support
>  obj-$(CONFIG_XEN) += xen/
> diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
> index 72fa955f4a15..2fae31459706 100644
> --- a/arch/x86/kvm/Kconfig
> +++ b/arch/x86/kvm/Kconfig
> @@ -96,6 +96,14 @@ config KVM_MMU_AUDIT
>          This option adds a R/W kVM module parameter 'mmu_audit', which allows
>          auditing of KVM MMU events at runtime.
>
> +# KVM_FREE_PAGE_HINTING will allow the guest to report the free pages to the
> +# host in regular interval of time.
> +config KVM_FREE_PAGE_HINTING
> +       def_bool y
> +       depends on KVM
> +       select VIRTIO
> +       select VIRTIO_BALLOON
> +
>  # OK, it's a little counter-intuitive to do this, but it puts it neatly under
>  # the virtualization menu.
>  source "drivers/vhost/Kconfig"
> diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
> index 69b3a7c30013..78640a80501e 100644
> --- a/arch/x86/kvm/Makefile
> +++ b/arch/x86/kvm/Makefile
> @@ -16,6 +16,8 @@ kvm-y                 += x86.o mmu.o emulate.o i8259.o irq.o lapic.o \
>                            i8254.o ioapic.o irq_comm.o cpuid.o pmu.o mtrr.o \
>                            hyperv.o page_track.o debugfs.o
>
> +obj-$(CONFIG_KVM_FREE_PAGE_HINTING)    += $(KVM)/page_hinting.o
> +
>  kvm-intel-y            += vmx/vmx.o vmx/vmenter.o vmx/pmu_intel.o vmx/vmcs12.o vmx/evmcs.o vmx/nested.o
>  kvm-amd-y              += svm.o pmu_amd.o
>
> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting.h
> new file mode 100644
> index 000000000000..90254c582789
> --- /dev/null
> +++ b/include/linux/page_hinting.h
> @@ -0,0 +1,15 @@
> +#include <linux/gfp.h>
> +/*
> + * Size of the array which is used to store the freed pages is defined by
> + * MAX_FGPT_ENTRIES.
> + */
> +#define MAX_FGPT_ENTRIES       256
> +/*
> + * Threshold value after which hinting needs to be initiated on the captured
> + * free pages.
> + */
> +#define HINTING_THRESHOLD      128
> +#define FREE_PAGE_HINTING_MIN_ORDER    (MAX_ORDER - 1)
> +
> +void guest_free_page_enqueue(struct page *page, int order);
> +void guest_free_page_try_hinting(void);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d295c9bc01a8..684d047f33ee 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -67,6 +67,7 @@
>  #include <linux/lockdep.h>
>  #include <linux/nmi.h>
>  #include <linux/psi.h>
> +#include <linux/page_hinting.h>
>
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -1194,9 +1195,11 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>                         mt = get_pageblock_migratetype(page);
>
>                 __free_one_page(page, page_to_pfn(page), zone, 0, mt);
> +               guest_free_page_enqueue(page, 0);
>                 trace_mm_page_pcpu_drain(page, 0, mt);
>         }
>         spin_unlock(&zone->lock);
> +       guest_free_page_try_hinting();
>  }
>

Trying to enqueue pages from here seems like a really bad idea. You
are essentially putting yourself in a hot-path for order 0 pages and
going to cause significant bottlenecks.

>  static void free_one_page(struct zone *zone,
> @@ -1210,7 +1213,9 @@ static void free_one_page(struct zone *zone,
>                 migratetype = get_pfnblock_migratetype(page, pfn);
>         }
>         __free_one_page(page, pfn, zone, order, migratetype);
> +       guest_free_page_enqueue(page, order);
>         spin_unlock(&zone->lock);
> +       guest_free_page_try_hinting();
>  }

I really think it would be better to leave the page assembly to the
buddy allocator. Instead you may want to focus on somehow tagging the
pages as being recently freed but not hinted on so that you can come
back later to work on them.

>  static void __meminit __init_single_page(struct page *page, unsigned long pfn,
> diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
> new file mode 100644
> index 000000000000..48b4b5e796b0
> --- /dev/null
> +++ b/virt/kvm/page_hinting.c
> @@ -0,0 +1,98 @@
> +#include <linux/mm.h>
> +#include <linux/page_hinting.h>
> +
> +/*
> + * struct guest_free_pages- holds array of guest freed PFN's along with an
> + * index variable to track total freed PFN's.
> + * @free_pfn_arr: array to store the page frame number of all the pages which
> + * are freed by the guest.
> + * @guest_free_pages_idx: index to track the number entries stored in
> + * free_pfn_arr.
> + */
> +struct guest_free_pages {
> +       unsigned long free_page_arr[MAX_FGPT_ENTRIES];
> +       int free_pages_idx;
> +};
> +
> +DEFINE_PER_CPU(struct guest_free_pages, free_pages_obj);
> +
> +struct page *get_buddy_page(struct page *page)
> +{
> +       unsigned long pfn = page_to_pfn(page);
> +       unsigned int order;
> +
> +       for (order = 0; order < MAX_ORDER; order++) {
> +               struct page *page_head = page - (pfn & ((1 << order) - 1));
> +
> +               if (PageBuddy(page_head) && page_private(page_head) >= order)
> +                       return page_head;
> +       }
> +       return NULL;
> +}
> +

You would be much better off just letting the buddy allocator take care of this.

I really think the spot I had my arch_merge_page call would work much
better than this. The buddy allocator is already optimized to handle
merging the pages and such so we should really let it do its job
rather than reinventing it ourselves.

> +static void guest_free_page_hinting(void)
> +{
> +       struct guest_free_pages *hinting_obj = &get_cpu_var(free_pages_obj);
> +
> +       hinting_obj->free_pages_idx = 0;
> +       put_cpu_var(hinting_obj);
> +}
> +

Shouldn't this be guarded with a local_irq_save to prevent someone
from possibly performing an enqueue on the same CPU as the one you are
resetting the work on, or is just the preempt_disable int he
get_cpu_var enough to handle the case? If so could we get away with
the same thing for the guest_free_page_enqueue?

> +int if_exist(struct page *page)
> +{
> +       int i = 0;
> +       struct guest_free_pages *hinting_obj = this_cpu_ptr(&free_pages_obj);
> +
> +       while (i < MAX_FGPT_ENTRIES) {
> +               if (page_to_pfn(page) == hinting_obj->free_page_arr[i])
> +                       return 1;
> +               i++;
> +       }
> +       return 0;
> +}
> +

Doing a linear search for the page is going to be painful. Also this
is only searching a per-cpu list. What if you have this split over a
couple of CPUs?

> +void guest_free_page_enqueue(struct page *page, int order)
> +{
> +       unsigned long flags;
> +       struct guest_free_pages *hinting_obj;
> +       int l_idx;
> +
> +       /*
> +        * use of global variables may trigger a race condition between irq and
> +        * process context causing unwanted overwrites. This will be replaced
> +        * with a better solution to prevent such race conditions.
> +        */
> +       local_irq_save(flags);
> +       hinting_obj = this_cpu_ptr(&free_pages_obj);
> +       l_idx = hinting_obj->free_pages_idx;
> +       if (l_idx != MAX_FGPT_ENTRIES) {
> +               if (PageBuddy(page) && page_private(page) >=
> +                   FREE_PAGE_HINTING_MIN_ORDER) {
> +                       hinting_obj->free_page_arr[l_idx] = page_to_pfn(page);
> +                       hinting_obj->free_pages_idx += 1;
> +               } else {
> +                       struct page *buddy_page = get_buddy_page(page);
> +
> +                       if (buddy_page && page_private(buddy_page) >=
> +                           FREE_PAGE_HINTING_MIN_ORDER &&
> +                           !if_exist(buddy_page)) {
> +                               unsigned long buddy_pfn =
> +                                       page_to_pfn(buddy_page);
> +
> +                               hinting_obj->free_page_arr[l_idx] =
> +                                                       buddy_pfn;
> +                               hinting_obj->free_pages_idx += 1;
> +                       }
> +               }
> +       }
> +       local_irq_restore(flags);
> +}
> +
> +void guest_free_page_try_hinting(void)
> +{
> +       struct guest_free_pages *hinting_obj;
> +
> +       hinting_obj = this_cpu_ptr(&free_pages_obj);
> +       if (hinting_obj->free_pages_idx >= HINTING_THRESHOLD)
> +               guest_free_page_hinting();
> +}
> --
> 2.17.2
>

