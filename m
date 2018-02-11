Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 475FC6B0011
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 03:39:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id s11so4067598pfh.23
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 00:39:13 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id r23si658449pfj.315.2018.02.11.00.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Feb 2018 00:39:12 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: The usage of page_mapping() in architecture code
References: <87vaf4xbz8.fsf@yhuang-dev.intel.com>
	<20180211081707.GM9418@n2100.armlinux.org.uk>
Date: Sun, 11 Feb 2018 16:39:07 +0800
In-Reply-To: <20180211081707.GM9418@n2100.armlinux.org.uk> (Russell King's
	message of "Sun, 11 Feb 2018 08:17:07 +0000")
Message-ID: <87fu67yl78.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@intel.com>, Chen Liqin <liqin.linux@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Vineet Gupta <vgupta@synopsys.com>, Ley Foon Tan <lftan@altera.com>, Ralf Baechle <ralf@linux-mips.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

Hi, Russell,

Russell King - ARM Linux <linux@armlinux.org.uk> writes:

> On Sun, Feb 11, 2018 at 02:43:39PM +0800, Huang, Ying wrote:
[snip]
>> 
>> 
>> if page is an anonymous page in swap cache, "mapping &&
>> !mapping_mapped()" will be true, so we will delay flushing.  But if my
>> understanding of the code were correct, we should call
>> flush_kernel_dcache() because the kernel may access the page during
>> swapping in/out.
>> 
>> The code in other architectures follow the similar logic.  Would it be
>> better for page_mapping() here to return NULL for anonymous pages even
>> if they are in swap cache?  Of course we need to change the function
>> name.  page_file_mapping() appears a good name, but that has been used
>> already.  Any suggestion?
>
> flush_dcache_page() does nothing for anonymous pages (see cachetlb.txt,
> it's only defined to do anything for page cache pages.)
>
> flush_anon_page() deals with anonymous pages.

Thanks for your information!  But I found this isn't followed exactly in
the code.  For example, in get_mergeable_page() in mm/ksm.c,

	if (PageAnon(page)) {
		flush_anon_page(vma, page, addr);
		flush_dcache_page(page);
	} else {
		put_page(page);

flush_dcache_page() is called for anonymous pages too.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
