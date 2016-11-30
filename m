From: Michal Hocko <mhocko@kernel.org>
Subject: Re: PROBLEM-PERSISTS: dmesg spam: alloc_contig_range: [XX, YY) PFNs
 busy
Date: Wed, 30 Nov 2016 14:28:49 +0100
Message-ID: <20161130132848.GG18432@dhcp22.suse.cz>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
 <20161130092239.GD18437@dhcp22.suse.cz>
 <xa1ty4012k0f.fsf@mina86.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <xa1ty4012k0f.fsf@mina86.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: "Robin H. Johnson" <robbat2@orbis-terrarum.net>, linux-kernel@vger.kernel.org, robbat2@gentoo.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wed 30-11-16 14:08:00, Michal Nazarewicz wrote:
> On Wed, Nov 30 2016, Michal Hocko wrote:
> > [Let's CC linux-mm and Michal]
> >
> > On Tue 29-11-16 22:43:08, Robin H. Johnson wrote:
> >> I didn't get any responses to this.
> >> 
> >> git bisect shows that the problem did actually exist in 4.5.0-rc6, but
> >> has gotten worse by many orders of magnitude (< 1/week to ~20M/hour).
> >> 
> >> Presently with 4.9-rc5, it's now writing ~2.5GB/hour to syslog.
> >
> > This is really not helpful. I think we should simply make it pr_debug or
> > need some ratelimitting.  AFAIU the message is far from serious
> 
> On the other hand, if this didn’t happen and now happens all the time,
> this indicates a regression in CMA’s capability to allocate pages so
> just rate limiting the output would hide the potential actual issue.

Or there might be just a much larger demand on those large blocks, no?
But seriously, dumping those message again and again into the low (see
the 2.5_GB_/h to the log is just insane. So there really should be some
throttling.

Does the following help you Robin. At least to not get swamped by those
message.
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0fbfead6aa7d..96eb8d107582 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7424,7 +7424,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
-		pr_info("%s: [%lx, %lx) PFNs busy\n",
+		printk_ratelimited(KERN_DEBUG "%s: [%lx, %lx) PFNs busy\n",
 			__func__, outer_start, end);
 		ret = -EBUSY;
 		goto done;

I would also suggest to add dump_stack() to that path to see who is
actually demanding so much large continuous blocks.
-- 
Michal Hocko
SUSE Labs
