Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0RK2YId020158
	for <linux-mm@kvack.org>; Fri, 27 Jan 2006 15:02:34 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0RK0iO9273496
	for <linux-mm@kvack.org>; Fri, 27 Jan 2006 13:00:45 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0RK2X1a031121
	for <linux-mm@kvack.org>; Fri, 27 Jan 2006 13:02:33 -0700
Subject: Re: [PATCH] Compile error on x86 with hotplug but no highmem
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0601271014090.25836@skynet>
References: <Pine.LNX.4.58.0601271014090.25836@skynet>
Content-Type: text/plain
Date: Fri, 27 Jan 2006 12:02:28 -0800
Message-Id: <1138392149.19801.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-01-27 at 10:17 +0000, Mel Gorman wrote:
> Memory hotplug without highmem is meaningless but it is still an allowed
> configuration. This is one possible fix. Another is to not allow memory
> hotplug without high memory being available. Another is to take
> online_page() outside of the #ifdef CONFIG_HIGHMEM block in init.c .

If it is meaningless, then we should probably fix it in the Kconfig
file, not just work around it at runtime.

What we really want is something to tell us that the architecture
_supports_ highmem and isn't using it.  Maybe something like this?

in mm/Kconfig:

config MEMORY_HOTPLUG
	depends on ... && !ARCH_HAS_DISABLED_HIGHMEM

in arch/i386/Kconfig:

config ARCH_HAS_DISABLED_HIGHMEM
	def_bool n
	depends on !HIGHMEM

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
