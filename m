Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 120EB6B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:30:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y90so6389711wrb.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 02:30:26 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id n107si2346966wrb.4.2017.03.24.02.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 02:30:21 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id u132so2028470wmg.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 02:30:21 -0700 (PDT)
Date: Fri, 24 Mar 2017 12:30:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 26/26] x86/mm: allow to have userspace mappings above
 47-bits
Message-ID: <20170324093019.ts7sljfg32kpajd2@node.shutemov.name>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
 <20170313055020.69655-27-kirill.shutemov@linux.intel.com>
 <8760j4sfcz.fsf@skywalker.in.ibm.com>
 <20170324090408.xsj7othssj547w5k@node.shutemov.name>
 <d1007940-5066-4fcf-9744-0bb0514b33d4@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d1007940-5066-4fcf-9744-0bb0514b33d4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 24, 2017 at 02:44:10PM +0530, Aneesh Kumar K.V wrote:
> 
> 
> On Friday 24 March 2017 02:34 PM, Kirill A. Shutemov wrote:
> > On Mon, Mar 20, 2017 at 10:40:20AM +0530, Aneesh Kumar K.V wrote:
> > > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> > >  @@ -168,6 +182,10 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
> > > >  	unsigned long addr = addr0;
> > > >  	struct vm_unmapped_area_info info;
> > > > 
> > > > +	addr = mpx_unmapped_area_check(addr, len, flags);
> > > > +	if (IS_ERR_VALUE(addr))
> > > > +		return addr;
> > > > +
> > > >  	/* requested length too big for entire address space */
> > > >  	if (len > TASK_SIZE)
> > > >  		return -ENOMEM;
> > > > @@ -192,6 +210,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
> > > >  	info.length = len;
> > > >  	info.low_limit = PAGE_SIZE;
> > > >  	info.high_limit = mm->mmap_base;
> > > > +
> > > > +	/*
> > > > +	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
> > > > +	 * in the full address space.
> > > > +	 */
> > > > +	if (addr > DEFAULT_MAP_WINDOW)
> > > > +		info.high_limit += TASK_SIZE - DEFAULT_MAP_WINDOW;
> > > > +
> > > 
> > > Is this ok for 32 bit application ?
> > 
> > DEFAULT_MAP_WINDOW is equal to TASK_SIZE on 32-bit, so it's nop and will
> > be compile out.
> > 
> 
> That is not about CONFIG_X86_32 but about 32 bit application on a 64 bit
> kernel. I guess we will never find addr > DEFAULT_MAP_WINDOW with
> a 32 bit app ?

I have local change to avoid this within 32-bit syscall, but I'll need to
recheck everthing.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
