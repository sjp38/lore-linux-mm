Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7760C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:38:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 769F02253D
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:38:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 769F02253D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED8376B0003; Tue, 23 Jul 2019 17:38:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8A026B0005; Tue, 23 Jul 2019 17:38:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9FEF6B0006; Tue, 23 Jul 2019 17:38:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A64586B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 17:38:58 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id e95so22753544plb.9
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:38:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kBPZgqsyNX8UtgGw3izWCQK4T23gPqxEyDyRpnoaCgU=;
        b=iku/Vh0i6PgX5qu94w7OOmdJmcvBNKGh3fJbNTeX+nR7Cs8qYR0zBWjgq2aT5xSMth
         9yulDKGpH2G8EgkQiSNYritYXHbL0eAcwrBqfh52Rg8yME1vmYlQzPjn+0S/PjvxhAWk
         2qNGVcroz63ZbXIUWUyroPQtaMAfNXDeb9ZHf+tssLLOSF6VB5om5Gb6dX193Qs1VAv+
         9INCChvUKw/e0CT8knWpAJbplQmBZ5Jp6eIrPR2syuICU6eZ5gkb8FnicxA4VTa5yvTd
         84HCzJOu9E8XSRzruC72YiK2BnjUg5x8ao6Y264F5NUQNFe0fkLy1rhLE4oARsSd8QOR
         seeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of ricardo.neri-calderon@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ricardo.neri-calderon@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVCDsShY1Rd/T1rFGglYFdeQER4BltE8OwSaU4D+v9WqJjnsP4V
	OTg/YiyU8ATaTOJL3IG+VyWHBGCp0FK5qNoe3zs+hqpOaJrHvuTWImTvGlDlXZm5T+VWdVT9O7a
	nkJjPpbJgNrl3wE2IYZHRd2GuHbq1ZvRj3hcKgU9yUzWXi+V27BQKn0c0wIsmKg8tYw==
X-Received: by 2002:a17:902:8d97:: with SMTP id v23mr80309249plo.157.1563917938336;
        Tue, 23 Jul 2019 14:38:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCvbr1lQYgdme49ZgUcJt++GozDJswONYsxidgVwbz1sH8KuUNNm7BQx80EfGF7kBOw6mG
X-Received: by 2002:a17:902:8d97:: with SMTP id v23mr80309217plo.157.1563917937601;
        Tue, 23 Jul 2019 14:38:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563917937; cv=none;
        d=google.com; s=arc-20160816;
        b=gPWQGM22ZtnXwPGrUvSphnN0+jb1Bgm5DLzFpHfS7GMzkRCmxeHvnEsIoG7DVcINfJ
         3JA9wNPSU1S82bxAlrHKnj+jDWRzfYPb1yTu0g8nq14H5uueHrQn/mbdF75khTT+NdJN
         B6y+LOaAjgmB+U2nKUO3qpdgx1aSHBSgHw2+MzkzUftvrNS2aDH4CWIU05kEwbiidEx6
         1Dlj3IT6CH8qeQUgS6O+M34lUlw5KJZL0iYJgQAC1rYjUPQV1wAm9DXR9WAfjnmobHIU
         43ZvqMU8TkcLRYgeqiVvBs43i/bod9XuRvLFUrhh0h0I+zY7+bfgiNWyjxbLJV1JPF+0
         O6Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kBPZgqsyNX8UtgGw3izWCQK4T23gPqxEyDyRpnoaCgU=;
        b=q2SPdjPkeOVyvg8uGYTWUAd6M5IMy5kd7+ItMezoRlSCYoRh6xPTJ5RJftLgxmY414
         6GEYVmqS9I9LtpjdLlUfE0AAB1Xj6lzRkyhoc5cy6wW097OlGw9SA+m5TSDMWZH+PsyE
         V5xCsPFTp4y1Ug4jhwus9lrFHG29xv0OcVO6Ulm7NrD6Vj/5ISlpKxPA/qJCP/eMYI6d
         cW+dWwc+w72LyPEsn1XrsJWYNCMwXHtgRNLbSUnkjwEViVCY3wEdsVEFpNz0BbVCMEUl
         BrSsylf3smQBULtW+oioAlqkugUIFJOhw6c9AQRZiONhgoGG6TzvU+Ind0jKRCHnoP91
         nrHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of ricardo.neri-calderon@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ricardo.neri-calderon@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a18si14631331pgn.132.2019.07.23.14.38.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 14:38:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of ricardo.neri-calderon@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of ricardo.neri-calderon@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ricardo.neri-calderon@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jul 2019 14:38:56 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,300,1559545200"; 
   d="scan'208";a="169682593"
