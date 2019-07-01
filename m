Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F796C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 15:18:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC0A8206A3
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 15:18:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZMRbdM6e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC0A8206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F4876B0003; Mon,  1 Jul 2019 11:18:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A5728E0003; Mon,  1 Jul 2019 11:18:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BB0B8E0002; Mon,  1 Jul 2019 11:18:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f205.google.com (mail-pf1-f205.google.com [209.85.210.205])
	by kanga.kvack.org (Postfix) with ESMTP id CAC686B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 11:18:50 -0400 (EDT)
Received: by mail-pf1-f205.google.com with SMTP id y5so8978390pfb.20
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 08:18:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=u8Ydyg4ThM0wZoBNokarC4fhtypB6gh7eVSA4X7ZgvI=;
        b=W89eDogU8FjkXuQia982M6US7kLQira0jDfQpwOPGbyNbnLPqolWNdZ1xIMzVXCpsX
         Da2OvJu97ZQ1Cf+dTrgII4X53RDX3nju9ZaYWpfutIyuNV4ZY98QVlXnw6p2R6dE1s8V
         lWp8SZv2rtCnC7MW/ZevAerwSgXcp8VdNSS7Sk9UG4TLbnfMiVNBO7NZ9EvKgFJoe96r
         1BXP62mApOsNduokRRVQ02tyEqIiwlZ2wKV3MnL3R8z/XkpQA2NR9a3z4m5DdUXwNjvW
         ds617LzPYzjwTrFb3OOjGTvlTdvwWXuXMw4FF/K15GWBF9/lTrmstH7t+tlNJQwHSHEf
         jVZw==
X-Gm-Message-State: APjAAAUkVzTX8Pt2xMAfp98N6y5S3cXV0T0QGuLfwi0xUEybYxi32IU3
	KC0JkKocDl1opLI+g8UVw5YKOeBVzRpH8swWaqduOWOqB88MJs6IW/E0hgmlHD8d8ViYxgSMSoC
	Ci22ufJKp6uxQAmjK3qGHQkX/yz2iVbvKzJhAPSvSDMwH3W7yyuft7mYXk4yGx0A=
X-Received: by 2002:a17:902:106:: with SMTP id 6mr30236916plb.64.1561994330322;
        Mon, 01 Jul 2019 08:18:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0knES54B0brlJ4b5YvNqv09zD2N2M6vHtEh6W+5BsNeg/IDkTDE+dsoCu3DjO+HiP2Tbh
X-Received: by 2002:a17:902:106:: with SMTP id 6mr30236850plb.64.1561994329454;
        Mon, 01 Jul 2019 08:18:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561994329; cv=none;
        d=google.com; s=arc-20160816;
        b=1LlI+1SFfbOLvhLO01u6kIVB5wCR+FLn733RgLp4j4gSMmXn5HANBoJ8tcXRGgeNXW
         76+gGgr1KWXd+NPqCcvjYx9DkfKmnBt3HyVQ7cIKmthpLP/LHtJ+IMTWrh00muDhVcS0
         M+DF4p4zR48waiee9Xns0V88lbbt/b/ZVKoR7E9l/+NyZiGp9EMz0w3jQ6RSleYo2tTg
         vtqT1iX5cO0pGIvucm35K6UzI8wc5hKONhpS3VpeUtSwgmju2Hafxnvk8lVyvkYY/Jhv
         QiYbqxLTSpY86tnZmMh/vSILLcVQrxkSppXz87e3ubhe9Q1l62bljX73mb81jXPfDFOA
         1Hhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=u8Ydyg4ThM0wZoBNokarC4fhtypB6gh7eVSA4X7ZgvI=;
        b=hz04nXtiKwQs5MdDSucGAev5M5J29NedYm0LWOpEWWJCuSNHimt755zZUGn8WQPelk
         k9cV1IrnzAwdvCpJ+9WzqYaZWw0q9GRew2+DvIKfxu6nnSQagVYEJkVxvwFz9TexQRzX
         0H28bcqA4Hqkuk3OmcphxP9AAU9iFAu2Ce3vLaVzw0aWiqM8hey3lI072IEz6DKj0D8d
         QNk7UzotnRhjuoZ/BrB2tIlMmM2U29tBKM3AWh4CCDfVBrU9yPBxTm198pNtF9yqHz9U
         UBeODwOcUbOPkS/ajVYhKg+C4YLR6EfG2fupUHKU/8wMmquugU3+PdLDDUIkSUHgEPX1
         f35A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZMRbdM6e;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t135si12002847pfc.251.2019.07.01.08.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 01 Jul 2019 08:18:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZMRbdM6e;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=u8Ydyg4ThM0wZoBNokarC4fhtypB6gh7eVSA4X7ZgvI=; b=ZMRbdM6eOD9DM9nl6ih789M+y
	/weD9Lv7MDAu/CkQxbpv6QZnMuIyETVExshi+1qmnmnaTXdmHMSrlLoIXuaO7l0dnM4tD4+VfHeov
	AZK1HKJTguGVTdeXg8LvmaNayitxSZjnDL+h+Hl/eBzxAClHClYV+1lrcnrioPqf04ucw5hIc0gMP
	7bbnXDhHd+WL/tYi3+f46y24jlftwmt0AoqQzjccriLZLGt7l0YjsbrMfsc4k65raCANyn6stx65w
	eK/FAwcqvNmmPGNbv661FRa6YFXNZW+8nAQgUPqATFtFbUOFkFcGoGezQh/jUAQjtMBJLL/XVj+SV
	5qSjmlCFg==;
Received: from [38.98.37.141] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhy4Z-0003oc-HJ; Mon, 01 Jul 2019 15:18:28 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>
Cc: linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: generic gup fixups
Date: Mon,  1 Jul 2019 17:18:16 +0200
Message-Id: <20190701151818.32227-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000065, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

below two fixups for the generic GUP series, as reported by Guenter.

