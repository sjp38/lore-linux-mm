Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC7BB8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 16:26:07 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so3349412edm.18
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 13:26:07 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id b3si2031695ede.42.2019.01.09.13.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 13:26:06 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id E06821C2AD8
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 21:26:05 +0000 (GMT)
Date: Wed, 9 Jan 2019 21:26:03 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, compaction: Use free lists to quickly locate a
 migration target -fix
Message-ID: <20190109212603.GY31517@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190109111344.GU31517@techsingularity.net>
 <20190109112731.7d189ba6a606ca8f84dc5fa2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190109112731.7d189ba6a606ca8f84dc5fa2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Linux-MM <linux-mm@kvack.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Wed, Jan 09, 2019 at 11:27:31AM -0800, Andrew Morton wrote:
> On Wed, 9 Jan 2019 11:13:44 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > Full compaction of a node passes in negative orders which can lead to array
> > boundary issues. While it could be addressed in the control flow of the
> > primary loop, it would be fragile so explicitly check for the condition.
> > This is a fix for the mmotm patch
> > broken-out/mm-compaction-use-free-lists-to-quickly-locate-a-migration-target.patch
> > 
> > ...
> >
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1206,6 +1206,10 @@ fast_isolate_freepages(struct compact_control *cc)
> >  	bool scan_start = false;
> >  	int order;
> >  
> > +	/* Full compaction passes in a negative order */
> > +	if (order <= 0)
> > +		return cc->free_pfn;
> > +
> >  	/*
> >  	 * If starting the scan, use a deeper search and use the highest
> >  	 * PFN found if a suitable one is not found.
> 
> `order' is uninitialized.

Twice I managed to send out the wrong one :(

---8<---
mm, compaction: Use free lists to quickly locate a migration target -fix

Full compaction of a node passes in negative orders which can lead to array
boundary issues. While it could be addressed in the control flow of the
primary loop, it would be fragile so explicitly check for the condition.
This is a fix for the mmotm patch
broken-out/mm-compaction-use-free-lists-to-quickly-locate-a-migration-target.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9438f0564ed5..4b46ae96cc1b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1206,6 +1206,10 @@ fast_isolate_freepages(struct compact_control *cc)
 	bool scan_start = false;
 	int order;
 
+	/* Full compaction passes in a negative order */
+	if (cc->order <= 0)
+		return cc->free_pfn;
+
 	/*
 	 * If starting the scan, use a deeper search and use the highest
 	 * PFN found if a suitable one is not found.
