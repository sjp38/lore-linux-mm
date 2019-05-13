Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24239C04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:20:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3B51208C3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:20:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3B51208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56F146B000A; Mon, 13 May 2019 04:20:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5204A6B000C; Mon, 13 May 2019 04:20:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EA0D6B000D; Mon, 13 May 2019 04:20:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDDB6B000A
	for <linux-mm@kvack.org>; Mon, 13 May 2019 04:20:57 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t67so12143024qkd.15
        for <linux-mm@kvack.org>; Mon, 13 May 2019 01:20:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=akG5gDZZrRCpiWKMB+us0g7rMXXAVWeDWgokOXjlX2I=;
        b=DyC5Xm1j66YqhijpuOOH3dA+rI/qKdlt6OjiOh4c/LSeXquCt+9HD0/TR+eOh+pRWP
         R+wpYU148o5NSkKVzIRm7C4yIXaH5R5gJlBMrjEj3461furMV67a25kfJslYxgvGgI5z
         4G13N6Dbj4iUdMYN5+T+PUIlNcxrFNsJ7kxUKj+2pz8M56hb3Fgy92+wQw29O1gKDkYA
         nmw86Yxv7+stNsX7VDSczosN7Od97MFAGOydCew3zL8fz0wtMO4bbyckcX0s6tXobtgS
         u7P1ExWgErtNwN+I/PpawPZpqccij6oI3QugnQweSG3s5RsI/uKyznd4vprQbQfHGdKp
         qBwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUL+mWf2BgxC3tdAtPXxWDu0EM854QBhIbdVXNXHkT0oZVQ7i1K
	i6oqeYQjxCXiLjzg6ADsEIEdVyy0vWVu30X+JLykU4rZFK4SWBUSUPtGKCSqpNPaV+z4t7W9Isz
	zdeCCWxbVF0UlVXT4J70kI9tlBiWomKIDFZhUteD5IqGVn84XpWeThJ0efM+ixTnZsg==
X-Received: by 2002:ac8:36ce:: with SMTP id b14mr22586535qtc.190.1557735656854;
        Mon, 13 May 2019 01:20:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjlhuywLUuwaflwyMIn40KM4rrvDpLVyyW/Ka3oVKbURDC1W2E5EmClY3I8nulkxlxfMlx
X-Received: by 2002:ac8:36ce:: with SMTP id b14mr22586499qtc.190.1557735656161;
        Mon, 13 May 2019 01:20:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557735656; cv=none;
        d=google.com; s=arc-20160816;
        b=kFJSa5Wc1TksonuWNlWX5Oi0dQQu/5/78kUKD9nMje0lLy/ZGdmfzFl+/7v+mSTXlv
         3B6Cjpo9GFb9XXJqKc4nYeYf+dSz14lHQlNaMbbKo/3a94U4S/uWXDhgkBmibABLYeWB
         Pqta2Jnr56WEEqEIS74XoNS4tPonmSKrwIKnZQaFcQmVpeXNxwFlYHLe/mSM1MBb16/D
         yAAi09lQQ8lJmJxGaLGeM376uy34pfxPECr7EhChnxVrxdErDXuGlIM1BcC6hQx8PY2g
         qbXorIw6P/fv3H0RJH13ZcS90C9yOA+A36ZOU+iIXw7iPJkm2xKB5SLQXOYFr7pjcQH2
         YRrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:cc:to:from:subject;
        bh=akG5gDZZrRCpiWKMB+us0g7rMXXAVWeDWgokOXjlX2I=;
        b=UFejzmP/qRZzUlrb5UnzT9Q+OwUj5GGsZxR/5C5DnmZqKHaeU4/OIrO7BHm+NgrUu5
         1fQ14IuGyd7YayDWGIAod17r9udSWAYpe2D9fE7+Bpc3lLPi1HB4b9n74cjFeNa1kMeE
         39WrjrT5unRFEzoHNnnKh/LDJYfXFqdfmPpHtwBcYcELPgFCmqTa9aUUF9bzqT4ZNWKG
         W7f7v5jeTvD7hwAk4vtj/AEzqQPB3mT6PZPMFTkB/sIiy3gQzeDIyIWheop5xejk/bsc
         oYCZfDLrTUgtH6sTlNsI6lBZni3AXkO5VZcVvSejSNrGzWkWuOg/6kVvZQKjvNYLROxX
         7dSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e3si6413187qvj.108.2019.05.13.01.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 01:20:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5CCBD307D96D;
	Mon, 13 May 2019 08:20:53 +0000 (UTC)
Received: from [10.36.117.84] (ovpn-117-84.ams2.redhat.com [10.36.117.84])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 837341001E8B;
	Mon, 13 May 2019 08:20:44 +0000 (UTC)
Subject: Re: [PATCH v2 3/8] mm/memory_hotplug: arch_remove_memory() and
 __remove_pages() with CONFIG_MEMORY_HOTPLUG
From: David Hildenbrand <david@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>,
 Oscar Salvador <osalvador@suse.com>
Cc: Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
 linux-s390 <linux-s390@vger.kernel.org>, Linux-sh
 <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
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
 Baoquan He <bhe@redhat.com>, Logan Gunthorpe <logang@deltatee.com>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-4-david@redhat.com>
 <CAPcyv4jpnKjeP3QEvF3_9CzdZhtFXN2nMU7P-Ee7y06J3bGZ0A@mail.gmail.com>
 <c027a782-1cef-a076-92a3-3ce36140f3f2@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <fd061541-4433-d7a2-df73-66f39b61d0c9@redhat.com>
Date: Mon, 13 May 2019 10:20:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <c027a782-1cef-a076-92a3-3ce36140f3f2@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 13 May 2019 08:20:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.05.19 09:48, David Hildenbrand wrote:
> On 07.05.19 23:02, Dan Williams wrote:
>> On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>>>
>>> Let's prepare for better error handling while adding memory by allowing
>>> to use arch_remove_memory() and __remove_pages() even if
>>> CONFIG_MEMORY_HOTREMOVE is not set. CONFIG_MEMORY_HOTREMOVE effectively
>>> covers
>>> - Offlining of system ram (memory block devices) - offline_pages()
>>> - Unplug of system ram - remove_memory()
>>> - Unplug/remap of device memory - devm_memremap()
>>>
>>> This allows e.g. for handling like
>>>
>>> arch_add_memory()
>>> rc = do_something();
>>> if (rc) {
>>>         arch_remove_memory();
>>> }
>>>
>>> Whereby do_something() will for example be memory block device creation
>>> after it has been factored out.
>>
>> What's left after this? Can we just get rid of CONFIG_MEMORY_HOTREMOVE
>> option completely when CONFIG_MEMORY_HOTPLUG is enabled? It's not
>> clear to me why there was ever the option to compile out the remove
>> code when the add code is included.
>>
> 
> If there are no other comments, I will go ahead and rip out
> CONFIG_MEMORY_HOTREMOVE completely, gluing the functionality to
> CONFIG_MEMORY_HOTPLUG.
> 

Hmmmm, however this will require CONFIG_MEMORY_HOTPLUG to require

- MEMORY_ISOLATION
- HAVE_BOOTMEM_INFO_NODE if (X86_64 || PPC64)

And depends on
- MIGRATION

Which would limit the configurations where memory hotplug would be
available. I guess going with this patch here is ok as a first step.

I just realized, that we'll need arch_remove_memory() for arm64 to make
this patch here work.

-- 

Thanks,

David / dhildenb

