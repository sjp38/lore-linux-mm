Return-Path: <SRS0=MSKp=Q7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91394C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 11:41:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E5B720663
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 11:41:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IOkatBRQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E5B720663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73D628E015E; Sun, 24 Feb 2019 06:41:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C5DB8E015D; Sun, 24 Feb 2019 06:41:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58DAD8E015E; Sun, 24 Feb 2019 06:41:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25B3E8E015D
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 06:41:28 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id e4so5502824pfh.14
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 03:41:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kurBAzCOK3m5IGucKu0DWpuJ0RmeW0Ui+49xTU/hQEc=;
        b=SzNyoVmGxNWGENPkIy0Z5SRwK1H/Nypw0Aw6eAxgIAWk0HDP5zAj0lwE1T8LUbSbmL
         YJjOsre7G2dvYX/UU/DfLJhq3Q3uyum0s7xtRIy6pqj0u+L/2tiIVLKk1XtOlQlygftD
         s9Hypal48fydfKByouraMWYUpRlaw+sL39AbkW1rvzkNZyzT7VjJAQlp9DnzGbA3XCpt
         hD4gRwEnt6XX/vQKRQ6IAiJKcSbCu+UwsheDKlXaUsimRIuFxJqmKbr+LRBfp/HyxMnh
         iqW+O2PFstLbyyFKnVgxt++aF5PX6FhHLyXtVKwwP9orXovveNe8xMqoIOI1aA2PgP4g
         qPKA==
X-Gm-Message-State: AHQUAuamb4P8h8j4deNKeZS3PT0M8DBmBUXUp0CTGY9MZo0yaA4VvNBX
	YBu0JNWbI5SfqpdlsNQFHBKLftKcRafJr5yFYNXUqVK72WSO6XrD01tc4Wm9xaSf/zU3wE4zi9k
	NaawsXWCuSA3kgGYg8ra5EZS7F2RuYmO7e9rSWhbbADAi7SAlWG90cHWYhlgzyrMmLA==
X-Received: by 2002:a17:902:8f82:: with SMTP id z2mr13555023plo.163.1551008487701;
        Sun, 24 Feb 2019 03:41:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib380hYKLnWFW0mwR3TrT3pIyIRVwwcUlq7HMhD8Rn5HMPA788aIYvymd78DmMrjUsq5Pbq
X-Received: by 2002:a17:902:8f82:: with SMTP id z2mr13554984plo.163.1551008486971;
        Sun, 24 Feb 2019 03:41:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551008486; cv=none;
        d=google.com; s=arc-20160816;
        b=DNBrIYvSsBcnse8maxDMrPisE6pq/KFDS+tVY9E+g9w8t5lL2bkl60WMcCtDgESE4+
         7QojlR2aRC4fHKOJB5u/Q9A1jQUMIhPIMB5jj1dTTK0MgNQaDVkrIlT61q3PfHmZJP0x
         3gyBEDQDVn/E7oLndFCasXLu+SLne/FJPfpgUBOzvyrD8TCRsuBGp+cVXuD6m/6BSFdt
         RKLj1O5wHXOUiB01Naqe9VUMEIZHTd6qiuJScJmkdHZVNaYOOtZP90wRVuChL8D/9MQH
         Vt8PrGS6JvouvQRJYLWHuFdRUKn6YlzN0HpY3HUgSh11yr6u5j7Sx8sB1taMW7M2ocBk
         M9Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kurBAzCOK3m5IGucKu0DWpuJ0RmeW0Ui+49xTU/hQEc=;
        b=SsKDAJ77XE3dAyaKRpTpYJu6RaibBwsZM4B349VRch61TYIVgAeExdIdhU7O08ijDZ
         GbktoLPVacqtcRbd6hCEDw2G+yXqRwNY9WmxyWsPPqmdOqYbFT0atC/TwjShVa/Zg5+N
         9BZxRtaCSm4tKkVqvJukQFpWqmZ7rvxVYkUtyGxdW9aahSCHVGmD4Q6x2w520aJuklKS
         Q/xVMEo1zOMOhE3T5B0FsmRII8SzsphUp3X1jI6RL/5uA2niH1znmsAugy8SSffuUgiF
         2Vl3vqc+ZI2Mo63Q1ToYhMqSwd614DcQixH/4xvBp/UllsFK0lTdlxFRSo4eqzSSekMA
         M1Nw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IOkatBRQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id a143si6267447pfd.24.2019.02.24.03.41.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 24 Feb 2019 03:41:26 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IOkatBRQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=kurBAzCOK3m5IGucKu0DWpuJ0RmeW0Ui+49xTU/hQEc=; b=IOkatBRQIYT//uGu2Erw6DlMr
	9bPD3EaMl0Yk7KZTOS/9Cn/ez9I07jo2MsJF3Kx3X7KT3hMfsmaVVQPyK5U4NMLua9UUpB38KMCUL
	c7Pj4aYDYyLfEfseQ0MYEG8u0fL6wKbx/Kxza8ql6LzasQ7EVAOpevSHml69EPscazTLbvre0IZvi
	P1OEbmnKaUqfNgeCIVJXDiTOaEXr9TQrKl8SMeVkta048Mh9bV4hjnPNZlw7N/vCE6fgPc5fxfxsq
	a1cXCkVuc7ZcScjMiE4y6F4edKY/+xixa+FMh8scgtm2tgUu/3rFhqgE0FT08pqN4PlNldoYcjP3q
	VgxmPDSVw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gxs51-0007pN-1b; Sun, 24 Feb 2019 11:36:23 +0000
Date: Sun, 24 Feb 2019 03:36:22 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: arm@lists.fedoraproject.org, Maxime Ripard <maxime.ripard@bootlin.com>,
	Chen-Yu Tsai <wens@csie.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org, Florian Fainelli <f.fainelli@gmail.com>,
	filbar@centrum.cz
Subject: Re: Banana Pi-R1 stabil
Message-ID: <20190224113622.GF24889@bombadil.infradead.org>
References: <7b20af72-76ea-a7b1-9939-ca378dc0ed83@wiesinger.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7b20af72-76ea-a7b1-9939-ca378dc0ed83@wiesinger.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 24, 2019 at 09:04:57AM +0100, Gerhard Wiesinger wrote:
> I guess it has something to do with virtual memory.

No, it's a NULL pointer dereference in the voltage regulator code.
Nothing to do with virtual memory.

