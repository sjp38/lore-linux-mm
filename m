Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 797656B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 16:53:32 -0400 (EDT)
Message-ID: <501996CD.70007@redhat.com>
Date: Wed, 01 Aug 2012 16:51:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
References: <cover.1342485774.git.aquini@redhat.com> <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com> <20120718054824.GA32341@bbox> <20120720194858.GA16249@t510.redhat.com> <20120723023332.GA6832@bbox>
In-Reply-To: <20120723023332.GA6832@bbox>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Rafael Aquini <aquini@linux.com>

On 07/22/2012 10:33 PM, Minchan Kim wrote:

> IMHO, better approach is that after we can get complete free pageblocks
> by compaction or reclaim, move balloon pages into that pageblocks and make
> that blocks to unmovable. It can prevent fragmentation and it makes
> current or future code don't need to consider balloon page.

I believe this is the wrong thing to do.

In a KVM guest, getting applications in transparent
huge pages can be a 10-25% performance benefit.

Therefore, we need to make all the 2MB pageblocks
we can available for use by userland.

Using 2MB blocks for the balloon (which is never
touched) is extremely wasteful and could result in
a large performance penalty, if we cannot defragment
the remaining memory enough to give 2MB pages to
applications.

The 2MB blocks are prime real estate. They should
remain available for applications.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
