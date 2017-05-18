Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E041831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 11:41:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z88so10045973wrc.9
        for <linux-mm@kvack.org>; Thu, 18 May 2017 08:41:39 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id w129si21278083wmg.130.2017.05.18.08.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 08:41:37 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id v4so12148045wmb.2
        for <linux-mm@kvack.org>; Thu, 18 May 2017 08:41:37 -0700 (PDT)
Date: Thu, 18 May 2017 18:41:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5, REBASED 9/9] x86/mm: Allow to have userspace mappings
 above 47-bits
Message-ID: <20170518154135.zekuqls6almevrjt@node.shutemov.name>
References: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
 <20170515121218.27610-10-kirill.shutemov@linux.intel.com>
 <20170518114359.GB25471@dhcp22.suse.cz>
 <20170518151952.jzvz6aeelgx7ifmm@node.shutemov.name>
 <20170518152736.GA18333@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518152736.GA18333@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Thu, May 18, 2017 at 05:27:36PM +0200, Michal Hocko wrote:
> On Thu 18-05-17 18:19:52, Kirill A. Shutemov wrote:
> > On Thu, May 18, 2017 at 01:43:59PM +0200, Michal Hocko wrote:
> > > On Mon 15-05-17 15:12:18, Kirill A. Shutemov wrote:
> > > [...]
> > > > @@ -195,6 +207,16 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
> > > >  	info.length = len;
> > > >  	info.low_limit = PAGE_SIZE;
> > > >  	info.high_limit = get_mmap_base(0);
> > > > +
> > > > +	/*
> > > > +	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
> > > > +	 * in the full address space.
> > > > +	 *
> > > > +	 * !in_compat_syscall() check to avoid high addresses for x32.
> > > > +	 */
> > > > +	if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
> > > > +		info.high_limit += TASK_SIZE_MAX - DEFAULT_MAP_WINDOW;
> > > > +
> > > >  	info.align_mask = 0;
> > > >  	info.align_offset = pgoff << PAGE_SHIFT;
> > > >  	if (filp) {
> > > 
> > > I have two questions/concerns here. The above assumes that any address above
> > > 1<<47 will use the _whole_ address space. Is this what we want?
> > 
> > Yes, I believe so.
> > 
> > > What if somebody does mmap(1<<52, ...) because he wants to (ab)use 53+
> > > bits for some other purpose? Shouldn't we cap the high_limit by the
> > > given address?
> > 
> > This would screw existing semantics of hint address -- "map here if
> > free, please".
> 
> Well, the given address is just _hint_. We are still allowed to map to a
> different place. And it is not specified whether the resulting mapping
> is above or below that address. So I do not think it would screw the
> existing semantic. Or do I miss something?

You are right, that this behaviour is not fixed by any standard or written
down in documentation, but it's de-facto policy of Linux mmap(2) the
beginning.

And we need to be very careful when messing with this.

I believe that qemu linux-user to some extend relies on this behaviour to
do 32-bit allocations on 64-bit machine.

https://github.com/qemu/qemu/blob/master/linux-user/mmap.c#L256

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
