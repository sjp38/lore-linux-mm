Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E873C282D0
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 22:53:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAD1D2175B
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 22:53:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAD1D2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 900F88E0004; Mon, 28 Jan 2019 17:53:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B3048E0001; Mon, 28 Jan 2019 17:53:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A2238E0004; Mon, 28 Jan 2019 17:53:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7EC8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 17:53:13 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v2so12849211plg.6
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 14:53:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9dDLESgUXGz1/oRJ38625V4OIxQ2B5iz0iK2T2wAMdQ=;
        b=GsRUiJVskcg+Pop56G3bYei6anCl58tmvTRywNNvgZ67rgpDYo3mwS2z6xv7szowtc
         lg5ZsGWFhjBEv22REHqyKXjWiAlZAeQzclrVah0GoBwpMumfuW1I7+vKSCOC7Kcau57v
         ixdLx1g91YnxhvphMRT+en75sZlXwrXNEsNHAzYUlEz2L51KUUldx/KBR1q19t31i/Y4
         sK/F4Pg7tAP8GB9BGUfMLcCJfdnkE9UdQzD7Z4r1gEo1X1NaAC4D5XLmObnkkrbSzw73
         x67pcD8LIkoAcRzCrgtjzgJocgcQFy8ni3QbGMJWPRRtad02iqdQn9FeRFeig8Ub5yrI
         HXBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukcGTaaBMPlgIIjjROSFL2kr7Ohl+gVcSRotwf2hC0oZweD/7gKV
	ll3lY55lluzTHlxQwcu/7RlGuwDW48KsfxqNvkReqr5AZp76/b6ZEvgpAJ6DpNNElYMenW5jSL5
	mOhS9z5DRyTMBBKCRzXZoM7igZK8wbk9RVVRCzxgVFm6Bdy0O3Jwh+evEq7JbLoXExA==
X-Received: by 2002:a63:be4d:: with SMTP id g13mr21651732pgo.378.1548715992926;
        Mon, 28 Jan 2019 14:53:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN51IAn6K51AkkxAaEbQIlFnO2E0KB4gs2c0XOdWqCKl47h3KaYccw7YZSYo0cjmboC3TSpA
X-Received: by 2002:a63:be4d:: with SMTP id g13mr21651700pgo.378.1548715992265;
        Mon, 28 Jan 2019 14:53:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548715992; cv=none;
        d=google.com; s=arc-20160816;
        b=EZIF2MxUMjhid23r2V1Lqfb7Cf/tm3ZkOhiW3sOAmyH4PLBFPOTpOcvKxtfhYrYDo9
         arLmIuho9tO1gYYcEP9SwYBpZqWZVvHO6jB2JFoIy5e8OHsk8qI6tJcnWrFgJdetNkBt
         DWuZt4MQ+0c6rttIaHwr7T38xjZlsGRMhfnq2h+h0uMTxSraOfxvKue+XprZDJVOQQHF
         VOsjbCsN/O3en/YdhMYY6yi7bWFFr2f0CoQm5vSdo4T7B3f6JrF8OXaHgtYQwUyllDpM
         UrvUKlLTaOQB71HieI5+vNXX+v9lTpa8u1r5vpYmSNaCaMBcLZLJVAmQc/igzxfgtVJH
         PvYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=9dDLESgUXGz1/oRJ38625V4OIxQ2B5iz0iK2T2wAMdQ=;
        b=jth/ykLC981Ax8NUc1cQ7hmlqFsuiXHa2NMi3/BZCJ2lsYlunKgekWCX5vdepK5gOQ
         R0iqAa3pYej64a45CUap+DRL9BP7lniGlEEYZxw5M0l5YvGVqgGiSu+p88V7aaSY1Ew5
         pRR2qaC1WjoVimaPgxX6CdueNUDFeGakuGa0PwXbvJrMpWtfHI9BhE4eWB9ds0SZEotn
         McbtrIXGnAN9OErzXr63lF8GlCGYuihdiR/CchFiD1Kd9uaHA29ATaxf3eA4QRzFDymN
         X/+Zvej6e3Zhn0MYDLO900vPjeTAj2tERwnO7mJjxdWNDqUooXcvygafpCyGuyTZTV+3
         DRhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u30si34643256pgn.170.2019.01.28.14.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 14:53:12 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 0A1EA1DFA;
	Mon, 28 Jan 2019 22:53:10 +0000 (UTC)
