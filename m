Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0447CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:16:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2CB22085A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:16:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KJ4n1fsC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2CB22085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F1286B0003; Sun, 17 Mar 2019 20:16:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 479156B0006; Sun, 17 Mar 2019 20:16:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31BA86B0007; Sun, 17 Mar 2019 20:16:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F76B6B0003
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 20:16:41 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id k5so12417200ioh.13
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 17:16:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:from:subject:message-id
         :date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=PNC+yOc9qLOR+abq/u69TbFgVOPDMoWfP8uSYfFe5f4=;
        b=YI8t2XgaIEVLx/SdGg8wACY/FBHSWaKr5+kRH9VhNjE9wGHxV657Detl1/0fGtBr7a
         8zPaLScYxrSqHjxVbTaMxLbmVcJkFQwlC46JVgHaTH5lwnxMPX6wmMo748jOLqeeG/F5
         tweJnPnVN3nq3fZSkWAKt0xD7sDEE5MN4AnaZ6girFXZPMWxdDj/dHZlBPlk3uNjoJng
         OexVgUx8HzQQAGklqmxRIzmOdiUX+8sAAdPbvOIKL3t6tZytR+1Int5v1BvvuJ/+tl4S
         xjWh5fdreGmxt31T+0TZpQLHspPKX48/BiJpNtu7JIsUtRF4lKK0qYYH0banw5+l6WE7
         elsw==
X-Gm-Message-State: APjAAAWnrJg8b3+D0kzHoc0pmFjoh7GIfS2A7l8VFZ7JCV1neP+bIIWC
	veiGKJ9xnWkehd5SxwG2N9g5qNaB1xJM5pV0/lFonT5w5kjTVNQd9IyOUDyz/n2qjdxAdkSboXj
	Vi+G7sT0H9D8+QfCCmyRwPMMVjL6VLswVPQGHY9SQOrautymITHF7rdmjjnzlKMRVmQ==
X-Received: by 2002:a24:a50c:: with SMTP id k12mr2254137itf.6.1552868200758;
        Sun, 17 Mar 2019 17:16:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzL32Nj8ehKYuIuP/q+ZlMGfDbeGAgHK6JiQ5UvO40EPS9h+swM4emV8/WS6zaEmctXJ3V9
X-Received: by 2002:a24:a50c:: with SMTP id k12mr2254103itf.6.1552868199817;
        Sun, 17 Mar 2019 17:16:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552868199; cv=none;
        d=google.com; s=arc-20160816;
        b=L3Fib2yf/Ll5IDuejxbbFVNbgrSH6lki/+44SYCi7BVzxssmayUdx51m28u4b6gcyQ
         /jDw+3bMcYI1gV0RpzBdoDFpeZmbFMNAAzMHLqbAYfRFgd+QkA1YSvFwu6AC33eMT7NJ
         g6Nbcy1hNJew3h0sLKOeFyWx5YQ6Z7Ejj/eKwlbtX1iQKyiHs7GGQpYAcuyemMw5ShCR
         ammnV+oonEAxHOMlkVUQyVl3CfB8ct+r22fHMPdMx4jKYGZ9W8ftCZBc5PWCo7vnweWZ
         Hygt/fqRMOOzPoFh1X+PrwZSzNM77ANBVgrahVCYThU7QR0oCdPOyD/4h5pxmA7k9zkn
         D67Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:cc:to:dkim-signature;
        bh=PNC+yOc9qLOR+abq/u69TbFgVOPDMoWfP8uSYfFe5f4=;
        b=1KvcDXKWtERRAk0h/u6LkPCPiXjmWAje14oEpHFKomoLOSN++cbgUsR2s20bJmaQ9k
         sjQkLDWpMkM3R4paAM78HWRnx0dXQSQDTFH67OOsUzw7IRIQpfuTLLkHPDYM972Q6Q0e
         HrQSJVP6aBTpCttap6gI0yKpmmhe1n5410YE3ZaWcD8tTkbP07lqGvZFRanh3lVKjx++
         CxjXGTi60lY/ttQ61wNk7+oFalWnbvXj4D900RXIbwxa7MtxocnD8vXki9iKiA8mZmuW
         k5ep7jceB8o03xX1eincWE76J5d9OHypgpAV0kzM6vfcZgvUGSz6JvfjKHa14chPOf33
         M5Nw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=KJ4n1fsC;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id v193si4553586itv.111.2019.03.17.17.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Mar 2019 17:16:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=KJ4n1fsC;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Date:Message-ID:Subject:From:Cc:To:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=PNC+yOc9qLOR+abq/u69TbFgVOPDMoWfP8uSYfFe5f4=; b=KJ4n1fsCdjTUR/uoQWKyabs8Qa
	phJbX/V/Emq7X6qBpclFx5gSE1lpIYY3TVVeyOdN5xC/qvEjxexpveFXqbPg7bZ3psI+01XFVjZa1
	Wh03Y7EW/3BzM3I6uOD/2gmyDS3YccPDGK0qdMcg6SSv4s6IxUeJuS4dxukanp1TFfXHc32QCsQNR
	ainDgqos5S+ekUe6Bx5IKbJsmxtud/bBoyhoKjxbgbuhjHLU7rtsLoM3kasC688EYbYsJ5wYfnkdK
	b60QmcZL0/RjKUcI7Tr4eAYY8aV69dlYd4m21WZyW92gMka0oOF3mv2VpAwqJotBNLkGElatye5DN
	n29vj33w==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h5fx7-00061D-BU; Mon, 18 Mar 2019 00:16:29 +0000
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
 "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] list.h: fix list_is_first() kernel-doc
Message-ID: <ddce8b80-9a8a-d52d-3546-87b2211c089a@infradead.org>
Date: Sun, 17 Mar 2019 17:16:26 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix typo of kernel-doc parameter notation (there should be
no space between '@' and the parameter name).

Also fixes bogus kernel-doc notation output formatting.

Fixes: 70b44595eafe9 ("mm, compaction: use free lists to quickly locate a migration source")

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/list.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-51-rc1.orig/include/linux/list.h
+++ lnx-51-rc1/include/linux/list.h
@@ -207,7 +207,7 @@ static inline void list_bulk_move_tail(s
 }
 
 /**
- * list_is_first -- tests whether @ list is the first entry in list @head
+ * list_is_first -- tests whether @list is the first entry in list @head
  * @list: the entry to test
  * @head: the head of the list
  */


