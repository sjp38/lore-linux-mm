Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18E02C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 14:15:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1A5C21E6C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 14:15:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fl04xyXZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1A5C21E6C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B75D6B0003; Wed,  7 Aug 2019 10:15:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 667DA6B0006; Wed,  7 Aug 2019 10:15:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 530FE6B0007; Wed,  7 Aug 2019 10:15:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C23B6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 10:15:27 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id j96so6321822plb.5
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 07:15:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hlfBT6TXSUpnllA47N2HUtHetiSK58in3jxlr+iv0pw=;
        b=dNQN/ZGowkiHH32BULwkf75S4D/6466ml15YfkAEvPL9+ujNVMCE5xums3BOAcW9lS
         MThW17S/ZuOsQQqPF+0QiGgGnnVJjsZk6z1LE7qOSBjEBbxgXEeVyoQgvXdEoXbVdE1C
         WL/Jhva1+QTz+Xb8gVBxnJuv8i7OT/uLLefYJXKbyRoLBP2Dix/r/1K7jzT96hqA7hfn
         4W7EJ5getD8XVAE3MVvYFgrqp3Z2MGZOVHcXXj3x/q4IE5rC06Gc1kQnrjt3TSb4uw/J
         ynCaU2k1IOOtZvkpaOxIzapql0APVO0qy8sEF2cf7IH7BQLRj6JjFo1CH3OLiDzNxpGh
         3t1Q==
X-Gm-Message-State: APjAAAWZF7xTNEbBF+z6Cuzlbf9599gQUMm65s4D0Mho+z7ZJ+glZ4hP
	Jl1lpDoVtrK4UbQUFB+NBkqKMKjHJXA/FCXhn9YwCU4TwZKkmW7/aNcSzIoT0ESaPtUg+pKeeSC
	hqDN7FKpsa1t4nvEK3C0spUb1tEtstW9f3m0/ulYcBdgAiIYvUorvoelGuE+9ESyD7A==
X-Received: by 2002:a17:902:b696:: with SMTP id c22mr8349825pls.305.1565187326595;
        Wed, 07 Aug 2019 07:15:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrKMvie9PTZKw0A+Y5P04Nn0Bnlm06669rS+lV6Eadqe1Hlyh/2IbPJncudp2wYKdaqBwv
X-Received: by 2002:a17:902:b696:: with SMTP id c22mr8349773pls.305.1565187325837;
        Wed, 07 Aug 2019 07:15:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565187325; cv=none;
        d=google.com; s=arc-20160816;
        b=uZNi368oVuiCye9yneUK3Usy2II8bLYyFx/1oTOT09rphcK4CSd4955bv1DeIXUl9D
         Ljwg/XX5NMrQiJ+G75t5bh5cP2+gEXAB4xiSdp2AzeO2h5klBlQ+eRA0ui/Z8ImVLYQD
         rXtfxposJ1wy7qRcVTuq2fXjem5Ymr0vrc8JEM8Ox7vv7ct9c01kCf77qlyPHgYkbz22
         p3nip/xQph83ZJLs+YkTbOunSxO59OzQl5nN0GqZRgngysPp2+WRYNMXrdP6emI6uCGN
         sErPNqyub3pEKe5dywg9+xbnOet4pOXWxqTAF4GJN7iN/De8vG5j+9ITHkAh2kjzdC+x
         MCpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hlfBT6TXSUpnllA47N2HUtHetiSK58in3jxlr+iv0pw=;
        b=o+VGri1KrIioAd8Vt6nZdtODqJe1Xgq7dhPUmwQm3hJDe+pgIwNLjTVqNFDZzkihV8
         lTlkFV2N6X/neMcDiwTMTi0tLUFTqaRtT0vUKCJhCx5WlRoWk1fAKHHcg5gADPzLmiAH
         RlXhCRjSY8I/40WjxyskGpoN75EIuPymxNspFtEggoMUAep4DnTSa1ht6+Hn8OyrxvIV
         ALXzdY1nz3yjNUKW7eXQ5ik6YZhYZdwYBYQ8tnE51LZujxvA/4pza3dXXtUE5C2ubdVu
         FW6pKkUzDrrrMEnfNJ/0z24yflpmtM2KLDzyteCtMga3+KsDDFNnAEC3zLJIL+pHkxXU
         AAxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fl04xyXZ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a11si1131494pgt.124.2019.08.07.07.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 07:15:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fl04xyXZ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=hlfBT6TXSUpnllA47N2HUtHetiSK58in3jxlr+iv0pw=; b=fl04xyXZ1MF4FV7R7c9+2e3mc
	BnEgn9ziqhqIJRRcqRGXr5xuLz626V4rw1XP31jZzwq1IoksUtAYJUgps0z8pBhH0+FMZFkhISBNx
	Q5YRJDQd0C6WBWV3zqHiLbtLFAMgbBa3U9JSXYKyw8RJ5M3Pf9JUD8STq452o7t/3toUUCeipkl05
	eu2Tihzhn0ue6tHKKThBIn0XkdjBi368CTpA9WdpKwBsxHwpN/izSGN7a10VxkbqlHcs7rNxywvMq
	PH89XHFpzIT7ys9UqwBp/TiaY+4/2uzjtzf9xtC9fXhtVE6Gk44R+jhXza0R4NTl71C4x7lJJ1jUD
	VaWCGWKzw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvMij-0000L4-QT; Wed, 07 Aug 2019 14:15:17 +0000
Date: Wed, 7 Aug 2019 07:15:17 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thomas@shipmail.org>,
	Dave Airlie <airlied@gmail.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>,
	dri-devel <dri-devel@lists.freedesktop.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>
Subject: Re: drm pull for v5.3-rc1
Message-ID: <20190807141517.GA5482@bombadil.infradead.org>
References: <CAPM=9twvwhm318btWy_WkQxOcpRCzjpok52R8zPQxQrnQ8QzwQ@mail.gmail.com>
 <CAHk-=wjC3VX5hSeGRA1SCLjT+hewPbbG4vSJPFK7iy26z4QAyw@mail.gmail.com>
 <CAHk-=wiD6a189CXj-ugRzCxA9r1+siSCA0eP_eoZ_bk_bLTRMw@mail.gmail.com>
 <48890b55-afc5-ced8-5913-5a755ce6c1ab@shipmail.org>
 <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com>
 <20190806073831.GA26668@infradead.org>
 <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
 <20190806190937.GD30179@bombadil.infradead.org>
 <20190807064000.GC6002@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807064000.GC6002@infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 11:40:00PM -0700, Christoph Hellwig wrote:
> On Tue, Aug 06, 2019 at 12:09:38PM -0700, Matthew Wilcox wrote:
> > Has anyone looked at turning the interface inside-out?  ie something like:
> > 
> > 	struct mm_walk_state state = { .mm = mm, .start = start, .end = end, };
> > 
> > 	for_each_page_range(&state, page) {
> > 		... do something with page ...
> > 	}
> > 
> > with appropriate macrology along the lines of:
> > 
> > #define for_each_page_range(state, page)				\
> > 	while ((page = page_range_walk_next(state)))
> > 
> > Then you don't need to package anything up into structs that are shared
> > between the caller and the iterated function.
> 
> I'm not an all that huge fan of super magic macro loops.  But in this
> case I don't see how it could even work, as we get special callbacks
> for huge pages and holes, and people are trying to add a few more ops
> as well.

We could have bits in the mm_walk_state which indicate what things to return
and what things to skip.  We could (and probably should) also use different
iterator names if people actually want to iterate different things.  eg
for_each_pte_range(&state, pte) as well as for_each_page_range().

