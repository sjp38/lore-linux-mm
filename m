Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36AFEC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:07:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8CEC21904
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:07:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qYRV/s33"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8CEC21904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FA018E0038; Thu,  7 Feb 2019 10:07:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8638E0002; Thu,  7 Feb 2019 10:07:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 197788E0038; Thu,  7 Feb 2019 10:07:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C93248E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 10:07:53 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 202so102398pgb.6
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 07:07:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RvhgZZiNjrchkt8tGLRKuRoiHHJ2J8lC3cqTBJJMPdA=;
        b=BNzz5rj5YFYew5UpCna5dL1CQ4Nc7OU/R2Wh/xG1XbEemTUleHiXvEdcdbakjckbyA
         DAVo28o42Rr9rYUngQcueVG8g+AG05nIEesn71tvrVdGYXI8ti3RYMTw1fduZgH5Giv4
         G1NtYEv/zxdnoY+GZmcrbjiIbvWEA24sjM2yp8E4aPbwkYLkBO9TZnB+oTnfel7ntx3x
         NYIAKUZwDsl99RCSt3t/QR/VrNMxAUt+A2/qyqjdg/sydBrMb45DQcUt2U8e3iTw56x/
         vpIHtPQr9jndVRFIJOpA1SVlWAac60kMEmiM+TiDtXlymJkRvGnrrUK+T8ThIOyAU34d
         7ciQ==
X-Gm-Message-State: AHQUAuZM8EdiEWLuPes/ueIpQoJ+oHjySogpbHrJVIwf9w1+FXO8A3Kr
	PdLklhFITyEN4J9RMHs6xs+t3rFFRnWMpbN6k0IkH56ipOM+ChcUBhwyt7gJ5FQNEZ2pYa8YfKc
	avaHFrnR1dw8OKqNZXVO2NzwMdQxCzM1oe3XilN5V6H0ALX2dP138K3TVx76xZ0erqA==
X-Received: by 2002:aa7:8812:: with SMTP id c18mr1212477pfo.36.1549552073326;
        Thu, 07 Feb 2019 07:07:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaswvqCFvRs+Yv8ZkGtBmnZk6u8LYC1Ci535xhcYv2rlvIsjGBgTWQ+WTotaUW0RSybZGkm
X-Received: by 2002:aa7:8812:: with SMTP id c18mr1212407pfo.36.1549552072608;
        Thu, 07 Feb 2019 07:07:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549552072; cv=none;
        d=google.com; s=arc-20160816;
        b=Dkobg/6gtFsqUdf0ML7yWIDLdlh71hFfSH3R2yeoesBtbudZp5Mpc8fH/TXky3Vj4c
         5ORf0BWIPJ02BLakR0WwPE48728FBz3Sakv6JE0EYVhV3Z5sAK6RqSR/oLnVhNnp2/zm
         ZZN8/P2wffIjVAazQ6cWy3OwoIcjg/DQtsy5cC9PI4SBrq1XeUTq64N3wI8pyKcWeA7Q
         Pl+ZW0UDqgpkZmzaL6A8iiaFeciSGeNh8JO+cIj2ht3M6095vvQuU9ykhkTnJUgLY7Pj
         z9+HG1rNtT4WISglZskOTuXXfZWi0+wtTZWaWrtP0BeT8YnYwaajGsc9QpXVyWuqlgs0
         YRgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RvhgZZiNjrchkt8tGLRKuRoiHHJ2J8lC3cqTBJJMPdA=;
        b=QSyhCCX80TV7gMf+BCDsHVfHDB8m6PCVddfEvvcBPBsnYhCE2VDrTUZBxjJMKGhHQJ
         tUoRWWB5wsP+dfHKgFrHof1K1A8lwxgV+3OOos+e7PzKqsfxfFSl1NMu3SO46E8Ric7M
         2Zs3dR2+X0HHv1NJ/+EINPL3MUud5Vi/fhrVRwkdAdzYva8V/Kn54FapbZUG9wJHgZmi
         0sAlZsh+xfZX8dwN8FGSj2rFSgmctnZQ3kMIRmpBVHbxPsRRBbyo4SvLp+ObxvqH5rAq
         6kBWDlMe3PGwlS3PtY26o3nZztZrmkQCTl4rjRQVnDpD/ZBhtahyNsvb4m9X3MtkkXLg
         nbaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="qYRV/s33";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b70si9136577pfe.168.2019.02.07.07.07.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 07:07:52 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="qYRV/s33";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RvhgZZiNjrchkt8tGLRKuRoiHHJ2J8lC3cqTBJJMPdA=; b=qYRV/s33SwufxYIcTEcE1h2kd
	ymD3bMGIUxOVs94/eickTZ49U4nzaFa/BvA4nfGcrw26HRqvf7CrI2Ayrd64n0M7UTN1cNYZSz6B7
	iNgPD5fFRwAf3WsEgkBrL7WPsnDCa/R787rcZ6BxyF6okHZJLXWWcHK7X9o35yUev/lFXOmJKpUUM
	/C532myfmxX4mzicUD3t4r8VI5uH2oJ6U2YUPEkeBuDu/gezrAeLD6MD3vsazUEI9o0fSsC0vqb/1
	wk3Mg5p1+wf/ZASgQ/Ekw8oZxvKrIo+BFprAQ2XYgQWIOT+cDKZ6ThBscrGsBWW3R2rUqbLJmVhOU
	LnBL7BO0A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grlHF-0001NI-6e; Thu, 07 Feb 2019 15:07:45 +0000
Date: Thu, 7 Feb 2019 07:07:45 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Ilias Apalodimas <ilias.apalodimas@linaro.org>
Cc: brouer@redhat.com, tariqt@mellanox.com, toke@redhat.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	mgorman@techsingularity.net, linux-mm@kvack.org
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Message-ID: <20190207150745.GW21860@bombadil.infradead.org>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 04:36:36PM +0200, Ilias Apalodimas wrote:
> +/* Until we can update struct-page, have a shadow struct-page, that
> + * include our use-case
> + * Used to store retrieve dma addresses from network drivers.
> + * Never access this directly, use helper functions provided
> + * page_pool_get_dma_addr()
> + */

Huh?  Why not simply:

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..2495a93ad90c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -28,6 +28,10 @@ struct address_space;
 struct mem_cgroup;
 struct hmm;
 
+struct page_pool {
+       dma_addr_t dma_addr;
+};
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -77,6 +81,7 @@ struct page {
         * avoid collision and false-positive PageTail().
         */
        union {
+               struct page_pool pool;
                struct {        /* Page cache and anonymous pages */
                        /**
                         * @lru: Pageout list, eg. active_list protected by

