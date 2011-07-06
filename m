Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C25A79000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 16:24:21 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [PATCH 6/8] drivers: add Contiguous Memory Allocator
Date: Wed, 6 Jul 2011 22:23:01 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <201107061831.59739.arnd@arndb.de> <alpine.LFD.2.00.1107061459520.14596@xanadu.home>
In-Reply-To: <alpine.LFD.2.00.1107061459520.14596@xanadu.home>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201107062223.01940.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-mm-sig@lists.linaro.org
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, 'Daniel Walker' <dwalker@codeaurora.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-media@vger.kernel.org, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, lkml <linux-kernel@vger.kernel.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, 'Ankita Garg' <ankita@in.ibm.com>

On Wednesday 06 July 2011 21:10:07 Nicolas Pitre wrote:
> If you get a highmem page, because the cache is VIPT, that page might 
> still be cached even if it wasn't mapped.  With a VIVT cache we must 
> flush the cache whenever a highmem page is unmapped.  There is no such 
> restriction with VIPT i.e. ARMv6 and above.  Therefore to make sure the 
> highmem page you get doesn't have cache lines associated to it, you must 
> first map it cacheable, then perform cache invalidation on it, and 
> eventually remap it as non-cacheable.  This is necessary because there 
> is no way to perform cache maintenance on L1 cache using physical 
> addresses unfortunately.  See commit 7e5a69e83b for an example of what 
> this entails (fortunately commit 3e4d3af501 made things much easier and 
> therefore commit 39af22a79 greatly simplified things).

Ok, thanks for the explanation. This definitely makes the highmem approach
much harder to get right, and slower. Let's hope then that Marek's approach
of using small pages for the contiguous memory region and changing their
attributes on the fly works out better than this.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
