Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04696C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:34:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B48052081B
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:34:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="UQuiyrvd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B48052081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36B736B0008; Tue, 10 Sep 2019 05:34:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31CB26B000C; Tue, 10 Sep 2019 05:34:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 233106B000D; Tue, 10 Sep 2019 05:34:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0208.hostedemail.com [216.40.44.208])
	by kanga.kvack.org (Postfix) with ESMTP id 045086B0008
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:33:59 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A30A3180AD802
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:33:59 +0000 (UTC)
X-FDA: 75918499398.27.bat67_5b59ef017a1f
X-HE-Tag: bat67_5b59ef017a1f
X-Filterd-Recvd-Size: 4274
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:33:59 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id p2so15215413edx.11
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 02:33:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DX6nBH3yNst1ZU2NEzhckyn0QlyA4jPkREPOFCTWGVk=;
        b=UQuiyrvd4QKCVHm0tdq6Zg2xKvaPRBN4RpPR7Uk2rghD63TaoUYBNjlC60KPkBiDZq
         MXDU9wKk87AGaek5IkGaD27NJM0tYGWNgy8o9dvtsocZSW1TNG0iFJGx3YFhIs5RhXr0
         Tk1oeOMs5UR+AccdOgEpeTRCqzIvQrpcwl1x22QVDT5LlzY/qCh5f7zLId5tquo2t+Ts
         tRMeMiP/vL2WrmNSP4Bids5NuJnR/EuduOESVGZ2E4M6xqTuy3psOhy/fdiLUwqpsTQO
         mYCopm/02blZ+8vWxV851uIamyEnyNaUL7JxzOZ4a4RFmfJyjnflPY9TJEKjHE2Qvxk4
         HX0A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=DX6nBH3yNst1ZU2NEzhckyn0QlyA4jPkREPOFCTWGVk=;
        b=rgx2y1F884GdDusXnvvwojHixYQsyYExi7MP6ydc2yP1K8ScXpLDlJkMNE5ixfHQNf
         8kCHUHw2JDNSabRGF/rkHXmRGo5NiPa7Yv4mKBB8fRIDFmx2sYNu4EwDJOJB7IxqxNtf
         OIIIpx9kFlCmZxOgLFUN3rM81/sBB3revOMoRkiUqgP+QphYlvnoAIi4kbCBwiQFfzcc
         +hvqUPaxifZ1jHCb1LlxrGSfXUzYBAdKdoGosxvZYZpUnoK8ytaxwggHXlhZPm4YDvV0
         WilHxd90SDkOpdoHP47BsbdXHJdf57in6Lvnm2YIIkX/AMwWQUi/O2vk52iwNzpm64BS
         XR9A==
X-Gm-Message-State: APjAAAXk4XjPZE26TE2+G9YxmMaIWfi5tQDxj0D8F88Xi63kpTebLYqW
	vJwt8y9xPGrz3yRl08FumOKN6Q==
X-Google-Smtp-Source: APXvYqz5jGr8f7TU0qeIoKDx3riv+EnSeDs5FCS+pQHC5IlTkdDUVF+bpROHyJ1KmTXWrCPTkNid9Q==
X-Received: by 2002:a17:906:235a:: with SMTP id m26mr24137560eja.297.1568108037999;
        Tue, 10 Sep 2019 02:33:57 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id v24sm3476899edl.67.2019.09.10.02.33.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Sep 2019 02:33:57 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 91A0A1009F6; Tue, 10 Sep 2019 12:33:57 +0300 (+03)
Date: Tue, 10 Sep 2019 12:33:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: git.cmpxchg.org/linux-mmots.git repository corruption?
Message-ID: <20190910093357.zoidae3j5nyy5g2v@box.shutemov.name>
References: <1568037544.5576.119.camel@lca.pw>
 <1568062593.5576.123.camel@lca.pw>
 <20190910070720.GF2063@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190910070720.GF2063@dhcp22.suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 09:07:20AM +0200, Michal Hocko wrote:
> On Mon 09-09-19 16:56:33, Qian Cai wrote:
> > On Mon, 2019-09-09 at 09:59 -0400, Qian Cai wrote:
> > > Tried a few times without luck. Anyone else has the same issue?
> > > 
> > > # git clone git://git.cmpxchg.org/linux-mmots.git
> > > Cloning into 'linux-mmots'...
> > > remote: Enumerating objects: 7838808, done.
> > > remote: Counting objects: 100% (7838808/7838808), done.
> > > remote: Compressing objects: 100% (1065702/1065702), done.
> > > remote: aborting due to possible repository corruption on the remote side.
> > > fatal: early EOF
> > > fatal: index-pack failed
> > 
> > It seems that it is just the remote server is too slow. Does anyone consider
> > moving it to a more popular place like git.kernel.org or github etc?
> 
> Andrew was considering about a git tree for mm patches earlier this
> year. But I am not sure it materialized in something. Andrew? poke poke
> ;)

Johannes, maybe it's time to move these trees to git.kernel.org?

-- 
 Kirill A. Shutemov