Received: from ranerica-svr.sc.intel.com ([172.25.110.23])
  by fmsmga008.fm.intel.com with ESMTP; 23 Jul 2019 14:38:56 -0700
Date: Tue, 23 Jul 2019 14:38:21 -0700
From: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
To: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
Cc: linux-mm@kvack.org, linux-efi@vger.kernel.org, mingo@kernel.org,
	bp@alien8.de, peterz@infradead.org, ard.biesheuvel@linaro.org,
	rppt@linux.ibm.com, pj@sgi.com
Subject: Re: Why does memblock only refer to E820 table and not EFI Memory
 Map?
Message-ID: <20190723213821.GA3311@ranerica-svr.sc.intel.com>
References: <cfee410c5dd4b359ee395ad075f31133387def70.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cfee410c5dd4b359ee395ad075f31133387def70.camel@intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 20, 2019 at 03:52:04PM -0700, Sai Praneeth Prakhya wrote:
> Hi All,
> 
> Disclaimer:
> 1. Please note that this discussion is x86 specific
> 2. Below stated things are my understanding about kernel and I could have
> missed somethings, so please let me know if I understood something wrong.
> 3. I have focused only on memblock here because if I understand correctly,
> memblock is the base that feeds other memory management subsystems in kernel
> (like the buddy allocator).
> 
> On x86 platforms, there are two sources through which kernel learns about
> physical memory in the system namely E820 table and EFI Memory Map. Each table
> describes which regions of system memory is usable by kernel and which regions
> should be preserved (i.e. reserved regions that typically have BIOS code/data)
> so that no other component in the system could read/write to these regions. I
> think they are duplicating the information and hence I have couple of
> questions regarding these

But isn't it true that in x86 systems the E820 table is populated from the EFI
memory map? At least in systems with EFI firmware and a Linux which understands
EFI. If booting from the EFI stub, the stub will take the EFI memory map and
assemble the E820 table passed as part of the boot params [4]. It also considers
the case when there are more than 128 entries in the table [5]. Thus, if booting
as an EFI application it will definitely use the EFI memory map. If Linux' EFI
entry point is not used the bootloader should to the same. For instance, grub
also reads the EFI memory map to assemble the E820 memory map [6], [7], [8].

> 
> 1. I see that only E820 table is being consumed by kernel [1] (i.e. memblock
> subsystem in kernel) to distinguish between "usable" vs "reserved" regions.
> Assume someone has called memblock_alloc(), the memblock subsystem would
> service the caller by allocating memory from "usable" regions and it knows
> this *only* from E820 table [2] (it does not check if EFI Memory Map also says
> that this region is usable as well). So, why isn't the kernel taking EFI
> Memory Map into consideration? (I see that it does happen only when
> "add_efi_memmap" kernel command line arg is passed i.e. passing this argument
> updates E820 table based on EFI Memory Map) [3]. The problem I see with
> memblock not taking EFI Memory Map into consideration is that, we are ignoring
> the main purpose for which EFI Memory Map exists.
> 
> 2. Why doesn't the kernel have "add_efi_memmap" by default? From the commit
> "200001eb140e: x86 boot: only pick up additional EFI memmap if add_efi_memmap
> flag", I didn't understand why the decision was made so. Shouldn't we give
> more preference to EFI Memory map rather than E820 table as it's the latest
> and E820 is legacy?

I did a a quick experiment with and without add_efi_memmmap. the e820
table looked exactly the same. I guess this shows that what I wrote
above makes sense ;) . Have you observed difference?

Thanks and BR,
Ricardo

[4]. https://elixir.bootlin.com/linux/latest/source/arch/x86/boot/compressed/eboot.c#L516
[5]. https://elixir.bootlin.com/linux/latest/source/arch/x86/boot/compressed/eboot.c#L493
[6]. http://git.savannah.gnu.org/cgit/grub.git/tree/grub-core/loader/i386/linux.c#n573
[7]. http://git.savannah.gnu.org/cgit/grub.git/tree/grub-core/mmap/mmap.c#n110
[8]. http://git.savannah.gnu.org/cgit/grub.git/tree/grub-core/mmap/efi/mmap.c#n139
 

