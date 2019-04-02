Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA1C5C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 19:06:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EDE32075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 19:06:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="DwVu0TB0";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ZAkeXXEL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EDE32075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C9BF6B0273; Tue,  2 Apr 2019 15:06:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 379226B0274; Tue,  2 Apr 2019 15:06:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23FE36B0275; Tue,  2 Apr 2019 15:06:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06C156B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 15:06:12 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n10so14413750qtk.9
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 12:06:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tRHgReLT3oOtyuahd5OJIneMe7psB9fqOhUXYvm8M/I=;
        b=qjmb3BU+Pk6hjW0AGLNB/FDxMT44OWkFkVAWk/pgO9XCMiBzg8KfOdy82Eg5JB8OJt
         YSki9XxvZB80sYnolUmGvRxGXqp/ZSnnirRY97XY/DZ2Lgf3E5ISZ9anNxh8DtVZ6Xl5
         3CvSdzGhfHxODPdF9ok5an+wCVuWtykFZd5NZLQW0x+UGwiqOG99IlkY9YK+7G70tgpg
         AsE4TGmhiZxOA3aYlJv2eYvisqCOVC5EFQNp7QlFtodNrKNrQQl3EKfos32HjG/E9dSm
         9kiG4yR8YJLgHYjaTmV5/hCnzQb2LK+EXXimtziji4TwP8GNayaSHSgoCw1fdKMlUrIb
         z3Iw==
X-Gm-Message-State: APjAAAVrbPa4cMSMKmy9mJUHSdphbnQykg8rEhIAVJ/Sg+nHnmNf6rmJ
	9LkyNjWOjbuDlXCe6TOTjRCkBneQc/PsciuLaYdqY8EFUPCn5f/dSJ6WzYGqPfJOSTE16hSs33n
	LtgtBlWosZbI9WmQz787bJiJFO16oOZ7JKOYs/fzmpXczvvxKr6Ii/9Vz5BsnaRmeSA==
X-Received: by 2002:a37:b303:: with SMTP id c3mr14647539qkf.154.1554231971699;
        Tue, 02 Apr 2019 12:06:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyr874ZlETv/43GSLeW7Q9XK3geNzrze1SkjIVzvFcNiWFQjxvn1K7QoWG41CfREtTkE6dS
X-Received: by 2002:a37:b303:: with SMTP id c3mr14647471qkf.154.1554231970909;
        Tue, 02 Apr 2019 12:06:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554231970; cv=none;
        d=google.com; s=arc-20160816;
        b=0aye1544xG18GrJdoNk/xjXPzdu6i7eWewaioH/G3AUUAQB/pfo5WPXwWz4FlOlqD7
         Gv/kST8pDMyb/s5U+V7zkg4+nPrXunA7ExAHV7jIurtRt9jm+vehN+vl/fqtBNUovBRd
         t8AmzjkPkMfemFkYe8Z/IbrMlN9uAgqC0n8Wkq41UULmebLmcY2be4iBnjjDPxo7DORg
         nSFzDd6x7EDzbUmHa8w+w0Wr/SFMmfZQdBqSWYeJFupTt6XKpeXfjUufeNgYvO+CnmCq
         XZ+LA9N3QC2Dt8x/rMAVGhIBgqwSKquHTqk/xHW/TeQnCzdPWIUqO+DGX/jxt0BYC+FQ
         1xMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=tRHgReLT3oOtyuahd5OJIneMe7psB9fqOhUXYvm8M/I=;
        b=sYxlXr1YdbSliKdoNlFceP8v15lhSvQa4aevd6XoT7uTl/XCuEM2U+tl5TC3JfXYuf
         IeUAGH7XR0xgxdGFs0yF6DtPgDJrYxdutw9myqRNqPORbByLtNqhUiw0w9AinUFqeWzK
         HvjSpWJIV7OiC6BgKvlsdeimS6/7H8DAgKE1j5j7g9Ci16jRyCC8FzXGa1CWJ8ZQmiVS
         8elaBUDcUh/Guhk2eDM7IpOalqAINpnKUt0TFS7Grm0LVKYS42SmLPZg9ZlON5yTctqF
         fJAm0Eq0GI2XAMdz726AGS+zPfYNpE79eWpMpfMK2jT1DuYa29yi8LL9o8JKjgyzVtck
         pmKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=DwVu0TB0;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ZAkeXXEL;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id r16si1565865qta.336.2019.04.02.12.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 12:06:10 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=DwVu0TB0;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ZAkeXXEL;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 4B3BB21C57;
	Tue,  2 Apr 2019 15:06:10 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Tue, 02 Apr 2019 15:06:10 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=tRHgReLT3oOtyuahd5OJIneMe7p
	sB9fqOhUXYvm8M/I=; b=DwVu0TB0bBuDj1lZNjOpeldVkKgQyV/+QobDE6sSyDn
	doGE2BfKpnqPWMYAOmEa84n8QTYNrBxHM7yveETmT7YVBthnjm2KQ3ot52I9u0Lv
	MOraVi9ABRFs/zn8NUpFEQzKV+9FJzPkk8jz1JVe7pXiHhhllKH7cmp4O5s90SMT
	KyTK8yjS1vOReS0duyE+rQarqujIfnqQBWnni5ZnaSvS7+kaG4kR47z8TU286hOi
	nHPzCi94lvVNGV1tLZxFy2b3MaveVf8CFrw+et6YP21nBAGefWOy0nVjJW8s4Qw8
	h8ycf/QLKmSUf+EbiZg+YwEirQJmnj50MNU4N8VWvpg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=tRHgRe
	LT3oOtyuahd5OJIneMe7psB9fqOhUXYvm8M/I=; b=ZAkeXXELE4vDYclUgl6Y4c
	RLZxxGWZdIqjWIY7JIOu7a+KRfUhQrLB/Yi6zhUCXwEqQS/X1o0Of2Gfx3aYTD/e
	WdUozuvvlsZTUA8O7VwhZqWIvOT+wJx46//U43TspLr0PaJ5S3lX5w2uq927D80s
	p6IMZp+Mtqm9Ba8zjmeNgMgvBe8BrtyjAMCu6KzgiXlrv2bA3GCBYSNlxgFkVmt2
	QpBB+d+KysQQzVCUmehPUGlnJo4hhyyi1NOQ5Fs7yndd/VtoApvSRSp4xde/GECL
	HVXBVutHZrZHuxb0WRbtgn1bLx58Gk1sEAd7y7JovAH4Ko5LKIRlhOyfDI+xnjAg
	==
