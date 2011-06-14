Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AF73F6B0082
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 12:03:47 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
Date: Tue, 14 Jun 2011 18:03:00 +0200
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com> <201106141549.29315.arnd@arndb.de> <op.vw2jmhir3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <op.vw2jmhir3l0zgt@mnazarewicz-glaptop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201106141803.00876.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>

On Tuesday 14 June 2011, Michal Nazarewicz wrote:
> On Tue, 14 Jun 2011 15:49:29 +0200, Arnd Bergmann <arnd@arndb.de> wrote:
> > Please explain the exact requirements that lead you to defining multiple
> > contexts.
> 
> Some devices may have access only to some banks of memory.  Some devices
> may use different banks of memory for different purposes.

For all I know, that is something that is only true for a few very special
Samsung devices, and is completely unrelated of the need for contiguous
allocations, so this approach becomes pointless as soon as the next
generation of that chip grows an IOMMU, where we don't handle the special
bank attributes. Also, the way I understood the situation for the Samsung
SoC during the Budapest discussion, it's only a performance hack, not a
functional requirement, unless you count '1080p playback' as a functional
requirement.

Supporting contiguous allocation is a very useful goal and many people want
this, but supporting a crazy one-off hardware design with lots of generic
infrastructure is going a bit too far. If you can't be more specific than
'some devices may need this', I would suggest going forward without having
multiple regions:

* Remove the registration of specific addresses from the initial patch
  set (but keep the patch).
* Add a heuristic plus command-line override to automatically come up
  with a reasonable location+size for *one* CMA area in the system.
* Ship the patch to add support for multiple CMA areas with the BSP
  for the boards that need it (if any).
* Wait for someone on a non-Samsung SoC to run into the same problem,
  then have /them/ get the final patch in.

Even if you think you can convince enough people that having support
for distinct predefined regions is a good idea, I would recommend
splitting that out of the initial merge so we can have that discussion
separately from the other issues.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
