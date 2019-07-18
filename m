Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5766C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:20:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96FE621850
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:20:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96FE621850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3248B6B0006; Thu, 18 Jul 2019 12:20:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AF826B0008; Thu, 18 Jul 2019 12:20:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19E6D8E0005; Thu, 18 Jul 2019 12:20:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id A61ED6B0006
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 12:20:22 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id r5so6292700ljn.1
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:20:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=rUEHhJXc7IUGp/9xpom9kdyD+1TduVj1LeXOHJgI0ms=;
        b=TUGQoJMrV9BLVMeYcOIGG1D4M0FBRgLvIJkCWeg4iXwyRpUIdkrn05fxzp0HzU5ijK
         eR7rcMkHFn9vqsLw53bp8t0faVFoZhJMe6+tnuDsktcjJmC1J24Fa1MCqbmgEt/HQgWD
         HQcLztKGmED1/9d0nIGCQ2IiPATOv08zAywMNhLiNe316bCD5CEbLnVxom3me1shkG5g
         zJ/ZNXVcn83g5acunhlG3OTTTIXL0yfvwo5UxZyB+kW5UK44Gr1yTU2KpQINJC8Y0+FJ
         bGEsjwG+roQCHwtbPYI22z9lYtpiRoSRE17jG2qYncQmKv0FCMCJY2u2nyFhaP1ye+x6
         JOfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAV4JRx2rZnWFDPNpjtoOKfwjFTGz4XPvRMD9Jz4XS3I1qvfF734
	8cSsFQdvwo9bTqP0njksNGAZMl2n5qgk33kl97cjwUn9tUp/PUfzILLBccbRjHFf2jVostFDHtG
	N7iRH33ZKhDAgfGRBS3DzGma/DTb1f7RDPq2YTpbFbAnh8NyM01UqQR1Frj/U0kMe2Q==
X-Received: by 2002:a2e:8e90:: with SMTP id z16mr3018467ljk.4.1563466822128;
        Thu, 18 Jul 2019 09:20:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMZs52AHtnDth3Pil5W1qT6quM9WHEH+OpPmeEen/lDhUW9DByjcxYtr9fcQkIVhuNQQie
X-Received: by 2002:a2e:8e90:: with SMTP id z16mr3018442ljk.4.1563466821286;
        Thu, 18 Jul 2019 09:20:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563466821; cv=none;
        d=google.com; s=arc-20160816;
        b=nccdkduHr5AnV7BZH8o7douDnNZZyYIVeXLHqC0rWjpCG5hUvgviBEXIUQV6P6yO/1
         38xdv52YMmUpRd2pbiD1rPTL9fsyJwbtAp/fzWNcpjiy+ySTsGmpn0x0J6VlrJp71eH8
         6liSwviHF7SYDZBhTklEzMXMyddl38s8HyPsg7jZI5g4HhcFMaYO2CjZf7+D97fLD6vF
         QcCqoKU6DMfPgBYbgxqAKZ7KgtCUn8fRGEp32N4lsyap8nLDLM/NeQ1MwQgqYPHwCFfT
         jWoOCTT15sRdjE94r3iA90iYHddw9Qdwa36pulK1hgvnuP6gUTZFyTR3gqOfC17M4Ulv
         cxzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=rUEHhJXc7IUGp/9xpom9kdyD+1TduVj1LeXOHJgI0ms=;
        b=TrY7VB1ZBzo0vH1vB5FCE2mvci9YnWaT6UZxZDhINklXgCe+UpwnsoMiZzLd06N1Co
         so/E6PzPu2UZhrc0HhHLXp92r3wuv9ZABV+UIKCoVII/GxyCbEdx4YEiWQ0MkDtPvhMD
         42s/qaFvC0Q8k9zq7Tp1zpEyZ62IyPN1FMqy+qmFXEe2k1JugBOgC7ERdPZ9fiHR/VpS
         xBQGQZNfrzshLuw6n6Uufd15D+vEUhamWOdAFCkg+tYbM74Ne6rKjrx4ZuF0aWP9YxdR
         SfMwaHvxM4lPXfdASsgwXfAwuy64wXTiT9RGkxibrbRvEnpvoMMrXGrUTMUMgxj75K2s
         4k5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id d6si21323462lfb.94.2019.07.18.09.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 09:20:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1ho98k-00084V-Td; Thu, 18 Jul 2019 19:20:19 +0300
Subject: Re: kasan: paging percpu + kasan causes a double fault
To: Dmitry Vyukov <dvyukov@google.com>, Dennis Zhou <dennis@kernel.org>
Cc: Alexander Potapenko <glider@google.com>, Tejun Heo <tj@kernel.org>,
 Kefeng Wang <wangkefeng.wang@huawei.com>,
 kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>
References: <20190708150532.GB17098@dennisz-mbp>
 <CACT4Y+YevDd-y4Au33=mr-0-UQPy8NR0vmG8zSiCfmzx6gTB-w@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <912176db-f616-54cc-7665-94baa61ea11d@virtuozzo.com>
