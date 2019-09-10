Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03BBFC4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 14:30:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B983020863
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 14:30:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Ka/BR6YZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B983020863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B3B46B0006; Tue, 10 Sep 2019 10:30:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 264436B0007; Tue, 10 Sep 2019 10:30:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 153A96B0008; Tue, 10 Sep 2019 10:30:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id DE8FA6B0006
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:16 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8C8A0181AC9AE
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:30:16 +0000 (UTC)
X-FDA: 75919246032.15.wool86_76b093e65da0b
X-HE-Tag: wool86_76b093e65da0b
X-Filterd-Recvd-Size: 4528
Received: from mail-wr1-f68.google.com (mail-wr1-f68.google.com [209.85.221.68])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:30:15 +0000 (UTC)
Received: by mail-wr1-f68.google.com with SMTP id h7so19706048wrw.8
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:30:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YgQItG5PCRc9g0nbQuqINa/v4dyQ1RbuXP2g6ftq/EM=;
        b=Ka/BR6YZsksS0LXRDNvJMTlENUMIZtI3ZBD+WOHDdCpDHpqkzVscdBBWqVZj86TgIf
         VNESczmfxAt5pp7MrZ7ChooAgthBwTZ7uk8KKLXJu4ck9oYDYylyYNzCHpWXY/6lh9tU
         GVFywq/fWpfvfBgyPMC73Vz6c3OaIxhrg61UmAoWU/gB0DTZWAyjxZFb+tgovrSi2e7V
         mTEtYLkO3cIgpC5ZZjd4ZKCsvu3f7ZJ5KZoMBult7WA080RPWNsVmNUvJiCRyAbOkoqY
         kUg9C8GWYUdehRRyKr6nbA3y/uMSHhlzA4fG1pXod8GiSu5oTvy+xhB1atDQCDJUcY09
         B77g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=YgQItG5PCRc9g0nbQuqINa/v4dyQ1RbuXP2g6ftq/EM=;
        b=NmUDAcTv7uu2GpMtUdysAJOqmmAnnOT3Wfk2L/17QYlwj+JjTj5KblofyHevnXEt2z
         TV8vGYKtn7OpaXoDvlEqhChwxdA8zULlv25BpFmn2GN+Rgydcp4PWXaf2HfZnItXhxID
         Q4FvYzC/H51ZaHjklgPOetOXgCbkYOLJgkvj7rO1RVO1EDCdFhDZZWwN/2XfQ56XfCYm
         +Jk4nWuXGvX23hqXdI5LangmyIpNDjV2iZagCjxcq8R1xzkF7M9EK8aTYz36v/1nYIfY
         e1i3tQ+ZzBWUeo5SOCWPoY1XBA0OoSklgNyxBD5l9Jt6q1zfGMRNcc++eGVEYjGQ6FV0
         bmyw==
X-Gm-Message-State: APjAAAVzsPUuV5dHJN5i8tFCU0xSJOtbSK1KZ6/74CCKCSDiEI9/oiCi
	aJ+SiCqKYP0nwhVCDe9xKv4Z1g==
X-Google-Smtp-Source: APXvYqzttUCwAz/u/dIVmc1gy32lf8xZKTKKT8Rno4qxhGQHLIaW/KUOfgI3sPhdvhHWdb9BPUjkXQ==
X-Received: by 2002:adf:e605:: with SMTP id p5mr26398061wrm.105.1568125814081;
        Tue, 10 Sep 2019 07:30:14 -0700 (PDT)
Received: from localhost ([148.69.85.38])
        by smtp.gmail.com with ESMTPSA id n8sm4844114wma.7.2019.09.10.07.30.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Sep 2019 07:30:13 -0700 (PDT)
Date: Tue, 10 Sep 2019 10:30:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Michal Hocko <mhocko@kernel.org>, Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: git.cmpxchg.org/linux-mmots.git repository corruption?
Message-ID: <20190910143012.GA15624@cmpxchg.org>
References: <1568037544.5576.119.camel@lca.pw>
 <1568062593.5576.123.camel@lca.pw>
 <20190910070720.GF2063@dhcp22.suse.cz>
 <20190910093357.zoidae3j5nyy5g2v@box.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190910093357.zoidae3j5nyy5g2v@box.shutemov.name>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000015, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 12:33:57PM +0300, Kirill A. Shutemov wrote:
> On Tue, Sep 10, 2019 at 09:07:20AM +0200, Michal Hocko wrote:
> > On Mon 09-09-19 16:56:33, Qian Cai wrote:
> > > On Mon, 2019-09-09 at 09:59 -0400, Qian Cai wrote:
> > > > Tried a few times without luck. Anyone else has the same issue?
> > > > 
> > > > # git clone git://git.cmpxchg.org/linux-mmots.git
> > > > Cloning into 'linux-mmots'...
> > > > remote: Enumerating objects: 7838808, done.
> > > > remote: Counting objects: 100% (7838808/7838808), done.
> > > > remote: Compressing objects: 100% (1065702/1065702), done.
> > > > remote: aborting due to possible repository corruption on the remote side.
> > > > fatal: early EOF
> > > > fatal: index-pack failed
> > > 
> > > It seems that it is just the remote server is too slow. Does anyone consider
> > > moving it to a more popular place like git.kernel.org or github etc?
> > 
> > Andrew was considering about a git tree for mm patches earlier this
> > year. But I am not sure it materialized in something. Andrew? poke poke
> > ;)
> 
> Johannes, maybe it's time to move these trees to git.kernel.org?

Sorry, cmpxchg.org has had some connectivity issues recently. I don't
mind moving the tree somewhere else.

I lost my kernel.org gpg key, but I'm migrating it to github right
now. I'll follow up with the new locations once that's complete.

