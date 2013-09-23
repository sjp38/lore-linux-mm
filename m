Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5506B0033
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 12:04:41 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so2461926pad.21
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:04:41 -0700 (PDT)
Received: by mail-yh0-f44.google.com with SMTP id f64so1380229yha.17
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:39:00 -0700 (PDT)
Date: Mon, 23 Sep 2013 11:38:53 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 1/5] memblock: Introduce allocation direction to
 memblock.
Message-ID: <20130923153853.GC14547@htj.dyndns.org>
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com>
 <1379064655-20874-2-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1379064655-20874-2-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, toshi.kani@hp.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

Sorry about the delay.  Was traveling.

On Fri, Sep 13, 2013 at 05:30:51PM +0800, Tang Chen wrote:
> +/* Allocation order. */
> +#define MEMBLOCK_DIRECTION_HIGH_TO_LOW	0
> +#define MEMBLOCK_DIRECTION_LOW_TO_HIGH	1
> +#define MEMBLOCK_DIRECTION_DEFAULT	MEMBLOCK_DIRECTION_HIGH_TO_LOW

Can we please settle on either top_down/bottom_up or
high_to_low/low_to_high?  The two seem to be used interchangeably in
the patch series.  Also, it'd be more customary to use enum for things
like above, but more on the interface below.

> +static inline bool memblock_direction_bottom_up(void)
> +{
> +	return memblock.current_direction == MEMBLOCK_DIRECTION_LOW_TO_HIGH;
> +}

Maybe just memblock_bottom_up() would be enough?

Also, why not also have memblock_set_bottom_up(bool enable) as the
'set' interface?

>  /**
> + * memblock_set_current_direction - Set current allocation direction to allow
> + *                                  allocating memory from higher to lower
> + *                                  address or from lower to higher address
> + *
> + * @direction: In which order to allocate memory. Could be
> + *             MEMBLOCK_DIRECTION_{HIGH_TO_LOW|LOW_TO_HIGH}
> + */
> +void memblock_set_current_direction(int direction);

Function comments should go with the function definition.  Dunno what
happened with set_current_limit but let's please not spread it.

> +void __init_memblock memblock_set_current_direction(int direction)
> +{
> +	if (direction != MEMBLOCK_DIRECTION_HIGH_TO_LOW &&
> +	    direction != MEMBLOCK_DIRECTION_LOW_TO_HIGH) {
> +		pr_warn("memblock: Failed to set allocation order. "
> +			"Invalid order type: %d\n", direction);
> +		return;
> +	}
> +
> +	memblock.current_direction = direction;
> +}

If set_bottom_up() style interface is used, the above will be a lot
simpler, right?  Also, it's kinda weird to have two separate patches
to introduce the flag and actually implement bottom up allocation.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
