Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C345C46460
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 05:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3629C20862
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 05:06:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3629C20862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99D476B0005; Wed, 15 May 2019 01:06:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94EAB6B0006; Wed, 15 May 2019 01:06:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83D8F6B0007; Wed, 15 May 2019 01:06:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC586B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 01:06:36 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z7so1078571pgc.1
        for <linux-mm@kvack.org>; Tue, 14 May 2019 22:06:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+qom0Qn6LwXg8UJkqiMrz8BQabBvoo+xpSl9SHnkWOY=;
        b=AUX0klpF6gQZkiIk2DGcmJUVmCQJuLrWmoD2GXaR1R1uMetKdc4jxpk0skI0jPJxAv
         Xs55DmsZToWHu5jQzkWDnYvdkDat8rdguhOPmHLplJByvZByCkD5uyMbO+65Sd1fVXaL
         nypYobgm3uF1MQA6vrifPZTx4XQjS0bKQy6P7/uEXQuuQhaHjbe26ku9vOeZSsAg68tv
         WO5pnufu3YbI6IFnobsaEcwoqf7Y0ZFpgSWdgmt7S96H4anq71iCTYRRZTfCsNLgc+c+
         TBKA20IstYBry2Um6AUFITzQ5rqyGF1sVwSu5Vcp5tXuYUCKkPZjvmu+PWuHe1VT947Y
         aBHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU8gJVNvAP06bSEkD6Qo5YkfC7INB6nnXY49sal9gju8LhunkXh
	bjWJ/xdQxHxPaQ9JmB3yKZZkH4u8B/AC09KD/hzarD05cOIPKAqiOIAH5VeHMTwzaDlfuhILQSK
	S2pi0b0hm5+3OfQ/M0wnTLfiBd92OzoXIJ5SkvTplYZYAFpgY0IZFi7z+/rWK1FnUsA==
X-Received: by 2002:a62:2b82:: with SMTP id r124mr36468243pfr.235.1557896795956;
        Tue, 14 May 2019 22:06:35 -0700 (PDT)
X-Received: by 2002:a62:2b82:: with SMTP id r124mr36468157pfr.235.1557896794601;
        Tue, 14 May 2019 22:06:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557896794; cv=none;
        d=google.com; s=arc-20160816;
        b=g3ffbBYbSzEBLpibvfhlu3wlwL/BcHGS1qQ7a2qt1QgJwZesuCCxp2/lAKlph7IpyM
         ucMHq1PViD7JfEbSANbVfjhp+9oZUoPhVE+2tGq+AVfJBlvYErsYysvYP0BFOz/yOc25
         Ef5TTTYYMsMSVJzF+cNnSqilX0JRXQYYfe+h8qHA49OEXN/ST/AYt3gWVvjmyi/35mVm
         YfyE90aXCuRPSCsiycrYx2HOxfNh/aOqUzdqoubuwS91ZcenVhK8R31YS5eJ4i7ofr12
         StttVLZrQlqXLwil5T93e7NtWOwf3f8E7YZ1YBNAwcHDM8L0VYKEI4ENU7wUqsKVVBfG
         lWJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+qom0Qn6LwXg8UJkqiMrz8BQabBvoo+xpSl9SHnkWOY=;
        b=xCAmFaq2LAGoejGIdqil4AJFLv1gVeSdSwHKvrKAavafwNqiis3KBowOg+ndhn7zmc
         UjJHMznKIuOQ68l5PSOb7IPeYRaQbUILbor5uU/zs2HWOCAw0iXBArY8RO5U1ctyldcq
         Kc61gQ4bO3FvX+HL1mHSsxLXgbDmG8j+YEXxL0H56dov7c8UFIbfceT69PfUBx+Stwpy
         WCFFM5D3SEYvVKZWcdKft5COZpOEuJixUQ5BKl7u7hlCIaYD+gctzcOXQZEBIDiFuWNu
         +IHrSsnuwtya15zt+04jHlAyaKrgdvUMP9mHoE+PrGZJAqu4OJU3OZFnck4GUgFN4A8d
         Rwcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cn1sor998223plb.20.2019.05.14.22.06.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 22:06:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqydcRf68wup3tmXCJXop6KI1ZxTGUxdyH6wtMYn4HOqUMhx5MO0r5tKJnQQFTgrfoAnruhVow==
X-Received: by 2002:a17:902:2e83:: with SMTP id r3mr26825633plb.139.1557896794167;
        Tue, 14 May 2019 22:06:34 -0700 (PDT)
Received: from localhost.localdomain ([106.215.121.117])
        by smtp.gmail.com with ESMTPSA id v81sm1354825pfa.16.2019.05.14.22.06.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 22:06:32 -0700 (PDT)
Subject: Re: [PATCH 0/4] support reserving crashkernel above 4G on arm64 kdump
To: Chen Zhou <chenzhou10@huawei.com>, catalin.marinas@arm.com,
 will.deacon@arm.com, akpm@linux-foundation.org, ard.biesheuvel@linaro.org,
 rppt@linux.ibm.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
 ebiederm@xmission.com
