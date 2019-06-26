Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAA1AC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 07:58:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 750882133F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 07:58:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oXeJYZx8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 750882133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 125A38E0003; Wed, 26 Jun 2019 03:58:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D6598E0002; Wed, 26 Jun 2019 03:58:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE1038E0003; Wed, 26 Jun 2019 03:58:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4E878E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 03:58:33 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id r7so959254plo.6
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 00:58:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wk3gTV2rxOUxzK6dYo6NPW/evlC+KmzGL/BklH8DVGI=;
        b=qjHXSsGy/cJAYLi8LbbdB4O4z518T8WN6xG61N83V8bp6dMjdGPstYsD2uqehkj7fR
         GgREOKLu4QfaJTYPX0Nvy+9hUZfXsWmhvh+OrpNvk/LiWFDlQ9AwoTbB1DzUSr8LGxnJ
         ekiLmd55zBeO3i0zBDdBTQPsFY4JwsIKS/J5iRFnkauypJysQwEpnmLAPDBpJ20HHv5H
         3V2QH7Ei8gpeHNIsTZGaMv0xiPB0Z91kbgwly+T8XGLWhGAwfuYywsLVgVQvcWW3zKoS
         QKzkjsSrOVvaVdG9ZWEeMZjXp3jdq2b9L4U0ocAfM/UcXg3gy2OTdsVvsmSa/zat8N55
         qZEg==
X-Gm-Message-State: APjAAAXAz2GWARzsa+ykycEnUNcFoM+Gtm2EsSQhLKS1fIjONuL69MO+
	E0BkBM6caFFXms+e28G37zGrvkDtRfid42+auaWgzMfI1oNm7DzZQEWoJF0biqwhnYds40KqHK/
	OvMreZGkCvFtZEYECQSE68EyoWcvEea8tv2gQAHcV/jvyQUt7yeBuwZg77bCOYgh1hw==
X-Received: by 2002:a17:90a:2023:: with SMTP id n32mr3007122pjc.3.1561535913266;
        Wed, 26 Jun 2019 00:58:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwZpXVr2LP+gXlVqaZcUhIyXadQFDNBGNcdrcIhZJq4NhDAGxkKJjKC4tvxl4PR6qDwEN8
X-Received: by 2002:a17:90a:2023:: with SMTP id n32mr3007070pjc.3.1561535912606;
        Wed, 26 Jun 2019 00:58:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561535912; cv=none;
        d=google.com; s=arc-20160816;
        b=yAOYMjgxTsrLk2gRxz5j775NT7hVZNwRJ2imhpDkBVty1kQImDE8G18UT/NDdhNixw
         JXo1NLKEYeGuQl4mA2Inh5+m/2NH5eXJnZot/tYmpp6JV5imvrdifLHTl0Nn4dh9HOz7
         CTBsn62RdMuXOoauhApXLV/5ixybse491+VonN4PlJ46HVV34PuZYXgi2K50lV+rXE1H
         U+0gPGdYkKjAaJoh3txFYwaxcQTDlbAHP/VEwQRu1NoRDA/WdGjz15CaqJtgji26WFZl
         2PuBVvz/BQ8gcCX0LD+odS8srzJSjlYHUdHGdRzwONai8n6h3e6htgqAEVI7nrtUyCW1
         73CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wk3gTV2rxOUxzK6dYo6NPW/evlC+KmzGL/BklH8DVGI=;
        b=jMDFeO6gsyE1oX9TlrDh/L0zp7h642n2+6ESu6/s+mC1Lv+x8nRcxXrfDHtE5qWrJM
         Q4jZFObMxNRPNPEY3ISFtOFcOmCHIdaEQQ23P7F8O23CWTdBDw6QPlEQQu5CcjC7/iv7
         n1RQbxCFjV6aWrYa3RyhTfFFU8aqW42r6fJh8vpELElYUEZd3zd0YVvhjs7LwuAQpxdc
         Qw4ZWpt/ZXhEn6rcEJYVPnTkTYsv+5pgD2a5437DIDkyuTNSaftR8FDoR1dxjqybu3CT
         zsY9uBzufqSjJ7J9y/bhxRn1kXaA8Q83emWl2lWsmDfhmElWC30BggAaR9PgF3LYEt+N
         IhqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oXeJYZx8;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q125si15606058pgq.483.2019.06.26.00.58.32
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 00:58:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oXeJYZx8;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=wk3gTV2rxOUxzK6dYo6NPW/evlC+KmzGL/BklH8DVGI=; b=oXeJYZx84PoEDtYajsGmQzn39
	xi9TIEcA8hiu2D5oFu9mbD1PgsbVdgRnAOLsgOnh1Gxe4tPvZxOHCu8mXty01blDpfv3jUECQtMvl
	XeZpFefr4u+CYnn5ZBMMQJ7x7j2t06Z3FBAEUv0klRe0pjqbEImOdN2RQrj84aSAOL02chEbh8NfQ
	8rJVk5VUinGHxU9zF5JXtwxjfsFdK9OfURrkjt8japaN5G0VqyRJeB29xmRkNw4p9sGWyQCBri8Aj
	qqWS9CtcR4C0yi0q96eWQHvehJ1kKps51KJb+zlrtdYv5tzdNXYyx7tpPTSstvXlwqKZ3sh8hNENn
	EuNRJTulQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hg2oT-0006vL-19; Wed, 26 Jun 2019 07:57:53 +0000
Date: Wed, 26 Jun 2019 00:57:53 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Alastair D'Silva <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 0/3] mm: Cleanup & allow modules to hotplug memory
Message-ID: <20190626075753.GA24711@infradead.org>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626061124.16013-1-alastair@au1.ibm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 04:11:20PM +1000, Alastair D'Silva wrote:
>   - Drop mm/hotplug: export try_online_node
>         (not necessary)

With this the subject line of the cover letter seems incorrect now :)

