Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7D65831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 11:19:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k57so9921097wrk.6
        for <linux-mm@kvack.org>; Thu, 18 May 2017 08:19:56 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id x66si6375303wmb.51.2017.05.18.08.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 08:19:55 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id v4so12015277wmb.2
        for <linux-mm@kvack.org>; Thu, 18 May 2017 08:19:54 -0700 (PDT)
Date: Thu, 18 May 2017 18:19:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5, REBASED 9/9] x86/mm: Allow to have userspace mappings
 above 47-bits
Message-ID: <20170518151952.jzvz6aeelgx7ifmm@node.shutemov.name>
References: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
 <20170515121218.27610-10-kirill.shutemov@linux.intel.com>
 <20170518114359.GB25471@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518114359.GB25471@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Thu, May 18, 2017 at 01:43:59PM +0200, Michal Hocko wrote:
> On Mon 15-05-17 15:12:18, Kirill A. Shutemov wrote:
> [...]
> > @@ -195,6 +207,16 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
> >  	info.length = len;
> >  	info.low_limit = PAGE_SIZE;
> >  	info.high_limit = get_mmap_base(0);
> > +
> > +	/*
> > +	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
> > +	 * in the full address space.
> > +	 *
> > +	 * !in_compat_syscall() check to avoid high addresses for x32.
> > +	 */
> > +	if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
> > +		info.high_limit += TASK_SIZE_MAX - DEFAULT_MAP_WINDOW;
> > +
> >  	info.align_mask = 0;
> >  	info.align_offset = pgoff << PAGE_SHIFT;
> >  	if (filp) {
> 
> I have two questions/concerns here. The above assumes that any address above
> 1<<47 will use the _whole_ address space. Is this what we want?

Yes, I believe so.

> What if somebody does mmap(1<<52, ...) because he wants to (ab)use 53+
> bits for some other purpose? Shouldn't we cap the high_limit by the
> given address?

This would screw existing semantics of hint address -- "map here if
free, please".

> Another thing would be that 
> 	/* requesting a specific address */
> 	if (addr) {
> 		addr = PAGE_ALIGN(addr);
> 		vma = find_vma(mm, addr);
> 		if (TASK_SIZE - len >= addr &&
> 				(!vma || addr + len <= vma->vm_start))
> 			return addr;
> 	}
> 
> would fail for mmap(-1UL, ...) which is good because we do want to
> fallback to vm_unmapped_area and have randomized address which is
> ensured by your info.high_limit += ... but that wouldn't work for
> mmap(1<<N, ...) where N>47. So the first such mapping won't be
> randomized while others will be. This is quite unexpected I would say.
> So it should be documented at least or maybe we want to skip the above
> shortcut for addr > DEFAULT_MAP_WINDOW altogether.

Again, you're missing existing semantics of hint address. You may have a
reason to set hint address above 47-bit, besides getting access to full
address space.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