Cc: wangkefeng.wang@huawei.com, linux-mm@kvack.org,
 kexec@lists.infradead.org, linux-kernel@vger.kernel.org,
 takahiro.akashi@linaro.org, horms@verge.net.au,
 linux-arm-kernel@lists.infradead.org,
 "kexec@lists.infradead.org" <kexec@lists.infradead.org>,
 Bhupesh SHARMA <bhupesh.linux@gmail.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
From: Bhupesh Sharma <bhsharma@redhat.com>
Message-ID: <a9d017d0-82d3-3e5f-4af2-4c611393106d@redhat.com>
Date: Wed, 15 May 2019 10:36:24 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.2.1
MIME-Version: 1.0
In-Reply-To: <20190507035058.63992-1-chenzhou10@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+Cc kexec-list.

Hi Chen,

I think we are still in the quiet period of the merge cycle, but this is 
a change which will be useful for systems like HPE Apollo where we are 
looking at reserving crashkernel across a larger range.

Some comments inline and in respective patch threads..

On 05/07/2019 09:20 AM, Chen Zhou wrote:
> This patch series enable reserving crashkernel on high memory in arm64.

Please fix the patch subject, it should be v5.
Also please Cc the kexec-list (kexec@lists.infradead.org) for future 
versions to allow wider review of the patchset.

> We use crashkernel=X to reserve crashkernel below 4G, which will fail
> when there is no enough memory. Currently, crashkernel=Y@X can be used
> to reserve crashkernel above 4G, in this case, if swiotlb or DMA buffers
> are requierd, capture kernel will boot failure because of no low memory.

... ^^ required

s/capture kernel will boot failure because of no low memory./capture 
kernel boot will fail because there is no low memory available for 
allocation.

> When crashkernel is reserved above 4G in memory, kernel should reserve
> some amount of low memory for swiotlb and some DMA buffers. So there may
> be two crash kernel regions, one is below 4G, the other is above 4G. Then
> Crash dump kernel reads more than one crash kernel regions via a dtb
> property under node /chosen,
> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.

Please use consistent naming for the second kernel, better to use crash 
dump kernel.

I have tested this on my HPE Apollo machine and with 
crashkernel=886M,high syntax, I can get the board to reserve a larger 
memory range for the crashkernel (i.e. 886M):

# dmesg | grep -i crash
[    0.000000] kexec_core: Reserving 256MB of low memory at 3560MB for 
crashkernel (System low RAM: 2029MB)
[    0.000000] crashkernel reserved: 0x0000000bc5a00000 - 
0x0000000bfd000000 (886 MB)

kexec/kdump can also work also work fine on the board.

So, with the changes suggested in this cover letter and individual 
patches, please feel free to add:

Reviewed-and-Tested-by: Bhupesh Sharma <bhsharma@redhat.com>

Thanks,
Bhupesh

> Besides, we need to modify kexec-tools:
>    arm64: support more than one crash kernel regions(see [1])
> 
> I post this patch series about one month ago. The previous changes and
> discussions can be retrived from:
> 
> Changes since [v4]
> - reimplement memblock_cap_memory_ranges for multiple ranges by Mike.
> 
> Changes since [v3]
> - Add memblock_cap_memory_ranges back for multiple ranges.
> - Fix some compiling warnings.
> 
> Changes since [v2]
> - Split patch "arm64: kdump: support reserving crashkernel above 4G" as
>    two. Put "move reserve_crashkernel_low() into kexec_core.c" in a separate
>    patch.
> 
> Changes since [v1]:
> - Move common reserve_crashkernel_low() code into kernel/kexec_core.c.
> - Remove memblock_cap_memory_ranges() i added in v1 and implement that
>    in fdt_enforce_memory_region().
>    There are at most two crash kernel regions, for two crash kernel regions
>    case, we cap the memory range [min(regs[*].start), max(regs[*].end)]
>    and then remove the memory range in the middle.
> 
> [1]: http://lists.infradead.org/pipermail/kexec/2019-April/022792.html
> [v1]: https://lkml.org/lkml/2019/4/2/1174
> [v2]: https://lkml.org/lkml/2019/4/9/86
> [v3]: https://lkml.org/lkml/2019/4/9/306
> [v4]: https://lkml.org/lkml/2019/4/15/273
> 
> Chen Zhou (3):
>    x86: kdump: move reserve_crashkernel_low() into kexec_core.c
>    arm64: kdump: support reserving crashkernel above 4G
>    kdump: update Documentation about crashkernel on arm64
> 
> Mike Rapoport (1):
>    memblock: extend memblock_cap_memory_range to multiple ranges
> 
>   Documentation/admin-guide/kernel-parameters.txt |  6 +--
>   arch/arm64/include/asm/kexec.h                  |  3 ++
>   arch/arm64/kernel/setup.c                       |  3 ++
>   arch/arm64/mm/init.c                            | 72 +++++++++++++++++++------
>   arch/x86/include/asm/kexec.h                    |  3 ++
>   arch/x86/kernel/setup.c                         | 66 +++--------------------
>   include/linux/kexec.h                           |  5 ++
>   include/linux/memblock.h                        |  2 +-
>   kernel/kexec_core.c                             | 56 +++++++++++++++++++
>   mm/memblock.c                                   | 44 +++++++--------
>   10 files changed, 157 insertions(+), 103 deletions(-)
> 

