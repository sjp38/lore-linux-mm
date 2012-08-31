Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id BC1F66B0070
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 16:55:16 -0400 (EDT)
Date: Fri, 31 Aug 2012 13:55:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v8 PATCH 04/20] memory-hotplug: offline and remove memory
 when removing the memory device
Message-Id: <20120831135514.2a2dc0d4.akpm@linux-foundation.org>
In-Reply-To: <1346148027-24468-5-git-send-email-wency@cn.fujitsu.com>
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
	<1346148027-24468-5-git-send-email-wency@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

On Tue, 28 Aug 2012 18:00:11 +0800
wency@cn.fujitsu.com wrote:

> +int remove_memory(int nid, u64 start, u64 size)
> +{
> +	int ret = -EBUSY;
> +	lock_memory_hotplug();
> +	/*
> +	 * The memory might become online by other task, even if you offine it.
> +	 * So we check whether the cpu has been onlined or not.

I think you meant "memory", not "cpu".

Actually, "check whether any part of this memory range has been
onlined" would be better.  If that is accurate ;)

> +	 */
> +	if (!is_memblk_offline(start, size)) {
> +		pr_warn("memory removing [mem %#010llx-%#010llx] failed, "
> +			"because the memmory range is online\n",
> +			start, start + size);
> +		ret = -EAGAIN;
> +	}
> +
> +	unlock_memory_hotplug();
> +	return ret;
> +
> +}
> +EXPORT_SYMBOL_GPL(remove_memory);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