Date: Mon, 28 Jan 2019 14:53:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mhocko@suse.com
Subject: Re: [PATCH] mm,memory_hotplug: Fix scan_movable_pages for gigantic
 hugepages
Message-Id: <20190128145309.c7dcf075b469d6a54694327d@linux-foundation.org>
In-Reply-To: <20190125075830.6mqw2io4rwz7wxx5@d104.suse.de>
References: <20190122154407.18417-1-osalvador@suse.de>
	<5368e2b4-5aca-40dd-fe18-67d861a04a29@redhat.com>
	<20190125075830.6mqw2io4rwz7wxx5@d104.suse.de>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jan 2019 08:58:33 +0100 Oscar Salvador <osalvador@suse.de> wrote:

> On Wed, Jan 23, 2019 at 11:33:56AM +0100, David Hildenbrand wrote:
> > If you use {} for the else case, please also do so for the if case.
> 
> Diff on top:
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 25aee4f04a72..d5810e522b72 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1338,9 +1338,9 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  				struct page *head = compound_head(page);
>  
>  				if (hugepage_migration_supported(page_hstate(head)) &&
> -				    page_huge_active(head))
> +				    page_huge_active(head)) {
>  					return pfn;
> -				else {
> +				} else {
>  					unsigned long skip;
>  
>  					skip = (1 << compound_order(head)) - (page - head);
> 

The indenting is getting a bit deep also, so how about this?

static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
{
	unsigned long pfn;

	for (pfn = start; pfn < end; pfn++) {
		struct page *page, *head;
	
		if (!pfn_valid(pfn))
			continue;
		page = pfn_to_page(pfn);
		if (PageLRU(page))
			return pfn;
		if (__PageMovable(page))
			return pfn;

		if (!PageHuge(page))
			continue;
		head = compound_head(page);
		if (hugepage_migration_supported(page_hstate(head)) &&
		    page_huge_active(head)) {
			return pfn;
		} else {
			unsigned long skip;

			skip = (1 << compound_order(head)) - (page - head);
			pfn += skip - 1;
		}
	}
	return 0;
}


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mmmemory_hotplug-fix-scan_movable_pages-for-gigantic-hugepages-fix

fix brace layout, per David.  Also reduce indentation

Cc: Anthony Yznaga <anthony.yznaga@oracle.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory_hotplug.c |   38 ++++++++++++++++++++------------------
 1 file changed, 20 insertions(+), 18 deletions(-)

--- a/mm/memory_hotplug.c~mmmemory_hotplug-fix-scan_movable_pages-for-gigantic-hugepages-fix
+++ a/mm/memory_hotplug.c
@@ -1305,27 +1305,29 @@ int test_pages_in_a_zone(unsigned long s
 static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 {
 	unsigned long pfn;
-	struct page *page;
+
 	for (pfn = start; pfn < end; pfn++) {
-		if (pfn_valid(pfn)) {
-			page = pfn_to_page(pfn);
-			if (PageLRU(page))
-				return pfn;
-			if (__PageMovable(page))
-				return pfn;
-			if (PageHuge(page)) {
-				struct page *head = compound_head(page);
+		struct page *page, *head;
+	
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+		if (PageLRU(page))
+			return pfn;
+		if (__PageMovable(page))
+			return pfn;
 
-				if (hugepage_migration_supported(page_hstate(head)) &&
-				    page_huge_active(head))
-					return pfn;
-				else {
-					unsigned long skip;
+		if (!PageHuge(page))
+			continue;
+		head = compound_head(page);
+		if (hugepage_migration_supported(page_hstate(head)) &&
+		    page_huge_active(head)) {
+			return pfn;
+		} else {
+			unsigned long skip;
 
-					skip = (1 << compound_order(head)) - (page - head);
-					pfn += skip - 1;
-				}
-			}
+			skip = (1 << compound_order(head)) - (page - head);
+			pfn += skip - 1;
 		}
 	}
 	return 0;
_

