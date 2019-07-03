Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7E5BC06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 12:24:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F897218A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 12:24:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UDoIDDID"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F897218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 275686B0003; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 226E58E0003; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EE258E0001; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD6D96B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 08:24:03 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i13so1537011pgq.3
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 05:24:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=UgSdS+LcNa3zwD10AD2JimuZLbxV3TtpHzyJ+/tBrVk=;
        b=RGdH/dc1osker3GxnxfIdoZE09e0lmUnGXX8zI7gtwoOIRZRhSK5HoOvItSikHw1tD
         UZPiCBZVyI9mC3G2wMKsDHHTt9AxzFlTBvfIqlWgAjkoT+FdmYp/ktPmol1ZvOllcKBm
         aNSjrQkTOgylvsPz16ICj6ZpZnN8nh1EzldkyqkDblVgYHIbicTD0zht+puA37tneOEQ
         HP+BsTGwlJSkQYzW/2BBmtbnKOPSt2EbkiqxAxP0WdjvtmgAKe8F+fGkV9xYToUw6uba
         8kBvYlXW7X3DwymoORgt8IJI8GawrkFOfVVca3tHMe9cCtGrECu98v/gFQYMdbH4YuEj
         KB2Q==
X-Gm-Message-State: APjAAAVJsNYNruWOwwv7w+/8jchdNDmeJ3py9c7vpyk9lBI1eXqiqXkL
	6J3oWYDZ2ioZMtHZ/MGZO9a1SNdBWLBcqmkUh70EaUL1hE6U22W7QPtH8t2ujs1sEYfrB9pWMYm
	7+VuPknr2PHhT3l+VlWdXAtVHjrPQhNa1lHRxYzswUUnsD08kQ7buTKgJyzo5wZM=
X-Received: by 2002:a17:90a:fa07:: with SMTP id cm7mr12615615pjb.115.1562156643594;
        Wed, 03 Jul 2019 05:24:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0b7a7KUZPUvFCvJu3B/9IYClqFmQwqXPwcm9yWPvnDPqtjXxjKNOJo/vLnTWHOi85E4ya
X-Received: by 2002:a17:90a:fa07:: with SMTP id cm7mr12615526pjb.115.1562156642775;
        Wed, 03 Jul 2019 05:24:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562156642; cv=none;
        d=google.com; s=arc-20160816;
        b=K40mIWcxir7cND6ikPsVK7Qu1qVWwRJXo65xvsIjFX5LwTdZd5hsGhBq76nglwZWF3
         HwMg9oOK0GIv7MpACW9mEldlRjD0FM7psbx1Wf7fzAvZJFAvDIy8vYlRKA7fr12IpZ0+
         6Vs3Ljs9xpCwLoj67we97g+LMr5Ln7m6RCcaTdTqParnC7aDq2pYQZWgbWB4hJqfDBy2
         IwrRK2BppIaIkPm9gU5Q4c7JOWHDPeh0mK+n/HK05rblhjZv6F1PlAlVlZlXvVCaiTNB
         fwGuGpUhIWPYh2cBBFJl0B9XuAcEQe5nXpYmMvNWkUwWKmcqPruJ8dg4TxqxWjiXVb2k
         JqHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=UgSdS+LcNa3zwD10AD2JimuZLbxV3TtpHzyJ+/tBrVk=;
        b=BwZuMLAWvMPSdI9jwJneRMrpLqSw9tC29AnpfOr/uNDWV7VRGozQ4OPI/sUvQ/+X+S
         HwFJKQa/085cmNCFpP7LXyBvAJzcW+ZPSZ9lFC3GOqezZhOdDm7YmOZ3roIb1mkA52Cg
         MoqBvCiNhOqQiGLhrtLUIg4uTfbVg6H23TNo7fI6lMOIrZJRwcpcMGNPMqF1kOCL/TuL
         ZT1dfPf35aUqF/5Bbp5MVDtJbM6RLN9e+VvSOg0LxHoX4QGvQqoDy7ouW5kS1Vb0f3uf
         k8zEIE7qO4vvSRco0+XhMLZuWBKSvKKZnpajix0z0TpEcu7fS6FHzoPzNVZ+JCQ99xuu
         yapg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UDoIDDID;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f12si2197476pfn.98.2019.07.03.05.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 05:24:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UDoIDDID;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=UgSdS+LcNa3zwD10AD2JimuZLbxV3TtpHzyJ+/tBrVk=; b=UDoIDDIDp27kYD+vUzj+WOd/x
	qA/af8OpWKGlaG58JedwTfNudNtn79jCIY3ilgnX5Zoc2AhrEgKGkFUxN7hpDJ9fIDXLqAvKpfHYl
	HAGdBt/1N800dvMubfmU101bRoVW9PA09hLi/fQ8ZqRdnfpW96fOXfL4Xi+Rf75jnVUVn2etspIFA
	j6Oct+3Crt6la+yx0SC6VTJLvHrf0BVjEf7e7ya3u9yxx2Je9wIUbzFv8kIPBIFoWlT1DkW4lDakS
	uq5EizvrixbNEnUKfqoTsOzemLLaiG3b29Woeij+b45ivwS5VUDT7+0g9asYMNQYsdHVtJ/6mEgXV
	U5VlSE2FQ==;
Received: from [12.46.110.2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hieIp-0002Fj-EV; Wed, 03 Jul 2019 12:23:59 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-riscv@lists.infradead.org,
	linux-arch@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: nommu fixups
Date: Wed,  3 Jul 2019 05:23:56 -0700
Message-Id: <20190703122359.18200-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

the patches are fixups developed for the RISC-V nommu port.  Can you
queue them up in -mm?

