Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 956DAC3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 11:02:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BE6520828
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 11:02:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="s6DFBTmg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BE6520828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3F006B0005; Tue, 27 Aug 2019 07:02:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF02C6B0006; Tue, 27 Aug 2019 07:02:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDEB16B0007; Tue, 27 Aug 2019 07:02:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0227.hostedemail.com [216.40.44.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8296B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:02:11 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 47E882C8F
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 11:02:11 +0000 (UTC)
X-FDA: 75867918462.25.club29_6a4eb69224a4a
X-HE-Tag: club29_6a4eb69224a4a
X-Filterd-Recvd-Size: 10070
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 11:02:10 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id h8so30830780edv.7
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 04:02:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7fnPfQvHdj0cCNP+7IEvEZfVCE/dpJFzoNujaWzCQQQ=;
        b=s6DFBTmgS6Yc0h0SlDz+odoUsq7fVE6ckLWOQ9B4676EawP55OiesX/CkBb2PcaSqx
         4II3rHil2BZinimKMh7NnIYRqQuMh1dtHXD8fu09KgJrrb4dMj50RNDsXrKb15XLIPcJ
         fDtRdYmszY76Z7L82+sJ/S9VAOGUbVAVMMyu9wXMyYMIj2NcjLGGerWy2B7S74N/XrcT
         W6u1ueehHlNJoIYcnzb27i6FAQoj7FWy+C7Iome07z++tCj3h51lAAaV9/fCODgeEd0r
         +qTx8YM+vRuEJddtY1iQBq0V3t58xtdyn5ccHLDne8wYGnbUeivy36XxEt1ITDZg1wJn
         XLng==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=7fnPfQvHdj0cCNP+7IEvEZfVCE/dpJFzoNujaWzCQQQ=;
        b=UWGlR6MPcgTeAL9X1vaU0tyGGfUvMg5EDK10fLyZQT4HS7ptDViveC2xinkHcq/f0Z
         4U5l0RRW/mMOjiuvxYxb7fqUiSasIW9PkbV5Vy9K05Lb3dHkx/hX2g04B73tjFi+GyNf
         w7Dir+4glqeqRpxBaGlTyM6AU08L/NBiRQp3Z+/kH6UUBGAfFiXIpYY5fbT5VH6jfDgS
         7WZeqYSIsnWe7yzroAxRsqC0Kr63XuaE22aOUOTGC74RqkjFaKEzSMI9OlEOBuvhrZDX
         c/Cz7edH7obYzf+awbRt43XsYNVbzhnEPy6XCyJ0+WxGKaCU4wr73ft69CJwR4/pzbI6
         +M2g==
X-Gm-Message-State: APjAAAVv+1QZa+Vh5TQtnG3vZduoBUr2Ge978TP5wf/Y08T3OhVGmhhq
	NdUnCQSHtIsNRDIXG/vZH/DM3Q==
X-Google-Smtp-Source: APXvYqw1xRlVWnZVVSBchXgBbxOyJjGLDPVUV8uy23WlamQ1eK8AXx5ktvNpSgsNEg2R7DkbIsMpyw==
X-Received: by 2002:a17:906:4d8d:: with SMTP id s13mr20130220eju.86.1566903729183;
        Tue, 27 Aug 2019 04:02:09 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c6sm1933149edx.20.2019.08.27.04.02.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Aug 2019 04:02:08 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 5F8AE100746; Tue, 27 Aug 2019 14:02:10 +0300 (+03)
Date: Tue, 27 Aug 2019 14:02:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com,
	Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
	rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190827110210.lpe36umisqvvesoa@box>
References: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190822080434.GF12785@dhcp22.suse.cz>
 <ee048bbf-3563-d695-ea58-5f1504aee35c@suse.cz>
 <20190822152934.w6ztolutdix6kbvc@box>
 <20190826074035.GD7538@dhcp22.suse.cz>
 <20190826131538.64twqx3yexmhp6nf@box>
 <20190827060139.GM7538@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827060139.GM7538@dhcp22.suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 08:01:39AM +0200, Michal Hocko wrote:
