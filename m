Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id CCE936B00DB
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 10:29:14 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so14692681pde.4
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 07:29:14 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id bi2si25913824pbb.68.2014.11.13.07.29.07
        for <linux-mm@kvack.org>;
        Thu, 13 Nov 2014 07:29:08 -0800 (PST)
Message-ID: <5464CE41.2090601@sr71.net>
Date: Thu, 13 Nov 2014 07:29:05 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 10/11] x86, mpx: cleanup unused bound tables
References: <20141112170443.B4BD0899@viggo.jf.intel.com> <20141112170512.C932CF4D@viggo.jf.intel.com> <alpine.DEB.2.11.1411131541520.3935@nanos>
In-Reply-To: <alpine.DEB.2.11.1411131541520.3935@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, dave.hansen@linux.intel.com

On 11/13/2014 06:55 AM, Thomas Gleixner wrote:
> On Wed, 12 Nov 2014, Dave Hansen wrote:
>> +/*
>> + * Get the base of bounds tables pointed by specific bounds
>> + * directory entry.
>> + */
>> +static int get_bt_addr(struct mm_struct *mm,
>> +			long __user *bd_entry, unsigned long *bt_addr)
>> +{
>> +	int ret;
>> +	int valid;
>> +
>> +	if (!access_ok(VERIFY_READ, (bd_entry), sizeof(*bd_entry)))
>> +		return -EFAULT;
>> +
>> +	while (1) {
>> +		int need_write = 0;
>> +
>> +		pagefault_disable();
>> +		ret = get_user(*bt_addr, bd_entry);
>> +		pagefault_enable();
>> +		if (!ret)
>> +			break;
>> +		if (ret == -EFAULT)
>> +			ret = mpx_resolve_fault(bd_entry, need_write);
>> +		/*
>> +		 * If we could not resolve the fault, consider it
>> +		 * userspace's fault and error out.
>> +		 */
>> +		if (ret)
>> +			return ret;
>> +	}
>> +
>> +	valid = *bt_addr & MPX_BD_ENTRY_VALID_FLAG;
>> +	*bt_addr &= MPX_BT_ADDR_MASK;
>> +
>> +	/*
>> +	 * When the kernel is managing bounds tables, a bounds directory
>> +	 * entry will either have a valid address (plus the valid bit)
>> +	 * *OR* be completely empty. If we see a !valid entry *and* some
>> +	 * data in the address field, we know something is wrong. This
>> +	 * -EINVAL return will cause a SIGSEGV.
>> +	 */
>> +	if (!valid && *bt_addr)
>> +		return -EINVAL;
>> +	/*
>> +	 * Not present is OK.  It just means there was no bounds table
>> +	 * for this memory, which is completely OK.  Make sure to distinguish
>> +	 * this from -EINVAL, which will cause a SEGV.
>> +	 */
>> +	if (!valid)
>> +		return -ENOENT;
> 
> So here you have the extra -ENOENT return value, but at the
> direct/indirect call sites you ignore -EINVAL or everything.

I've gone and audited the call sites and cleaned this up a bit.

>> +static int mpx_unmap_tables(struct mm_struct *mm,
>> +		unsigned long start, unsigned long end)
> 
>> +	ret = unmap_edge_bts(mm, start, end);
>> +	if (ret == -EFAULT)
>> +		return ret;
> 
> So here you ignore EINVAL despite claiming that it will cause a
> SIGSEGV. So this should be:
> 
> 	switch (ret) {
> 	case 0:
> 	case -ENOENT:	break;
> 	default:	return ret;
> 	}
> 
>> +	for (bd_entry = bde_start + 1; bd_entry < bde_end; bd_entry++) {
>> +		ret = get_bt_addr(mm, bd_entry, &bt_addr);
>> +		/*
>> +		 * If we encounter an issue like a bad bounds-directory
>> +		 * we should still try the next one.
>> +		 */
>> +		if (ret)
>> +			continue;
> 
> You ignore all error returns. 

That was somewhat intentional with the idea that if we have a problem in
the middle of a large unmap we should attempt to complete the unmap.
But, I've changed my mind.  If we have any kind of validity issue, we
should just SIGSEGV and not attempt to keep unmapping things.  I've
updated the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
