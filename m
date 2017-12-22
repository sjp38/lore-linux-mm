Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE05D6B0253
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 07:31:27 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f64so20163582pfd.6
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 04:31:27 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v3si15202762pgq.731.2017.12.22.04.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Dec 2017 04:31:26 -0800 (PST)
Date: Fri, 22 Dec 2017 04:31:12 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] Introduce __cond_lock_err
Message-ID: <20171222123112.GA6401@bombadil.infradead.org>
References: <20171219165823.24243-1-willy@infradead.org>
 <20171219165823.24243-2-willy@infradead.org>
 <20171221214810.GC9087@linux.intel.com>
 <20171222011000.GB23624@bombadil.infradead.org>
 <20171222042120.GA18036@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171222042120.GA18036@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Thu, Dec 21, 2017 at 08:21:20PM -0800, Josh Triplett wrote:
> On Thu, Dec 21, 2017 at 05:10:00PM -0800, Matthew Wilcox wrote:
> > Yes, but this define is only #if __CHECKER__, so it doesn't matter what we
> > return as this code will never run.
> 
> It does matter slightly, as Sparse does some (very limited) value-based
> analyses. Let's future-proof it.
> 
> > That said, if sparse supports the GNU syntax of ?: then I have no
> > objection to doing that.
> 
> Sparse does support that syntax.

Great, I'll fix that and resubmit.

While I've got you, I've been looking at some other sparse warnings from
this file.  There are several caused by sparse being unable to handle
the following construct:

	if (foo)
		x = NULL;
	else {
		x = bar;
		__acquire(bar);
	}
	if (!x)
		return -ENOMEM;

Writing it as:

	if (foo)
		return -ENOMEM;
	else {
		x = bar;
		__acquire(bar);
	}

works just fine.  ie this removes the warning:

@@ -1070,9 +1070,9 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct
 mm_struct *src_mm,
 again:
        init_rss_vec(rss);
 
-       dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
-       if (!dst_pte)
+       if (pte_alloc(dst_mm, dst_pmd, addr))
                return -ENOMEM;
+       dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
        src_pte = pte_offset_map(src_pmd, addr);
        src_ptl = pte_lockptr(src_mm, src_pmd);
        spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);

Is there any chance sparse's dataflow analysis will be improved in the
near future?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
