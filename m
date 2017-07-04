Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAEB6B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 01:11:51 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j79so218937142pfj.9
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 22:11:51 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id g9si9820665plk.482.2017.07.03.22.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 22:11:50 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id u36so25138405pgn.3
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 22:11:50 -0700 (PDT)
Date: Tue, 4 Jul 2017 14:11:41 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: "mm: use early_pfn_to_nid in page_ext_init" broken on some
 configurations?
Message-ID: <20170704051138.GA28589@js1304-desktop>
References: <20170630141847.GN22917@dhcp22.suse.cz>
 <20170630154224.GA9714@dhcp22.suse.cz>
 <20170630154416.GB9714@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170630154416.GB9714@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linaro.org>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 30, 2017 at 05:44:16PM +0200, Michal Hocko wrote:
> On Fri 30-06-17 17:42:24, Michal Hocko wrote:
> [...]
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 16532fa0bb64..894697c1e6f5 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -1055,6 +1055,7 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
> >  	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
> >  static inline unsigned long early_pfn_to_nid(unsigned long pfn)
> >  {
> > +	BUILD_BUG_ON(!IS_ENABLED(CONFIG_NUMA));
> 
> Err, this should read BUILD_BUG_ON(IS_ENABLED(CONFIG_NUMA)) of course

Agreed.

However, AFAIK, ARM can set CONFIG_NUMA but it doesn't have
CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID and CONFIG_HAVE_MEMBLOCK_NODE_MAP.

If page_ext uses early_pfn_to_nid(), it will cause build error in ARM.

Therefore, I suggest following change.
CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on proper early_pfn_to_nid().
So, following code will always work as long as
CONFIG_DEFERRED_STRUCT_PAGE_INIT works.

Thanks.

----------->8---------------
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 88ccc044..e3db259 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -384,6 +384,7 @@ void __init page_ext_init(void)
 
        for_each_node_state(nid, N_MEMORY) {
                unsigned long start_pfn, end_pfn;
+               int page_nid;
 
                start_pfn = node_start_pfn(nid);
                end_pfn = node_end_pfn(nid);
@@ -405,8 +406,15 @@ void __init page_ext_init(void)
                         *
                         * Take into account DEFERRED_STRUCT_PAGE_INIT.
                         */
-                       if (early_pfn_to_nid(pfn) != nid)
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+                       page_nid = early_pfn_to_nid(pfn);
+#else
+                       page_nid = pfn_to_nid(pfn);
+#endif
+
+                       if (page_nid != nid)
                                continue;
+
                        if (init_section_page_ext(pfn, nid))
                                goto oom;
                }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
