Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 0AEC76B0062
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 11:28:41 -0500 (EST)
Received: by yenq10 with SMTP id q10so4255670yen.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 08:28:41 -0800 (PST)
Date: Mon, 19 Dec 2011 08:28:35 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: memblock and bootmem problems if start + size = 4GB
Message-ID: <20111219162835.GA24519@google.com>
References: <4EEF42F5.7040002@monstr.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EEF42F5.7040002@monstr.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Simek <monstr@monstr.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello, Michal.

On Mon, Dec 19, 2011 at 02:58:13PM +0100, Michal Simek wrote:
> I have reached some problems with memblock and bootmem code for some configurations.
> We can completely setup the whole system and all addresses in it.
> The problem happens if we place main memory to the end of address space when
> mem_start + size reach 4GB limit.
> 
> For example:
> mem_start      0xF000 0000
> mem_size       0x1000 0000 (or better lowmem size)
> mem_end        0xFFFF FFFF
> start + size 0x1 0000 0000 (u32 limit reached).
> 
> I have done some patches which completely remove start + size values from architecture specific
> code but I have found some problem in generic code too.
> 
> For example in bootmem code where are three places where physaddr + size is used.
> I would prefer to retype it to u64 because baseaddr and size don't need to be 2^n.
> 
> Is it correct solution? If yes, I will create proper patch.

Yeah, that's an inherent problem in using [) ranges but I think
chopping off the last page probably is simpler and more robust
solution.  Currently, memblock_add_region() would simply ignore if
address range overflows but making it just ignore the last page is
several lines of addition.  Wouldn't that be effective enough while
staying very simple?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
