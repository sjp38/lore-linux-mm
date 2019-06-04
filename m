Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B81AAC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:00:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75CD724DB4
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:00:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75CD724DB4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA2716B000A; Tue,  4 Jun 2019 03:00:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2B586B000C; Tue,  4 Jun 2019 03:00:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA5536B000D; Tue,  4 Jun 2019 03:00:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 963ED6B000A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:00:04 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id 12so6123307oii.0
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:00:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=g61hfiekMhEDzVRJSbqTXiiNJrcqhF/h5OW9BT4l3qw=;
        b=C3GhyjODqOopxUvOEAKCzN3G6nKaN7unYnAzq7jtcwWruBBbZ9lG2hX25rl+kTzuf6
         OMQVq4HpV1N+mSA6L/5TSjNlI6T3gHr1BQJogdYtXf3PYcAd7J3PLz1k2kRJJULtEPcv
         XG/oc7QN5MjkjlwwNEID4+/DoyvYkBeKAwtbuvEAiKwJwx2Hemi1EP3GqIAsQOnS8eTG
         SkXVHDRX4xt7sKcSWuARW//Ifc38qN+Zqx2wvza3/QOxDQNWs9HWMrXjO0zgUxZKxCBH
         0xuUvReOu57F0Hnz00uu2rVT9ljqvWDEerH/08z1CB2FXULemazxq4YLnKnLvxwHfKEE
         T46w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVHe1r+peVifbZON+XhQM5X09OBNCFHnmz6dT3helbt5cRvxTM4
	QX7snXcpkhlGb3hiW4hAoU9Ij9qRzEIjWL9FnD3Gc3L6rgE6jeEBsTMLufEeRpNz5FR1jPSvQXw
	qPQ/jV/GKm+whn3dc8Ge5i2fkZb52CFBjPx01NP9UEbN7D7kP3bVkSdWO9gxo7cktMw==
X-Received: by 2002:aca:c1c6:: with SMTP id r189mr3604817oif.162.1559631604350;
        Tue, 04 Jun 2019 00:00:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQobkcTESLlPhQOHClELXpO6PJ2iZl7jRI4g8VoHLaQ0KX81GKXPj89qY0l2lN8RZrJS4U
X-Received: by 2002:aca:c1c6:: with SMTP id r189mr3604774oif.162.1559631603660;
        Tue, 04 Jun 2019 00:00:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631603; cv=none;
        d=google.com; s=arc-20160816;
        b=e+kc48wWGPcrSf2HDa0KK9qbIfwKlnTgD+H67SAk7ownOv+l2WamHMsEqX8d/+qsnT
         bMnbzzqVN8Eg/l4QfnYNHK8XLadieSzGy35oCh48Wblb2vHOdKvOz2nOI3cuTrJWY8SJ
         ev9l56EvJrZI2MWKYmNsJp0fPRC3/qONNziG0fp61DyRo44l8eIvzQAldSddHMYGgtbK
         9XAQu0wF+yWV9vRUUx2MegcppTC2C8eNSRG1csSFklDLt94DkUTtblWUoAApsK6GPPq7
         8LikJaA+R5ehV8EGaguBty9Nx/AimD1n7cDz+jVfaCEO+5+QLAcdZlKnbHL9sRnR+tlI
         w/+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=g61hfiekMhEDzVRJSbqTXiiNJrcqhF/h5OW9BT4l3qw=;
        b=dAnBxDrFEVYbgwfeoWv3BqD6/ykRkDK8zRLCdoz62Gq8oQEkXA0AKi2z4TM/49Xje9
         g+9ovcjJNa00DPf6TuM3ZNoOwfxGDAVNrG0VpqfKTdE7a3tirVPXmGq+t9AchO3lPEOV
         VCiez7dwq9caycp0B0ZCax4UAdeXxWzMqflfnFGpuSS8DQtkrVgAsdBCW2qUS5hRbH31
         sLEpzS+3Cd6f43V3FLqrekqflwzsrjSytXvQj/vK0QLATGELMRjGxfp/uC7S3QDYlD+w
         ncgwQKQ94F28w5zO+Ci8kyE8V9/F/pk9nIfS5Adc5wgyvpele3/BKYY08uqk423HvKsj
         ySWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y64si8133057oig.211.2019.06.04.00.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 00:00:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7E4D518DF7C;
	Tue,  4 Jun 2019 07:00:00 +0000 (UTC)
Received: from [10.36.117.37] (ovpn-117-37.ams2.redhat.com [10.36.117.37])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 107EB5C89D;
	Tue,  4 Jun 2019 06:59:49 +0000 (UTC)
Subject: Re: [PATCH v3 06/11] mm/memory_hotplug: Allow arch_remove_pages()
 without CONFIG_MEMORY_HOTREMOVE
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Igor Mammedov
 <imammedo@redhat.com>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
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
 "Rafael J. Wysocki" <rafael@kernel.org>, Michal Hocko <mhocko@suse.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Oscar Salvador <osalvador@suse.com>,
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
 <20190603221540.bvhuvltlwuirm5sl@master>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <2ba74d1d-643e-7e22-acff-2b04c579b4f8@redhat.com>
Date: Tue, 4 Jun 2019 08:59:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190603221540.bvhuvltlwuirm5sl@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 04 Jun 2019 07:00:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04.06.19 00:15, Wei Yang wrote:
> Allow arch_remove_pages() or arch_remove_memory()?

Looks like I merged __remove_pages() and arch_remove_memory().

@Andrew, can you fix this up to

"mm/memory_hotplug: Allow arch_remove_memory() without
CONFIG_MEMORY_HOTREMOVE"

? Thanks!

> 
> And want to confirm the kernel build on affected arch succeed?

I compile-tested on s390x and x86. As the patches are in linux-next for
some time, I think the other builds are also fine.

Thanks!

-- 

Thanks,

David / dhildenb

