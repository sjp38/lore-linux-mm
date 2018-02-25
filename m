Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 17D956B0003
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 19:50:48 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u83so3664269wmb.3
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 16:50:48 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id q8si416234wrc.316.2018.02.24.16.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Feb 2018 16:50:45 -0800 (PST)
Date: Sun, 25 Feb 2018 01:50:32 +0100
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: mmotm 2018-02-21-14-48 uploaded (mm/page_alloc.c on UML)
Message-ID: <20180225005032.GA11826@vmlxhi-102.adit-jv.com>
References: <20180221224839.MqsDtkGCK%akpm@linux-foundation.org>
 <7bcc52db-57eb-45b0-7f20-c93a968599cd@infradead.org>
 <20180222072037.GC30681@dhcp22.suse.cz>
 <20180222103832.GA11623@vmlxhi-102.adit-jv.com>
 <20180222125955.GD30681@dhcp22.suse.cz>
 <20180222130814.GA30385@vmlxhi-102.adit-jv.com>
 <20180222132630.GH30681@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180222132630.GH30681@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org
Cc: Randy Dunlap <rdunlap@infradead.org>, broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mm-commits@vger.kernel.org, sfr@canb.auug.org.au, richard -rw- weinberger <richard.weinberger@gmail.com>, Eugeniu Rosca <rosca.eugeniu@gmail.com>, Eugeniu Rosca <erosca@de.adit-jv.com>

Hello Andrew, Michal,

On Thu, Feb 22, 2018 at 02:26:30PM +0100, Michal Hocko wrote:
> On Thu 22-02-18 14:08:14, Eugeniu Rosca wrote:
> > On Thu, Feb 22, 2018 at 01:59:55PM +0100, Michal Hocko wrote:
> > > On Thu 22-02-18 11:38:32, Eugeniu Rosca wrote:
> > > > Hi Michal,
> > > > 
> > > > Please, let me know if any action is expected from my end.
> > > 
> > > I do not thing anything is really needed right now. If you have a strong
> > > opinion about the solution (ifdef vs. noop stub) then speak up.
> > 
> > No different preference on my side. I was more thinking if you are going
> > to amend the patch or create a fix on top of it. Since it didn't reach
> > mainline, it makes sense to amend it. If you can do it without the
> > intervention of the author, that's also fine for me.
> 
> Andrew usually takes the incremental fix and then squash them when
> sending to Linus

This may sound like bikeshedding, but if commit [1] is squashed onto [2],
the resulted commit will pointlessly relocate the ifdef line, like seen
in [3]. Feel free to skip this comment/request, but imho applying [4] on
top of [1] would then result in a cleaner squashed commit. No functional
change is intended here. TIA.

[1] linux-next commit 5fd667a8c762 ("mm-page_alloc-skip-over-regions-of-invalid-pfns-on-uma-fix")
[2] linux-next commit 72a571e91476 ("mm: page_alloc: skip over regions of invalid pfns on UMA")

[3] Ugly and unneeded ifdef line relocation
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb416723538f..a89b029985ef 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5355,12 +5355,12 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
                        goto not_early;

                if (!early_pfn_valid(pfn)) {
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
                        /*
                         * Skip to the pfn preceding the next valid one (or
                         * end_pfn), such that we hit a valid pfn (or end_pfn)
                         * on our next iteration of the loop.
                         */
+#ifdef CONFIG_HAVE_MEMBLOCK
                        pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
 #endif
                        continue;


[4] Patch to be applied on top of [1], for a cleaner squashed commit.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a89b029985ef..10cbf9f1fb35 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5355,12 +5355,12 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
                        goto not_early;

                if (!early_pfn_valid(pfn)) {
+#ifdef CONFIG_HAVE_MEMBLOCK
                        /*
                         * Skip to the pfn preceding the next valid one (or
                         * end_pfn), such that we hit a valid pfn (or end_pfn)
                         * on our next iteration of the loop.
                         */
-#ifdef CONFIG_HAVE_MEMBLOCK
                        pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
 #endif
                        continue;

Best regards,
Eugeniu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
