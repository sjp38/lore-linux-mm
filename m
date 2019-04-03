Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76920C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:48:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33C6E206BA
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:48:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="aLGJ9mTd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33C6E206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D94C06B0010; Wed,  3 Apr 2019 11:48:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D42D76B0266; Wed,  3 Apr 2019 11:48:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0BA56B026A; Wed,  3 Apr 2019 11:48:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1F716B0010
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 11:48:43 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k13so17002716qtc.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 08:48:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
        b=AXFwPPdg6Dm1bdT+dr4DS83mQX9y/qQc18u4+yY6AoP485isAOvcx5H1wn3OflqGKG
         rxyIG7Zsvb21xPoq40mSfEP7RGs9NVu8pUYeZ2iTJtzbSXA/fgNw+fo7V38wiZKai0D9
         GlUAOS9ZsmqZiFUU1DOgJNzF1IOHfXOt0BXvQvVehwB7ZMl5z3rWPZmPyrraNAj0zlXt
         kj45no3Jw0Bm7Df2CQv2e/O5MSe4R/c/XM2wfXSTSLUwdCGAfHwurHA4uIvT32bjK3r0
         YuGkp7iqIYPojqeqJjjGB9qgBDoi3n3daLa3z27ZT+hGlNJrfsnYoutAiDS6QWLJ+DWJ
         QRxg==
X-Gm-Message-State: APjAAAVXlp/Dr+02n5Wp4gJptCrkVZVr7qrHzR5ZBwOoE9bF5gG1lgcf
	5CAHvkaBMD2vm09lBSBbrdvuawbEP/ZlroqCAshzx1JQWeuQANfuwoHEW0uOzChY9ttWxZUOgMc
	LRDNM014AMWhT9Yta5hfyAT6n+iJhy+SrTw03kOFWFG6gEqvBw/EojtsJtyOutms=
X-Received: by 2002:ac8:2195:: with SMTP id 21mr577662qty.182.1554306523479;
        Wed, 03 Apr 2019 08:48:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4bH6Et8McL/r79bvz3QAVZDQDa/Fq6DDWMTw1CyCIfvsvP0hS0J7aQHXpsQcCWsCwwPt1
X-Received: by 2002:ac8:2195:: with SMTP id 21mr577631qty.182.1554306522984;
        Wed, 03 Apr 2019 08:48:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554306522; cv=none;
        d=google.com; s=arc-20160816;
        b=0OK+a5XRvTD0yHQ6OnmDpvvFEdQV54ov/wkWEI/97xTALaVuI/GuFeN1MLbA7UWRax
         5SVuW1LxnpHv2Vss65LjxwGKUw6vsi6C6oW/F9uiQsjEIhKmfydErHwIlkf+OcFbUztN
         3xi5TuVN+asWelsrVMsB7XY1G/azT5urcwJoxfsUlQ6NZGB1VjR9f6zbIIRh5yTcQxkQ
         vtggi9yqxDgiBOMVPD3I4sZVh3C+LVtbr5Lpw5jgi9FBtU1ryY/D/r1bEYegjK1UdJc8
         ExrEaDp4/rbamNd1uijDQ1d+7EvpXDeOnh5eZoPkSubkXV1ljrRgCoFOcexpdnOLbFwC
         8Ipg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
        b=eT5jVHThh0y12hpHm0cM5aCw9SBNosSr88xg0yvnqZE7FIkAL98Nn4WmiU3WKcW8Ds
         i/ZoMB7yjyfwNuiNOWUxsY+Q/p6jAKse9d2yyT6Lp85YWCNghzSy0cFAOmKJ+oa2UeXR
         YNTPsizrwgEjjj9209vMQEyDIgk4JsdVE4B04IAKkbfCa7bZGLcuXgUFaFSgGMcOFGmJ
         fOnqnYPOSuxv/l3zs/aOh0uUw0Wak3hBlkHTsRQhdcazQ1BMzUJyfAuuOM/dGMcYgLES
         b4u8W15GciqH/8eUI03rYaPmq/2Fn+WbVxk5BURcQq70mDHGFGvoOmwt+QrwTG17oPJF
         4+gA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=aLGJ9mTd;
       spf=pass (google.com: domain of 01000169e3e35d91-7a8b7b63-dd87-4d0f-bcff-e7f1031abbe9-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=01000169e3e35d91-7a8b7b63-dd87-4d0f-bcff-e7f1031abbe9-000000@amazonses.com
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id k50si248955qtk.103.2019.04.03.08.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Apr 2019 08:48:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169e3e35d91-7a8b7b63-dd87-4d0f-bcff-e7f1031abbe9-000000@amazonses.com designates 54.240.9.34 as permitted sender) client-ip=54.240.9.34;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=aLGJ9mTd;
       spf=pass (google.com: domain of 01000169e3e35d91-7a8b7b63-dd87-4d0f-bcff-e7f1031abbe9-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=01000169e3e35d91-7a8b7b63-dd87-4d0f-bcff-e7f1031abbe9-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554306522;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
	b=aLGJ9mTdOIRbGejut86wsSoihvyWLiKCMoKGatxbO2GGbt0rgmrk1u/IZHSnOqaI
	9q6he+SwBYm0IBVF3FfhF0iw8p1u0huggAQh8Ajdj81qHKdVBq8aeZbCqixT6d+8hF5
	vRSMboQSBPUXNruZYO+UV7UfVgto6s/J40j8SZwo=
Date: Wed, 3 Apr 2019 15:48:42 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "Tobin C. Harding" <tobin@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 6/7] slab: Use slab_list instead of lru
In-Reply-To: <20190402230545.2929-7-tobin@kernel.org>
Message-ID: <01000169e3e35d91-7a8b7b63-dd87-4d0f-bcff-e7f1031abbe9-000000@email.amazonses.com>
References: <20190402230545.2929-1-tobin@kernel.org> <20190402230545.2929-7-tobin@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.03-54.240.9.34
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Acked-by: Christoph Lameter <cl@linux.com>


