Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B175AC31E4E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 22:41:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65C4A21841
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 22:41:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="CPGuBSov"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65C4A21841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDBD86B0008; Fri, 14 Jun 2019 18:41:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E65C36B000C; Fri, 14 Jun 2019 18:41:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D07796B000D; Fri, 14 Jun 2019 18:41:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 817686B0008
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 18:41:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so5545417edt.4
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 15:41:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kKBlaaZ2e0R8Qmq/ym3o296XdTEZmGz+dmrLAMFTTnM=;
        b=XACO5ARXp5iedjdYqx8Apup3t/1A2tiC829WqAIEmgd8D9iIcDOLd6RUWxdrUl2G6T
         jzWAx3l+6EnW6dWM1M7/Y3Urn+o8a0SMrEMs6YYqSGzwXtRcNtIbwLJPJoqJ788YmrTj
         KTjWZHFMGBEuI74tlz3d37iPx6vjj/CimScfx/7Yl3T3QIsHA7J/JSb2buCit8dYB516
         lJbl+JZIKnHkqYCVZGULHWaTH4ABvhO5Ysl+Dz5tVOPB43yD1euEnyRguHGGQHzQEbUD
         mJB6ABgQEq4M6ESnusZYBdfcT2mC6ub/T32ChuxY9XW99n3dPBzJNs/pHquU81QhT8Xa
         7mHA==
X-Gm-Message-State: APjAAAXAoVJscZV/fkdSumxoc60ow5YHHlTk34+iluGeYPxTq0Ld1L7E
	h11XLHdOx+OoG5lfgJH6EIzFFGwYCZEmk2aYutlqFbZTKBSAwzY0HiWtXeAKm7AtpmISkQ8afQf
	9mdIxAxPpL07oeeNXcN9ayzJFy8BjSGvDdS49pT7x2qDB2iEEfqhF0s7rwsfAAJMbmA==
X-Received: by 2002:a17:906:8053:: with SMTP id x19mr66339538ejw.306.1560552093021;
        Fri, 14 Jun 2019 15:41:33 -0700 (PDT)
X-Received: by 2002:a17:906:8053:: with SMTP id x19mr66339503ejw.306.1560552092117;
        Fri, 14 Jun 2019 15:41:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560552092; cv=none;
        d=google.com; s=arc-20160816;
        b=xW182/AbiT3Xy6T/dgqmn7NzHzNCRGCuEAzHIS/NkseHlN+YggSyJ414Hadv1dHjqz
         kNeX8Ygq53lFPDZnVdwvlE86vM/UeeweqiUv+IZLE6zxCfiNU9WbsvtuhoVn+gIJ3KJC
         2zvnYrc3+RQE6tYKHgfDRJSYjkSBWjBUWRMQxksTcDuWoPEzJFvDbHRuV0JjvonAmPAv
         wF6Raf5rsMe3STG15N04LXb/BHl2NKeD4NHHEQKmWneA50Cc5D6TaqmOrvxnRnA7VwdS
         af1XaRYd9wk22Yt+09f4LfdXXWJziEosRbYmPG1AMXC86bKJGkVgwf34YBI7LeQQc8s2
         J2Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kKBlaaZ2e0R8Qmq/ym3o296XdTEZmGz+dmrLAMFTTnM=;
        b=gn515WSsqyB1FO3WaJnV4ob4LrGuoaN7qjv64CzuaSZv4Ls7MvqU/iiVpQL4eW00oy
         3IBt9wnZukWMGJNQmjJD3qry3rlxRgzrQllzMBur5drBTpPpPJ1ZlIoHyn/mTxksBAj5
         vq85OLOazp/LVRqZRJHqCrwQuocQbLFxLORqwMmhRmYNrjkmT8hyN71dtEU88JoTmcz+
         fXkNVnlB5c67g3c8DOEk3XMijuwvGpnNxq7bMHLrFbF6vJkO4ETVZNODPakTn+/6qTZ5
         6lGcfHTsoSRPaXZL/OevCSevwb34fxFI9r2TLCwy9maPozbm8V9xa5rP+llDd1j2ZTqy
         tlLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=CPGuBSov;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b56sor4060951edb.9.2019.06.14.15.41.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 15:41:32 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=CPGuBSov;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=kKBlaaZ2e0R8Qmq/ym3o296XdTEZmGz+dmrLAMFTTnM=;
        b=CPGuBSov5EtyIvw2ZTZfpLXH+m7nArR8FUWgvlBePXdjMMPA+IllY65N5XVaJeFXGX
         S+EacF/ActYMQZRJhhIJSfzfPop2+kZjoBgPJHcx2z7p74dlBg7IqjzTZHOH9FY6/FML
         ANudxrhtB9aceq/ZfOdQyRFEixvnwgQkUXUiC7Etp+RfnHnVOMi2aXkzm1Sb6OiKEhpk
         /5FhyQKkpk+Sf0MdmVKR3Ybqhj011xuJYbjEXw5yYkJ2a1UmUhyXcG5zJOlWCYCvWUfA
         nRLArs2z6tB3k5oWgjh6c060atJzsvPn8rYXaHW2T2LLR+ioz03Ty/SSN2uIo8CUCZAH
         qyZg==
