Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00528C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 22:05:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9223B218F0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 22:05:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9223B218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E75C26B0003; Tue, 23 Jul 2019 18:05:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E27C96B0005; Tue, 23 Jul 2019 18:05:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3D398E0002; Tue, 23 Jul 2019 18:05:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1156B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 18:05:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h3so26837640pgc.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 15:05:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=IUz6GcA5PHYQHFCwePQ31D0jtUoh0a1ZGkBkp/aZ+Q4=;
        b=pNb5jgTQTStuLo7vN1pXwB7C6dPXZTwmpVl0EL1ASRNUTgHhZxbtu+zUGFsSR8iU3R
         pYGxH9C8aTwIhJASn/tujVtdg1bmqEK4NNYOTRbS/yv2yEEkvTzEiWYqxhGbvzSmZfWF
         MXhVEWLO5ED3szXTkUEjk1JMDS0gn3WSz6bg1iKHUGAtpVigdCkFrOkeSIWQKxczciIN
         6xSi831j71GMfYzBnGBLdoXe+Vm8nqen4jrnExSIhnmV7jfMsOXf8zapXP75CQPnv8dD
         7JSBlP6T/TCY1l97Z8VlIlREOZ6Qdeo8Cf53Ft5kzQFXBj5ePDNUFOn2if85ZjOg5C4M
         Zy8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW6ixmYVVxqLTxcJyHl8IVsnqKdOpN8MJoIR8dKcUz9f+6W7GAa
	zhU8zuT1Gp4+H4VF1Da0WSfv+xKXxlA4YwGEszGOPNkQCWBpdROzwARx6yYreuGybPiBBqsRICt
	rtfK6IaF8TnHPsNHQQo4M0TqMMP5TAw2W9DOgP3EQd8z3XH0RY7f180Ca21oGB/O8bw==
X-Received: by 2002:a17:902:2aa8:: with SMTP id j37mr78773442plb.316.1563919528243;
        Tue, 23 Jul 2019 15:05:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxchl0PetBC+DHeYqMGTFPOff3b/NPsVVAZvBK4SfeRdJP/RwX4NA+sb81MiqOUn05AAl8F
X-Received: by 2002:a17:902:2aa8:: with SMTP id j37mr78773376plb.316.1563919527328;
        Tue, 23 Jul 2019 15:05:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563919527; cv=none;
        d=google.com; s=arc-20160816;
        b=dV4KCThY+s7p+I7jmsvfWP2Rx14PUy0+K7zos2D1/BzxXmX2r5172DQlTSEyS5grPk
         nXyumlLJjmq2AQb+6ZMunvGOSSDnze9sZ3KLY7YUUmWQMvrCTTjuai9YT4+vlNHCFq1J
         PmVC+67YCzAZYPgpmP1Yr/teEjGO1Y0LDK6AeQGXDZU5f9zXsIbWcNpCOSgY7786lRB7
         uc/1+oixxK0E0O+cqfuWxxAJi13AT7tPU0ow0j70eDgt4+8HzOqQyN5YYuPv93SizNiM
         xjoxz0L9OPszg8uydyFHRmBbq46cGEh4bYyVrsb1t8onfa0pN8tEtGE+8KK5e5ZBZXEt
         Zz3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=IUz6GcA5PHYQHFCwePQ31D0jtUoh0a1ZGkBkp/aZ+Q4=;
        b=wXPWB+/FAYvMRTu+7Lf5nDSngm+r5JAGlBLfUfJZUptl87SCDvpgc7it0XnLDugv0X
         n2Ittx13Eo0RRccTBW44FLtJazem+qofmlPXy6/r4ZnoCiFOBgKAdk6qo8haakBY/h7Z
         76nlVf3QFOEN36M5uCa5mi/2/evziD/CIq87qw9vUMgnBka0j3PVrQARCgsPR1SXLPGK
         j5z8UQcNO1ma5jtFQ1Mfx1TCjIoH+rKeKWKSWwUuuToZSWMhkh/1xG+FwbwtTnMssC55
         LrzA/iraty6HcGGdoF1zvLDUHTcSWucgqmdnAqwZwwU4x9hPQZt5o861tnraSJ7qfDla
         lYNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y8si12760613pgr.89.2019.07.23.15.05.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 15:05:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jul 2019 15:05:26 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,300,1559545200"; 
   d="scan'208";a="369056989"
