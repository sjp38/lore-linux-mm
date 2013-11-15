Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id E4E916B0037
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 23:52:43 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id um1so3025841pbc.36
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 20:52:43 -0800 (PST)
Received: from psmtp.com ([74.125.245.201])
        by mx.google.com with SMTP id vs7si776623pbc.355.2013.11.14.20.52.41
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 20:52:42 -0800 (PST)
Message-ID: <5285A896.3030204@codeaurora.org>
Date: Thu, 14 Nov 2013 20:52:38 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/4] mm/vmalloc.c: Allow lowmem to be tracked in vmalloc
References: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org> <1384212412-21236-4-git-send-email-lauraa@codeaurora.org> <52850C37.1080506@sr71.net>
In-Reply-To: <52850C37.1080506@sr71.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Neeti Desai <neetid@codeaurora.org>

On 11/14/2013 9:45 AM, Dave Hansen wrote:
> On 11/11/2013 03:26 PM, Laura Abbott wrote:
>> +config ENABLE_VMALLOC_SAVING
>> +	bool "Intermix lowmem and vmalloc virtual space"
>> +	depends on ARCH_TRACKS_VMALLOC
>> +	help
>> +	  Some memory layouts on embedded systems steal large amounts
>> +	  of lowmem physical memory for purposes outside of the kernel.
>> +	  Rather than waste the physical and virtual space, allow the
>> +	  kernel to use the virtual space as vmalloc space.
>
> I really don't think this needs to be exposed with help text and so
> forth.   How about just defining a 'def_bool n' with some comments and
> let the architecture 'select' it?
>
>> +#ifdef ENABLE_VMALLOC_SAVING
>> +int is_vmalloc_addr(const void *x)
>> +{
>> +	struct rb_node *n;
>> +	struct vmap_area *va;
>> +	int ret = 0;
>> +
>> +	spin_lock(&vmap_area_lock);
>> +
>> +	for (n = rb_first(vmap_area_root); n; rb_next(n)) {
>> +		va = rb_entry(n, struct vmap_area, rb_node);
>> +		if (x >= va->va_start && x < va->va_end) {
>> +			ret = 1;
>> +			break;
>> +		}
>> +	}
>> +
>> +	spin_unlock(&vmap_area_lock);
>> +	return ret;
>> +}
>> +EXPORT_SYMBOL(is_vmalloc_addr);
>> +#endif
>
> It's probably worth noting that this makes is_vmalloc_addr() a *LOT*
> more expensive than it was before.  There are a couple dozen of these in
> the tree in kinda weird places (ext4, netlink, tcp).  You didn't
> mention it here, but you probably want to at least make sure you're not
> adding a spinlock and a tree walk in some critical path.
>

Yes, that was a concern I had as well. If is_vmalloc_addr returned true 
the spinlock/tree walk would happen anyway so essentially this is 
getting rid of the fast path. This is typically used in the idiom

alloc(size) {
	if (size > some metric)
		vmalloc
	else
		kmalloc
}

free (ptr) {
	if (is_vmalloc_addr(ptr)
		vfree
	else
		kfree
}

so my hypothesis would be that any path would have to be willing to take 
the penalty of vmalloc anyway. The actual cost would depend on the 
vmalloc / kmalloc ratio. I haven't had a chance to get profiling data 
yet to see the performance difference.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
