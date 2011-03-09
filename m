Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4269E8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 19:03:05 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p28NvDFP030104
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 16:57:13 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2902NrQ085956
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 17:02:24 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p28Nxwnj018803
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 17:00:00 -0700
Subject: Re: [PATCH R4 7/7] xen/balloon: Memory hotplug support for Xen
 balloon driver
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110308215049.GH27331@router-fw-old.local.net-space.pl>
References: <20110308215049.GH27331@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 08 Mar 2011 16:02:19 -0800
Message-ID: <1299628939.9014.3499.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2011-03-08 at 22:50 +0100, Daniel Kiper wrote:
> +static enum bp_state reserve_additional_memory(long credit)
> +{
> +	int rc;
> +	unsigned long balloon_hotplug = credit;
> +
> +	balloon_hotplug <<= PAGE_SHIFT;
> +
> +	rc = add_virtual_memory((u64 *)&balloon_hotplug);

This would work if all 'unsigned long's were 64-bits.  It'll break on
32-bit kernels in a very bad way by overwriting 4 bytes of stack.

> +	if (rc) {
> +		pr_info("xen_balloon: %s: add_virtual_memory() failed: %i\n", __func__, rc);
> +		return BP_EAGAIN;
> +	}
> +
> +	balloon_hotplug >>= PAGE_SHIFT;
> +
> +	balloon_hotplug -= credit;
> +
> +	balloon_stats.hotplug_pages += credit;
> +	balloon_stats.balloon_hotplug = balloon_hotplug;
> +
> +	return BP_DONE;
> +}
> +
> +static int xen_online_page_notifier(struct notifier_block *nb, unsigned long val, void *v)
> +{
> +	struct page *page = v;
> +	unsigned long pfn = page_to_pfn(page);
> +
> +	if (pfn >= num_physpages)
> +		num_physpages = pfn + 1;
> +
> +	inc_totalhigh_pages();
> +
> +#ifdef CONFIG_FLATMEM
> +	max_mapnr = max(pfn, max_mapnr);
> +#endif

I really don't like that this is a direct copy of online_page() up to
this point.  They're already subtly different.  I'm also curious if this
breaks on 32-bit kernels because of the unconditional
inc_totalhigh_pages().

If it's done this way, I'd almost guarantee that the first time someone
fixes a bug or adds a generic feature in online_page() that Xen gets
missed.  

> +	mutex_lock(&balloon_mutex);
> +
> +	__balloon_append(page);
> +
> +	if (balloon_stats.hotplug_pages)
> +		--balloon_stats.hotplug_pages;
> +	else
> +		--balloon_stats.balloon_hotplug;
> +
> +	mutex_unlock(&balloon_mutex);
> +
> +	return NOTIFY_STOP;
> +}

I'm not a _huge_ fan of these notifier chains, but I guess it works.
However, if you're going to use these notifier chains, then we probably
should use them to full effect.  Have a notifier list like this:

	1. generic online_page()
	2. xen_online_page_notifier() (returns NOTIFY_STOP)
	3. free_online_page()

Where finish_online_page() does something like this:

finish_online_page(...)
{
        ClearPageReserved(page);
        init_page_count(page);
        __free_page(page);
}

These patches are definitely getting there.  Just another round or two,
and they should be ready to go.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
