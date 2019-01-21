Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 730AA8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 12:19:14 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id z16so11183906wrt.5
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 09:19:14 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id o15si37084922wmg.81.2019.01.21.09.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 09:19:13 -0800 (PST)
Date: Mon, 21 Jan 2019 18:19:10 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 19/25] ACPI / APEI: Only use queued estatus entry
 during _in_nmi_notify_one()
Message-ID: <20190121171910.GM29166@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-20-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-20-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:06:07PM +0000, James Morse wrote:
> Each struct ghes has an worst-case sized buffer for storing the
> estatus. If an error is being processed by ghes_proc() in process
> context this buffer will be in use. If the error source then triggers
> an NMI-like notification, the same buffer will be used by
> _in_nmi_notify_one() to stage the estatus data, before
> __process_error() copys it into a queued estatus entry.
> 
> Merge __process_error()s work into _in_nmi_notify_one() so that
> the queued estatus entry is used from the beginning. Use the new
> ghes_peek_estatus() to know how much memory to allocate from
> the ghes_estatus_pool before reading the records.
> 
> Reported-by: Borislav Petkov <bp@suse.de>
> Signed-off-by: James Morse <james.morse@arm.com>
> 
> Change since v6:
>  * Added a comment explaining the 'ack-error, then goto no_work'.
>  * Added missing esatus-clearing, which is necessary after reading the GAS,
> ---
>  drivers/acpi/apei/ghes.c | 59 ++++++++++++++++++++++++----------------
>  1 file changed, 35 insertions(+), 24 deletions(-)

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
