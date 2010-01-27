Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1EABD6B004D
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 17:00:09 -0500 (EST)
Date: Wed, 27 Jan 2010 22:59:59 +0100
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH] Flush dcache before writing into page to avoid alias
Message-ID: <20100127215959.GC15325@Chamillionaire.breakpoint.cc>
References: <979dd0561001202107v4ddc1eb7xa59a7c16c452f7a2@mail.gmail.com>
 <20100125133308.GA26799@desktop>
 <20100125115814.156d401d.akpm@linux-foundation.org>
 <20100125200004.GF22481@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100125200004.GF22481@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, anfei <anfei.zhou@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jamie Lokier <jamie@shareable.org>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

* Russell King - ARM Linux | 2010-01-25 20:00:04 [+0000]:

>On Mon, Jan 25, 2010 at 11:58:14AM -0800, Andrew Morton wrote:
>> On Mon, 25 Jan 2010 21:33:08 +0800 anfei <anfei.zhou@gmail.com> wrote:
>> 
>> > Hi Andrew,
>> > 
>> > On Thu, Jan 21, 2010 at 01:07:57PM +0800, anfei zhou wrote:
>> > > The cache alias problem will happen if the changes of user shared mapping
>> > > is not flushed before copying, then user and kernel mapping may be mapped
>> > > into two different cache line, it is impossible to guarantee the coherence
>> > > after iov_iter_copy_from_user_atomic.  So the right steps should be:
>> > > 	flush_dcache_page(page);
>> > > 	kmap_atomic(page);
>> > > 	write to page;
>> > > 	kunmap_atomic(page);
>> > > 	flush_dcache_page(page);
>> > > More precisely, we might create two new APIs flush_dcache_user_page and
>> > > flush_dcache_kern_page to replace the two flush_dcache_page accordingly.
>> > > 
>> > > Here is a snippet tested on omap2430 with VIPT cache, and I think it is
>> > > not ARM-specific:
>> > > 	int val = 0x11111111;
>> > > 	fd = open("abc", O_RDWR);
>> > > 	addr = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
>> > > 	*(addr+0) = 0x44444444;
>> > > 	tmp = *(addr+0);
>> > > 	*(addr+1) = 0x77777777;
>> > > 	write(fd, &val, sizeof(int));
>> > > 	close(fd);
>> > > The results are not always 0x11111111 0x77777777 at the beginning as expected.
>> > > 
>> > Is this a real bug or not necessary to support?
>> 
>> Bug.  If variable `addr' has type int* then the contents of that file
>> should be 0x11111111 0x77777777.  You didn't tell us what the contents
>> were in the incorrect case, but I guess it doesn't matter.
>
>FYI, from a previous email from anfei:
>
>0x44444444 0x77777777

I just wanted to query what the status of this patch is. This patch
seems to fix a real bug which causes a test suite to fail on ARM [0].
The test suite passes on my VIVT ARM with this patch.

[0] http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=524003

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
