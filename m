Return-Path: <SRS0=krm6=SB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2171EC43381
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 03:04:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A007B218A3
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 03:04:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="io1Nmw0t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A007B218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 059EC6B0003; Fri, 29 Mar 2019 23:04:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0097E6B0005; Fri, 29 Mar 2019 23:04:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3D276B0006; Fri, 29 Mar 2019 23:04:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A95036B0003
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 23:04:36 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s19so1957500plp.6
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 20:04:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=8n8kb/6mGjw/eVvVXT+iku29g9P/RMOgBPJAQ0CS9qw=;
        b=A/BfFvAl0x74/V2fiZz3SUUOnpDuZawZ6MyuX2FAtXrKrGwBbCCEW/R5G7pAVC8cQa
         hejTTCz9G4NMk+OHHkR+c8iKELWOxfYhVZ9HcMC5tMckbQMPSHiFY0t4uFvjWnv3To6O
         EDNuQSxoKpX+kM8LwvyIvv+vjc7kLfeg5aOSQZRrS78KD0vPyxJ3CRjU8HnodS1lusPP
         G1t+iMipwlwHbz2eb8Z4Xnfu0NrD3NRL7ulukeS/FV1QgGWSOberwWem244udx8k7Lwg
         WgtG9k93WGTjs9zZdSC+wiE5jQ08BHBGsviiGf1V/TNIohlwVmFiNjyI4hKfMqh0Ob5b
         PBag==
X-Gm-Message-State: APjAAAWFX2eD5/n4/TXGhhu4UNHXAtJ6ZJFfmlBmmw/YNp5sBL5eCT+M
	rejMc9o4LaHrRPiSZnrcwbBCTeCa8sFCwmoSJigofg00gQQ6su7NlSuWX5jMvBnc7l8Adz4LB7G
	8sOk0KFNRsQ74EtoD788l4I/TuTLKV6IsCGXaFXXQv0/koRMoM04JHVe1NJxGIU17ZA==
X-Received: by 2002:a63:1410:: with SMTP id u16mr47564839pgl.420.1553915076177;
        Fri, 29 Mar 2019 20:04:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuMhVqg+0yDF/bpC7O9Pd1iUh8O9LYztGzPg0pHR1BNvt2A4s7FNVVnQOiRp/qxuYujy86
X-Received: by 2002:a63:1410:: with SMTP id u16mr47564783pgl.420.1553915075301;
        Fri, 29 Mar 2019 20:04:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553915075; cv=none;
        d=google.com; s=arc-20160816;
        b=ZCcL17IYs5hE2rb3c7WaKY9JCRqqfrFmb2Wr5OASU2NfhMoGRhlOcIb8HW3Cfwtd8w
         gsDGeJY6t55RoEhHPZEOGCcyUBvqbYDbX6PGRFARBtBAAGSZRVxZg9o1xmaPz7nE3sp7
         Q+6fSM+bhA4UgANob+xTPHt+H7pUrWdj26c8OmkTzi6Oysh3tF9NvzSgz55hOv5b62K3
         l8yHvNRRHSoTB825oOVZgyHEyOvncfevYWD6Q6Qt+kYR2Yvk4iciCuj+35tDhmCu6NZJ
         CE9gkXwETrEKtyCHpQwh0ZP4HBX36f/09ffVCI5xEvioTNC2loOeAqh6qhZ7JglljOc/
         2lyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=8n8kb/6mGjw/eVvVXT+iku29g9P/RMOgBPJAQ0CS9qw=;
        b=UHsb3mGc0Nb3DRVOxbxPdx4Uer/uBNW7A3H29WIh3FMjJ/zSPRYMyODEPESTGXgMBf
         WI+eTqSXG8aOxsHWc1BLr8k4DU6BZpJV9GLotdmxx+9hKJk3qjuiwnymAcl1ZdhNO8Ds
         W6ygLZHOmAEmKvdKs0lzwrlyFwQt3e2rhpwuycew6Bjk8fof4WoEq5S2EUsCMJ5LnLIH
         Dyv+w3puFrfpbci5Cful/LLUcsydwNmuv4o1sdaYymsyf0kMPSpxzHk1X3MJtAumCU0X
         Uf8hOc86yccW1RxTRBe5LZFYdytapkLIdOvpO4CVmEUmvbTRaqbiC/wPO0p5RhCc8i3r
         2w1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=io1Nmw0t;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v3si3270875pga.209.2019.03.29.20.04.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 20:04:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=io1Nmw0t;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=8n8kb/6mGjw/eVvVXT+iku29g9P/RMOgBPJAQ0CS9qw=; b=io1Nmw0tOIU6GNl8D+L7G1DqLf
	trODHzX7DGzU8q3Llq+G79OJIuctnnIER2XBC5pmyR1ouxmVOFUwotFEA22/aFQ8t1lFlve6wqH8i
	s8Tq/3JGEwnlJ/Bh2fw5azMQHokp5sn9jUmfzVYMQs7XafiXhLNaum+4Ub7wiCNk3ZiLM0S/T9PNh
	XxKZMPF8tLUmMr+lns52ae9eaUPkH35s6cGzvj3DiaUaQ8OAj8BskUqG1B5Wed7tWQcxmd+pBOMTf
	LQLH6UH6XGt1Zb0EuyRCzcjKczAXVGSC39Ri4eiGVvyuKLVD5liWvYO2NkPUn584XpQ3ixZ9TX5Ah
	rJiqjPUA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hA4IK-0007p2-6V; Sat, 30 Mar 2019 03:04:32 +0000
