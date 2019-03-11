Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C31D3C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 15:09:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 804C12075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 15:09:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Bd7ZvUX2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 804C12075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 101788E0003; Mon, 11 Mar 2019 11:09:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B1E88E0002; Mon, 11 Mar 2019 11:09:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E944A8E0003; Mon, 11 Mar 2019 11:09:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A574A8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 11:09:50 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x23so6465809pfm.0
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 08:09:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WBXiJsth6ZRy4NnXvBEm40XbIfkraeDBimeU3qelFzU=;
        b=tgTlbMd84LXpPrj0ULa2e8vl954By6QYTV1BTfgIDqJsPfiy/fgmOoHlZQr1AEJq5s
         gUeIVESkAGxNwCEbrszBmWLkqlm7S7ZfJw861mCdYbrBdusJ6S0ZMG8BSQNm/2NGQ+/D
         VcwkBqU0v9phlbNMmPxqvO3OsewwsOiQdTJoU4gMeYVOX6EHbenhyXiMY1W1qmmiANm2
         hPYbImN8/BbVHtoox5AXbBya0TQJmpp9tP/x8G5374voBAnTJah4FMzRvDQL9bdFdzND
         V12PzYtVsaFUaKqfaxvZkpC/yga+mbenkqQl0orIcYES/gkYKOGnSOPtrpQRLSRF/4rn
         Gyhg==
X-Gm-Message-State: APjAAAXB+O0eTzWqACY56FPCQAC44hzhDffpt4fe7xSyI2KJX52IUQGi
	XFb5K37zkeDPWNeClDKRqwnwlI2F/GhSUakqoam79zmOik8uwxe4UeEP0OHL+GL7A6QrCBcWrxG
	jUE+ZyZhul+Dd30WKokwY7kcVtk1IAfexh+8sXqQccLUwc6m4uT4FjnI3N8WYCQamIg==
X-Received: by 2002:a17:902:b78c:: with SMTP id e12mr16919009pls.329.1552316990004;
        Mon, 11 Mar 2019 08:09:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyu/70iPW/hEvIzhjtALXK64RqsMabvBECCGPvCo0F3YsrOzLK6dv6pVa9vvXE2OqWTbkYM
X-Received: by 2002:a17:902:b78c:: with SMTP id e12mr16918912pls.329.1552316988642;
        Mon, 11 Mar 2019 08:09:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552316988; cv=none;
        d=google.com; s=arc-20160816;
        b=udUJ3qW1IGSWTHtKbY0wE7mrHvZyqYl66jV3Me6I2sYLa+YZtMAptWtNc+NyXuWmaL
         3Ts9PQycdqRs7skkx8osHSkTsMSu9Rse3tMxT9aY4Kw9y+YND4j+vuEkD7UXcmvW0A2S
         FLRladFPQ2NOnsyWo3SJ+EI8hcLUkDyUOxx2yX6is98EqDR7CSndh1RebwfRD/covmKa
         WV8qQ+qCmOnaxBGGmtcGuI0+BXyRHysCDKbXAkO9uyIGc5Bb9HSDo5P2SaFI1foVzev7
         q9jTqxCj2j/7jq572Bl8+OkXVeRlP4jyPsAv/hQT4kJBjdE/jI63Lt1HjFkL6rp3SNjr
         apvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WBXiJsth6ZRy4NnXvBEm40XbIfkraeDBimeU3qelFzU=;
        b=hMofhXd+GU0m7NcuIgeuWcC/hKMFZBXroHqVKevD2sJKkkmO3YQZ7i95wu0JhHOkZ+
         /s6JHLixH5zJYJaaEwc/y74BtqIw3RGIDDiEdnHndwttb6aXXra95KMMHGgOt+ZPPWl9
         W5v59WCUwlwc4DpOLMEcYStp58xEY9WqPxsrlj+yaRtaxEiKwv3c1fNu32Swc0gEg+1Y
         GhQxqVZ8w6cnLFiWnLOQFfcTT7HYPiVS3YnX3FOYl3tBH0eFkoDqNT7qZri50bN+I2IR
         QYqKOxNwliB4AXkzFSGFDlUnrbvwZP12MK/mq+A87Ca8rAM5rgzMeG+yeSEgCW+Nq8JM
         QVOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Bd7ZvUX2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g5si5180681pfi.60.2019.03.11.08.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 08:09:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Bd7ZvUX2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=WBXiJsth6ZRy4NnXvBEm40XbIfkraeDBimeU3qelFzU=; b=Bd7ZvUX2y4PxO1EIn4KySo+3Q
	eteJtV//cZGYPMH5OL5vGuOHVk9+SgU3zPSwU8836Bm/mfFWELjsiXId8ieTyy8jekyQHhdHCXuWe
	T1fHnDzr+SPYy6FKgsl6iOHGPcqIzi3M15vR+pXmHKq1wrd5zauFP2NPlDHWh/aHXG76TSECdxVmN
	30Z8Q8fRb+EY74Ol1rHXThvErA62J1HtwmWP416mwOl0ChWxJRi6UFB7k6sl2TVqPmijGljMRBhmR
	xRbcDeOZAXzRWzfGf+RHWt4CeLySYB4CAGMVJQZM21TWtDfg3CwcxtyG08bk7GRlNbY/WwLbwuZ0B
	BnwtoY5mA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h3MYl-0004UM-Ib; Mon, 11 Mar 2019 15:09:47 +0000
Date: Mon, 11 Mar 2019 08:09:47 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	"Barror, Robert" <robert.barror@intel.com>
Subject: Re: Hang / zombie process from Xarray page-fault conversion
 (bisected)
Message-ID: <20190311150947.GD19508@bombadil.infradead.org>
References: <CAPcyv4hwHpX-MkUEqxwdTj7wCCZCN4RV-L4jsnuwLGyL_UEG4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hwHpX-MkUEqxwdTj7wCCZCN4RV-L4jsnuwLGyL_UEG4A@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 10:16:17PM -0800, Dan Williams wrote:
> Hi Willy,
> 
> We're seeing a case where RocksDB hangs and becomes defunct when
> trying to kill the process. v4.19 succeeds and v4.20 fails. Robert was
> able to bisect this to commit b15cd800682f "dax: Convert page fault
> handlers to XArray".
> 
> I see some direct usage of xa_index and wonder if there are some more
> pmd fixups to do?
> 
> Other thoughts?

I don't see why killing a process would have much to do with PMD
misalignment.  The symptoms (hanging on a signal) smell much more like
leaving a locked entry in the tree.  Is this easy to reproduce?  Can you
get /proc/$pid/stack for a hung task?

