From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re: Remove page flags for software suspend)
Date: Thu, 8 Mar 2007 23:05:42 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200703041450.02178.rjw@sisk.pl> <1173315625.3546.32.camel@johannes.berg>
In-Reply-To: <1173315625.3546.32.camel@johannes.berg>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703082305.43513.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pavel Machek <pavel@ucw.cz>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thursday, 8 March 2007 02:00, Johannes Berg wrote:
> On Sun, 2007-03-04 at 14:50 +0100, Rafael J. Wysocki wrote:
> 
> > Okay, the next three messages contain patches that should do the trick.
> > 
> > They have been tested on x86_64, but not very thoroughly.
> 
> Looks nice, but I'm having some trouble with it. Solved too though :)
> 
> Thing is that I need to call register_nosave_region for a region
> reserved for the IOMMU. Because the region is reserved so early during
> boot I cannot call register_nosave_region at that time. However, I also
> can't call register_nosave_region during a late initcall because at that
> point bootmem can no longer be allocated. I could of course put a hook
> somewhere into the arch code to do the marking, but I'd prefer not to.
> 
> The easiest solution I came up with is below. Of course, the suspend
> patches for powerpc64 are still very much work in progress and I might
> end up changing the whole reservation scheme after some feedback... If
> nobody else needs this then don't think about it now.

Well, it may be needed for other things too.

> However, would that patch be acceptable to you? What about error
> handling? Printing a message and setting a "suspend not permitted"
> variable would be great but I don't think such a variable exists.

You're right, there's nothing like that.

> Also, maybe passing in a gfp mask would be better (and we could use 0 to mean
> bootmem too, I'd think)

I think we should pass a mask.  BTW, can you please check if the appended patch
is sufficient?

> Actually... I'd never have noticed this if register_nosave_region merged
> regions. I have these two regions:
> [    0.000000] swsusp: Registered nosave memory region: 0000000080000000 - 0000000100000000
> [...]
> [   19.406116] swsusp: Registered nosave memory region: 000000007f000000 - 0000000080000000
> But they aren't merged, if they were the latter call wouldn't need to do
> any allocations. Not that I'd want to rely on these positions!

It only merges regions passed in the right order (ie. sorted).

> With this patch and appropriate changes to my suspend code, it works.

OK, thanks for testing!

Greetings,
Rafael


---
 kernel/power/snapshot.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

Index: linux-2.6.21-rc3/kernel/power/snapshot.c
===================================================================
--- linux-2.6.21-rc3.orig/kernel/power/snapshot.c
+++ linux-2.6.21-rc3/kernel/power/snapshot.c
@@ -624,8 +624,18 @@ register_nosave_region(unsigned long sta
 			goto Report;
 		}
 	}
-	/* This allocation cannot fail */
-	region = alloc_bootmem_low(sizeof(struct nosave_region));
+	if (system_state == SYSTEM_BOOTING) {
+		/* This allocation cannot fail */
+		region = alloc_bootmem_low(sizeof(struct nosave_region));
+	} else {
+		region = kzalloc(sizeof(struct nosave_region), GFP_ATOMIC);
+		if (!region) {
+			printk(KERN_WARNING "swsusp: Not enough memory "
+				"to register a nosave region!\n");
+			WARN_ON(1);
+			return;
+		}
+	}
 	region->start_pfn = start_pfn;
 	region->end_pfn = end_pfn;
 	list_add_tail(&region->list, &nosave_regions);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
