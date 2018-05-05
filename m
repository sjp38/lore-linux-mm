Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56E456B0269
	for <linux-mm@kvack.org>; Sat,  5 May 2018 06:12:37 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i11-v6so15908146wre.16
        for <linux-mm@kvack.org>; Sat, 05 May 2018 03:12:37 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id m2-v6si14637049wri.460.2018.05.05.03.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 May 2018 03:12:36 -0700 (PDT)
Date: Sat, 5 May 2018 12:12:09 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 02/12] ACPI / APEI: Generalise the estatus queue's
 add/remove and notify code
Message-ID: <20180505101209.GC3708@pd.tnic>
References: <20180427153510.5799-1-james.morse@arm.com>
 <20180427153510.5799-3-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180427153510.5799-3-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Apr 27, 2018 at 04:35:00PM +0100, James Morse wrote:
> To support asynchronous NMI-like notifications on arm64 we need to use
> the estatus-queue. These patches refactor it to allow multiple APEI
> notification types to use it.
> 
> Refactor the estatus queue's pool grow/shrink code and notification
> routine from NOTIFY_NMI's handlers. This will allow another notification
> method to use the estatus queue without duplicating this code.

These two are repeated from patch 1.

> This patch adds rcu_read_lock()/rcu_read_unlock() around the list
> list_for_each_entry_rcu() walker. These aren't strictly necessary as
> the whole nmi_enter/nmi_exit() window is a spooky RCU read-side
> critical section.
> 
> Keep the oops_begin() call for x86, arm64 doesn't have one of these,
> and APEI is the only thing outside arch code calling this..

Next patch removes it so I guess you don't have to talk about it here.

> The existing ghes_estatus_pool_shrink() is folded into the new
> ghes_estatus_queue_shrink_pool() as only the queue uses it.
> 
> _in_nmi_notify_one() is separate from the rcu-list walker for a later
> caller that doesn't need to walk a list.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
> 
> ---
> Changes since v1:
>  * Tidied up _in_nmi_notify_one().
> 
>  drivers/acpi/apei/ghes.c | 100 ++++++++++++++++++++++++++++++-----------------
>  1 file changed, 65 insertions(+), 35 deletions(-)

...

> +static int ghes_estatus_queue_notified(struct list_head *rcu_list)
> +{
> +	int ret = -ENOENT;
> +	struct ghes *ghes;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(ghes, rcu_list, list) {
> +		if (!_in_nmi_notify_one(ghes))
> +			ret = 0;
> +	}
> +	rcu_read_unlock();
> +
> +	if (IS_ENABLED(CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG) && ret == 0)

		... && !ret

like the rest of the file.

> +		irq_work_queue(&ghes_proc_irq_work);
> +
> +	return ret;
> +}
> +
>  static unsigned long ghes_esource_prealloc_size(
>  	const struct acpi_hest_generic *generic)
>  {

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