X-Google-Smtp-Source: APXvYqzGx/+9/zTI71X2KsJYZP9s0HxE5l2n9lbx9/IlAC6AFkQjQN9+Z7eAaIEasZDypTRFQX080A==
X-Received: by 2002:a50:f4d8:: with SMTP id v24mr3644568edm.166.1560552091661;
        Fri, 14 Jun 2019 15:41:31 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id i16sm845646ejc.16.2019.06.14.15.41.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 15:41:30 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 453FB1032BB; Sat, 15 Jun 2019 01:41:31 +0300 (+03)
Date: Sat, 15 Jun 2019 01:41:31 +0300
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
Subject: Re: [PATCH, RFC 13/62] x86/mm: Add hooks to allocate and free
 encrypted pages
Message-ID: <20190614224131.q2gjai32la4zb42p@box>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-14-kirill.shutemov@linux.intel.com>
 <20190614093409.GX3436@hirez.programming.kicks-ass.net>
 <20190614110458.GN3463@hirez.programming.kicks-ass.net>
 <20190614132836.spl6bmk2kkx65nfr@box>
 <20190614134335.GU3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614134335.GU3436@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 03:43:35PM +0200, Peter Zijlstra wrote:
> On Fri, Jun 14, 2019 at 04:28:36PM +0300, Kirill A. Shutemov wrote:
> > On Fri, Jun 14, 2019 at 01:04:58PM +0200, Peter Zijlstra wrote:
> > > On Fri, Jun 14, 2019 at 11:34:09AM +0200, Peter Zijlstra wrote:
> > > > On Wed, May 08, 2019 at 05:43:33PM +0300, Kirill A. Shutemov wrote:
> > > > 
> > > > > +		lookup_page_ext(page)->keyid = keyid;
> > > 
> > > > > +		lookup_page_ext(page)->keyid = 0;
> > > 
> > > Also, perhaps paranoid; but do we want something like:
> > > 
> > > static inline void page_set_keyid(struct page *page, int keyid)
> > > {
> > > 	/* ensure nothing creeps after changing the keyid */
> > > 	barrier();
> > > 	WRITE_ONCE(lookup_page_ext(page)->keyid, keyid);
> > > 	barrier();
> > > 	/* ensure nothing creeps before changing the keyid */
> > > }
> > > 
> > > And this is very much assuming there is no concurrency through the
> > > allocator locks.
> > 
> > There's no concurrency for this page: it has been off the free list, but
> > have not yet passed on to user. Nobody else sees the page before
> > allocation is finished.
> > 
> > And barriers/WRITE_ONCE() looks excessive to me. It's just yet another bit
> > of page's metadata and I don't see why it's has to be handled in a special
> > way.
> > 
> > Does it relax your paranoia? :P
> 
> Not really, it all 'works' because clflush_cache_range() includes mb()
> and page_address() has an address dependency on the store, and there are
> no other sites that will ever change 'keyid', which is all kind of
> fragile.

Hm. I don't follow how the mb() in clflush_cache_range() relevant...

Any following access of page's memory by kernel will go through
page_keyid() and therefore I believe there's always address dependency on
the store.

Am I missing something?

> At the very least that should be explicitly called out in a comment.
> 

-- 
 Kirill A. Shutemov

