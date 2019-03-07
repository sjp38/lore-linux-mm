Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEA2CC10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:32:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6262F20854
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:32:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6262F20854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2A448E0003; Thu,  7 Mar 2019 14:32:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED8EF8E0002; Thu,  7 Mar 2019 14:32:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D79868E0003; Thu,  7 Mar 2019 14:32:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4A5C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 14:32:35 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b40so16354455qte.1
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 11:32:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=HacS1MucMtBKOF2yn0p2joIgyw5UFBoUBLAb4i3XbN0=;
        b=c4nr5POrBhq/P21HGMrzssd4wRsbsLqcMnjrPwcmu6v02sPf3E9Ea/avcc3715iRED
         1mcLxLGmBRRXCuioVVDe6NaIxXCLe4UJp0ISu/sszHrP8C0fo1Rf04ksABPysXjqbkoO
         X1fS5S0qwv3wg4q0P8DJMGmSpoWinZ9xccC2K6pHGa4R0IsSWV/fMIOKh4O8Fd6QNY0x
         IR3cn8AMIGtUvNpE+0oWAd5W6NqaH4Es0QHdF0QjKiBVhzVL8lPVgmSaA9TgqE8jgPkp
         U5uExrcLfpT/+sVT/f8N8cttxCXseS7GQSyCt9yKZYhk7uVH94Rs7GozcbSZUieFbGvE
         /I6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXw4Cxleb9lLMaLPzxTihaGLC9Cr8E8WR7tY1iVY1wvANTAGXI2
	x4Hz8HieXJwsC7rzoZfb06KDYwJnie4a7hscN0OElkQ3qy0qKrmR8Onxya+A/IToXWzg6xT2eOW
	GCs/G/UiKLlHLH2ll5AdJmWhAFqFxXdxcKO/JINW4Ui8YLEEHvv9+mo5g2b7jZxn/jA==
X-Received: by 2002:ae9:c30f:: with SMTP id n15mr11046429qkg.227.1551987155367;
        Thu, 07 Mar 2019 11:32:35 -0800 (PST)
X-Google-Smtp-Source: APXvYqzt04y4kgKJt9rH5PSqL4Mu4tdjmN1At3a23nfe75vheXUnx3kKn8jFzzABFITGV+3vGZwQ
X-Received: by 2002:ae9:c30f:: with SMTP id n15mr11046360qkg.227.1551987154259;
        Thu, 07 Mar 2019 11:32:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551987154; cv=none;
        d=google.com; s=arc-20160816;
        b=b3lRgaQWXJ7T6SE8nHplvN7mQ0n1Zj11iGpXodRizEiiOrhg3zuV15jGEcVmR2WCNa
         BDCymh2ECauz2b4BZcbcDM0w/xo/jJ5EEMzvhQDsozt22saiqLdNZLyve+2d55vypDtY
         SH7v9FwAKzmD/OI4CzJBBAMDcxjOkBOO0B5+HTGvIgRIeut31DBFOzkbArwpdHw3zncR
         ULednxMmXthJRo7lnYRzBhPfxlxXp/Q6QX2tHLwZAaIenQe8OKY12ry1K96ELR/3kRgS
         /oUjwXILdsLHq98zD1If4QB35E1mTE0gBN/RyniSL5hj4g71ilbGxAzHgFJHx4zj+AnP
         +HfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=HacS1MucMtBKOF2yn0p2joIgyw5UFBoUBLAb4i3XbN0=;
        b=tJJSVigWirxNuJPtdZv0CZOaXX3fLxnOyNVe6G5d7nS4HwFaTyuqdTFXhlbC2Ws/BW
         7TuQ/3VPykM6Q0Zs6xKhXwrDlMysZB8YisMqDaRuSIm8Emuc9HWsob6F1d9oYFwL36HS
         v7CI2/aNAtfDdZLcll8PI6TN+qDw/cTGieJ9K1RVT7BdKLB5bxfqc/dhzSr1G9dD3Ssm
         SSxZI9iHPgq2aE0XC86XRjt0IaDE0KaRegBzK93IkJk04r1paNgKKUmuyqDzV7gfU92I
         IAa8K8WnABG5DJBs5t/46TFx6Z5Gs/5ufc1y/rioxbRFoQKRGAzrUnNWvrbF8+iiPglM
         Ns9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o1si317687qkk.270.2019.03.07.11.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 11:32:34 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6751458E38;
	Thu,  7 Mar 2019 19:32:33 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9981FBA5D;
	Thu,  7 Mar 2019 19:32:27 +0000 (UTC)
