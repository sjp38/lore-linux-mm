Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76DD7C31E4E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 22:43:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2918B21841
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 22:43:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="yX+cOzz8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2918B21841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1F326B0008; Fri, 14 Jun 2019 18:43:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CFDD6B000C; Fri, 14 Jun 2019 18:43:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E50A6B000D; Fri, 14 Jun 2019 18:43:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 415FA6B0008
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 18:43:11 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so5511105edm.21
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 15:43:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=M+zbZlurnvydl/6SQ6CAVUk3op7xjOMn2bTLkOUdsIE=;
        b=XYxppBPeSB32pTA3YKu60zH3WTu6Mw1v0df3pT41a1ybpEcjI9ngsN7+mOD6yHJb0U
         d6O1PKt/ZEubJCuKiGomEHw+Eyzfh1sjdZydyj0sgp0kEhGIR6C+JXw0FrRZ317nb/0P
         SDfB9GGTjg0NOektP0aIuC6FZ/zKB9QGBBEtTsWK/sGgdyoFL2uZCjjS+FZyTv/MFmeH
         5dn0D5QuA5wyYg/IllxtPc984rX11mSS+U9NIeYzKREQL9RvfbaaAr2VAzuzrh6JFWYE
         J6sPSrFbVjKxERIFWETJXha8I7+W2liFTLkLLkPTrtMsR/SnRFvTFA12S/Ba3uZdGo17
         Af+w==
X-Gm-Message-State: APjAAAXMbgNcCG3nXt/6WPeRb0RFt3pqBaX+hoo4vDpVzBUuG+q0ngmD
	dLYcWOhiO9gke2CWi/N4Noire1Fj1/fhmItx5zKm1lKD/47gW5rT1RqyIXnZepa9EAdAOYKxZR8
	ZRDQiA9YkODWx9Bk5OZjkV/YMW+zg4tZ2zfxi0erbz9vIfWk/2UM9tg/p6LYCjyuBfA==
X-Received: by 2002:aa7:c554:: with SMTP id s20mr29285551edr.209.1560552190852;
        Fri, 14 Jun 2019 15:43:10 -0700 (PDT)
X-Received: by 2002:aa7:c554:: with SMTP id s20mr29285521edr.209.1560552190243;
        Fri, 14 Jun 2019 15:43:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560552190; cv=none;
        d=google.com; s=arc-20160816;
        b=MYE15mAn8vFLLPRFb+7zEljBmuHRlK7axMz/O+rK+WV+vXmO51oorz5x5s8M3Rjko2
         07df8x/RYbbKSixfSs65EQ38YiDCNGIjFGiieIIp6uc2rTqP3V13LbITbbYSDnZK4pTs
         4/rTztB+jWei4v4fQ9wnwUD4lgwkQILMnITC2rYQfclKHhtrV5N9yphwSxtliw68mzFy
         gBKvbEaQhF7dC/S2jqw/yzyhtAHMy0YS91ljuGFXP2WrxAszMGYc74svwY03IF+r13GE
         DnVFJHZWGgmX8f/lA2PgSSN174HCzcRUqGQ1qrWt2PgTmY+xEqN7QBpxvOArsg354kvK
         THIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=M+zbZlurnvydl/6SQ6CAVUk3op7xjOMn2bTLkOUdsIE=;
        b=XHIdrDdzZ0diQqnrQxcaSYNaR+46p6QI6HAo5HePzQHYh+GbUFLKidfyYdWIx4DY0/
         xscz4sqG5FiMB4uF3mPZ2ccHATFXf6nVHljxe6MEjcXI4aps1LXg+Tti1JpSFCeZLLL/
         eJwNkDGBPhd4st1LWyg7YhaDaXUAbmlU6wTUUUiBuODayhiUqEsG5LLSFDdpJgKkbXHw
         tJVaszvShgYYy1JZx/SYCvQySywsmmYFNcq4yFKftNYvw4TlSllMkYeSoKZXQXfRdIUp
         cst3k+KPQTqa35D7YUq/y1XpIZ1fixM7dvoVD+k59TxyXhHMCBEhdDI76M4n9M54SnoX
         GViA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=yX+cOzz8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cw2sor1501180ejb.24.2019.06.14.15.43.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 15:43:10 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=yX+cOzz8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=M+zbZlurnvydl/6SQ6CAVUk3op7xjOMn2bTLkOUdsIE=;
        b=yX+cOzz8Sxb7/voZ95Esa2tAFIQ4ZDV+JXtp2AqsXPwtzu00IC7YhwUjTqMSZmmDWG
         jyJrN1VeTCeyuHxyQHWRxyzsfTK23n488pO5wGs9FVsSgFSo//1oSd4n0Kcztkx5qY41
         UW1blc0iLoR//CqQxKecxSMwZ5tv+cqyr60vaqn9mFiRh3ods3UnncsNCUptxHe2aL/a
         hiU6Da9QXyXnFfdPu4umhw6Wmt40nfUTwgU2EkPwHa849X1gd/4ve4pGxQhIudmyLuRF
         6g0gnjJHItqyD2iY7f5DPjM0W4SSILwtM4oAyxobutdvFsFYJwzeKyVqsk9sw9zu8ONX
         LzhQ==
X-Google-Smtp-Source: APXvYqw9qKi1+ylGIvjwojh4i4QzrWkN08hFImxH0eZYpGMAfqyAEToAzK6czxnnTAxd1f84jFyajQ==
X-Received: by 2002:a17:906:4e92:: with SMTP id v18mr28509947eju.57.1560552189912;
        Fri, 14 Jun 2019 15:43:09 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id g37sm1360017edb.50.2019.06.14.15.43.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 15:43:09 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 6DB911032BB; Sat, 15 Jun 2019 01:43:09 +0300 (+03)
Date: Sat, 15 Jun 2019 01:43:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 18/62] x86/mm: Implement syncing per-KeyID direct
 mappings
Message-ID: <20190614224309.t4ce7lpx577qh2gu@box>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-19-kirill.shutemov@linux.intel.com>
 <20190614095131.GY3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614095131.GY3436@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 11:51:32AM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:43:38PM +0300, Kirill A. Shutemov wrote:
> > For MKTME we use per-KeyID direct mappings. This allows kernel to have
> > access to encrypted memory.
> > 
> > sync_direct_mapping() sync per-KeyID direct mappings with a canonical
> > one -- KeyID-0.
> > 
> > The function tracks changes in the canonical mapping:
> >  - creating or removing chunks of the translation tree;
> >  - changes in mapping flags (i.e. protection bits);
> >  - splitting huge page mapping into a page table;
> >  - replacing page table with a huge page mapping;
> > 
> > The function need to be called on every change to the direct mapping:
> > hotplug, hotremove, changes in permissions bits, etc.
> 
> And yet I don't see anything in pageattr.c.

You're right. I've hooked up the sync in the wrong place.
> 
> Also, this seems like an expensive scheme; if you know where the changes
> where, a more fine-grained update would be faster.

Do we have any hot enough pageattr users that makes it crucial?

I'll look into this anyway.

-- 
 Kirill A. Shutemov

