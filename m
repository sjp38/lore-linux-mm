Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38CE9C10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:09:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F37712064A
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:09:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F37712064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9847C6B0005; Thu, 18 Apr 2019 02:09:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90EA56B0007; Thu, 18 Apr 2019 02:09:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AEAF6B0008; Thu, 18 Apr 2019 02:09:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 27BCF6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:09:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e22so671048edd.9
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 23:09:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=CwfaXGLFS0Bh+c1tKgG8UT2fF7GZVGQHh4IM5ABA3F0=;
        b=MbHr6xQ6VOKx8r80pk4MGpnPQGfikcmnzyA6CqiXl1JjuGMCUw0W12NODtleZDbBcX
         7i6ZmgXZL8cdjjkSX3Qf8FIifDD1O3do2ZTjclrdDMqDuz79M4NzCnvxOuQrhG64jqz4
         BtFCZvbKZyRr9HbxSPWhITc5rUXunqL023XR0f17hAtsRtcDKCQpeb0JFPoqpKgIH9cE
         kwNIjMpdcp9AnkCD+o2XnW7X39kCs643ykWdgq9tNioV8l6iMktJ6GohdRk6Va3Fxxsm
         rJeiiD5d1HPmqsZNKWMmPpJ2feCYpowSeF/UKasvBaFtFdDQ1fzd5QBS2C20Q0mJLqe7
         cJ+A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXqJClk5vcb9AsggS+CS19y8K07xne+WSt37uETWJv/gDWDHq7r
	cxwReNk7OLrwcJJ13pis+Kx/fyHTQGjRi+j3OI5KGkYmKo1AYKCIBaJCFx2ICEGATkmUP5h2+1Z
	+I0nVvphkpVF100kqZaNWkLu01PQ2LzUA2bKl6zRupPQua139+ko8A80nhWfF5tA=
X-Received: by 2002:a50:bd85:: with SMTP id y5mr25416369edh.112.1555567754734;
        Wed, 17 Apr 2019 23:09:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuuWa97V2PrT2T6q2OlL7dEXGQrRMtSyJGFqvyE4H+uNGvaBV8Q5XC4bhHqAPmfhsGXuIU
X-Received: by 2002:a50:bd85:: with SMTP id y5mr25416323edh.112.1555567753918;
        Wed, 17 Apr 2019 23:09:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555567753; cv=none;
        d=google.com; s=arc-20160816;
        b=bHpfcGropIY7YkF+6ll2bkzpdfq4xUJKE0Q56Te6R1lXLhyXXfdn49UXCpfswGqipL
         JW8lg0FEUUGOralW4ZWYdtQik6GsxclPm+VmdZjkJzGd3sYt18hoslKp2xepcqTZxTjZ
         nLd5hIj7Swdag1C7NNaOzfBPnImxEggeiAJXx1wWd3qmRc0OSVxFa5EPPn3aR7zyP5ga
         dBDwV9UO/uH2O6GOeeAIwh0R6xOA0AYbh/VHAOQqxrYellII3co1NzNMUyNdd6r1oEeO
         +3M7Px2D5c6Fq4eNuZHTOy0Fg7e5s49iInBsffKbKxdRQwfOHLL3mrLrivy1EmNdbtxa
         89ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=CwfaXGLFS0Bh+c1tKgG8UT2fF7GZVGQHh4IM5ABA3F0=;
        b=swHPUQQgNysSZnhwIQLoMXfiO6LOLc0g2DgyrYhmCsRxPmktbIp6HH9uHkwX2f76Vo
         cQtkjksF+uA6q3Dx1g4MHA+9W6uTmTmWJGJQwIUK066J9ZvRxeup6XOYdC7KXOS7ZLo/
         tTNUstQkHx2ucjTmwMzFE+DUwg9Lgv2gtK3tzNsOMzDIB1TQ0PBDAVLmYuiGNDcko8Hz
         UY3JDX8a/TAdUvNBJN60mS57mVn9QC7DmRIE+XEc3IcQBzQ+EHLGHnlbRI3+r1ltYQmo
         hAp3wx5CS0sh0ZeANj77R71INfBMvYyiqvaKBJI7c9eLP2vmO44//fcVaDee359ZI2Kz
         PvQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id i22si524106edg.131.2019.04.17.23.09.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 23:09:13 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id 0791E240008;
	Thu, 18 Apr 2019 06:09:08 +0000 (UTC)
