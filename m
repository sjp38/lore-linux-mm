Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2081F6B0003
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 11:15:59 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id n13-v6so8885567wrt.5
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 08:15:59 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id p6-v6si4303072wrm.280.2018.10.04.08.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 08:15:57 -0700 (PDT)
Date: Thu, 4 Oct 2018 17:15:55 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 00/18] APEI in_nmi() rework
Message-ID: <20181004151555.GN1864@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180925124526.GD23986@zn.tnic>
 <c04d1b78-122b-d7f2-5a75-3d9c56386b11@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <c04d1b78-122b-d7f2-5a75-3d9c56386b11@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Wed, Oct 03, 2018 at 06:50:38PM +0100, James Morse wrote:

...

> The non-ghes HEST entries have a "number of records to pre-allocate" too, we
> could make this memory pool something hest.c looks after, but I can't see if the
> other error sources use those values.

Thanks for the detailed analysis!

> Hmmm, The size is capped to 64K, we could ignore the firmware description of the
> memory requirements, and allocate SZ_64K each time. Doing it per-GHES is still
> the only way to avoid allocating nmi-safe memory for irqs.

Right, so I'm thinking a lot simpler: allocate a pool which should
be large enough to handle all situations and drop all that logic
which recomputes and reallocates pool size. Just a static thing which
JustWorks(tm).

For a couple of reasons:

 - you state it above: all those synchronization issues are gone with a
 prellocated pool

 - 64K per-GHES pool is nothing if you consider the machines this thing
 runs on - fat servers with lotsa memory. And RAS there *is* important.
 And TBH 64K is nothing even on a small client sporting gigabytes of
 memory.

 - code is a lot simpler and cleaner - you don't need all that pool
 expanding and shrinking. I mean, I'm all for smarter solutions if they
 have any clear advantages warranting the complication but this is a
 lot of machinery just so that we can save a couple of KBs. Which, as a
 whole, sounds just too much to me.

But this is just me.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
