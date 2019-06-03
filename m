Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EF7FC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:41:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9054224695
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:41:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9054224695
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 177FA6B026A; Mon,  3 Jun 2019 17:41:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 128F66B026F; Mon,  3 Jun 2019 17:41:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F32C16B0270; Mon,  3 Jun 2019 17:40:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id C728F6B026A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:40:59 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id f30so5767171oij.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:40:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Ly0xNz6lB51dOYtlveVJhI9msoD4dzW8CfwdhHtDwZU=;
        b=BEt3TIxI5P3iiL28KZvqJ+YohAK0IqoNG4MbrhTAzpq74RKenRYDkkx9mFh6XtzLEj
         GBRFrU6y6Ao1trEX3uV2Q8/igOFqkiudnxezMdoMAYZ9ZFBm3eEQxN9EURdVR8nfl27C
         eOSKJELCwyhdmMIGVbQm4gNyOCWdeJuCrpjxroxWX3jGxGrOpIs4bAryMMEaQpJ6Pjdr
         aZGWM6ZnBCtvsbg7+l7eWVomzdiyYssVE4l+gtHvGo36zvMgJHxseLXOMEAs+rmgxVPq
         RAPzyo2M8jZ5Raq0H0DFFcWH1QSchR+RBX7nWhA1QaKtAoiUFWUuNuphYaNnKFV9WIgl
         cMTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU7RaLYgHSjwEHq3MnOWcDA4cffQGbdkQfQT4nRCwJfBMTY1R6l
	u1LmDKui1kVwwxkWQeYVlKuigzccmEE9hX2B4/49z/Le2lcl269ye7UWGr1QQKWP3zibVKsK9OY
	+pOVEDQ/vkh7bWcJWtbP9XR9nwMYbSsj8W+5nILW7mA7J7j36etu9Z8NoCLYrLlgWGA==
X-Received: by 2002:a9d:6d8d:: with SMTP id x13mr2688249otp.6.1559598059539;
        Mon, 03 Jun 2019 14:40:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxl34sXnO6TsMzL1TEpOmzB9rVeAPm07XfwP2VkWaUMjfMqQsQhrJKfqgLyuTl0C1abACwI
X-Received: by 2002:a9d:6d8d:: with SMTP id x13mr2688216otp.6.1559598058465;
        Mon, 03 Jun 2019 14:40:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559598058; cv=none;
        d=google.com; s=arc-20160816;
        b=MBD5K10ieozU4spHr6iHJBw6YrmnEaQvc2mbVukifD9blc7HrpJglF3qzhU3F5tXGO
         VFnJVRbm7ztyuaGFQNSDVMB2O9V2VDWcYml4z2Y2KoRiOBoOvVEoXYHL5IvTyiETx/OX
         WIGE2LA0fdtU0npnjY3ltU6IpufGMcdxa2uZdGG+YE/JZs9lkp75Ws48TO+Az5bdc8Tg
         uDHjY7ol3LIJAjPfOF1r6vnXHZPY0cw/VtYsfCIDNY7RYbfEacc84s0T9upqZpQ0swxJ
         6df9gxXiLLCbcvzacAwdcuQGKlaqNzEKGREcLsddVJyCGm+wbuihn5jdRYcFW5Bf8e2b
         5AMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Ly0xNz6lB51dOYtlveVJhI9msoD4dzW8CfwdhHtDwZU=;
        b=nb/Gvml6MY9yVkDNATQu6FZjYSfwEfpNqgq+WSQPOz4GmtKF6xtpgUcIkOqpjl7kwE
         Esl5ejkyO0la3EKPNLLn4nzboQ/JoGW0CHh10BwVktGUNd4GKupeP034yuX2DtEUzcZ4
         gXJNNsVE804v2POxB2tIlBfWzxXnfpM/z+NYvAnUEtcEfSTuYFqtr8EYe/Y+eVMgUzQm
         WZKVWZOBhzHfyqP8P4uUT659T0u8ZXj6nE18CK/1q5n+6J8TTHN2+Ij9ZBNf+NRE2gnO
         8RzkfIRgL2SNeCfLE1R3EZxij+lIA/PRQCaxdtn4p4+KuTrvkMdCBsbeBS7MdYdGGCF6
         lwyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si7047193otn.165.2019.06.03.14.40.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 14:40:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 472B313AAE;
	Mon,  3 Jun 2019 21:40:50 +0000 (UTC)
