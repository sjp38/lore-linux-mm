Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 745F58E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 05:51:51 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w16so12150613wrk.10
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 02:51:51 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id n204si34301070wma.87.2019.01.22.02.51.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 02:51:50 -0800 (PST)
Date: Tue, 22 Jan 2019 11:51:43 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 22/25] ACPI / APEI: Kick the memory_failure() queue
 for synchronous errors
Message-ID: <20190122105143.GB26587@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-23-james.morse@arm.com>
 <9d153a07-aa7a-6e0c-3bd3-994a66f9639a@huawei.com>
 <5c775aa9-ea57-dea7-6083-c1e3fc160b29@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5c775aa9-ea57-dea7-6083-c1e3fc160b29@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Xie XiuQi <xiexiuqi@huawei.com>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Fan Wu <wufan@codeaurora.org>, Wang Xiongfeng <wangxiongfeng2@huawei.com>

On Mon, Dec 10, 2018 at 07:15:13PM +0000, James Morse wrote:
> What happens if we miss MF_ACTION_REQUIRED?

AFAICU, the logic is to force-send a signal to the user process, i.e.,
force_sig_info() which cannot be ignored. IOW, an "enlightened" process
would know how to do recovery action from a memory error.

VS the action optional thing which you can handle at your leisure.

So the question boils down to what kind of severity do the errors
reported through SEA have? I mean, if the hw would go the trouble to do
the synchronous reporting, then something important must've happened and
it wants us to know about it and handle it.

> Surely the page still gets unmapped as its PG_Poisoned, an AO signal
> may be pending, but if user-space touches the page it will get an AR
> signal. Is this just about removing an extra AO signal to user-space?
>
> If we do need this, I'd like to pick it up from the CPER records, as x86's
> NOTIFY_NMI looks like it covers both AO/AR cases. (as does NOTIFY_SDEI). The
> Master/Target abort or Invalid-address types in the memory-error-section CPER
> records look like the best bet.

Right, and we do all kinds of severity mapping there aka ghes_severity()
so that'll be a good start, methinks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
