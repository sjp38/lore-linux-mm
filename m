Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 48E806B0080
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 16:24:36 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so20904984pab.5
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 13:24:36 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id mz3si3033738pbc.162.2015.01.27.13.24.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jan 2015 13:24:35 -0800 (PST)
Date: Tue, 27 Jan 2015 13:24:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2015-01-22-15-04: qemu failures due to 'mm: account pmd
 page tables to the process'
Message-Id: <20150127132433.dbe4461d9caeecdb50f28b42@linux-foundation.org>
In-Reply-To: <20150127162428.GA21638@roeck-us.net>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
	<20150123050445.GA22751@roeck-us.net>
	<20150123111304.GA5975@node.dhcp.inet.fi>
	<54C263CC.1060904@roeck-us.net>
	<20150123135519.9f1061caf875f41f89298d59@linux-foundation.org>
	<20150124055207.GA8926@roeck-us.net>
	<20150126122944.GE25833@node.dhcp.inet.fi>
	<54C6494D.80802@roeck-us.net>
	<20150127161657.GA7155@node.dhcp.inet.fi>
	<20150127162428.GA21638@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, 27 Jan 2015 08:24:28 -0800 Guenter Roeck <linux@roeck-us.net> wrote:

> > __PAGETABLE_PMD_FOLDED is defined during <asm/pgtable.h> which is not
> > included into <linux/mm_types.h>. And we cannot include it here since
> > many of <asm/pgtables> needs <linux/mm_types.h> to define struct page.
> > 
> > I failed to come up with better solution rather than put nr_pmds into
> > mm_struct unconditionally.
> > 
> > One possible solution would be to expose number of page table levels
> > architecture has via Kconfig, but that's ugly and requires changes to
> > all architectures.
> > 
> FWIW, I tried a number of approaches. Ultimately I gave up and concluded
> that it has to be either this patch or, as you say here, we would have
> to add something like PAGETABLE_PMD_FOLDED as a Kconfig option.

It's certainly a big mess.  Yes, I expect that moving
__PAGETABLE_PMD_FOLDED and probably PAGETABLE_LEVELS into Kconfig logic
would be a good fix.

Adding 8 bytes to the mm_struct (sometimes) isn't a huge issue, but
it does make the kernel just a little bit worse.

Has anyone taken a look at what the Kconfig approach would look like?

Possibly another fix for this would be to move mm_struct into its own
header file, or something along those lines?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
