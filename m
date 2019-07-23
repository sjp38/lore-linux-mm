Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E847DC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:10:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F054223A0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:10:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F054223A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 292626B0003; Tue, 23 Jul 2019 04:10:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21ADF8E0002; Tue, 23 Jul 2019 04:10:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E2E96B0007; Tue, 23 Jul 2019 04:10:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E08FD6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:10:00 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x1so35746784qkn.6
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:10:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bqql16DCdU54/p4Rr6Lj7mTG66zanflGix1IvjfI88E=;
        b=J6bSlUshi2ZlI0cNsf/ucg4hZhayYb2jEXKjugx03/ZizGkC6hEYHksle35HRbhr3L
         GzqVvibzn5fWpavmQxemDJQfZxalSkk/adCfqDFW2jsdNMbEN4ntG5O5CJ6HjD+AB5zf
         RYrIdAPn0K9bEjceDgoFZ6Xq4syfL85g6Tds2mBMI0fM6BZS9RFIO2kxpIM5IS54JfcD
         T1INYeJXtDy/WPQae71yazUm0XMBhiV/NfbMYojv9LdDOgw/FPaZ75/yHimmiT5mrOBb
         Js7IQ4Nl4ufaGgpDmIY3P9zoT3mo7djZCr8133eAKfxqkarRrQW+kAa7Vcy15GQ+LNMl
         CieQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW9ObRGc0C5xpQY1/2+1bxq6XZ1odA2FNqRBNn+4+eLR7QCNtRP
	FAQbhzrbT15UqU5Bldr16xZn+HO+eTocGSR/lxDo8DFONl9Lopn7F0u/Ghhr8hKXefofhDeijOU
	w2r01Ey0ozVQxd55lCB+5mvAB4tmglSRo/e8vxQrAMkpz7nseHbIvH48hAA4EcjyYtQ==
X-Received: by 2002:ad4:498b:: with SMTP id t11mr55167602qvx.139.1563869400661;
        Tue, 23 Jul 2019 01:10:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhBXsSTnLudjCpGzOzCITyaIvLP/D1p85KV1T55wUCA/o+3wrSQaepw0WdbESkDJPT4Ddh
X-Received: by 2002:ad4:498b:: with SMTP id t11mr55167573qvx.139.1563869400040;
        Tue, 23 Jul 2019 01:10:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563869400; cv=none;
        d=google.com; s=arc-20160816;
        b=HoIcrAyvxu92eSdp015GVsmZbC7gck1TcABvk2v8cBZqu7A4brChKn1XRt7q5NtzlE
         u3cGZ0/12FcLXPuFLrLBUeHRnwuEZLbX2b5yA92G9s6aUC6kwhI9z3P7zr4E27x/OQXV
         GH9uiGIgAv4J5d5BssFZKPptFBprejoXNp4Rch3E8HpLMgZo4r8sNAsFtr3W8+RIR95W
         pyhg+3MyH7T221Irqp9nVeGgRxDsStIFqZkQvZMthhFKsxKvKGaQ9gYA7iVO/Ou8oiXL
         7+H1zcHbPWmd9kboOMDHxpt8yByUgk5oBjLQ3yUr6RMgtWvScUJtPltG5/IrOPDbO3jQ
         W8ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bqql16DCdU54/p4Rr6Lj7mTG66zanflGix1IvjfI88E=;
        b=E0LvKUvOVKDh57lWqPW7XjnNRmwbfvfoIHomWX/Rd5FbImb7Bu1KlfgatbLPakn0me
         FhKjemI1h7XoN/I7FQjadiqJLrQDeHIhG1PUfifeiYBwIMvtWWfmwBNS0owDclRFItB6
         pY6ENBRSMHv8/Tl806cEhTFP8eIm6ZuJr9Oeb7+k+G8eKrgm5K3mwXqZFUFpTJZOhhfS
         jySkQPAtvH7wVE9iAs5CXfU3XWlYkKuUOCDlWeL59whmNVdXp+trf1VnSsoASkT4IyRI
         NVfWvGtnN6XSigi6nINZomABKN0c12yNrhnyjUrnvfolhqETQN2JL4qF1PK/xiauTKWf
         zegQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a38si28566792qvd.50.2019.07.23.01.09.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 01:10:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 36B3C308FE8D;
	Tue, 23 Jul 2019 08:09:59 +0000 (UTC)
Received: from dhcp-128-65.nay.redhat.com (ovpn-12-90.pek2.redhat.com [10.72.12.90])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6705B60606;
	Tue, 23 Jul 2019 08:09:55 +0000 (UTC)
Date: Tue, 23 Jul 2019 16:09:49 +0800
From: Dave Young <dyoung@redhat.com>
To: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
Cc: linux-mm@kvack.org, linux-efi@vger.kernel.org, mingo@kernel.org,
	bp@alien8.de, peterz@infradead.org, ard.biesheuvel@linaro.org,
	rppt@linux.ibm.com, pj@sgi.com
Subject: Re: Why does memblock only refer to E820 table and not EFI Memory
 Map?
Message-ID: <20190723080949.GB9859@dhcp-128-65.nay.redhat.com>
References: <cfee410c5dd4b359ee395ad075f31133387def70.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cfee410c5dd4b359ee395ad075f31133387def70.camel@intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 23 Jul 2019 08:09:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
On 07/20/19 at 03:52pm, Sai Praneeth Prakhya wrote:
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

https://blog.fpmurphy.com/2012/08/uefi-memory-v-e820-memory.html
Probably above blog can explain some background.

> 
> 2. Why doesn't the kernel have "add_efi_memmap" by default? From the commit
> "200001eb140e: x86 boot: only pick up additional EFI memmap if add_efi_memmap
> flag", I didn't understand why the decision was made so. Shouldn't we give
> more preference to EFI Memory map rather than E820 table as it's the latest
> and E820 is legacy?
> 
> 3. Why isn't kernel checking that both the tables E820 table and EFI Memory
> Map are in sync i.e. is there any *possibility* that a buggy BIOS could report
> a region as usable in E820 table and as reserved in EFI Memory Map?
> 
> [1] 
> https://elixir.bootlin.com/linux/latest/source/arch/x86/kernel/setup.c#L1106
> [2] 
> https://elixir.bootlin.com/linux/latest/source/arch/x86/kernel/e820.c#L1265
> [3] 
> https://elixir.bootlin.com/linux/latest/source/arch/x86/platform/efi/efi.c#L129
> 
> Regards,
> Sai
> 

Thanks
Dave

