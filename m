Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B5EFC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 10:54:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1801C206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 10:54:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1801C206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A595A6B0010; Mon, 15 Jul 2019 06:54:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0A736B0266; Mon, 15 Jul 2019 06:54:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D37D6B0269; Mon, 15 Jul 2019 06:54:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7AF6B0010
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:54:35 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d26so14457586qte.19
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 03:54:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=QZZOKsiuKCjbin5wwa5611k0nzp8PVWf4aN26B8LhQo=;
        b=L13Dq9FIy0ruo3IngInp3WvfCMsINNd7UIoo0Hwv7gLnWqHZFdMIo41xqIUFphq50Y
         MlesYwiTpWQDgbu4PnVAEec0+bQ7Q6By27T/cTUyyibY/I5FIyiFU/c+CVjsgTVGr03m
         L9S1uD9ZcbeFzBxm3lRsQ2Qf0zqX5bG1AF9+MKGhQcFyzMpxo5akqIRo2OnQFYkFB5Of
         nkOZ06li02FRVJ/i3OwN9gWNL2YS3FMv6RDQdrIy3ncOQpKbJaiFTlSIxrCmnVaAWTiy
         tqSrjrwpvetYaiZOiPEX9KiqQ+7uKxhaT3XHgSIk2a1H6FIQ/DRpnrPA9jGPhZcxuweI
         zulQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAViowZNszb8TOyoGDtg3IybIfSlOCRgFgTsvr5f0lM8RPIleciQ
	QdImzl86ad8cMG84so4sjGcKfWxg8wRmZGBssurduawLjog/mSNYO/Igtj0wJ3lCBPygDbvQ+YK
	wsznlobfUU1p1iS+zMcsd9N8bhjapb5gngd52IEmmrKjuA+INZ65ewEA4SHHIF5EEOg==
X-Received: by 2002:a0c:8695:: with SMTP id 21mr18412297qvf.166.1563188075233;
        Mon, 15 Jul 2019 03:54:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwK68jcdGDgF5YO7hMCjHiaLBlH4e+ji+fnRdMjNfFB2RL7ivYpRmoAIWw0nSHlYwu9XZYn
X-Received: by 2002:a0c:8695:: with SMTP id 21mr18412270qvf.166.1563188074772;
        Mon, 15 Jul 2019 03:54:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563188074; cv=none;
        d=google.com; s=arc-20160816;
        b=Cg2aIL4h1GfybIRzBCbU7bpwXEv73CISImvNDo5uOzlcELMzo9akcDD0ILPi4g2tDk
         Y01z95VahumzPk3xXETstnKo3KPmqoNn353jOKIyQa3Pvg5KMaHd6GiRtR5loxnzXPtO
         TUFiJEpStXcHYj7iwacfkIUkQQ7zZVg0SqC6izfqpwZ/xF/u5Iy7qNrMN42FKaQaqEqu
         GXBljJ9pisgEAESbSrNeavIpS96JXkS/d6BBLGIYMt7goTeTgdPkx1RG1sRy4NXRIJ5e
         gYRdlzeQ4cNuBxJy6WRlJgv6bfhck1i4RlvPFVM79PI/TqNxXQPxJnTSVDDFl1HBysRh
         iozg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=QZZOKsiuKCjbin5wwa5611k0nzp8PVWf4aN26B8LhQo=;
        b=ImeKfYe9HYWIQLNAMvtF/ifV33DPtENCRjy/QRPJHBsgjqyVjw/Nue2fFxFRfD3VPx
         Ak9EWNW9qoJ5jebsxwFvYtBtbCxGZyDHxAsNtoYnO1JS++WYQ3xhC69DTCnb7zZdNSJc
         JFyV6xWLr46yyfokPvBBHGNisR8lrKXcdjyzWJ2P1Vra7vlEkvDGUFrPmQQC5Egsy9Sr
         +O9YAOB3idFW/BrMs6wMDrXz+2CKREMB9En/uh0imJIZ65f/HiPJvqiz7TnpJGm4zo2z
         NVukLM3SKdChfjWev0eKeLL/wVQtn5dKd1gBgw95FH5Rwb3Z09p1fytN++1fJ7Lmy+vc
         +OUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n65si10425159qte.319.2019.07.15.03.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 03:54:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AB4A95AFE3;
	Mon, 15 Jul 2019 10:54:32 +0000 (UTC)