Received: from sai-dev-mach.sc.intel.com ([143.183.140.153])
  by fmsmga006.fm.intel.com with ESMTP; 23 Jul 2019 15:05:26 -0700
Message-ID: <180ae7c8af18d7a73cd8ba18e8fe2aa7ef562fd3.camel@intel.com>
Subject: Re: Why does memblock only refer to E820 table and not EFI Memory
 Map?
From: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
To: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
Cc: linux-mm@kvack.org, linux-efi@vger.kernel.org, mingo@kernel.org,
 bp@alien8.de,  peterz@infradead.org, ard.biesheuvel@linaro.org,
 rppt@linux.ibm.com, pj@sgi.com
Date: Tue, 23 Jul 2019 15:01:57 -0700
In-Reply-To: <20190723213821.GA3311@ranerica-svr.sc.intel.com>
References: <cfee410c5dd4b359ee395ad075f31133387def70.camel@intel.com>
	 <20190723213821.GA3311@ranerica-svr.sc.intel.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> > On x86 platforms, there are two sources through which kernel learns about
> > physical memory in the system namely E820 table and EFI Memory Map. Each
> > table
> > describes which regions of system memory is usable by kernel and which
> > regions
> > should be preserved (i.e. reserved regions that typically have BIOS
> > code/data)
> > so that no other component in the system could read/write to these
> > regions. I
> > think they are duplicating the information and hence I have couple of
> > questions regarding these
> 
> But isn't it true that in x86 systems the E820 table is populated from the
> EFI memory map?

I don't know that it happens.. :(

> At least in systems with EFI firmware and a Linux which understands
> EFI. If booting from the EFI stub, the stub will take the EFI memory map and
> assemble the E820 table passed as part of the boot params [4]. It also
> considers the case when there are more than 128 entries in the table [5].
> Thus, if booting as an EFI application it will definitely use the EFI memory
> map. If Linux' EFI entry point is not used the bootloader should to the
> same. For instance, grub also reads the EFI memory map to assemble the E820
> memory map [6], [7], [8].

Thanks a lot! for the pointers Ricardo :)
I haven't looked at EFI stub and Grub code and hence didn't knew this was
happening. It does make me feel better that EFI Memory Map is indeed being
used to generate e820 in EFI stub case, so at-least it's getting consumed
indirectly.

> > 1. I see that only E820 table is being consumed by kernel [1] (i.e.
> > memblock
> > subsystem in kernel) to distinguish between "usable" vs "reserved"
> > regions.
> > Assume someone has called memblock_alloc(), the memblock subsystem would
> > service the caller by allocating memory from "usable" regions and it knows
> > this *only* from E820 table [2] (it does not check if EFI Memory Map also
> > says
> > that this region is usable as well). So, why isn't the kernel taking EFI
> > Memory Map into consideration? (I see that it does happen only when
> > "add_efi_memmap" kernel command line arg is passed i.e. passing this
> > argument
> > updates E820 table based on EFI Memory Map) [3]. The problem I see with
> > memblock not taking EFI Memory Map into consideration is that, we are
> > ignoring
> > the main purpose for which EFI Memory Map exists.
> > 
> > 2. Why doesn't the kernel have "add_efi_memmap" by default? From the
> > commit
> > "200001eb140e: x86 boot: only pick up additional EFI memmap if
> > add_efi_memmap
> > flag", I didn't understand why the decision was made so. Shouldn't we give
> > more preference to EFI Memory map rather than E820 table as it's the
> > latest
> > and E820 is legacy?
> 
> I did a a quick experiment with and without add_efi_memmmap. the e820
> table looked exactly the same. I guess this shows that what I wrote
> above makes sense ;) . Have you observed difference?

When I did a quick test, I didn't notice any difference (with and without
add_efi_memap) because both e820 and EFI Memory Map were reporting regions in
sync. So, "add_efi_memmap" didn't have to add any new regions into e820. Hence
my last question, what if both the tables (EFI Memory Map and e820) are out of
sync? Shouldn't happen in Grub and EFI stub because they generate e820 from
EFI Memory Map, as pointed by you.

Regards,
Sai

