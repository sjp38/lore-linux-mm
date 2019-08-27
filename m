Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB719C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 12:59:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E62B206BF
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 12:59:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="j18oVjBO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E62B206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 062376B0005; Tue, 27 Aug 2019 08:59:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2E826B0008; Tue, 27 Aug 2019 08:59:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA9406B000A; Tue, 27 Aug 2019 08:59:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id B7BF76B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 08:59:11 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 67618180AD802
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 12:59:11 +0000 (UTC)
X-FDA: 75868213302.09.cats26_6d3bb3e75aa22
X-HE-Tag: cats26_6d3bb3e75aa22
X-Filterd-Recvd-Size: 9094
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 12:59:10 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id t50so31301190edd.2
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 05:59:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HUKCbAic9eIa9RPzJgdlnYetwbCOkv22kAa+78v4bIE=;
        b=j18oVjBOmB2cLlDjVlcGlayzpzjWBYOXfyylep3Eo92D5ly5vZ898hO0xhJU/IGmO5
         2VkTLYgGZk7Tw84WyE2KqVZlxDHXsexj+b2rQAoPO0ReUTaC6lF3UtKLYFBb58j9Ozrt
         Aovc7Kj+Q+HU7vSYQAynu0BcPeb9J5hk4NalLHPFLmzXKHvkXlLk204b4p0ytQ7c/3er
         YIjVRv/9RaOSXa9WX9KuYDiZF7cULO15TVERwby+R3/Hx3u5pFl6NETjXpJu/hPs13TT
         mF+UpBfxDxPMthw6E+aCm/fScRoK7oWdXS1BVlwVbmWZs6/Efpl/9jaO1xw0WiB7N3pR
         ZCmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=HUKCbAic9eIa9RPzJgdlnYetwbCOkv22kAa+78v4bIE=;
        b=BawVxi18RjLX0lgMLEjYTrWoy8M95E2dOXt/q27cdfV9GAasMnqs3bOyJFvFV78Due
         VZK/C8ofL3CEzutCeJkx7V/H0iThRHmLRutiq9RkT1sLVSHxpFgkl46KNBk97nKZXQpS
         MYmSmMEptq+2uvN6YvLI+cCiSJf0wXgKzqMRKaOjUEEhRjv7N2+RM8nJAA1zwWjBpxvN
         xet4Pg9vl0FR9HFscN69GOomni1/4FUWWD4g8xTpFrUyW5HtmQX9g5bxdcxZ991unYJ2
         alHq7EfVaMOtPHPsklhxB5OtZ9aHo85SoDn0wwKcWHzLLPEPk3gejrZFTes/eAkbbbWH
         jrxw==
X-Gm-Message-State: APjAAAXjZglRW4CqSVVPK4tbSlex7R4LuNuoayYG0XA/cIL+gUg2BJYP
	wSAUbiBfUgViRGovsonNWPeouQ==
X-Google-Smtp-Source: APXvYqwfRfy3g0liRtJYUoliSYnjdswC/bLO6bfrDhpU643JJBSH6druOUvzA4FLemAESdw38z6yMw==
X-Received: by 2002:a17:906:c35a:: with SMTP id ci26mr21486446ejb.252.1566910749294;
        Tue, 27 Aug 2019 05:59:09 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id f6sm1941983edn.63.2019.08.27.05.59.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Aug 2019 05:59:08 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 1BE48100746; Tue, 27 Aug 2019 15:59:11 +0300 (+03)
Date: Tue, 27 Aug 2019 15:59:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com,
	Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
	rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190827125911.boya23eowxhqmopa@box>
References: <20190822080434.GF12785@dhcp22.suse.cz>
 <ee048bbf-3563-d695-ea58-5f1504aee35c@suse.cz>
 <20190822152934.w6ztolutdix6kbvc@box>
 <20190826074035.GD7538@dhcp22.suse.cz>
 <20190826131538.64twqx3yexmhp6nf@box>
 <20190827060139.GM7538@dhcp22.suse.cz>
 <20190827110210.lpe36umisqvvesoa@box>
 <aaaf9742-56f7-44b7-c3db-ad078b7b2220@suse.cz>
 <20190827120923.GB7538@dhcp22.suse.cz>
 <20190827121739.bzbxjloq7bhmroeq@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827121739.bzbxjloq7bhmroeq@box>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 03:17:39PM +0300, Kirill A. Shutemov wrote:
> On Tue, Aug 27, 2019 at 02:09:23PM +0200, Michal Hocko wrote:
> > On Tue 27-08-19 14:01:56, Vlastimil Babka wrote:
> > > On 8/27/19 1:02 PM, Kirill A. Shutemov wrote:
> > > > On Tue, Aug 27, 2019 at 08:01:39AM +0200, Michal Hocko wrote:
> > > >> On Mon 26-08-19 16:15:38, Kirill A. Shutemov wrote:
> > > >>>
> > > >>> Unmapped completely pages will be freed with current code. Deferred split
> > > >>> only applies to partly mapped THPs: at least on 4k of the THP is still
> > > >>> mapped somewhere.
> > > >>
> > > >> Hmm, I am probably misreading the code but at least current Linus' tree
> > > >> reads page_remove_rmap -> [page_remove_anon_compound_rmap ->\ deferred_split_huge_page even
> > > >> for fully mapped THP.
> > > > 
> > > > Well, you read correctly, but it was not intended. I screwed it up at some
> > > > point.
> > > > 
> > > > See the patch below. It should make it work as intened.
> > > > 
> > > > It's not bug as such, but inefficientcy. We add page to the queue where
> > > > it's not needed.
> > > 
> > > But that adding to queue doesn't affect whether the page will be freed
> > > immediately if there are no more partial mappings, right? I don't see
> > > deferred_split_huge_page() pinning the page.
> > > So your patch wouldn't make THPs freed immediately in cases where they
> > > haven't been freed before immediately, it just fixes a minor
> > > inefficiency with queue manipulation?
> > 
> > Ohh, right. I can see that in free_transhuge_page now. So fully mapped
> > THPs really do not matter and what I have considered an odd case is
> > really happening more often.
> > 
> > That being said this will not help at all for what Yang Shi is seeing
> > and we need a more proactive deferred splitting as I've mentioned
> > earlier.
> 
> It was not intended to fix the issue. It's fix for current logic. I'm
> playing with the work approach now.

Below is what I've come up with. It appears to be functional.

Any comments?

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d77d717c620c..c576e9d772b7 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -758,6 +758,8 @@ typedef struct pglist_data {
 	spinlock_t split_queue_lock;
 	struct list_head split_queue;
 	unsigned long split_queue_len;
+	unsigned int deferred_split_calls;
+	struct work_struct deferred_split_work;
 #endif
 
 	/* Fields commonly accessed by the page reclaim scanner */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index de1f15969e27..12d109bbe8ac 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2820,22 +2820,6 @@ void free_transhuge_page(struct page *page)
 	free_compound_page(page);
 }
 
-void deferred_split_huge_page(struct page *page)
-{
-	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
-	unsigned long flags;
-
-	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
-	if (list_empty(page_deferred_list(page))) {
-		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
-		list_add_tail(page_deferred_list(page), &pgdata->split_queue);
-		pgdata->split_queue_len++;
-	}
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
-}
-
 static unsigned long deferred_split_count(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
@@ -2901,6 +2885,44 @@ static struct shrinker deferred_split_shrinker = {
 	.flags = SHRINKER_NUMA_AWARE,
 };
 
+void flush_deferred_split_queue(struct work_struct *work)
+{
+	struct pglist_data *pgdata;
+	struct shrink_control sc;
+
+	pgdata = container_of(work, struct pglist_data, deferred_split_work);
+	sc.nid = pgdata->node_id;
+	sc.nr_to_scan = 0; /* Unlimited */
+
+	deferred_split_scan(NULL, &sc);
+}
+
+#define NR_CALLS_TO_SPLIT 32
+#define NR_PAGES_ON_QUEUE_TO_SPLIT 16
+
+void deferred_split_huge_page(struct page *page)
+{
+	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
+	unsigned long flags;
+
+	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+
+	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	if (list_empty(page_deferred_list(page))) {
+		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
+		list_add_tail(page_deferred_list(page), &pgdata->split_queue);
+		pgdata->split_queue_len++;
+		pgdata->deferred_split_calls++;
+	}
+
+	if (pgdata->deferred_split_calls > NR_CALLS_TO_SPLIT &&
+			pgdata->split_queue_len > NR_PAGES_ON_QUEUE_TO_SPLIT) {
+		pgdata->deferred_split_calls = 0;
+		schedule_work(&pgdata->deferred_split_work);
+	}
+	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+}
+
 #ifdef CONFIG_DEBUG_FS
 static int split_huge_pages_set(void *data, u64 val)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9c9194959271..86af66d463e9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6636,11 +6636,14 @@ static unsigned long __init calc_memmap_size(unsigned long spanned_pages,
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+void flush_deferred_split_queue(struct work_struct *work);
 static void pgdat_init_split_queue(struct pglist_data *pgdat)
 {
 	spin_lock_init(&pgdat->split_queue_lock);
 	INIT_LIST_HEAD(&pgdat->split_queue);
 	pgdat->split_queue_len = 0;
+	pgdat->deferred_split_calls = 0;
+	INIT_WORK(&pgdat->deferred_split_work, flush_deferred_split_queue);
 }
 #else
 static void pgdat_init_split_queue(struct pglist_data *pgdat) {}
-- 
 Kirill A. Shutemov