X-ME-Sender: <xms:oLKjXBTOrMqpTcEaqfRycN3wOaL5CY5NfGefnQHamWkcX2Z7UxDqWQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddtgdduuddvucdltddurdeguddtrddttd
    dmucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfv
    pdfurfetoffkrfgpnffqhgenuceurghilhhouhhtmecufedttdenucesvcftvggtihhpih
    gvnhhtshculddquddttddmnegfrhhlucfvnfffucdludehmdenucfjughrpeffhffvuffk
    fhggtggujgfofgesthdtredtofervdenucfhrhhomhepfdfvohgsihhnucevrdcujfgrrh
    guihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppeduvdegrdduieelrddvjedr
    vddtkeenucfrrghrrghmpehmrghilhhfrhhomhepmhgvsehtohgsihhnrdgttgenucevlh
    hushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:oLKjXEJIagNhapY_ZtTwDZR_S3rw24kOBhQuF9TWF_v952vMfKmbvQ>
    <xmx:oLKjXP-OJtkn7d0QYj_A9lZo1t7bfWTkt6y2GT9XDd2ECB8JK51S7w>
    <xmx:oLKjXMAq1UlhEqNmTO97x8DjE5iLtghGk687ktSWPZUmRhGkGqt-BQ>
    <xmx:orKjXHe8fFFfz9NFMPd5kqKu-yic0V2rq7jtDyv5wzxXtvz_vHjtng>
Received: from localhost (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 5803AE4210;
	Tue,  2 Apr 2019 15:06:07 -0400 (EDT)
Date: Wed, 3 Apr 2019 06:05:38 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>, LKP <lkp@01.org>,
	Roman Gushchin <guro@fb.com>, Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel test robot <lkp@intel.com>
Subject: Re: [PATCH 1/1] slob: Only use list functions when safe to do so
Message-ID: <20190402190538.GA5084@eros.localdomain>
References: <20190402032957.26249-1-tobin@kernel.org>
 <20190402032957.26249-2-tobin@kernel.org>
 <20190401214128.c671d1126b14745a43937969@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190401214128.c671d1126b14745a43937969@linux-foundation.org>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 09:41:28PM -0700, Andrew Morton wrote:
> On Tue,  2 Apr 2019 14:29:57 +1100 "Tobin C. Harding" <tobin@kernel.org> wrote:
> 
> > Currently we call (indirectly) list_del() then we manually try to combat
> > the fact that the list may be in an undefined state by getting 'prev'
> > and 'next' pointers in a somewhat contrived manner.  It is hard to
> > verify that this works for all initial states of the list.  Clearly the
> > author (me) got it wrong the first time because the 0day kernel testing
> > robot managed to crash the kernel thanks to this code.
> > 
> > All this is done in order to do an optimisation aimed at preventing
> > fragmentation at the start of a slab.  We can just skip this
> > optimisation any time the list is put into an undefined state since this
> > only occurs when an allocation completely fills the slab and in this
> > case the optimisation is unnecessary since we have not fragmented the slab
> > by this allocation.
> > 
> > Change the page pointer passed to slob_alloc_page() to be a double
> > pointer so that we can set it to NULL to indicate that the page was
> > removed from the list.  Skip the optimisation if the page was removed.
> > 
> > Found thanks to the kernel test robot, email subject:
> > 
> > 	340d3d6178 ("mm/slob.c: respect list_head abstraction layer"):  kernel BUG at lib/list_debug.c:31!
> > 
> 
> It's regrettable that this fixes
> slob-respect-list_head-abstraction-layer.patch but doesn't apply to
> that patch - slob-use-slab_list-instead-of-lru.patch gets in the way. 
> So we end up with a patch series which introduces a bug and later
> fixes it.

Yes I thought that also.  Do you rebase the mm tree?  Did you apply this
right after slob-use-slab_list-instead-of-lru or to the current tip?  If
it is applied to the tip does this effect the ability to later bisect in
between these two commits (if the need arises for some unrelated reason)?

> I guess we can live with that but if the need comes to respin this
> series, please do simply fix
> slob-respect-list_head-abstraction-layer.patch so we get a clean
> series.

If its not too much work for you to apply the new series I'll do another
version just to get this right.

	Tobin.

