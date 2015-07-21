Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A78649003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 19:34:54 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so128039475pdr.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:34:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b1si46701288pdk.16.2015.07.21.16.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 16:34:53 -0700 (PDT)
Date: Tue, 21 Jul 2015 16:34:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v9 6/8] proc: add kpageidle file
Message-Id: <20150721163452.c1e4075a2b193bcd325fad56@linux-foundation.org>
In-Reply-To: <d7a78b72053cf529c0c9ff6cbc02ffbb3d58fe35.1437303956.git.vdavydov@parallels.com>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<d7a78b72053cf529c0c9ff6cbc02ffbb3d58fe35.1437303956.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 19 Jul 2015 15:31:15 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:

> Knowing the portion of memory that is not used by a certain application
> or memory cgroup (idle memory) can be useful for partitioning the system
> efficiently, e.g. by setting memory cgroup limits appropriately.
> Currently, the only means to estimate the amount of idle memory provided
> by the kernel is /proc/PID/{clear_refs,smaps}: the user can clear the
> access bit for all pages mapped to a particular process by writing 1 to
> clear_refs, wait for some time, and then count smaps:Referenced.
> However, this method has two serious shortcomings:
> 
>  - it does not count unmapped file pages
>  - it affects the reclaimer logic
> 
> To overcome these drawbacks, this patch introduces two new page flags,
> Idle and Young, and a new proc file, /proc/kpageidle. A page's Idle flag
> can only be set from userspace by setting bit in /proc/kpageidle at the
> offset corresponding to the page, and it is cleared whenever the page is
> accessed either through page tables (it is cleared in page_referenced()
> in this case) or using the read(2) system call (mark_page_accessed()).
> Thus by setting the Idle flag for pages of a particular workload, which
> can be found e.g. by reading /proc/PID/pagemap, waiting for some time to
> let the workload access its working set, and then reading the kpageidle
> file, one can estimate the amount of pages that are not used by the
> workload.
> 
> The Young page flag is used to avoid interference with the memory
> reclaimer. A page's Young flag is set whenever the Access bit of a page
> table entry pointing to the page is cleared by writing to kpageidle. If
> page_referenced() is called on a Young page, it will add 1 to its return
> value, therefore concealing the fact that the Access bit was cleared.
> 
> Note, since there is no room for extra page flags on 32 bit, this
> feature uses extended page flags when compiled on 32 bit.
> 
> ...
>
>
> ...
>
> +static void kpageidle_clear_pte_refs(struct page *page)
> +{
> +	struct rmap_walk_control rwc = {
> +		.rmap_one = kpageidle_clear_pte_refs_one,
> +		.anon_lock = page_lock_anon_vma_read,
> +	};

I think this can be static const, since `arg' is unused?  That would
save some cycles and stack.

> +	bool need_lock;
> +
> +	if (!page_mapped(page) ||
> +	    !page_rmapping(page))
> +		return;
> +
> +	need_lock = !PageAnon(page) || PageKsm(page);
> +	if (need_lock && !trylock_page(page))

Oh.  So the feature is a bit unreliable.

I'm not immediately seeing anything which would prevent us from using
plain old lock_page() here.  What's going on?

> +		return;
> +
> +	rmap_walk(page, &rwc);
> +
> +	if (need_lock)
> +		unlock_page(page);
> +}
> +
> +static ssize_t kpageidle_read(struct file *file, char __user *buf,
> +			      size_t count, loff_t *ppos)
> +{
> +	u64 __user *out = (u64 __user *)buf;
> +	struct page *page;
> +	unsigned long pfn, end_pfn;
> +	ssize_t ret = 0;
> +	u64 idle_bitmap = 0;
> +	int bit;
> +
> +	if (*ppos & KPMMASK || count & KPMMASK)
> +		return -EINVAL;

Interface requires 8-byte aligned offset and size.

> +	pfn = *ppos * BITS_PER_BYTE;
> +	if (pfn >= max_pfn)
> +		return 0;
> +
> +	end_pfn = pfn + count * BITS_PER_BYTE;
> +	if (end_pfn > max_pfn)
> +		end_pfn = ALIGN(max_pfn, KPMBITS);

So we lose up to 63 pages.  Presumably max_pfn is well enough aligned
for this to not matter, dunno.

> +	for (; pfn < end_pfn; pfn++) {
> +		bit = pfn % KPMBITS;
> +		page = kpageidle_get_page(pfn);
> +		if (page) {
> +			if (page_is_idle(page)) {
> +				/*
> +				 * The page might have been referenced via a
> +				 * pte, in which case it is not idle. Clear
> +				 * refs and recheck.
> +				 */
> +				kpageidle_clear_pte_refs(page);
> +				if (page_is_idle(page))
> +					idle_bitmap |= 1ULL << bit;

I don't understand what's going on here.  More details, please?

> +			}
> +			put_page(page);
> +		}
> +		if (bit == KPMBITS - 1) {
> +			if (put_user(idle_bitmap, out)) {
> +				ret = -EFAULT;
> +				break;
> +			}
> +			idle_bitmap = 0;
> +			out++;
> +		}
> +	}
> +
> +	*ppos += (char __user *)out - buf;
> +	if (!ret)
> +		ret = (char __user *)out - buf;
> +	return ret;
> +}
> +
> +static ssize_t kpageidle_write(struct file *file, const char __user *buf,
> +			       size_t count, loff_t *ppos)
> +{
> +	const u64 __user *in = (const u64 __user *)buf;
> +	struct page *page;
> +	unsigned long pfn, end_pfn;
> +	ssize_t ret = 0;
> +	u64 idle_bitmap = 0;
> +	int bit;
> +
> +	if (*ppos & KPMMASK || count & KPMMASK)
> +		return -EINVAL;
> +
> +	pfn = *ppos * BITS_PER_BYTE;
> +	if (pfn >= max_pfn)
> +		return -ENXIO;
> +
> +	end_pfn = pfn + count * BITS_PER_BYTE;
> +	if (end_pfn > max_pfn)
> +		end_pfn = ALIGN(max_pfn, KPMBITS);
> +
> +	for (; pfn < end_pfn; pfn++) {
> +		bit = pfn % KPMBITS;
> +		if (bit == 0) {
> +			if (get_user(idle_bitmap, in)) {
> +				ret = -EFAULT;
> +				break;
> +			}
> +			in++;
> +		}
> +		if (idle_bitmap >> bit & 1) {

Hate it when I have to go look up a C precedence table.  This is

		if ((idle_bitmap >> bit) & 1) {

> +			page = kpageidle_get_page(pfn);
> +			if (page) {
> +				kpageidle_clear_pte_refs(page);
> +				set_page_idle(page);
> +				put_page(page);
> +			}
> +		}
> +	}
> +
> +	*ppos += (const char __user *)in - buf;
> +	if (!ret)
> +		ret = (const char __user *)in - buf;
> +	return ret;
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
