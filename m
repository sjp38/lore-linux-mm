Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5D01E8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 15:26:53 -0400 (EDT)
Date: Thu, 31 Mar 2011 15:26:50 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 05/12] mm: alloc_contig_range() added
Message-ID: <20110331192650.GE14441@home.goodmis.org>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
 <1301577368-16095-6-git-send-email-m.szyprowski@samsung.com>
 <1301587361.31087.1040.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1301587361.31087.1040.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

On Thu, Mar 31, 2011 at 09:02:41AM -0700, Dave Hansen wrote:
> On Thu, 2011-03-31 at 15:16 +0200, Marek Szyprowski wrote:
> > +       ret = 0;
> > +       while (!PageBuddy(pfn_to_page(start & (~0UL << ret))))
> > +               if (WARN_ON(++ret >= MAX_ORDER))
> > +                       return -EINVAL; 
> 
> Holy cow, that's dense.  Is there really no more straightforward way to
> do that?
> 
> In any case, please pull the ++ret bit out of the WARN_ON().  Some
> people like to do:
> 
> #define WARN_ON(...) do{}while(0)
> 
> to save space on some systems.  

That should be fixed, as the if (WARN_ON()) has become a standard in
most of the kernel. Removing WARN_ON() should be:

#define WARN_ON(x) ({0;})

But I agree, that there should be no "side effects" inside a WARN_ON(),
which that "++ret" is definitely one.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
