Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23486C4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 21:11:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6A4F20692
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 21:11:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qWhIUGIb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6A4F20692
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DA996B0003; Thu, 12 Sep 2019 17:11:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28B556B0005; Thu, 12 Sep 2019 17:11:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A1B86B0006; Thu, 12 Sep 2019 17:11:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id 063186B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 17:11:21 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B1A9B180AD7C3
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 21:11:20 +0000 (UTC)
X-FDA: 75927514320.02.sail62_63020a32ae736
X-HE-Tag: sail62_63020a32ae736
X-Filterd-Recvd-Size: 4495
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 21:11:20 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id r26so58126808ioh.8
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 14:11:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=62srlE3SBeqwLg3Pd9NJw2uOwPxjT0FuUEa1NpcJ1xg=;
        b=qWhIUGIbwLqnA77UZ14TIIf9D+cAZjHYn+mhylpeFjNYM7MeVdl9l3Q8gNgt9vowCE
         usvkwZg92ge3+m2sG9Zovwsf5Jdji//d4DgCkyxOA37bKPnG0mwy5iOZ/CbIq1g5hKyp
         tGIbkUstgAac+ynlhNq6+chmBgnlhYfCILlbgnV1xtiLpn7Ppkjsnq7KV9IL5/eh8KqU
         7PfS91T8+D93qqW85sKaeA/+wfgNGB3MYnMzluyNMvQSIu1CwGVlBZxL0iUBGoglKpDQ
         P4aqRniuu1HnlZqcTcF8VQed492BC1B5qlaCgP9krPjUwQRetrnZObRHpo+4DUPI4wy8
         5BqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=62srlE3SBeqwLg3Pd9NJw2uOwPxjT0FuUEa1NpcJ1xg=;
        b=RehfCQrKCUUStok3lXXFbNLbym0Omma2QROxnrkdFS29qwD/ji6LNzhQhkiBSAb2aC
         id05hywjb3uiL6Toxp2fzAeCcIwqvk/wEhEG98oL7nEh2O1bah97h9DjM0dhqWCe5hyd
         cyY01zQtHdQmWd9D3fsIEcLkhR/FjxHR4sD/BQftieSsb4x+mbYXBtpOK+BDY1CNnIG/
         nsdLWO9DpSyqopKbXAUlTAQlRioyUshFuQuqiCIEyskVflISYr2HkOYHrkhMVURLbmvs
         3uts2CFyuWiambrNcjJSJrDoIyzE2TMW9qqp9rF77R+osvm6EVg1IIVZXw6K02Kvj8Qj
         hlYg==
X-Gm-Message-State: APjAAAUeEXRhO4PXWoqy4WKG8whB5b26o8oDFJHsQ/5jSvMsHGoU+8mX
	m3risl9i+WsTXbt3l5QLFgAVdA==
X-Google-Smtp-Source: APXvYqxn+KCXBrBfZnrJIz4+Qc8lvkyqM8DtjXHGEMowE6lpWAOAuV9+fPmtupBmcM6xQSJ5JfKnhA==
X-Received: by 2002:a6b:f717:: with SMTP id k23mr6875020iog.210.1568322679426;
        Thu, 12 Sep 2019 14:11:19 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:9f3b:444a:4649:ca05])
        by smtp.gmail.com with ESMTPSA id c15sm22432089ioi.74.2019.09.12.14.11.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 12 Sep 2019 14:11:18 -0700 (PDT)
Date: Thu, 12 Sep 2019 15:11:14 -0600
From: Yu Zhao <yuzhao@google.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/4] mm: correct mask size for slub page->objects
Message-ID: <20190912211114.GA146974@google.com>
References: <20190912004401.jdemtajrspetk3fh@box>
 <20190912023111.219636-1-yuzhao@google.com>
 <20190912094035.vkqnj24bwh33yvia@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190912094035.vkqnj24bwh33yvia@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 12, 2019 at 12:40:35PM +0300, Kirill A. Shutemov wrote:
> On Wed, Sep 11, 2019 at 08:31:08PM -0600, Yu Zhao wrote:
> > Mask of slub objects per page shouldn't be larger than what
> > page->objects can hold.
> > 
> > It requires more than 2^15 objects to hit the problem, and I don't
> > think anybody would. It'd be nice to have the mask fixed, but not
> > really worth cc'ing the stable.
> > 
> > Fixes: 50d5c41cd151 ("slub: Do not use frozen page flag but a bit in the page counters")
> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> 
> I don't think the patch fixes anything.

Technically it does. It makes no sense for a mask to have more bits
than the variable that holds the masked value. I had to look up the
commit history to find out why and go through the code to make sure
it doesn't actually cause any problem.

My hope is that nobody else would have to go through the same trouble.

> Yes, we have one spare bit between order and number of object that is not
> used and always zero. So what?
> 
> I can imagine for some microarchitecures accessing higher 16 bits of int
> is cheaper than shifting by 15.

Well, I highly doubt the inconsistency is intended for such
optimization, even it existed.