Subject: Re: [RFC][Patch v9 1/6] KVM: Guest free page hinting support
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-2-nitesh@redhat.com>
 <CAKgT0Uf5ZAMbg8s3Shcs2ooMueajXvVNx+gKi3eUKchNBj1mrQ@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <d2fb61d9-8b50-78be-13d4-450a6f66bb14@redhat.com>
Date: Thu, 7 Mar 2019 14:32:26 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Uf5ZAMbg8s3Shcs2ooMueajXvVNx+gKi3eUKchNBj1mrQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Z3TviIheIIeDFGvyoxTLiFC4vRYSGaxce"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 07 Mar 2019 19:32:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Z3TviIheIIeDFGvyoxTLiFC4vRYSGaxce
Content-Type: multipart/mixed; boundary="8gM7KYMlNrXCn2l5mLKLO20GnXXLn7IVt";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <d2fb61d9-8b50-78be-13d4-450a6f66bb14@redhat.com>
Subject: Re: [RFC][Patch v9 1/6] KVM: Guest free page hinting support
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-2-nitesh@redhat.com>
 <CAKgT0Uf5ZAMbg8s3Shcs2ooMueajXvVNx+gKi3eUKchNBj1mrQ@mail.gmail.com>
In-Reply-To: <CAKgT0Uf5ZAMbg8s3Shcs2ooMueajXvVNx+gKi3eUKchNBj1mrQ@mail.gmail.com>

--8gM7KYMlNrXCn2l5mLKLO20GnXXLn7IVt
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/6/19 6:43 PM, Alexander Duyck wrote:
> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> w=
rote:
>> This patch adds the following:
>> 1. Functional skeleton for the guest implementation. It enables the
>> guest to maintain the PFN of head buddy free pages of order
>> FREE_PAGE_HINTING_MIN_ORDER (currently defined as MAX_ORDER - 1)
>> in a per-cpu array.
>> Guest uses guest_free_page_enqueue() to enqueue the free pages post bu=
ddy
>> merging to the above mentioned per-cpu array.
>> guest_free_page_try_hinting() is used to initiate hinting operation on=
ce
>> the collected entries of the per-cpu array reaches or exceeds
>> HINTING_THRESHOLD (128). Having larger array size(MAX_FGPT_ENTRIES =3D=
 256)
>> than HINTING_THRESHOLD allows us to capture more pages specifically wh=
en
>> guest_free_page_enqueue() is called from free_pcppages_bulk().
>> For now guest_free_page_hinting() just resets the array index to conti=
nue
>> capturing of the freed pages.
>> 2. Enables the support for x86 architecture.
>>
>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
>> ---
>>  arch/x86/Kbuild              |  2 +-
>>  arch/x86/kvm/Kconfig         |  8 +++
>>  arch/x86/kvm/Makefile        |  2 +
>>  include/linux/page_hinting.h | 15 ++++++
>>  mm/page_alloc.c              |  5 ++
>>  virt/kvm/page_hinting.c      | 98 +++++++++++++++++++++++++++++++++++=
+
>>  6 files changed, 129 insertions(+), 1 deletion(-)
>>  create mode 100644 include/linux/page_hinting.h
>>  create mode 100644 virt/kvm/page_hinting.c
>>
>> diff --git a/arch/x86/Kbuild b/arch/x86/Kbuild
>> index c625f57472f7..3244df4ee311 100644
>> --- a/arch/x86/Kbuild
>> +++ b/arch/x86/Kbuild
>> @@ -2,7 +2,7 @@ obj-y +=3D entry/
>>
>>  obj-$(CONFIG_PERF_EVENTS) +=3D events/
>>
>> -obj-$(CONFIG_KVM) +=3D kvm/
>> +obj-$(subst m,y,$(CONFIG_KVM)) +=3D kvm/
>>
>>  # Xen paravirtualization support
>>  obj-$(CONFIG_XEN) +=3D xen/
>> diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
>> index 72fa955f4a15..2fae31459706 100644
>> --- a/arch/x86/kvm/Kconfig
>> +++ b/arch/x86/kvm/Kconfig
>> @@ -96,6 +96,14 @@ config KVM_MMU_AUDIT
>>          This option adds a R/W kVM module parameter 'mmu_audit', whic=
h allows
>>          auditing of KVM MMU events at runtime.
>>
>> +# KVM_FREE_PAGE_HINTING will allow the guest to report the free pages=
 to the
