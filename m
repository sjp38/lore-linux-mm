Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A7EBC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:14:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C5BF214D9
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:14:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="wlmiK9qk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C5BF214D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C88C46B0007; Mon, 16 Sep 2019 10:14:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C11596B0008; Mon, 16 Sep 2019 10:14:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD8836B000A; Mon, 16 Sep 2019 10:14:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0100.hostedemail.com [216.40.44.100])
	by kanga.kvack.org (Postfix) with ESMTP id 8753A6B0007
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:14:37 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3372D2C0D
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:14:37 +0000 (UTC)
X-FDA: 75940979394.20.arch49_283bae1296740
X-HE-Tag: arch49_283bae1296740
X-Filterd-Recvd-Size: 5082
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:14:36 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id i8so142927edn.13
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:14:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1j515HGtXLaUHWVHA9eFiO7P9o782HtgJnRpI5g6dGU=;
        b=wlmiK9qk9rgN+gie2nVePtGglydSWpi9+olKWpAF8QCdFId0Ow9SMQdYBiPXMc09Hw
         58c80Jz9Z8v64EbFmorkPUXBzmynKX6++3CB2HD7YlBUkyLa3Bt3iaEmurFSr+A8HIJJ
         tMSOp4W/8s21vbkJU0eGm7/7hU1vqeLvVfAM2an+k76VG11Sr536XVDjIU61lUJMean0
         gFexOJaqrpYVg3XJe7BdylxQogUvwniXx9/6+DLBq+DAoU2BMTt3o317SKihQjfKYIcm
         H4J4tMi9UzhwGplJE32ibRROapnBEfZ0nDpZ5cWp4hi+4Mo79NccswGrZlDDoOE5EIg5
         VQOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=1j515HGtXLaUHWVHA9eFiO7P9o782HtgJnRpI5g6dGU=;
        b=HJgXrkLWwGRVALTd3QkKdKHI56pheTpjlUdsj7N6bRY+pUXfIRDhx56zl7SBQyWX86
         mHPoa6uCMuF9hq46bVNuMrbw6nZ/kJefVKiKnArL0A/2Ksw7p9Ne0SlPianFu74HkCqf
         8p0cltIhdY86n3E08DH043HKG22I1qKaXUNimp8tW+S5vRLikcgsv/NwBnMF2WOiJ2jS
         e93/HRdCPzORk9qlzGtfQ+Q5dxW3usb4ZBOglBHCQ39BouRpCvysi1vs3ilyDPPRLzWd
         B7q2n+0sXwaJLbTsqz4LKmQCyi+cihSvAL7isvQaeoNg0z8X2gI1v5pgA6SF6W900jfO
         xdXw==
X-Gm-Message-State: APjAAAVKcb3M3135uYWUHasEsrew+1TWlKNCbKK+vRpkgiUaIFUnsGud
	u7pSJZ34IXoonb+XvmSL+1WyOg==
X-Google-Smtp-Source: APXvYqzH/imgDSjwLPeAp+KfXiq/xhP1+q6Zkh/q+QPQET7pdYYb4hBhGQmRDlbPGkAbeABdutCgEg==
X-Received: by 2002:a17:906:4e8f:: with SMTP id v15mr212673eju.57.1568643275208;
        Mon, 16 Sep 2019 07:14:35 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id y25sm1352957eju.39.2019.09.16.07.14.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Sep 2019 07:14:34 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 5C80B10019A; Mon, 16 Sep 2019 17:14:36 +0300 (+03)
Date: Mon, 16 Sep 2019 17:14:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: git.cmpxchg.org/linux-mmots.git repository corruption?
Message-ID: <20190916141436.badjdhmetiph5h34@box.shutemov.name>
References: <1568037544.5576.119.camel@lca.pw>
 <1568062593.5576.123.camel@lca.pw>
 <20190910070720.GF2063@dhcp22.suse.cz>
 <20190910093357.zoidae3j5nyy5g2v@box.shutemov.name>
 <20190910143012.GA15624@cmpxchg.org>
 <20190916134327.GC29985@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190916134327.GC29985@cmpxchg.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 03:43:27PM +0200, Johannes Weiner wrote:
> On Tue, Sep 10, 2019 at 10:30:14AM -0400, Johannes Weiner wrote:
> > On Tue, Sep 10, 2019 at 12:33:57PM +0300, Kirill A. Shutemov wrote:
> > > On Tue, Sep 10, 2019 at 09:07:20AM +0200, Michal Hocko wrote:
> > > > On Mon 09-09-19 16:56:33, Qian Cai wrote:
> > > > > On Mon, 2019-09-09 at 09:59 -0400, Qian Cai wrote:
> > > > > > Tried a few times without luck. Anyone else has the same issue?
> > > > > > 
> > > > > > # git clone git://git.cmpxchg.org/linux-mmots.git
> > > > > > Cloning into 'linux-mmots'...
> > > > > > remote: Enumerating objects: 7838808, done.
> > > > > > remote: Counting objects: 100% (7838808/7838808), done.
> > > > > > remote: Compressing objects: 100% (1065702/1065702), done.
> > > > > > remote: aborting due to possible repository corruption on the remote side.
> > > > > > fatal: early EOF
> > > > > > fatal: index-pack failed
> > > > > 
> > > > > It seems that it is just the remote server is too slow. Does anyone consider
> > > > > moving it to a more popular place like git.kernel.org or github etc?
> > > > 
> > > > Andrew was considering about a git tree for mm patches earlier this
> > > > year. But I am not sure it materialized in something. Andrew? poke poke
> > > > ;)
> > > 
> > > Johannes, maybe it's time to move these trees to git.kernel.org?
> > 
> > Sorry, cmpxchg.org has had some connectivity issues recently. I don't
> > mind moving the tree somewhere else.
> > 
> > I lost my kernel.org gpg key, but I'm migrating it to github right
> > now. I'll follow up with the new locations once that's complete.
> 
> I put up a tree here: https://github.com/hnaz/linux-mm

Thanks!

-- 
 Kirill A. Shutemov

