Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5E68E00B9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:45:00 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id f193so946929wme.8
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:45:00 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id f196si409503wme.198.2018.12.11.09.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 09:44:59 -0800 (PST)
Date: Tue, 11 Dec 2018 18:44:49 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 09/25] ACPI / APEI: Generalise the estatus queue's
 notify code
Message-ID: <20181211174449.GM27375@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-10-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-10-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:05:57PM +0000, James Morse wrote:
> Refactor the estatus queue's pool notification routine from
> NOTIFY_NMI's handlers. This will allow another notification
> method to use the estatus queue without duplicating this code.
> 
> This patch adds rcu_read_lock()/rcu_read_unlock() around the list

s/This patch adds/Add/

> list_for_each_entry_rcu() walker. These aren't strictly necessary as
> the whole nmi_enter/nmi_exit() window is a spooky RCU read-side
> critical section.
> 
> _in_nmi_notify_one() is separate from the rcu-list walker for a later
> caller that doesn't need to walk a list.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
> Tested-by: Tyler Baicar <tbaicar@codeaurora.org>
> 
> ---
> Changes since v6:
>  * Removed pool grow/remove code as this is no longer necessary.
> 
> Changes since v3:
>  * Removed duplicate or redundant paragraphs in commit message.
>  * Fixed the style of a zero check.
> Changes since v1:
>    * Tidied up _in_nmi_notify_one().
> ---
>  drivers/acpi/apei/ghes.c | 63 ++++++++++++++++++++++++++--------------
>  1 file changed, 41 insertions(+), 22 deletions(-)

...

> +static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
> +{
> +	int ret = NMI_DONE;
> +
> +	if (!atomic_add_unless(&ghes_in_nmi, 1, 1))
> +		return ret;
> +
> +	if (!ghes_estatus_queue_notified(&ghes_nmi))
> +		ret = NMI_HANDLED;

So this reads kinda the other way around, at least to me:

	"if the queue was *not* notified, the NMI was handled."

Maybe rename to this:

	err = process_queue(&ghes_nmi);
	if (!err)
		ret = NMI_HANDLED;

to make it clearer...

And yeah, all those static functions having "ghes_" prefix is just
encumbering readability for no good reason.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
