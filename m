Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id B15F26B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 14:12:57 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 26 Jan 2012 12:12:56 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3A67119D804A
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 12:12:51 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0QJCqDD088532
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 12:12:52 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0QJCo1a001823
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 12:12:51 -0700
Message-ID: <4F21A5AF.6010605@linux.vnet.ibm.com>
Date: Thu, 26 Jan 2012 11:12:47 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 01/09/2012 02:51 PM, Seth Jennings wrote:
> +	area = &get_cpu_var(zs_map_area);
> +	if (off + class->size <= PAGE_SIZE) {
> +		/* this object is contained entirely within a page */
> +		area->vm_addr = kmap_atomic(page);
> +	} else {
> +		/* this object spans two pages */
> +		struct page *nextp;
> +
> +		nextp = get_next_page(page);
> +		BUG_ON(!nextp);
> +
> +
> +		set_pte(area->vm_ptes[0], mk_pte(page, PAGE_KERNEL));
> +		set_pte(area->vm_ptes[1], mk_pte(nextp, PAGE_KERNEL));
> +
> +		/* We pre-allocated VM area so mapping can never fail */
> +		area->vm_addr = area->vm->addr;
> +	}

This bit appears to be trying to make kmap_atomic() variant that can map
two pages in to contigious virtual addresses.  Instead of open-coding it
in a non-portable way like this, should we just make a new kmap_atomic()
variant that does this?

>From the way it's implemented, I _think_ you're guaranteed to get two
contiguous addresses if you do two adjacent kmap_atomics() on the same CPU:

void *kmap_atomic_prot(struct page *page, pgprot_t prot)
{
...
        type = kmap_atomic_idx_push();
        idx = type + KM_TYPE_NR*smp_processor_id();
        vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);

I think if you do a get_cpu()/put_cpu() or just a preempt_disable()
across the operations you'll be guaranteed to get two contiguous addresses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