Date: Fri, 29 Mar 2019 20:04:32 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190330030431.GX10344@bombadil.infradead.org>
References: <1553285568.26196.24.camel@lca.pw>
 <20190323033852.GC10344@bombadil.infradead.org>
 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
 <20190324020614.GD10344@bombadil.infradead.org>
 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
 <20190324030422.GE10344@bombadil.infradead.org>
 <d35bc0a3-07b7-f0ee-fdae-3d5c750a4421@lca.pw>
 <20190329195941.GW10344@bombadil.infradead.org>
 <1553894734.26196.30.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1553894734.26196.30.camel@lca.pw>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 05:25:34PM -0400, Qian Cai wrote:
> On Fri, 2019-03-29 at 12:59 -0700, Matthew Wilcox wrote:
> > Oh ... is it a race?
> > 
> > so CPU A does:
> > 
> > page = find_get_page(swap_address_space(entry), offset)
> >         page = find_subpage(page, offset);
> > trylock_page(page);
> > 
> > while CPU B does:
> > 
> > xa_lock_irq(&address_space->i_pages);
> > __delete_from_swap_cache(page, entry);
> >         xas_store(&xas, NULL);
> >         ClearPageSwapCache(page);
> > xa_unlock_irq(&address_space->i_pages);
> > 
> > and if the ClearPageSwapCache happens between the xas_load() and the
> > find_subpage(), we're stuffed.  CPU A has a reference to the page, but
> > not a lock, and find_get_page is running under RCU.
> > 
> > I suppose we could fix this by taking the i_pages xa_lock around the
> > call to find_get_pages().  If indeed, that's what this problem is.
> > Want to try this patch?
> 
> Confirmed. Well spotted!

Excellent!  I'm not comfortable with the rule that you have to be holding
the i_pages lock in order to call find_get_page() on a swap address_space.
How does this look to the various smart people who know far more about the
MM than I do?

The idea is to ensure that if this race does happen, the page will be
handled the same way as a pagecache page.  If __delete_from_swap_cache()
can be called while the page is still part of a VMA, then this patch
will break page_to_pgoff().  But I don't think that can happen ... ?

(also, is this the right memory barrier to use to ensure that the old
value of page->index cannot be observed if the PageSwapCache bit is
obseved as having been cleared?)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 2e15cc335966..a715efcf0991 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -165,13 +165,16 @@ void __delete_from_swap_cache(struct page *page, swp_entry_t entry)
 	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(PageWriteback(page), page);
 
+	page->index = idx;
+	smp_mb__before_atomic();
+	ClearPageSwapCache(page);
+
 	for (i = 0; i < nr; i++) {
 		void *entry = xas_store(&xas, NULL);
 		VM_BUG_ON_PAGE(entry != page, entry);
 		set_page_private(page + i, 0);
 		xas_next(&xas);
 	}
-	ClearPageSwapCache(page);
 	address_space->nrpages -= nr;
 	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
 	ADD_CACHE_INFO(del_total, nr);

