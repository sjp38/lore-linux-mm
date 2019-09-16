Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40815C4CECE
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 13:43:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4486216C8
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 13:43:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="g+XDrhVz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4486216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AFDE6B0005; Mon, 16 Sep 2019 09:43:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4607B6B0006; Mon, 16 Sep 2019 09:43:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 376C76B0007; Mon, 16 Sep 2019 09:43:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id 146FF6B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:43:32 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B5B89180AD801
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 13:43:31 +0000 (UTC)
X-FDA: 75940901022.06.gate49_3bc97bf1ea040
X-HE-Tag: gate49_3bc97bf1ea040
X-Filterd-Recvd-Size: 5012
Received: from mail-wr1-f66.google.com (mail-wr1-f66.google.com [209.85.221.66])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 13:43:30 +0000 (UTC)
Received: by mail-wr1-f66.google.com with SMTP id q17so34261884wrx.10
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 06:43:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=X7DT4R0FzV+OgEncpwgq4aiXf0wPlQub9SIKnN3Lod0=;
        b=g+XDrhVzeTxYZACGZePXUhFkHZ7bUs2d/R44wzIaJcxQ9o9Gf0TiU2eCrl0e/XIHeK
         A1zlQGuYHC1S+eAE7gMsSVlsmwK0CboTMbopKIz+FTFu7as2ZY3jK9h9S6x634femr1W
         B+Wgv9xaZn6UjtwH6fUBj6IHenlMUCZyySwoSesANs/Ps+un9ZeEERL33qBHMcoyO2lL
         Tk10LtTmkF/3GviWOuqbmwddxPWkVUAZq26Rc9Y/ouaH8W37diTQXsUUGTddGbw7mgmn
         EWUDJYTK+3xKDsnaZ6+Qakf9ygg5HNGta+9xROzP/Vv8pU5Ct6pdnfKKAVg9G3dmBf/z
         hq7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=X7DT4R0FzV+OgEncpwgq4aiXf0wPlQub9SIKnN3Lod0=;
        b=qqJ3WJ5tPmwPyRBISgFKABWzAEciUd2BmRpfj0UKYP8kcAjFDcGAQBUQ0xjF7bZwks
         +4/X8sxtTI830iUbwGdLnRzA5InP4OinPFLr62/5Zm6oCkwCAlCO8zeiXjcdX4Rb4WXy
         dfQfCStoGHyqqY9nbgZnzfR7X7qqZNJoW8y1kEqI0hUfAe6NPULg587DFOT0egxscVde
         KZn1bDRoPL3Kzl3bk0YDhfRhowC6w3z4KnzSk99HKIzaWQFLF+HdYCmtyrVrsQI9sj1g
         Ux4X/DXAdLF3daJLx2jadN9c5xo8BsmOlVWufZ0HrwxUa1TQGr/sBZp4tyjXvmIIEJd3
         Xh9Q==
X-Gm-Message-State: APjAAAUvet6nwsdpq2ZGjOSI3jIB4i8s+UE1lovRXjlF0AQ6cIGCm7oI
	Uxn+jgkgYyNqBHevnLQSFxEctKMuY0xpxw==
X-Google-Smtp-Source: APXvYqxQ9vBlVsD073DDIOVdLNWzA1XHAAaxVKzxTTqy4WmeSmbPq6AofQBmS6lxE24NgfhAos8+Aw==
X-Received: by 2002:a05:6000:110f:: with SMTP id z15mr14860230wrw.328.1568641409249;
        Mon, 16 Sep 2019 06:43:29 -0700 (PDT)
Received: from localhost (p4FC6B710.dip0.t-ipconnect.de. [79.198.183.16])
        by smtp.gmail.com with ESMTPSA id f3sm12726352wmh.9.2019.09.16.06.43.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 06:43:28 -0700 (PDT)
Date: Mon, 16 Sep 2019 15:43:27 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Michal Hocko <mhocko@kernel.org>, Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: git.cmpxchg.org/linux-mmots.git repository corruption?
Message-ID: <20190916134327.GC29985@cmpxchg.org>
References: <1568037544.5576.119.camel@lca.pw>
 <1568062593.5576.123.camel@lca.pw>
 <20190910070720.GF2063@dhcp22.suse.cz>
 <20190910093357.zoidae3j5nyy5g2v@box.shutemov.name>
 <20190910143012.GA15624@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190910143012.GA15624@cmpxchg.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 10:30:14AM -0400, Johannes Weiner wrote:
> On Tue, Sep 10, 2019 at 12:33:57PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Sep 10, 2019 at 09:07:20AM +0200, Michal Hocko wrote:
> > > On Mon 09-09-19 16:56:33, Qian Cai wrote:
> > > > On Mon, 2019-09-09 at 09:59 -0400, Qian Cai wrote:
> > > > > Tried a few times without luck. Anyone else has the same issue?
> > > > > 
> > > > > # git clone git://git.cmpxchg.org/linux-mmots.git
> > > > > Cloning into 'linux-mmots'...
> > > > > remote: Enumerating objects: 7838808, done.
> > > > > remote: Counting objects: 100% (7838808/7838808), done.
> > > > > remote: Compressing objects: 100% (1065702/1065702), done.
> > > > > remote: aborting due to possible repository corruption on the remote side.
> > > > > fatal: early EOF
> > > > > fatal: index-pack failed
> > > > 
> > > > It seems that it is just the remote server is too slow. Does anyone consider
> > > > moving it to a more popular place like git.kernel.org or github etc?
> > > 
> > > Andrew was considering about a git tree for mm patches earlier this
> > > year. But I am not sure it materialized in something. Andrew? poke poke
> > > ;)
> > 
> > Johannes, maybe it's time to move these trees to git.kernel.org?
> 
> Sorry, cmpxchg.org has had some connectivity issues recently. I don't
> mind moving the tree somewhere else.
> 
> I lost my kernel.org gpg key, but I'm migrating it to github right
> now. I'll follow up with the new locations once that's complete.

I put up a tree here: https://github.com/hnaz/linux-mm

It has tags for Andrew's mmots and mmotm uploads
(e.g. v5.3-rc7-mmots-2019-09-03-21-33).

master points to the latest mmots release (rebasing / non-pullable).

I will eventually decomission the cmpmxchg.org hosted trees.

