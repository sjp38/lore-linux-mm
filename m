Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 89BFC6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 11:12:32 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so10673427pab.12
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 08:12:32 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ha9si18189637pac.47.2014.07.28.08.12.31
        for <linux-mm@kvack.org>;
        Mon, 28 Jul 2014 08:12:31 -0700 (PDT)
Message-ID: <53D6685C.1060509@intel.com>
Date: Mon, 28 Jul 2014 08:12:28 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory hotplug: update the variables after memory removed
References: <1406550617-19556-1-git-send-email-zhenzhang.zhang@huawei.com> <53D642E5.2010305@huawei.com>
In-Reply-To: <53D642E5.2010305@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>, shaohui.zheng@intel.com, mgorman@suse.de, mingo@redhat.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: wangnan0@huawei.com, akpm@linux-foundation.org

On 07/28/2014 05:32 AM, Zhang Zhen wrote:
> -static void  update_end_of_memory_vars(u64 start, u64 size)
> +static void  update_end_of_memory_vars(u64 start, u64 size, bool flag)
>  {
> -	unsigned long end_pfn = PFN_UP(start + size);
> -
> -	if (end_pfn > max_pfn) {
> -		max_pfn = end_pfn;
> -		max_low_pfn = end_pfn;
> -		high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
> +	unsigned long end_pfn;
> +
> +	if (flag) {
> +		end_pfn = PFN_UP(start + size);
> +		if (end_pfn > max_pfn) {
> +			max_pfn = end_pfn;
> +			max_low_pfn = end_pfn;
> +			high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
> +		}
> +	} else {
> +		end_pfn = PFN_UP(start);
> +		if (end_pfn < max_pfn) {
> +			max_pfn = end_pfn;
> +			max_low_pfn = end_pfn;
> +			high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
> +		}
>  	}
>  }

I would really prefer not to see code like this.

This patch takes a small function that did one thing, copies-and-pastes
its code 100%, subtly changes it, and makes it do two things.  The only
thing to tell us what the difference between these two subtly different
things is a variable called 'flag'.  So the variable is useless in
trying to figure out what each version is supposed to do.

But, this fixes a pretty glaring deficiency in the memory remove code.

I would suggest making two functions.  Make it clear that one is to be
used at remove time and the other at add time.  Maybe

	move_end_of_memory_vars_down()
and
	move_end_of_memory_vars_up()

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
