Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89DA4C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:39:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26DEA21773
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:39:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="c5T+9+7p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26DEA21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A29106B0003; Thu,  8 Aug 2019 19:39:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B2936B0006; Thu,  8 Aug 2019 19:39:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 803DB6B0007; Thu,  8 Aug 2019 19:39:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45B226B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:39:31 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id y7so9507598pgq.3
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:39:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HKy6T/4y7O4KVDTpv4sDG8G8UOMemkqEbKFUEPlGIKQ=;
        b=Zo4CZN7CE3nm87XqF+9lUdT0SaphjyUQp0wMPsHz0FS+K7Ok8np94ogdye6P2+p2ts
         9LukhHZl2UkEQtK67S6BhbMjUr1GSDOiR9fHDuZnNOI17XYM/2z8Wm2bskf4dFSxMKbD
         UV75cWiAFiRJMLL39Sk6q6+njconJmBhpffov5Z99FhngwkSybnMMgtRm3yDZdqLiv9d
         3PGXteRXM+341ufB2tm3Bi1OPrBavWplytnTNstNqzyRm6eRc3JYj4xBgX/T3vptNLfb
         qR4VVLrl6osylwKMK7EGkMgkN5/cWK5XnvcSuCDa+Esl26RgFwVq0g/gisz3JAP2thb/
         sk7A==
X-Gm-Message-State: APjAAAWmQEQ3QTxlyUP2ksLNymIctb19G8Q3irbtEcUpzIl7gp0EGsLE
	q2diEB2DiaO5Y6ut86FnHqK4uAiPSPLdcd4ktK86g3qBwXP/+1LdXcxXjtz04vgnymYfwsFGuoW
	JpAF7Q/v1EWYMqTlbsMwWiX2W0pPNL9U5Pxcil8M7wKx2GH638PugXeT1hytFai6qaQ==
X-Received: by 2002:a17:902:b789:: with SMTP id e9mr15858812pls.294.1565307570871;
        Thu, 08 Aug 2019 16:39:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWTPXyoqk6qohWGpG27/fEeSK6DEIvND60Vv8FaI4XguckFGfYVyLSA3oV579/wxUbh7TT
X-Received: by 2002:a17:902:b789:: with SMTP id e9mr15858786pls.294.1565307570185;
        Thu, 08 Aug 2019 16:39:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565307570; cv=none;
        d=google.com; s=arc-20160816;
        b=iDhWpr5JmOSB9yE555ZDCv+NN62pPv+Jw59yWAz1h33i6h9ZPObQOzXuaLJLalBvMq
         zErffa/V/v/8DEkSsTSp2gtCvHMdWf7chS23VqEbaAuaIta8ZXHeeHMVVsl+WvIBUQ7+
         4JKtVKRoiHEfXY80K9g+n8/Tf6QxcfznnYyX/IjzFjC6rnhUt2F2wZWQhc48QZVyOTec
         Y4IQS+6cJQ+/NNAi7rbIGofl6ztrNGXkB1gEe4V2Whj61JkuBiGqXuQanLGRuW0tK4Rc
         /DkUKe8MeBl89/JPp+fDKF1m5JFLlHUtOFnHF8SnTDwoWi7EtphAnD4SpCvAw/mRrp6h
         RksQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HKy6T/4y7O4KVDTpv4sDG8G8UOMemkqEbKFUEPlGIKQ=;
        b=M9SnMFIjSny6y+vSSMaaNcAmBqEgVDfZ6i2RESFeuRGlG799cB2iQe1CmBPg1zxdJK
         rQr7KHmMlt92O9uxnd5LsywKkYgOAbkfFY0Nq9BgGj7l0zs1w2+boVu2Tmsg7tHJffb9
         OlF9BFjA4di9+e7xD8uXtlK6nHems3sBz0NgsKL67DJRO2dFeJtOy3v4NksQYX6fRHPu
         4cIK7KIFefGMHM1BR+cLAnFL8qIBMIa4spT93NjHUvyXo/0zygaSe2mmgFvOywJfRQeI
         sJpymVBmJjBiPKP2rtPZfHktpBz1rhDtA1rcUkwIj5P02HpKGhy7gB0lSwxViNvfU9r7
         LTCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=c5T+9+7p;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w12si47677482plp.296.2019.08.08.16.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 16:39:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=c5T+9+7p;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 555262173E;
	Thu,  8 Aug 2019 23:39:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565307569;
	bh=DkAAejaivtf5zjkmcresyTQ54IwUXOKSGkqOhqPx9q8=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=c5T+9+7pTiq+M8+tRJnzWxAdk5YAAoix4royPR9zIimI3fX2zFgoXWpW/NMtliOdE
	 HiW9bJP2T3sY3hkPDdPCAiM0fDFC70VcHJa0tzJi7i4wi5fW6XgFKvPqJNQ4Rpij5r
	 Vj8g+vFbWO3xkgW88RwCDFXw9p4DZOq4QsHt+1PU=
Date: Thu, 8 Aug 2019 16:39:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, ltp@lists.linux.it, Li Wang
 <liwang@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Cyril
 Hrubis <chrubis@suse.cz>, xishi.qiuxishi@alibaba-inc.com
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race
 causing SIGBUS
Message-Id: <20190808163928.118f8da4f4289f7c51b8ffd4@linux-foundation.org>
In-Reply-To: <20190808185313.GG18351@dhcp22.suse.cz>
References: <20190808000533.7701-1-mike.kravetz@oracle.com>
	<20190808074607.GI11812@dhcp22.suse.cz>
	<20190808074736.GJ11812@dhcp22.suse.cz>
	<416ee59e-9ae8-f72d-1b26-4d3d31501330@oracle.com>
	<20190808185313.GG18351@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Aug 2019 20:53:13 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > https://lkml.org/lkml/2019/6/1/165
> > 
> > Ironic to find that commit message in a stable backport.
> > 
> > I'm happy to drop the Fixes tag.
> 
> No, please do not drop the Fixes tag. That is a very _useful_
> information. If the stable tree maintainers want to abuse it so be it.
> They are responsible for their tree. If you do not think this is a
> stable material then fine with me. I tend to agree but that doesn't mean
> that we should obfuscate Fixes.

Well, we're responsible for stable trees too.  And yes, I find it
irksome.  I/we evaluate *every* fix for -stable inclusion and if I/we
decide "no" then dangit, it should be backported.

Maybe we should introduce the Fixes-no-stable: tag.  That should get
their attention.

