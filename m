Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72B84C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:07:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AE5E261B3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:07:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="VEU5u5GD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AE5E261B3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA83B6B026A; Thu, 30 May 2019 17:07:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A31896B026B; Thu, 30 May 2019 17:07:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D2FF6B026D; Thu, 30 May 2019 17:07:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1966B026A
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:07:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f15so8633340ede.8
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:07:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Pv5CB4WwZj0N9C+rEj8/2lRh5EGUHdn0uj79m0rM0oo=;
        b=OOXhoQgtDtW/uo3xrljCTds+F6A9DlVp7BJCKHu4MXI5eMEtFJGIMomLHyYs89rMGm
         xXG7bYq7kWPCS2ORtxxM3U07LDHpj/VL41JOlBSdIvkXZvE9MSJo7sz6JGOMJSB7Y8RE
         es+Djmr8xYHfJb9XqR+GtwG9E5WxR0LjzilagAQiJZ6XeA2pTCq+ErT3AmDtwQHSh9bE
         UsEVqv+Cadgpu5oYGl8wyfsmn2djWc6r/yNw79iWgTWWJFuhPDiaUWlHtidO6nvAA2b7
         4MaeYuQ/i/q77FFhNeo8KiueN0wskzvLDNBHV/YMYeNfmxXy2wcurXnTNuM8ddH6pCE3
         8VYw==
X-Gm-Message-State: APjAAAUT2dbSixcfwbgVWHTil/cPvR6fhCyQx1yuTPLUBghCgjyv1YjO
	sOm9kWftmlkmc+sOAaZM7wRd39PaBK8ElFd0XrdHNJAazZ+qjwQ2Hk+jTOVJ+pykerVAm9zwtJs
	VC5GWP3E8iQRZcLiVT+56I4MkEbraLHcCl90yBGVlGBP4FVJt5ZefxU0DusRjWlyC/g==
X-Received: by 2002:a17:906:a950:: with SMTP id hh16mr5618629ejb.136.1559250437727;
        Thu, 30 May 2019 14:07:17 -0700 (PDT)
X-Received: by 2002:a17:906:a950:: with SMTP id hh16mr5618559ejb.136.1559250436642;
        Thu, 30 May 2019 14:07:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559250436; cv=none;
        d=google.com; s=arc-20160816;
        b=YMJ9f2m48Yx+8asgqQ7jHVX4j8Y+fS74vt4iLHLGkjg/q/X5CLIcwY8bEy94CZApiO
         YnGUW9WcH3Z8yOgbjvYir+mESUg8Euv20bfGf+9jTuenZU1x/ZiTsKxSeVD8G2qNazj5
         Ff56BRicVbm1RaFfqidwAS6Tv4Ofg+E6N21tIpZaRCSeOJZ7nSkyHTi6UjJPySSjPzz9
         H3vvZ9CIJvI7Oin8XfzULbSbkbqZJg7h+f/1Rkry2e8p4unxE6TnIgG+9DR8MNF02jNo
         wWdW1GvxUrsyc1QaUF98QbO7VdHGxsyG435hzMPX3+V6AvZuO2i1Ej4lE2leoUrpMcb2
         +NuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Pv5CB4WwZj0N9C+rEj8/2lRh5EGUHdn0uj79m0rM0oo=;
        b=rAANxDloZHjanh/S7VRKCi72Wgh78ad+NnvRadKb7lt2zJOnMkGQDsjYWIs5ikSUQa
         IW3PpEoRhPEsUBovqMJZElYR0fISwMxbedQXmqwbnlv2uFfJTFKiyihJgvvKHjoFT8AL
         M0s+6nMjNdLh7OsaP6eDXi197gK5ZtJHu3XYkO1KFY00uOOCDMUDkrv1HQkgijDB3JuX
         +NE9w8jjIMgyzeurJHz6j6W/cjzBKJ9W1Tzt9BTjk1Hl8N8eV86aCDpiXMmaSqS1Cs1d
         XSHu2tSOSKxV/B/skdtA6JjM8Nh/JNSezEYEf5eVNbI39pgM8MSIq7s2sgz6OrcES8g+
         p+kA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=VEU5u5GD;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a10sor2020375eda.1.2019.05.30.14.07.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:07:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=VEU5u5GD;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Pv5CB4WwZj0N9C+rEj8/2lRh5EGUHdn0uj79m0rM0oo=;
        b=VEU5u5GDrcgB8PRAclAeTaxHNWRXxNgMKQuxMFD2SFRizhpvwX2vSFrW58YKLvKdGO
         eVuKFZtXyc1RHb9iKevkl1RKESa8X+H4JsE7X49/wDWGTTF1++R+Oi6bCGLu0qiMFC7q
         hWo0t+OsCQNb5YJC5V+PLRuPaGXL4SH2RlhfYwJV76d+wtYGM87zkTYGJrmM5dahxIDn
         qHnxrRKHJ981k6zXutXR8rLnD27RwSUR9gdS6t3qdzrPraAAqPEeILMrt+Xu+DkaI8aO
         CnVCUN2x67n04/yYkoMoVaF4yzXSA1yTow1K1ywH4DmLZh4o+OnP8FcuMAvRu6sLPZIL
         UDpQ==
X-Google-Smtp-Source: APXvYqzIBqcTjn5yiKx6Vr6nLGFPUVRyPMd7kuo7uA8Xmjn8HuSs90QeWcqYdxDxX2LpwL8i4qi0lXPOMCD5KRVUoAU=
X-Received: by 2002:aa7:d711:: with SMTP id t17mr7195382edq.80.1559250436307;
 Thu, 30 May 2019 14:07:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190527111152.16324-1-david@redhat.com> <20190527111152.16324-8-david@redhat.com>
In-Reply-To: <20190527111152.16324-8-david@redhat.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 30 May 2019 17:07:05 -0400
Message-ID: <CA+CK2bBLtZL8qxsjJt-tdaOraJCbDYfH2cbQ1ABJJ8hYif8LiQ@mail.gmail.com>
Subject: Re: [PATCH v3 07/11] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, 
	Wei Yang <richard.weiyang@gmail.com>, Igor Mammedov <imammedo@redhat.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	"mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>, 
	Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>, 
	Michal Hocko <mhocko@suse.com>, Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>, 
	Mathieu Malaterre <malat@debian.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 7:12 AM David Hildenbrand <david@redhat.com> wrote:
>
> Only memory to be added to the buddy and to be onlined/offlined by
> user space using /sys/devices/system/memory/... needs (and should have!)
> memory block devices.
>
> Factor out creation of memory block devices. Create all devices after
> arch_add_memory() succeeded. We can later drop the want_memblock parameter,
> because it is now effectively stale.
>
> Only after memory block devices have been added, memory can be onlined
> by user space. This implies, that memory is not visible to user space at
> all before arch_add_memory() succeeded.
>
> While at it
> - use WARN_ON_ONCE instead of BUG_ON in moved unregister_memory()
> - introduce find_memory_block_by_id() to search via block id
> - Use find_memory_block_by_id() in init_memory_block() to catch
>   duplicates
>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

LGTM
Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

