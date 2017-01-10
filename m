Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF79E6B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 19:37:45 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id s10so52963359itb.7
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 16:37:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e134si5652309itc.46.2017.01.09.16.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 16:37:45 -0800 (PST)
Date: Tue, 10 Jan 2017 08:37:35 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH v2 2/2] efi: efi_mem_reserve(): don't reserve through
 memblock after mm_init()
Message-ID: <20170110003735.GA2809@dhcp-128-65.nay.redhat.com>
References: <20161222102340.2689-1-nicstange@gmail.com>
 <20161222102340.2689-2-nicstange@gmail.com>
 <20170105091242.GA11021@dhcp-128-65.nay.redhat.com>
 <20170109114400.GF16838@codeblueprint.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170109114400.GF16838@codeblueprint.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Nicolai Stange <nicstange@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, Mika =?iso-8859-1?Q?Penttil=E4?= <mika.penttila@nextfour.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@techsingularity.net>

On 01/09/17 at 11:44am, Matt Fleming wrote:
> On Thu, 05 Jan, at 05:12:42PM, Dave Young wrote:
> > On 12/22/16 at 11:23am, Nicolai Stange wrote:
> > > Before invoking the arch specific handler, efi_mem_reserve() reserves
> > > the given memory region through memblock.
> > > 
> > > efi_mem_reserve() can get called after mm_init() though -- through
> > > efi_bgrt_init(), for example. After mm_init(), memblock is dead and should
> > > not be used anymore.
> > 
> > It did not fail during previous test so we did not catch this bug, if memblock
> > can not be used after mm_init(), IMHO it should fail instead of silently succeed.
>  
> This must literally be the fifth time or so that I've been caught out
> by this over the years because there's no hard error if you call the
> memblock code after slab and co. are up.
> 
> MM folks, is there some way to catch these errors without requiring
> the sprinkling of slab_is_available() everywhere?
> 
> > Matt, can we move the efi_mem_reserve to earlier code for example in
> > efi_memblock_x86_reserve_range just after reserving the memmap?
>  
> No, it *needs* to be callable from efi_bgrt_init(), because you only
> want to reserve those regions if you have the BGRT driver available.

It is true that it depends on acpi init, I was wondering if bgrt parsing can
be moved to early acpi code. But anyway I'm not sure it is doable and
worth.

Thanks
Dave 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