Received: from [10.36.116.16] (ovpn-116-16.ams2.redhat.com [10.36.116.16])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 76BD85C239;
	Mon,  3 Jun 2019 21:40:27 +0000 (UTC)
Subject: Re: [PATCH v3 00/11] mm/memory_hotplug: Factor out memory block
 devicehandling
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Igor Mammedov
 <imammedo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>,
 Andrew Banman <andrew.banman@hpe.com>, Andy Lutomirski <luto@kernel.org>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arun KS <arunks@codeaurora.org>,
 Baoquan He <bhe@redhat.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Chris Wilson <chris@chris-wilson.co.uk>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin"
 <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
 Ingo Molnar <mingo@redhat.com>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jun Yao <yaojun8558363@gmail.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Logan Gunthorpe <logang@deltatee.com>, Mark Brown <broonie@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Mathieu Malaterre <malat@debian.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>,
 Nicholas Piggin <npiggin@gmail.com>, Oscar Salvador <osalvador@suse.com>,
 Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
 "Rafael J. Wysocki" <rafael@kernel.org>, Rich Felker <dalias@libc.org>,
 Rob Herring <robh@kernel.org>, Robin Murphy <robin.murphy@arm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>,
 Vasily Gorbik <gor@linux.ibm.com>, Wei Yang <richardw.yang@linux.intel.com>,
 Will Deacon <will.deacon@arm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Yu Zhao <yuzhao@google.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190603212146.7hdha6wrlxtkxxxr@master>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <e8ff6f49-51ef-852a-f81c-bcd57d5e3a0c@redhat.com>
Date: Mon, 3 Jun 2019 23:40:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190603212146.7hdha6wrlxtkxxxr@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 03 Jun 2019 21:40:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.06.19 23:21, Wei Yang wrote:
> IMHO, there is some typo.

Yes, thanks.

> 
> s/devicehandling/device handling/
> 
> On Mon, May 27, 2019 at 01:11:41PM +0200, David Hildenbrand wrote:
>> We only want memory block devices for memory to be onlined/offlined
>> (add/remove from the buddy). This is required so user space can
>> online/offline memory and kdump gets notified about newly onlined memory.
>>
>> Let's factor out creation/removal of memory block devices. This helps
>> to further cleanup arch_add_memory/arch_remove_memory() and to make
>> implementation of new features easier - especially sub-section
>> memory hot add from Dan.
>>
>> Anshuman Khandual is currently working on arch_remove_memory(). I added
>> a temporary solution via "arm64/mm: Add temporary arch_remove_memory()
>> implementation", that is sufficient as a firsts tep in the context of
> 
> s/firsts tep/first step/
> 
>> this series. (we don't cleanup page tables in case anything goes
>> wrong already)
>>
>> Did a quick sanity test with DIMM plug/unplug, making sure all devices
>> and sysfs links properly get added/removed. Compile tested on s390x and
>> x86-64.
>>
>> Based on next/master.
>>
>> Next refactoring on my list will be making sure that remove_memory()
>> will never deal with zones / access "struct pages". Any kind of zone
>> handling will have to be done when offlining system memory / before
>> removing device memory. I am thinking about remove_pfn_range_from_zone()",
>> du undo everything "move_pfn_range_to_zone()" did.
> 
> what is "du undo"? I may not get it.

to undo ;)

-- 

Thanks,

David / dhildenb

