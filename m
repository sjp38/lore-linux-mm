Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CA1706B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 13:17:31 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 2 Jan 2013 11:17:30 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 4D3FC3E40045
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 11:17:23 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r02IHRq9331042
	for <linux-mm@kvack.org>; Wed, 2 Jan 2013 11:17:27 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r02IHQ1n024639
	for <linux-mm@kvack.org>; Wed, 2 Jan 2013 11:17:27 -0700
Message-ID: <50E479AD.9030502@linux.vnet.ibm.com>
Date: Wed, 02 Jan 2013 10:17:17 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] zswap: add to mm/
References: <<1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>> <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>> <0e91c1e5-7a62-4b89-9473-09fff384a334@default> <50E32255.60901@linux.vnet.ibm.com> <50E4588E.6080001@linux.vnet.ibm.com> <28a63847-7659-44c4-9c33-87f5d50b2ea0@default>
In-Reply-To: <28a63847-7659-44c4-9c33-87f5d50b2ea0@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/02/2013 09:26 AM, Dan Magenheimer wrote:
> However if one compares the total percentage
> of RAM used for zpages by zswap vs the total percentage of RAM
> used by slab, I suspect that the zswap number will dominate,
> perhaps because zswap is storing primarily data and slab is
> storing primarily metadata?

That's *obviously* 100% dependent on how you configure zswap.  But, that
said, most of _my_ systems tend to sit with about 5% of memory in
reclaimable slab which is certainly on par with how I'd expect to see
zswap used.

> I don't claim to be any kind of expert here, but I'd imagine
> that MM doesn't try to manage the total amount of slab space
> because slab is "a cost of doing business".  However, for
> in-kernel compression to be widely useful, IMHO it will be
> critical for MM to somehow load balance between total pageframes
> used for compressed pages vs total pageframes used for
> normal pages, just as today it needs to balance between
> active and inactive pages.

The issue isn't about balancing.  It's about reclaim where the VM only
cares about whole pages.  If our subsystem (zwhatever or slab) is only
designed to reclaim _parts_ of pages, can we be successful in returning
whole pages to the VM?

The slab shrinkers only work on parts of pages (singular slab objects).
 Yet, it does appear that they function well enough when we try to
reclaim from them.  I've never seen a slab's sizes spiral out of control
due to fragmentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
