Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBC02C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:43:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82B4B21721
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:43:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="wJWUaH4K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82B4B21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C6876B0003; Fri, 14 Jun 2019 09:43:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 177446B000A; Fri, 14 Jun 2019 09:43:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 066B36B000D; Fri, 14 Jun 2019 09:43:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB7046B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:43:45 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id r4so1075455wrt.13
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:43:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CEpLzxWl0gVhhE2loe/wZNC7HEFBNtusAecwnKLSC9Y=;
        b=I8VxDwV+BaZcAL1kuhMEKj29AjH33uFDvdCS+eRjbBWiT9cPfj3BpeZxxT5ZO7ill/
         Jn6L8bIE4rq/Nr/L5sVx19NDzk5HGzemdt/RSUXK4MZpH/2S40hh0jxYWIHiWMCbD71N
         Bm9Mp/Ejhn0YuE0z/qJKWJ77XE87N+xa/sUn9D3jJWswh0cNAAfic6D0pwrT/TcJ6PZY
         JLJmK+8iPCSD2m40FZVfioXRq4J1nN8la2FS5vWD4iofKfkKiwZn5fkI8z3yzCTb/Wqf
         vOvJujo0gSqRH/f7XRgXWpQExS2m/oUzmrscdWk4vrUEQhcbJePzHZiBnhjEiSHNSzNJ
         gyyQ==
X-Gm-Message-State: APjAAAWSL9mtEaXtvampP9rmusJHDmz5Fcn5v6m9vcigsqrOnMLdehi/
	7bhVG8Mf6NvGtD587G75XDxJTt1R87E9bcnCFwHigz5d+tuLKyiSxRmrpkjyn3fTHjmb1bj1dR7
	0J1W97+/GSqoeMbap3+a3oWsEC/ozrqrovHOP9H25OjvYFqbBDZN5MHmVWPDs+jbN/Q==
X-Received: by 2002:adf:9dcc:: with SMTP id q12mr14909749wre.93.1560519825281;
        Fri, 14 Jun 2019 06:43:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsqoi7p/eN9mEVR4I5OVdzu0q1tezRS+LfEO3zOpf8ZMRnBt+WbFmKfhkRiWdoWk95fS94
X-Received: by 2002:adf:9dcc:: with SMTP id q12mr14909697wre.93.1560519824404;
        Fri, 14 Jun 2019 06:43:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560519824; cv=none;
        d=google.com; s=arc-20160816;
        b=x4hphzdQapxdTtiqDU5WsaX5yQ/Jc2V6A4Ll5p6ZGUVUJA0QApnhMqlMnwJWW8dW7Q
         BH7Uo89CmlS6sdpFCcoGYFGH/SQH2dwrQBt/iXqrFXcWU21wT1jD55TunRZp6+dRPeax
         /8SxHNq2Ll3tUzBLiKylmMZnI6Z3XkuAIJcnOit5uKgY3of/cAQuu62/hBtZhksjXQGm
         cXd3wTvf73d9bzQlTnKWk186GaGKgofQeaJqEZeC1t7LlAYHAmzcbnfn2eZb0TSOUBkq
         CYlG9CJcsbsk6rPuGHeaczmflnOr0aE3VTrXsP67wDz+8rLtr/op16LrW4Q2WKiaODti
         uDdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CEpLzxWl0gVhhE2loe/wZNC7HEFBNtusAecwnKLSC9Y=;
        b=aiPi92s3R/2zvvNchjANyIN2iNDwA0KDQcM+62cm6nbg2DaIP5sRVqn5WxYsD7apnR
         DOUUZkMZyOvhRWXasYWbdPFMhRY3B2uhAGOhzAblgYKZbnfMENuXtsk05E9Rrc5+o0KQ
         2qsMyccHkJUyH4QtX+BJri+iL/N2egK1DaJan78PswyjAsBZYeVqE877krH2g8V3+mpU
         tiWHKVQ6AS5F7wDs8U3BePqzaGQ/9PGXH090qTfBkBKWsDQG/rGkb77rn3o6I8zBhA2t
         Yff4gud/NDMgKzorq3TByVO+mvdAbzW00CiNB0dJdPxI36WYe9g6d8bD3buRvjfioK20
         pcKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=wJWUaH4K;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c14si2550160wrn.264.2019.06.14.06.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:43:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=wJWUaH4K;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=CEpLzxWl0gVhhE2loe/wZNC7HEFBNtusAecwnKLSC9Y=; b=wJWUaH4KBhaf6FksZmx6YleNS
	SqJt2t24BqEHD50uiboct62KgbUmDCuQAqSNqCr87Vaizsbh9ww1KCcI+top6ZWkFHX3dyskStBzq
	UIViB3eY+V4668fgqSO5LtEzseW5ElzpJsd3aNvCMF/RVO9Lg/DIm9iLz357FOEQ+WxQ4pw2Q077W
	kf4mJRIvgRsBYqbPyY7CtR7XUwXqeFv4KrkG8WnWDVb7ouPheOhasUPP57/2hdI+uSHSKuH4XsfuR
	+Si9/YiEQVF9qWr46i2A8Hr8Uzh3Su4WRqmqOee1TLNOHja45yFHb/hTiCA++kVXKwxYFFWwXNFqx
	pH+R4j+Fg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmUS-00087g-TV; Fri, 14 Jun 2019 13:43:37 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 983BF20292FD5; Fri, 14 Jun 2019 15:43:35 +0200 (CEST)
Date: Fri, 14 Jun 2019 15:43:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
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
Message-ID: <20190614134335.GU3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-14-kirill.shutemov@linux.intel.com>
 <20190614093409.GX3436@hirez.programming.kicks-ass.net>
 <20190614110458.GN3463@hirez.programming.kicks-ass.net>
 <20190614132836.spl6bmk2kkx65nfr@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614132836.spl6bmk2kkx65nfr@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 04:28:36PM +0300, Kirill A. Shutemov wrote:
> On Fri, Jun 14, 2019 at 01:04:58PM +0200, Peter Zijlstra wrote:
> > On Fri, Jun 14, 2019 at 11:34:09AM +0200, Peter Zijlstra wrote:
> > > On Wed, May 08, 2019 at 05:43:33PM +0300, Kirill A. Shutemov wrote:
> > > 
> > > > +		lookup_page_ext(page)->keyid = keyid;
> > 
> > > > +		lookup_page_ext(page)->keyid = 0;
> > 
> > Also, perhaps paranoid; but do we want something like:
> > 
> > static inline void page_set_keyid(struct page *page, int keyid)
> > {
> > 	/* ensure nothing creeps after changing the keyid */
> > 	barrier();
> > 	WRITE_ONCE(lookup_page_ext(page)->keyid, keyid);
> > 	barrier();
> > 	/* ensure nothing creeps before changing the keyid */
> > }
> > 
> > And this is very much assuming there is no concurrency through the
> > allocator locks.
> 
> There's no concurrency for this page: it has been off the free list, but
> have not yet passed on to user. Nobody else sees the page before
> allocation is finished.
> 
> And barriers/WRITE_ONCE() looks excessive to me. It's just yet another bit
> of page's metadata and I don't see why it's has to be handled in a special
> way.
> 
> Does it relax your paranoia? :P

Not really, it all 'works' because clflush_cache_range() includes mb()
and page_address() has an address dependency on the store, and there are
no other sites that will ever change 'keyid', which is all kind of
fragile.

At the very least that should be explicitly called out in a comment.