>> +# host in regular interval of time.
>> +config KVM_FREE_PAGE_HINTING
>> +       def_bool y
>> +       depends on KVM
>> +       select VIRTIO
>> +       select VIRTIO_BALLOON
>> +
>>  # OK, it's a little counter-intuitive to do this, but it puts it neat=
ly under
>>  # the virtualization menu.
>>  source "drivers/vhost/Kconfig"
>> diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
>> index 69b3a7c30013..78640a80501e 100644
>> --- a/arch/x86/kvm/Makefile
>> +++ b/arch/x86/kvm/Makefile
>> @@ -16,6 +16,8 @@ kvm-y                 +=3D x86.o mmu.o emulate.o i82=
59.o irq.o lapic.o \
>>                            i8254.o ioapic.o irq_comm.o cpuid.o pmu.o m=
trr.o \
>>                            hyperv.o page_track.o debugfs.o
>>
>> +obj-$(CONFIG_KVM_FREE_PAGE_HINTING)    +=3D $(KVM)/page_hinting.o
>> +
>>  kvm-intel-y            +=3D vmx/vmx.o vmx/vmenter.o vmx/pmu_intel.o v=
mx/vmcs12.o vmx/evmcs.o vmx/nested.o
>>  kvm-amd-y              +=3D svm.o pmu_amd.o
>>
>> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting=
=2Eh
>> new file mode 100644
>> index 000000000000..90254c582789
>> --- /dev/null
>> +++ b/include/linux/page_hinting.h
>> @@ -0,0 +1,15 @@
>> +#include <linux/gfp.h>
>> +/*
>> + * Size of the array which is used to store the freed pages is define=
d by
>> + * MAX_FGPT_ENTRIES.
>> + */
>> +#define MAX_FGPT_ENTRIES       256
>> +/*
>> + * Threshold value after which hinting needs to be initiated on the c=
aptured
>> + * free pages.
>> + */
>> +#define HINTING_THRESHOLD      128
>> +#define FREE_PAGE_HINTING_MIN_ORDER    (MAX_ORDER - 1)
>> +
>> +void guest_free_page_enqueue(struct page *page, int order);
>> +void guest_free_page_try_hinting(void);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index d295c9bc01a8..684d047f33ee 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -67,6 +67,7 @@
>>  #include <linux/lockdep.h>
>>  #include <linux/nmi.h>
>>  #include <linux/psi.h>
>> +#include <linux/page_hinting.h>
>>
>>  #include <asm/sections.h>
>>  #include <asm/tlbflush.h>
>> @@ -1194,9 +1195,11 @@ static void free_pcppages_bulk(struct zone *zon=
e, int count,
>>                         mt =3D get_pageblock_migratetype(page);
>>
>>                 __free_one_page(page, page_to_pfn(page), zone, 0, mt);=

>> +               guest_free_page_enqueue(page, 0);
>>                 trace_mm_page_pcpu_drain(page, 0, mt);
>>         }
>>         spin_unlock(&zone->lock);
>> +       guest_free_page_try_hinting();
>>  }
>>
> Trying to enqueue pages from here seems like a really bad idea. You
> are essentially putting yourself in a hot-path for order 0 pages and
> going to cause significant bottlenecks.
>
>>  static void free_one_page(struct zone *zone,
>> @@ -1210,7 +1213,9 @@ static void free_one_page(struct zone *zone,
>>                 migratetype =3D get_pfnblock_migratetype(page, pfn);
>>         }
>>         __free_one_page(page, pfn, zone, order, migratetype);
>> +       guest_free_page_enqueue(page, order);
>>         spin_unlock(&zone->lock);
>> +       guest_free_page_try_hinting();
>>  }
> I really think it would be better to leave the page assembly to the
> buddy allocator. Instead you may want to focus on somehow tagging the
> pages as being recently freed but not hinted on so that you can come
> back later to work on them.
I think this will lead us to the same discussion which we are having
under other patch about having a page flag. Let's discuss it there.
>
>>  static void __meminit __init_single_page(struct page *page, unsigned =
long pfn,
>> diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
>> new file mode 100644
>> index 000000000000..48b4b5e796b0
>> --- /dev/null
>> +++ b/virt/kvm/page_hinting.c
>> @@ -0,0 +1,98 @@
>> +#include <linux/mm.h>
>> +#include <linux/page_hinting.h>
>> +
>> +/*
>> + * struct guest_free_pages- holds array of guest freed PFN's along wi=
th an
>> + * index variable to track total freed PFN's.
>> + * @free_pfn_arr: array to store the page frame number of all the pag=
es which
>> + * are freed by the guest.
>> + * @guest_free_pages_idx: index to track the number entries stored in=

>> + * free_pfn_arr.
>> + */
>> +struct guest_free_pages {
>> +       unsigned long free_page_arr[MAX_FGPT_ENTRIES];
>> +       int free_pages_idx;
>> +};
>> +
>> +DEFINE_PER_CPU(struct guest_free_pages, free_pages_obj);
>> +
>> +struct page *get_buddy_page(struct page *page)
>> +{
>> +       unsigned long pfn =3D page_to_pfn(page);
>> +       unsigned int order;
>> +
>> +       for (order =3D 0; order < MAX_ORDER; order++) {
>> +               struct page *page_head =3D page - (pfn & ((1 << order)=
 - 1));
>> +
>> +               if (PageBuddy(page_head) && page_private(page_head) >=3D=
 order)
>> +                       return page_head;
>> +       }
>> +       return NULL;
>> +}
>> +
> You would be much better off just letting the buddy allocator take care=
 of this.
>
> I really think the spot I had my arch_merge_page call would work much
> better than this. The buddy allocator is already optimized to handle
> merging the pages and such so we should really let it do its job
> rather than reinventing it ourselves.
Yes I can have my hook in __free_one_page() but then in order to avoid
duplicate hints we need to have some page flag bit.
>
>> +static void guest_free_page_hinting(void)
>> +{
>> +       struct guest_free_pages *hinting_obj =3D &get_cpu_var(free_pag=
es_obj);
>> +
>> +       hinting_obj->free_pages_idx =3D 0;
>> +       put_cpu_var(hinting_obj);
>> +}
>> +
> Shouldn't this be guarded with a local_irq_save to prevent someone
> from possibly performing an enqueue on the same CPU as the one you are
> resetting the work on, or is just the preempt_disable int he
> get_cpu_var enough to handle the case? If so could we get away with
> the same thing for the guest_free_page_enqueue?
I am not sure about this, I will take a look at it.
>
>> +int if_exist(struct page *page)
>> +{
>> +       int i =3D 0;
>> +       struct guest_free_pages *hinting_obj =3D this_cpu_ptr(&free_pa=
ges_obj);
>> +
>> +       while (i < MAX_FGPT_ENTRIES) {
>> +               if (page_to_pfn(page) =3D=3D hinting_obj->free_page_ar=
r[i])
>> +                       return 1;
>> +               i++;
>> +       }
>> +       return 0;
>> +}
>> +
> Doing a linear search for the page is going to be painful. Also this
> is only searching a per-cpu list. What if you have this split over a
> couple of CPUs?
That's correct if there is the same page in multiple per cpu array. Then
the isolation request corresponding to the per cpu array in which it's
added at a later point of time will fail.
>
>> +void guest_free_page_enqueue(struct page *page, int order)
>> +{
>> +       unsigned long flags;
>> +       struct guest_free_pages *hinting_obj;
>> +       int l_idx;
>> +
>> +       /*
>> +        * use of global variables may trigger a race condition betwee=
n irq and
>> +        * process context causing unwanted overwrites. This will be r=
eplaced
>> +        * with a better solution to prevent such race conditions.
>> +        */
>> +       local_irq_save(flags);
>> +       hinting_obj =3D this_cpu_ptr(&free_pages_obj);
>> +       l_idx =3D hinting_obj->free_pages_idx;
>> +       if (l_idx !=3D MAX_FGPT_ENTRIES) {
>> +               if (PageBuddy(page) && page_private(page) >=3D
>> +                   FREE_PAGE_HINTING_MIN_ORDER) {
>> +                       hinting_obj->free_page_arr[l_idx] =3D page_to_=
pfn(page);
>> +                       hinting_obj->free_pages_idx +=3D 1;
>> +               } else {
>> +                       struct page *buddy_page =3D get_buddy_page(pag=
e);
>> +
>> +                       if (buddy_page && page_private(buddy_page) >=3D=

>> +                           FREE_PAGE_HINTING_MIN_ORDER &&
>> +                           !if_exist(buddy_page)) {
>> +                               unsigned long buddy_pfn =3D
>> +                                       page_to_pfn(buddy_page);
>> +
>> +                               hinting_obj->free_page_arr[l_idx] =3D
>> +                                                       buddy_pfn;
>> +                               hinting_obj->free_pages_idx +=3D 1;
>> +                       }
>> +               }
>> +       }
>> +       local_irq_restore(flags);
>> +}
>> +
>> +void guest_free_page_try_hinting(void)
>> +{
>> +       struct guest_free_pages *hinting_obj;
>> +
>> +       hinting_obj =3D this_cpu_ptr(&free_pages_obj);
>> +       if (hinting_obj->free_pages_idx >=3D HINTING_THRESHOLD)
>> +               guest_free_page_hinting();
>> +}
>> --
>> 2.17.2
>>
--=20
Regards
Nitesh


--8gM7KYMlNrXCn2l5mLKLO20GnXXLn7IVt--

--Z3TviIheIIeDFGvyoxTLiFC4vRYSGaxce
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyBccoACgkQo4ZA3AYy
ozn0ZhAAy428eMfnKzSHLRkdenTXCzQBgqqkmgNpMWJDa4xePYq98J39Wu+Fqq3t
2PPZvbYan2zeDZbPCVzgtFic8Dd8963wGEijfEjFQHSnNiD+er+4S+33JxFJIS8e
Onb39QDRS56PvvHjnUsUuAoUrUimtbNvCcD/jNwHUbG+ELk2yOjydvTDYc9iv0rj
m0vZpAlNmvPzC/UZ8roEP3MepeRhM3Ix5m2vvuOpaYBFtoLUzAZ3gLijqfF9X2yU
MIc2RfCfcmWvdFYknyTb8tehFfGvt5QGlQfCNI2KlslOeOuT3QJKjGBbsXVri6Wx
KG0mOvKHLkPbjmOXU26fNNzF6Mo/Qupys0RZtKPiD8+NKH+m8Vkgo92kzpX7f4HP
J9gF+c1q5Z3dNCxoD2XxDYA/7xq862yYj8G1Zjx+Ewxx1cpBk6ptAMs66ivMDzl8
9OY2ralA6LlwtkEeOtXpwCNI6FQFb0iGFwnOPQh926fFvzvU+L9BCOZg9vzMCHf0
8Frfe1DEDXejJPeXE5BplOHR8T4gVedtDClHRNjGyevfAFxZono8aRUyR0pS1CJk
m+/QHXofkvxmzXgVM+qmV6NaixQm3XENph1HQji2KQugE2p251o77uXKPeGsNk28
pADgGeNNtu1clRW0IxYHav7j9alj9pcDUQp8ChP6QSGnf/K76DE=
=rsx8
-----END PGP SIGNATURE-----

--Z3TviIheIIeDFGvyoxTLiFC4vRYSGaxce--

