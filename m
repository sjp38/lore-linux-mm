Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2D92C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:53:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FCA72184B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:53:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FCA72184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D3866B026B; Fri,  5 Apr 2019 09:53:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 181A86B026C; Fri,  5 Apr 2019 09:53:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0492F6B026D; Fri,  5 Apr 2019 09:53:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D30EA6B026B
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 09:53:28 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id p26so5310814qtq.21
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 06:53:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=WVpVG7WYnF3qMOdRmZUYe0KhrT5H5rUNj89NPKAV1Cc=;
        b=LPZrViMLb3UHhvlLvrNgj3EhkC4lVSDo4cQ4R4JFrd/bS4+sx+vAxZ8emxs392b070
         0WsENpfyP8f+2PB/p9NJmIhaGZUU5dMXmXtvsZ6rVFGVfeVZeQlJ2qG1ZtxmIHULt2ao
         hZrw+zfwdbfBdo403q+MOqjmi8aBnb86/QK+VY/iA4KjR11HzqDSDFeI1Zjl+9UsBSKl
         4D0bhhRMXU2vJR+VjsN8Xh8otsiovrYu/nWTwn0kxIw8mC1Dn2IhNGINMw7vFCvJm2ZZ
         fATTxTTTjTm4BLXEF0iC6oorWVmB5M6xFeyob2MIilyP5cu7ImAmYjD3BZNPaNHDpM4J
         XEPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUiIADw/qC0qAheBT4yQPh9rxADo142VtapAL3xbiDJVC46SoVv
	j68DgY/BhjDP5k4gb8n4vk3JEb7w3QOi1fwr0EK1hhYwfhNqztFT5AnS5cifhmTdkPkqTc5rE8M
	d5NtuQVvaO2twD4EnpgM7zg/9T9JlHHyd6/rqLPj8nTsKH1gSrIrSWSlI7RBaayzIHA==
X-Received: by 2002:a05:620a:1424:: with SMTP id k4mr10549413qkj.17.1554472408582;
        Fri, 05 Apr 2019 06:53:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSGpUFFd26A+QhNecAQc8m62U/p56Bc3hPO4xIQvsoZFS7WEE73ZaAcQFgFkvPbbYLbtL6
X-Received: by 2002:a05:620a:1424:: with SMTP id k4mr10549372qkj.17.1554472407990;
        Fri, 05 Apr 2019 06:53:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554472407; cv=none;
        d=google.com; s=arc-20160816;
        b=kKgnCqc5FVk75J/t+KUQp+W6hd/hA0Yk58A0D7L0hdWPlKboDguD4I0F50C1XBmOOR
         DGollVaFRLrDYVS3I40d5AReKs/hBD/w5zC46JX3AdnO8he9QQmGtlieBJi0FtWls269
         JZoB9C+wzyh4pnjacMq8CPXaur/AXlbQuZxbb9BbzmQ5myPcSSmZZdhqzN119quJCVed
         dYMdPVJR8gNqc5oNkL5r6WP9uhuVuFZF4z3zd6FqSfZ9ABZmKWQMieC2x7weu7glTzVi
         IcIvhTbJYJPGervU6nMlc4xBginWQ4R2On19MR3nsxpi7ba+Mp2uqhJDPaqH7vPKa3uy
         s58g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=WVpVG7WYnF3qMOdRmZUYe0KhrT5H5rUNj89NPKAV1Cc=;
        b=lUPfEyKHLqoxdc/04CdXrmw8ofxN3r61Fo3H0cjG35PZJKqLd4GDFCNPd5WBa8v/uF
         mW3Z72AVr6paU7bF7r175vB+NQX0oTVsLgP7dOS/L6mr2xyV1ZG3OeShq3lp976eFzCF
         YxtEScc3YZC4lTEjkby4gtRlUWNZyaY8N0A/sv5Ho5zWFoDRi7jBPy37+eR418SH2qow
         XwSgKq2gHyULFlBiPGBbR/xl/AMoJveSCLLAFlvzcnaM6psFibH0I9acyMBg/gR4sBWn
         e1/8XcB6H6SUoFM05PCRhwR1Z87XQsoNqvK4lnloqFZaFmfr946yw0/eXYmKXQPyvBWQ
         UyQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l1si2259738qkc.47.2019.04.05.06.53.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 06:53:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2F5484902D;
	Fri,  5 Apr 2019 13:53:27 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7E13860C11;
	Fri,  5 Apr 2019 13:53:26 +0000 (UTC)
