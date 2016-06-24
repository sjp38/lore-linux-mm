Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 633376B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 16:19:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so261708008pfa.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 13:19:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v16si8623509pfa.219.2016.06.24.13.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 13:19:45 -0700 (PDT)
Date: Fri, 24 Jun 2016 13:19:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 7/9] mm/page_owner: avoid null pointer dereference
Message-Id: <20160624131944.cf98a963de76938246a27e13@linux-foundation.org>
In-Reply-To: <09cfe295-87d0-16d9-36ed-458378b3bd05@suse.cz>
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1466150259-27727-8-git-send-email-iamjoonsoo.kim@lge.com>
	<09cfe295-87d0-16d9-36ed-458378b3bd05@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: js1304@gmail.com, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 17 Jun 2016 15:32:20 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 06/17/2016 09:57 AM, js1304@gmail.com wrote:
> > From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> >
> > We have dereferenced page_ext before checking it. Lets check it first
> > and then used it.
> >
> > Link: http://lkml.kernel.org/r/1465249059-7883-1-git-send-email-sudipm.mukherjee@gmail.com
> > Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hmm, this is already in mmotm as 
> http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-page_owner-use-stackdepot-to-store-stacktrace-fix.patch
> 
> But imho it's fixing a problem not related to your patch, but something that the 
> commit f86e4271978b missed. So it should separately go to 4.7 ASAP.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Fixes: f86e4271978b ("mm: check the return value of lookup_page_ext for all call 
> sites")

Thanks, I reordered Sudip's patch.



From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: mm/page_owner: avoid null pointer dereference

We have dereferenced page_ext before checking it. Lets check it first
and then used it.

Fixes: f86e4271978b ("mm: check the return value of lookup_page_ext for all call sites")
Link: http://lkml.kernel.org/r/1465249059-7883-1-git-send-email-sudipm.mukherjee@gmail.com
Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_owner.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN mm/page_owner.c~mm-page_owner-use-stackdepot-to-store-stacktrace-fix mm/page_owner.c
--- a/mm/page_owner.c~mm-page_owner-use-stackdepot-to-store-stacktrace-fix
+++ a/mm/page_owner.c
@@ -207,13 +207,15 @@ void __dump_page_owner(struct page *page
 		.nr_entries = page_ext->nr_entries,
 		.entries = &page_ext->trace_entries[0],
 	};
-	gfp_t gfp_mask = page_ext->gfp_mask;
-	int mt = gfpflags_to_migratetype(gfp_mask);
+	gfp_t gfp_mask;
+	int mt;
 
 	if (unlikely(!page_ext)) {
 		pr_alert("There is not page extension available.\n");
 		return;
 	}
+	gfp_mask = page_ext->gfp_mask;
+	mt = gfpflags_to_migratetype(gfp_mask);
 
 	if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags)) {
 		pr_alert("page_owner info is not active (free page?)\n");
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
