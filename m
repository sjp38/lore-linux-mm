Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 852D8C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 06:32:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C2D72147C
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 06:32:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C2D72147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7157E8E001F; Thu,  7 Feb 2019 01:32:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C4118E0002; Thu,  7 Feb 2019 01:32:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 565608E001F; Thu,  7 Feb 2019 01:32:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB7C28E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 01:32:07 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x15so3936513edd.2
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 22:32:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=vJ0M1dbSIaUrgNQ0T9Yn4uC98NPfXql0i2YAxDyqBW0=;
        b=Nj1gLB56/X9ZSH38Mjnrte2UYrmDoqY/xSs6eFRz6zuIEyySdU2D6QV/4d4jGgAZLj
         QWSor0fkPXRIRmqPXcEkCvjK/mRqGxooI08k3eiyvekfqKIDbLEXNd/2dugN/GrE+ntS
         1LWSDJVMLHB6+FmP71nSoYqNE6mdgf7zxvh/32DbtK2KEYiBy0KAxVpWA0dZaGqtIHzs
         FTZtSTJ3Nb5OBoHK8vdQOe8mKlp0Sr9C71K7Bj0viJF6OdOqZbWt84c6zFlc5SwkdVSg
         OQXtpsQxgwY+1GM3eva4znz88xtn5RmpXgTxweCACcGriuYMs9GbcBw19lYUi5VK3kIh
         /rLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: AHQUAuYNCeajRUS2R2WREdkcoy1V19hpafyAzQgY3ag8mvRBxkSEGpby
	tydBERFnRkeS5QbzOuLIqkvEOUeWlMH55HdaYF/W2luh4J4NF+OfaQkmK0ZwvM2O2incqlAtWz0
	r/hBw9ir7sCX1VZaPddBVwQYEKqzjdP8l2KofVvR3JeYbRFjvx+G0n1eh8/rdlBL89A==
X-Received: by 2002:a05:6402:185a:: with SMTP id v26mr11133663edy.163.1549521127486;
        Wed, 06 Feb 2019 22:32:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaXgQvzC2zl8UGIkljjixgVMnqe58EC5lPzd9513V3LMK2XqOzNU3WDz6/QVMcDBT4tM/Lx
X-Received: by 2002:a05:6402:185a:: with SMTP id v26mr11133619edy.163.1549521126541;
        Wed, 06 Feb 2019 22:32:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549521126; cv=none;
        d=google.com; s=arc-20160816;
        b=ke4JXJcMP1o4KCYPEMDC8gjLFTzof4abNd009v2fc5JVQWdQBGBqsksLY8JI32/rxH
         PxxOdUTZX9UHDDKkkmvBqu4zSEDYj84lxly2fLKhe91MiW0zt+INkfru0vVkVFDqTyM4
         39zZIfSR9WrYKzaRgn2b7Sa3mJfmgZfFj1uStE4UsCophLd9pLDrdL+znnBNt9Kkpnrq
         9wBJOk9JTBmTgmNRandWrXKKNXZp48WuaXZE76yOnVhMTXW17pnb8FdjgIuJPKcFUaCG
         f8QF4VhvONYvGDGAcF2jGTCSNEZOfU/QZB1cmiz90zVXrfhrGztJt4mHvOPKcWmhzaSD
         AuCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=vJ0M1dbSIaUrgNQ0T9Yn4uC98NPfXql0i2YAxDyqBW0=;
        b=nPX8JlnlT+4Zed0p26FweX3bKFs6YXEDe9cic2C8ejSGhdNsRa1dtpmTHORYZCZuMs
         1Q5fz0PYkhr4/woDWmEabigFVEtbdaQMU8wZCrhD8yVXK9aD7xkowDF23+DaOBVP/JwH
         rmKZs3yiCziqg0A0d/8NR0u+iG/7ieRRsvVu0SPC+yo/5qBNjIJdQzd0tC7sZ/DSXs47
         u2JdKO2XHp05becaYCwMCyQVg8WCrIiOBHWysLEq5fZMnJLtfbbaWPzT/H67/wArDcdS
         3v/ou9RMJFGZ6CWhweqMfiV/QQmDQfCyXmBmQWRX5NP0Ty6dB2upAkeVlXxEdCh10R8e
         BebA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v16si2017850ejq.113.2019.02.06.22.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 22:32:06 -0800 (PST)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4B289AED8;
	Thu,  7 Feb 2019 06:32:05 +0000 (UTC)
Subject: Re: [PATCH v2 2/2] x86/xen: dont add memory above max allowed
 allocation
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
 x86@kernel.org, linux-mm@kvack.org
Cc: sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de,
 mingo@redhat.com, bp@alien8.de
References: <20190130082233.23840-1-jgross@suse.com>
 <20190130082233.23840-3-jgross@suse.com>
 <8d4f7604-cc47-9cd7-2cca-b00b3667d2fa@oracle.com>
From: Juergen Gross <jgross@suse.com>
Openpgp: preference=signencrypt
Autocrypt: addr=jgross@suse.com; prefer-encrypt=mutual; keydata=
 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
