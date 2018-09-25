Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4C08E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:45:26 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u1-v6so1023546wrt.3
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 05:45:26 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id x4-v6si2072732wrq.319.2018.09.25.05.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 05:45:24 -0700 (PDT)
Date: Tue, 25 Sep 2018 14:45:26 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 00/18] APEI in_nmi() rework
Message-ID: <20180925124526.GD23986@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Sep 21, 2018 at 11:16:47PM +0100, James Morse wrote:
> Hello,
> 
> The GHES driver has collected quite a few bugs:
> 
> ghes_proc() at ghes_probe() time can be interrupted by an NMI that
> will clobber the ghes->estatus fields, flags, and the buffer_paddr.
> 
> ghes_copy_tofrom_phys() uses in_nmi() to decide which path to take. arm64's
> SEA taking both paths, depending on what it interrupted.
> 
> There is no guarantee that queued memory_failure() errors will be processed
> before this CPU returns to user-space.
> 
> x86 can't TLBI from interrupt-masked code which this driver does all the
> time.
> 
> 
> This series aims to fix the first three, with an eye to fixing the
> last one with a follow-up series.
> 
> Previous postings included the SDEI notification calls, which I haven't
> finished re-testing. This series is big enough as it is.

Yeah, and everywhere I look, this thing looks overengineered. Like,
for example, what's the purpose of this ghes_esource_prealloc_size()
computing a size each time the pool changes size?

AFAICT, this size can be computed exactly *once* at driver init and be
done with it. Right?

Or am I missing something subtle?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