Date: Thu, 18 Jul 2019 19:20:21 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CACT4Y+YevDd-y4Au33=mr-0-UQPy8NR0vmG8zSiCfmzx6gTB-w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/18/19 6:51 PM, Dmitry Vyukov wrote:
> On Mon, Jul 8, 2019 at 5:05 PM Dennis Zhou <dennis@kernel.org> wrote:
>>
>> Hi Andrey, Alexander, and Dmitry,
>>
>> It was reported to me that when percpu is ran with param
>> percpu_alloc=page or the embed allocation scheme fails and falls back to
>> page that a double fault occurs.
>>
>> I don't know much about how kasan works, but a difference between the
>> two is that we manually reserve vm area via vm_area_register_early().
>> I guessed it had something to do with the stack canary or the irq_stack,
>> and manually mapped the shadow vm area with kasan_add_zero_shadow(), but
>> that didn't seem to do the trick.
>>
>> RIP resolves to the fixed_percpu_data declaration.
>>
>> Double fault below:
>> [    0.000000] PANIC: double fault, error_code: 0x0
>> [    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 5.2.0-rc7-00007-ge0afe6d4d12c-dirty #299
>> [    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.el7 04/01/2014
>> [    0.000000] RIP: 0010:no_context+0x38/0x4b0
>> [    0.000000] Code: df 41 57 41 56 4c 8d bf 88 00 00 00 41 55 49 89 d5 41 54 49 89 f4 55 48 89 fd 4c8
>> [    0.000000] RSP: 0000:ffffc8ffffffff28 EFLAGS: 00010096
>> [    0.000000] RAX: dffffc0000000000 RBX: ffffc8ffffffff50 RCX: 000000000000000b
>> [    0.000000] RDX: fffff52000000030 RSI: 0000000000000003 RDI: ffffc90000000130
>> [    0.000000] RBP: ffffc900000000a8 R08: 0000000000000001 R09: 0000000000000000
>> [    0.000000] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000003
>> [    0.000000] R13: fffff52000000030 R14: 0000000000000000 R15: ffffc90000000130
>> [    0.000000] FS:  0000000000000000(0000) GS:ffffc90000000000(0000) knlGS:0000000000000000
>> [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [    0.000000] CR2: ffffc8ffffffff18 CR3: 0000000002e0d001 CR4: 00000000000606b0
>> [    0.000000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [    0.000000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>> [    0.000000] Call Trace:
>> [    0.000000] Kernel panic - not syncing: Machine halted.
>> [    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 5.2.0-rc7-00007-ge0afe6d4d12c-dirty #299
>> [    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.el7 04/01/2014
>> [    0.000000] Call Trace:
>> [    0.000000]  <#DF>
>> [    0.000000]  dump_stack+0x5b/0x90
>> [    0.000000]  panic+0x17e/0x36e
>> [    0.000000]  ? __warn_printk+0xdb/0xdb
>> [    0.000000]  ? spurious_kernel_fault_check+0x1a/0x60
>> [    0.000000]  df_debug+0x2e/0x39
>> [    0.000000]  do_double_fault+0x89/0xb0
>> [    0.000000]  double_fault+0x1e/0x30
>> [    0.000000] RIP: 0010:no_context+0x38/0x4b0
>> [    0.000000] Code: df 41 57 41 56 4c 8d bf 88 00 00 00 41 55 49 89 d5 41 54 49 89 f4 55 48 89 fd 4c8
>> [    0.000000] RSP: 0000:ffffc8ffffffff28 EFLAGS: 00010096
>> [    0.000000] RAX: dffffc0000000000 RBX: ffffc8ffffffff50 RCX: 000000000000000b
>> [    0.000000] RDX: fffff52000000030 RSI: 0000000000000003 RDI: ffffc90000000130
>> [    0.000000] RBP: ffffc900000000a8 R08: 0000000000000001 R09: 0000000000000000
>> [    0.000000] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000003
>> [ 0.000000] R13: fffff52000000030 R14: 0000000000000000 R15: ffffc90000000130
> 
> 
> Hi Dennis,
> 
> I don't have lots of useful info, but a naive question: could you stop
> using percpu_alloc=page with KASAN? That should resolve the problem :)
> We could even add a runtime check that will clearly say that this
> combintation does not work.
> 
> I see that setup_per_cpu_areas is called after kasan_init which is
> called from setup_arch. So KASAN should already map final shadow at
> that point.
> The only potential reason that I see is that setup_per_cpu_areas maps
> the percpu region at address that is not covered/expected by
> kasan_init. Where is page-based percpu is mapped? Is that covered by
> kasan_init?
> Otherwise, seeing the full stack trace of the fault may shed some light.
> 

percpu_alloc=page maps percpu areas into vmalloc, which don't have RW KASAN shadow mem.
irq stack are percpu thus we have GPF on attempt to poison stack redzones in irq.