> On Mon 26-08-19 16:15:38, Kirill A. Shutemov wrote:
> > On Mon, Aug 26, 2019 at 09:40:35AM +0200, Michal Hocko wrote:
> > > On Thu 22-08-19 18:29:34, Kirill A. Shutemov wrote:
> > > > On Thu, Aug 22, 2019 at 02:56:56PM +0200, Vlastimil Babka wrote:
> > > > > On 8/22/19 10:04 AM, Michal Hocko wrote:
> > > > > > On Thu 22-08-19 01:55:25, Yang Shi wrote:
> > > > > >> Available memory is one of the most important metrics for memory
> > > > > >> pressure.
> > > > > > 
> > > > > > I would disagree with this statement. It is a rough estimate that tells
> > > > > > how much memory you can allocate before going into a more expensive
> > > > > > reclaim (mostly swapping). Allocating that amount still might result in
> > > > > > direct reclaim induced stalls. I do realize that this is simple metric
> > > > > > that is attractive to use and works in many cases though.
> > > > > > 
> > > > > >> Currently, the deferred split THPs are not accounted into
> > > > > >> available memory, but they are reclaimable actually, like reclaimable
> > > > > >> slabs.
> > > > > >> 
> > > > > >> And, they seems very common with the common workloads when THP is
> > > > > >> enabled.  A simple run with MariaDB test of mmtest with THP enabled as
> > > > > >> always shows it could generate over fifteen thousand deferred split THPs
> > > > > >> (accumulated around 30G in one hour run, 75% of 40G memory for my VM).
> > > > > >> It looks worth accounting in MemAvailable.
> > > > > > 
> > > > > > OK, this makes sense. But your above numbers are really worrying.
> > > > > > Accumulating such a large amount of pages that are likely not going to
> > > > > > be used is really bad. They are essentially blocking any higher order
> > > > > > allocations and also push the system towards more memory pressure.
> > > > > > 
> > > > > > IIUC deferred splitting is mostly a workaround for nasty locking issues
> > > > > > during splitting, right? This is not really an optimization to cache
> > > > > > THPs for reuse or something like that. What is the reason this is not
> > > > > > done from a worker context? At least THPs which would be freed
> > > > > > completely sound like a good candidate for kworker tear down, no?
> > > > > 
> > > > > Agreed that it's a good question. For Kirill :) Maybe with kworker approach we
> > > > > also wouldn't need the cgroup awareness?
> > > > 
> > > > I don't remember a particular locking issue, but I cannot say there's
> > > > none :P
> > > > 
> > > > It's artifact from decoupling PMD split from compound page split: the same
> > > > page can be mapped multiple times with combination of PMDs and PTEs. Split
> > > > of one PMD doesn't need to trigger split of all PMDs and underlying
> > > > compound page.
> > > > 
> > > > Other consideration is the fact that page split can fail and we need to
> > > > have fallback for this case.
> > > > 
> > > > Also in most cases THP split would be just waste of time if we would do
> > > > them at the spot. If you don't have memory pressure it's better to wait
> > > > until process termination: less pages on LRU is still beneficial.
> > > 
> > > This might be true but the reality shows that a lot of THPs might be
> > > waiting for the memory pressure that is essentially freeable on the
> > > spot. So I am not really convinced that "less pages on LRUs" is really a
> > > plausible justification. Can we free at least those THPs which are
> > > unmapped completely without any pte mappings?
> > 
> > Unmapped completely pages will be freed with current code. Deferred split
> > only applies to partly mapped THPs: at least on 4k of the THP is still
> > mapped somewhere.
> 
> Hmm, I am probably misreading the code but at least current Linus' tree
> reads page_remove_rmap -> [page_remove_anon_compound_rmap ->\ deferred_split_huge_page even
> for fully mapped THP.

Well, you read correctly, but it was not intended. I screwed it up at some
point.

See the patch below. It should make it work as intened.

It's not bug as such, but inefficientcy. We add page to the queue where
it's not needed.

> > > > Main source of partly mapped THPs comes from exit path. When PMD mapping
> > > > of THP got split across multiple VMAs (for instance due to mprotect()),
> > > > in exit path we unmap PTEs belonging to one VMA just before unmapping the
> > > > rest of the page. It would be total waste of time to split the page in
> > > > this scenario.
> > > > 
> > > > The whole deferred split thing still looks as a reasonable compromise
> > > > to me.
> > > 
> > > Even when it leads to all other problems mentioned in this and memcg
> > > deferred reclaim series?
> > 
> > Yes.
> > 
> > You would still need deferred split even if you *try* to split the page on
> > the spot. split_huge_page() can fail (due to pin on the page) and you will
> > need to have a way to try again later.
> > 
> > You'll not win anything in complexity by trying split_huge_page()
> > immediately. I would ague you'll create much more complexity.
> 
> I am not arguing for in place split. I am arguing to do it ASAP rather
> than to wait for memory pressure which might be in an unbound amount of
> time. So let me ask again. Why cannot we do that in the worker context?
> Essentially schedure the work item right away?

Let me look into it.

diff --git a/mm/rmap.c b/mm/rmap.c
index 003377e24232..45388f1bf317 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1271,12 +1271,20 @@ static void page_remove_anon_compound_rmap(struct page *page)
 	if (TestClearPageDoubleMap(page)) {
 		/*
 		 * Subpages can be mapped with PTEs too. Check how many of
-		 * themi are still mapped.
+		 * them are still mapped.
 		 */
 		for (i = 0, nr = 0; i < HPAGE_PMD_NR; i++) {
 			if (atomic_add_negative(-1, &page[i]._mapcount))
 				nr++;
 		}
+
+		/*
+		 * Queue the page for deferred split if at least one small
+		 * page of the compound page is unmapped, but at least one
+		 * small page is still mapped.
+		 */
+		if (nr && nr < HPAGE_PMD_NR)
+			deferred_split_huge_page(page);
 	} else {
 		nr = HPAGE_PMD_NR;
 	}
@@ -1284,10 +1292,8 @@ static void page_remove_anon_compound_rmap(struct page *page)
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 
-	if (nr) {
+	if (nr)
 		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
-		deferred_split_huge_page(page);
-	}
 }
 
 /**
-- 
 Kirill A. Shutemov

