Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBINGMmq000617
	for <linux-mm@kvack.org>; Mon, 18 Dec 2006 18:16:23 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBINGMDG270582
	for <linux-mm@kvack.org>; Mon, 18 Dec 2006 18:16:22 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBINGM1U029652
	for <linux-mm@kvack.org>; Mon, 18 Dec 2006 18:16:22 -0500
Subject: Re: [PATCH] Fix sparsemem on Cell
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200612182354.47685.arnd@arndb.de>
References: <20061215165335.61D9F775@localhost.localdomain>
	 <20061215114536.dc5c93af.akpm@osdl.org>
	 <20061216170353.2dfa27b1.kamezawa.hiroyu@jp.fujitsu.com>
	 <200612182354.47685.arnd@arndb.de>
Content-Type: text/plain
Date: Mon, 18 Dec 2006 15:16:20 -0800
Message-Id: <1166483780.8648.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@osdl.org>, kmannth@us.ibm.com, linux-kernel@vger.kernel.org, hch@infradead.org, linux-mm@kvack.org, paulus@samba.org, mkravetz@us.ibm.com, gone@us.ibm.com, cbe-oss-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-12-18 at 23:54 +0100, Arnd Bergmann wrote:
>  #ifndef __HAVE_ARCH_MEMMAP_INIT
>  #define memmap_init(size, nid, zone, start_pfn) \
> -	memmap_init_zone((size), (nid), (zone), (start_pfn))
> +	memmap_init_zone((size), (nid), (zone), (start_pfn), 1)
>  #endif

This is what I was thinking of.  Sometimes I find these kinds of calls a
bit annoying:

	foo(0, 1, 1, 0, 99, 22)

It only takes a minute to look up what all of the numbers do, but that
is one minute too many. :)

How about an enum, or a pair of #defines?

enum context
{
        EARLY,
        HOTPLUG
};
extern void memmap_init_zone(unsigned long, int, unsigned long, unsigned long,
                                enum call_context);
...

So, the call I quoted above would become:

	memmap_init_zone((size), (nid), (zone), (start_pfn), EARLY)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
