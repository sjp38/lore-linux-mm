Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC84EC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:43:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96BAA24231
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:43:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96BAA24231
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43E4D6B026A; Wed, 29 May 2019 17:43:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C8036B026D; Wed, 29 May 2019 17:43:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B6B06B026E; Wed, 29 May 2019 17:43:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E5ED86B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:43:29 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so2444324pla.7
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:43:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eR4GkQNvFYBYqK7fIFymh6IRpW29zT0L4K+vRuPJ0zE=;
        b=natKzAFKvcFMMRykPk9FFoKf2e85NOWw6OHDuWm1c7A/oSum4avC0/+U0qxWiVrXU4
         IzcPQB/tw5zCFFxtgc0WybLK7tUgPePx97F636xjQIKxd2vxvhlRArg3DLc2u52XkyC4
         Be0cW4VjtdK21GLZ+NJ/t8Vz+i0vMuk4UndibE1masTBf2eIunx573Nc6kA/bK9UyQUx
         fbKVr6g9wYlRIYmlAVcaleXlDOKlah8rw/OTgTS5IYyy+dMch+GW75BrFap0YOEDpFQy
         uh2ZQ8/DqvQmiFemoLeCdfH3MbqJDsq/KjL5fh67QOs/O/aE4JWuINdzVwasXUpd60yt
         9iew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWvQbi/c2bCdCuffNqQe+3HIKaXXYOZT4qIL0OoNGfGPwjT2KZg
	g7CLvrxRnx2KkvLxkU0VaIka1Y+JUzk2oVBXShgdympe5W1KtSEU+o7n7d7SBErQFVL/UkyF8ql
	ilaPLQ4FzrgKAgqZsNxlxdXepG3yXTPMUpvHUwDPWi2x7yoA4d4Q0Lfq2f/2cSvj5kg==
X-Received: by 2002:a65:458f:: with SMTP id o15mr164073pgq.376.1559166209607;
        Wed, 29 May 2019 14:43:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7rMo6Lvj8urwV7p69fT1lkAdvj4LvjvEpmKVAcBlC+9i/Egxmyousv//UIjw1jPHgbLHP
X-Received: by 2002:a65:458f:: with SMTP id o15mr164003pgq.376.1559166208873;
        Wed, 29 May 2019 14:43:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559166208; cv=none;
        d=google.com; s=arc-20160816;
        b=IG5cE3BF/fh2xA04J1FXp3+WIzKBO9hKIlcggzIuC8B54lJkWsZeaUYs1l75oZUgvZ
         CtjlWHOj4Qgqh95fcym/+w8Sw7pXJqnxKgkA2z9kddQcAUGumULLuP3BOGYAKJeIO5v9
         OitVKcaJuBAb022GPI81zCKBNgscUqZ+EXQ+PHd4pUV6DAqg7NrnlyaPAgdLONYQFJYc
         ZulwZby83YXjAY/45kjd+DMrA7RWgaDm4oUIllBmmDyQrTNfVYNOedX8+Sy354LWWUpV
         DF210WX+vr5uHk2p2ZaKGvb4QRI78r+xB+qgIdHt7B5S0XrOi/waO9K1oTMbnaqOb64P
         kOOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eR4GkQNvFYBYqK7fIFymh6IRpW29zT0L4K+vRuPJ0zE=;
        b=hRhkftbbO0wiboBgU2lfhWG0VmK98md5wGxQkZ4kG71Tcvt7lJ4m/7Try8+0dqj6Yx
         Io+kSyRxStz2pH5l68CQZJjJU7vrVbMeIhdZSfBYD47F5g4BNehNCATIZDXPC8oL8x2C
         hI2sqUyyyA8GxcdJJeyAxZk7p3qLVEc6EEV85hJenmJRUIAjl4tkRoaxXgTHeE1ysxBB
         iopDCx1ZKr53TvKNWkpFFseB89ZSeB7x1k9aA8VUSxkKCtdlcbtdJnSGaxq6luSSNw9/
         p9AKQtKnJTJsy4D6HjvRX7xnoXrfT0pWfoi7+aRt2gknHrlsbfwGNhT11j6sSzRC7bhJ
         19tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id m3si1023742pld.40.2019.05.29.14.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 14:43:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 May 2019 14:43:27 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 29 May 2019 14:43:27 -0700
Date: Wed, 29 May 2019 14:44:30 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC 00/11] Remove 'order' argument from many mm functions
Message-ID: <20190529214428.GA1543@iweiny-DESK2.sc.intel.com>
References: <20190507040609.21746-1-willy@infradead.org>
 <20190509015809.GB26131@iweiny-DESK2.sc.intel.com>
 <20190509140713.GB23561@bombadil.infradead.org>
 <2807E5FD2F6FDA4886F6618EAC48510E79D0CFDA@CRSMSX101.amr.corp.intel.com>
 <20190509182902.GA11738@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509182902.GA11738@bombadil.infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 11:29:02AM -0700, Matthew Wilcox wrote:
> On Thu, May 09, 2019 at 04:48:39PM +0000, Weiny, Ira wrote:
> > > On Wed, May 08, 2019 at 06:58:09PM -0700, Ira Weiny wrote:
> > > > On Mon, May 06, 2019 at 09:05:58PM -0700, Matthew Wilcox wrote:
> > > > > It's possible to save a few hundred bytes from the kernel text by
> > > > > moving the 'order' argument into the GFP flags.  I had the idea
> > > > > while I was playing with THP pagecache (notably, I didn't want to add an
> > > 'order'
> > > > > parameter to pagecache_get_page())
> > > ...
> > > > > Anyway, this is just a quick POC due to me being on an aeroplane for
> > > > > most of today.  Maybe we don't want to spend five GFP bits on this.
> > > > > Some bits of this could be pulled out and applied even if we don't
> > > > > want to go for the main objective.  eg rmqueue_pcplist() doesn't use
> > > > > its gfp_flags argument.
> > > >
> > > > Over all I may just be a simpleton WRT this but I'm not sure that the
> > > > added complexity justifies the gain.
> > > 
> > > I'm disappointed that you see it as added complexity.  I see it as reducing
> > > complexity.  With this patch, we can simply pass GFP_PMD as a flag to
> > > pagecache_get_page(); without it, we have to add a fifth parameter to
> > > pagecache_get_page() and change all the callers to pass '0'.
> > 
> > I don't disagree for pagecache_get_page().
> > 
> > I'm not saying we should not do this.  But this seems odd to me.
> > 
> > Again I'm probably just being a simpleton...
> 
> This concerns me, though.  I see it as being a simplification, but if
> other people see it as a complication, then it's not.  Perhaps I didn't
> take the patches far enough for you to see benefit?  We have quite the
> thicket of .*alloc_page.* functions, and I can't keep them all straight.
> Between taking, or not taking, the nodeid, the gfp mask, the order, a VMA
> and random other crap; not to mention the NUMA vs !NUMA implementations,
> this is crying out for simplification.

Was there a new version of this coming?

Sorry perhaps I dropped the ball here by not replying?

Ira

> 
> It doesn't help that I screwed up the __get_free_pages patch.  I should
> have grepped and realised that we had over 200 callers and it's not
> worth changing them all as part of this patchset.
> 