Date: Fri, 5 Apr 2019 09:53:24 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: struct dev_pagemap corruption
Message-ID: <20190405135324.GA5627@redhat.com>
References: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 05 Apr 2019 13:53:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 05, 2019 at 10:10:22AM +0530, Anshuman Khandual wrote:
> Hello,
> 
> On arm64 platform "struct dev_pagemap" is getting corrupted during ZONE_DEVICE
> unmapping path through device_destroy(). Its device memory range end address
> (pgmap->res.end) which is getting corrupted in this particular case. AFAICS
> pgmap which gets initialized by the driver and mapped with devm_memremap_pages()
> should retain it's values during the unmapping path as well. Is this assumption
> right ?
> 
> [   62.779412] Call trace:
> [   62.779808]  dump_backtrace+0x0/0x118
> [   62.780460]  show_stack+0x14/0x20
> [   62.781204]  dump_stack+0xa8/0xcc
> [   62.781941]  devm_memremap_pages_release+0x24/0x1d8
> [   62.783021]  devm_action_release+0x10/0x18
> [   62.783911]  release_nodes+0x1b0/0x220
> [   62.784732]  devres_release_all+0x34/0x50
> [   62.785623]  device_release+0x24/0x90
> [   62.786454]  kobject_put+0x74/0xe8
> [   62.787214]  device_destroy+0x48/0x58
> [   62.788041]  zone_device_public_altmap_init+0x404/0x42c [zone_device_public_altmap]
> [   62.789675]  do_one_initcall+0x74/0x190
> [   62.790528]  do_init_module+0x50/0x1c0
> [   62.791346]  load_module+0x1be4/0x2140
> [   62.792192]  __se_sys_finit_module+0xb8/0xc8
> [   62.793128]  __arm64_sys_finit_module+0x18/0x20
> [   62.794128]  el0_svc_handler+0x88/0x100
> [   62.794989]  el0_svc+0x8/0xc
> 
> The problem can be traced down here.
> 
> diff --git a/drivers/base/devres.c b/drivers/base/devres.c
> index e038e2b3b7ea..2a410c88c596 100644
> --- a/drivers/base/devres.c
> +++ b/drivers/base/devres.c
> @@ -33,7 +33,7 @@ struct devres {
>          * Thus we use ARCH_KMALLOC_MINALIGN here and get exactly the same
>          * buffer alignment as if it was allocated by plain kmalloc().
>          */
> -       u8 __aligned(ARCH_KMALLOC_MINALIGN) data[];
> +       u8 __aligned(__alignof__(unsigned long long)) data[];
>  };

I doubt that pgmap->res.end get corrupted during device_destroy() but given
that the above changes fix the issue it kind of boggle the mind. If i where
to debug this i would probably run a kernel with qemu -s to get a gdbserver
and then attach gdb and set breakpoint on devm_memremap_pages() then when
that trigger i would set memory watch on the pgmap->res.end (there use to be
way to use memory as pmem through kernel boot option).

A printk alternative solution is, assuming you only have one pgmap, add a
global static struct pgmap *debug_pgmap = NULL; in memremap.c set that in
devm_memremap_pages() and add an helper function:

void debug_pgmap(const char *file, unsigned line)
{
    printk(... file, line);
    printk(... debug_pmap->res.end);
}

In a header:
#define DEBUG_PGMAP debug_pgmap(__FILE__, __LINE__);

Then sprinkle DEBUG_PGMAP within device_destroy(), device_unregister(),
device_release() and see when it get corrupted.

gdb would be faster but sometime i got issue with memory watchpoint and virt.

Cheers,
Jérôme