Received: from [10.36.117.137] (ovpn-117-137.ams2.redhat.com [10.36.117.137])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2483C1001DCB;
	Mon, 15 Jul 2019 10:54:20 +0000 (UTC)
Subject: Re: [PATCH v3 06/11] mm/memory_hotplug: Allow arch_remove_pages()
 without CONFIG_MEMORY_HOTREMOVE
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Wei Yang
 <richard.weiyang@gmail.com>, Igor Mammedov <imammedo@redhat.com>,
 Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski
 <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>,
 Oscar Salvador <osalvador@suse.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Alex Deucher <alexander.deucher@amd.com>,
 "David S. Miller" <davem@davemloft.net>, Mark Brown <broonie@kernel.org>,
 Chris Wilson <chris@chris-wilson.co.uk>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Nicholas Piggin <npiggin@gmail.com>, Vasily Gorbik <gor@linux.ibm.com>,
 Rob Herring <robh@kernel.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>,
 Andrew Banman <andrew.banman@hpe.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richardw.yang@linux.intel.com>, Arun KS <arunks@codeaurora.org>,
 Qian Cai <cai@lca.pw>, Mathieu Malaterre <malat@debian.org>,
 Baoquan He <bhe@redhat.com>, Logan Gunthorpe <logang@deltatee.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-7-david@redhat.com>
 <20190701080141.GF6376@dhcp22.suse.cz> <20190701125112.GW6376@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <717d8b84-2233-97f9-56cb-0b9e22732d30@redhat.com>
Date: Mon, 15 Jul 2019 12:54:20 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701125112.GW6376@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 15 Jul 2019 10:54:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.07.19 14:51, Michal Hocko wrote:
> On Mon 01-07-19 10:01:41, Michal Hocko wrote:
>> On Mon 27-05-19 13:11:47, David Hildenbrand wrote:
>>> We want to improve error handling while adding memory by allowing
>>> to use arch_remove_memory() and __remove_pages() even if
>>> CONFIG_MEMORY_HOTREMOVE is not set to e.g., implement something like:
>>>
>>> 	arch_add_memory()
>>> 	rc = do_something();
>>> 	if (rc) {
>>> 		arch_remove_memory();
>>> 	}
>>>
>>> We won't get rid of CONFIG_MEMORY_HOTREMOVE for now, as it will require
>>> quite some dependencies for memory offlining.
>>
>> If we cannot really remove CONFIG_MEMORY_HOTREMOVE altogether then why
>> not simply add an empty placeholder for arch_remove_memory when the
>> config is disabled?
> 
> In other words, can we replace this by something as simple as:
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index ae892eef8b82..0329027fe740 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -128,6 +128,20 @@ extern void arch_remove_memory(int nid, u64 start, u64 size,
>  			       struct vmem_altmap *altmap);
>  extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
>  			   unsigned long nr_pages, struct vmem_altmap *altmap);
> +#else
> +/*
> + * Allow code using
> + * arch_add_memory();
> + * rc = do_something();
> + * if (rc)
> + * 	arch_remove_memory();
> + *
> + * without ifdefery.
> + */
> +static inline void arch_remove_memory(int nid, u64 start, u64 size,
> +			       struct vmem_altmap *altmap)
> +{
> +}
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
>  /*
> 

A system configured without CONFIG_MEMORY_HOTREMOVE should not suddenly
behave worse than before when adding of memory fails. What you suggest
result in that.

The goal should be to force architectures to properly implement
arch_remove_memory() right from the start - which is the case for all
architectures after this patch set *except* arm, for which a proper
implementation is on the way.

So I'm leaving it like it is. arch_remove_memory() will be mandatory for
architectures implementing arch_add_memory().

-- 

Thanks,

David / dhildenb

