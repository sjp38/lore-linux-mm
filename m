From: "Robin H. Johnson" <robbat2@gentoo.org>
Subject: Re: PROBLEM-PERSISTS: dmesg spam: alloc_contig_range: [XX, YY) PFNs
 busy
Date: Wed, 30 Nov 2016 19:58:37 +0000
Message-ID: <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
 <20161130092239.GD18437@dhcp22.suse.cz>
 <xa1ty4012k0f.fsf@mina86.com>
 <20161130132848.GG18432@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161130132848.GG18432@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, "Robin H. Johnson" <robbat2@orbis-terrarum.net>, linux-kernel@vger.kernel.org, robbat2@gentoo.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

(I'm going to respond directly to this email with the stack trace.)

On Wed, Nov 30, 2016 at 02:28:49PM +0100, Michal Hocko wrote:
> > On the other hand, if this didn’t happen and now happens all the time,
> > this indicates a regression in CMA’s capability to allocate pages so
> > just rate limiting the output would hide the potential actual issue.
> 
> Or there might be just a much larger demand on those large blocks, no?
> But seriously, dumping those message again and again into the low (see
> the 2.5_GB_/h to the log is just insane. So there really should be some
> throttling.
> 
> Does the following help you Robin. At least to not get swamped by those
> message.
Here's what I whipped up based on that, to ensure that dump_stack got
rate-limited at the same pass as PFNs-busy. It dropped the dmesg spew to
~25MB/hour (and is suppressing ~43 entries/second right now).

commit 6ad4037e18ec2199f8755274d8a745a9904241a1
Author: Robin H. Johnson <robbat2@gentoo.org>
Date:   Wed Nov 30 10:32:57 2016 -0800

    mm: ratelimit & trace PFNs busy.
    
    Signed-off-by: Robin H. Johnson <robbat2@gentoo.org>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440e3ae2..3c28ec3d18f8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7289,8 +7289,15 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
-		pr_info("%s: [%lx, %lx) PFNs busy\n",
-			__func__, outer_start, end);
+		static DEFINE_RATELIMIT_STATE(ratelimit_pfn_busy,
+					DEFAULT_RATELIMIT_INTERVAL,
+					DEFAULT_RATELIMIT_BURST);
+		if (__ratelimit(&ratelimit_pfn_busy)) {
+			pr_info("%s: [%lx, %lx) PFNs busy\n",
+				__func__, outer_start, end);
+			dump_stack();
+		}
+
 		ret = -EBUSY;
 		goto done;
 	}

-- 
Robin Hugh Johnson
Gentoo Linux: Dev, Infra Lead, Foundation Trustee & Treasurer
E-Mail   : robbat2@gentoo.org
GnuPG FP : 11ACBA4F 4778E3F6 E4EDF38E B27B944E 34884E85
GnuPG FP : 7D0B3CEB E9B85B1F 825BCECF EE05E6F6 A48F6136