Message-ID: <dc681ef2-8437-8614-87ef-72762eff81ce@suse.com>
Date: Thu, 7 Feb 2019 07:32:04 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <8d4f7604-cc47-9cd7-2cca-b00b3667d2fa@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/02/2019 19:46, Boris Ostrovsky wrote:
> On 1/30/19 3:22 AM, Juergen Gross wrote:
>> Don't allow memory to be added above the allowed maximum allocation
>> limit set by Xen.
>>
>> Trying to do so would result in cases like the following:
>>
>> [  584.559652] ------------[ cut here ]------------
>> [  584.564897] WARNING: CPU: 2 PID: 1 at ../arch/x86/xen/multicalls.c:129 xen_alloc_pte+0x1c7/0x390()
>> [  584.575151] Modules linked in:
>> [  584.578643] Supported: Yes
>> [  584.581750] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.4.120-92.70-default #1
>> [  584.590000] Hardware name: Cisco Systems Inc UCSC-C460-M4/UCSC-C460-M4, BIOS C460M4.4.0.1b.0.0629181419 06/29/2018
>> [  584.601862]  0000000000000000 ffffffff813175a0 0000000000000000 ffffffff8184777c
>> [  584.610200]  ffffffff8107f4e1 ffff880487eb7000 ffff8801862b79c0 ffff88048608d290
>> [  584.618537]  0000000000487eb7 ffffea0000000201 ffffffff81009de7 ffffffff81068561
>> [  584.626876] Call Trace:
>> [  584.629699]  [<ffffffff81019ad9>] dump_trace+0x59/0x340
>> [  584.635645]  [<ffffffff81019eaa>] show_stack_log_lvl+0xea/0x170
>> [  584.642391]  [<ffffffff8101ac51>] show_stack+0x21/0x40
>> [  584.648238]  [<ffffffff813175a0>] dump_stack+0x5c/0x7c
>> [  584.654085]  [<ffffffff8107f4e1>] warn_slowpath_common+0x81/0xb0
>> [  584.660932]  [<ffffffff81009de7>] xen_alloc_pte+0x1c7/0x390
>> [  584.667289]  [<ffffffff810647f0>] pmd_populate_kernel.constprop.6+0x40/0x80
>> [  584.675241]  [<ffffffff815ecfe8>] phys_pmd_init+0x210/0x255
>> [  584.681587]  [<ffffffff815ed207>] phys_pud_init+0x1da/0x247
>> [  584.687931]  [<ffffffff815edb3b>] kernel_physical_mapping_init+0xf5/0x1d4
>> [  584.695682]  [<ffffffff815e9bdd>] init_memory_mapping+0x18d/0x380
>> [  584.702631]  [<ffffffff81064699>] arch_add_memory+0x59/0xf0
>>
>> Signed-off-by: Juergen Gross <jgross@suse.com>
>> ---
>>  arch/x86/xen/setup.c      | 10 ++++++++++
>>  drivers/xen/xen-balloon.c |  6 ++++++
>>  2 files changed, 16 insertions(+)
>>
>> diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
>> index d5f303c0e656..fdb184cadaf5 100644
>> --- a/arch/x86/xen/setup.c
>> +++ b/arch/x86/xen/setup.c
>> @@ -12,6 +12,7 @@
>>  #include <linux/memblock.h>
>>  #include <linux/cpuidle.h>
>>  #include <linux/cpufreq.h>
>> +#include <linux/memory_hotplug.h>
>>  
>>  #include <asm/elf.h>
>>  #include <asm/vdso.h>
>> @@ -825,6 +826,15 @@ char * __init xen_memory_setup(void)
>>  				xen_max_p2m_pfn = pfn_s + n_pfns;
>>  			} else
>>  				discard = true;
>> +#ifdef CONFIG_MEMORY_HOTPLUG
>> +			/*
>> +			 * Don't allow adding memory not in E820 map while
>> +			 * booting the system. Once the balloon driver is up
>> +			 * it will remove that restriction again.
>> +			 */
>> +			max_mem_size = xen_e820_table.entries[i].addr +
>> +				       xen_e820_table.entries[i].size;
>> +#endif
>>  		}
>>  
>>  		if (!discard)
>> diff --git a/drivers/xen/xen-balloon.c b/drivers/xen/xen-balloon.c
>> index 2acbfe104e46..2a960fcc812e 100644
>> --- a/drivers/xen/xen-balloon.c
>> +++ b/drivers/xen/xen-balloon.c
>> @@ -37,6 +37,7 @@
>>  #include <linux/mm_types.h>
>>  #include <linux/init.h>
>>  #include <linux/capability.h>
>> +#include <linux/memory_hotplug.h>
>>  
>>  #include <xen/xen.h>
>>  #include <xen/interface/xen.h>
>> @@ -63,6 +64,11 @@ static void watch_target(struct xenbus_watch *watch,
>>  	static bool watch_fired;
>>  	static long target_diff;
>>  
>> +#ifdef CONFIG_MEMORY_HOTPLUG
>> +	/* The balloon driver will take care of adding memory now. */
>> +	max_mem_size = U64_MAX;
>> +#endif
> 
> 
> I don't think I understand this. Are you saying the guest should ignore
> 'mem' boot option?

No, I just managed to forget thinking about that possibility.

I need to save the old max_mem_size setting in setup.c and restore it here.


Juergen