Subject: Re: [PATCH v3 11/11] riscv: Make mmap allocation top-down by default
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
 <hch@lst.de>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190417052247.17809-1-alex@ghiti.fr>
 <20190417052247.17809-12-alex@ghiti.fr>
 <CAGXu5jJcQzDQGy907H0WXu-q1sPQaXgjuFbHHW60ajUuksZb3A@mail.gmail.com>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <23d2a38d-363a-929c-5296-c2f8c3b7d1b4@ghiti.fr>
Date: Thu, 18 Apr 2019 02:09:08 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJcQzDQGy907H0WXu-q1sPQaXgjuFbHHW60ajUuksZb3A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 1:31 AM, Kees Cook wrote:
> On Wed, Apr 17, 2019 at 12:34 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>> In order to avoid wasting user address space by using bottom-up mmap
>> allocation scheme, prefer top-down scheme when possible.
>>
>> Before:
>> root@qemuriscv64:~# cat /proc/self/maps
>> 00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
>> 00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
>> 00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
>> 00018000-00039000 rw-p 00000000 00:00 0          [heap]
>> 1555556000-155556d000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
>> 155556d000-155556e000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
>> 155556e000-155556f000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
>> 155556f000-1555570000 rw-p 00000000 00:00 0
>> 1555570000-1555572000 r-xp 00000000 00:00 0      [vdso]
>> 1555574000-1555576000 rw-p 00000000 00:00 0
>> 1555576000-1555674000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
>> 1555674000-1555678000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
>> 1555678000-155567a000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
>> 155567a000-15556a0000 rw-p 00000000 00:00 0
>> 3fffb90000-3fffbb1000 rw-p 00000000 00:00 0      [stack]
>>
>> After:
>> root@qemuriscv64:~# cat /proc/self/maps
>> 00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
>> 00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
>> 00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
>> 00018000-00039000 rw-p 00000000 00:00 0          [heap]
>> 3ff7eb6000-3ff7ed8000 rw-p 00000000 00:00 0
>> 3ff7ed8000-3ff7fd6000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
>> 3ff7fd6000-3ff7fda000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
>> 3ff7fda000-3ff7fdc000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
>> 3ff7fdc000-3ff7fe2000 rw-p 00000000 00:00 0
>> 3ff7fe4000-3ff7fe6000 r-xp 00000000 00:00 0      [vdso]
>> 3ff7fe6000-3ff7ffd000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
>> 3ff7ffd000-3ff7ffe000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
>> 3ff7ffe000-3ff7fff000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
>> 3ff7fff000-3ff8000000 rw-p 00000000 00:00 0
>> 3fff888000-3fff8a9000 rw-p 00000000 00:00 0      [stack]
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Kees Cook <keescook@chromium.org>


Thank you very much for all your comments,

Alex


>
> -Kees
>
>> ---
>>   arch/riscv/Kconfig | 11 +++++++++++
>>   1 file changed, 11 insertions(+)
>>
>> diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
>> index eb56c82d8aa1..f5897e0dbc1c 100644
>> --- a/arch/riscv/Kconfig
>> +++ b/arch/riscv/Kconfig
>> @@ -49,6 +49,17 @@ config RISCV
>>          select GENERIC_IRQ_MULTI_HANDLER
>>          select ARCH_HAS_PTE_SPECIAL
>>          select HAVE_EBPF_JIT if 64BIT
>> +       select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
>> +       select HAVE_ARCH_MMAP_RND_BITS
>> +
>> +config ARCH_MMAP_RND_BITS_MIN
>> +       default 18
>> +
>> +# max bits determined by the following formula:
>> +#  VA_BITS - PAGE_SHIFT - 3
>> +config ARCH_MMAP_RND_BITS_MAX
>> +       default 33 if 64BIT # SV48 based
>> +       default 18
>>
>>   config MMU
>>          def_bool y
>> --
>> 2.20.1
>>
>

