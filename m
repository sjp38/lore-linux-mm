Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E6E8C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:35:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D4C8214C6
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:35:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="otE89qYM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D4C8214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BE4D6B0003; Wed,  7 Aug 2019 02:35:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06F596B0006; Wed,  7 Aug 2019 02:35:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA1C36B0007; Wed,  7 Aug 2019 02:35:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1EEA6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:35:17 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y22so50067128plr.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:35:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=h/YO9E7Kk2GlCfqzWsOaLMxcaYYFJaO+2uQZpeggUB0=;
        b=rf3j5s6Q4ObZv8ZmWeZ2PsRAWrG2/cRr4UE1X0dQaRJP9Xfj7lM16MW3yNNmdbv0uy
         8ojw05mLLSasOyHCjUuHTBoMOp5v6qqXb5y/HNxKxrijnIFmRKvUHf73m/m+CQrLpuK5
         5j/uAmxhCTRZn2wHQE3irpT78xaviurzQ7IxqpabQsUSJiXqUnqbXsXVzKjtOhD+agO8
         Sy8JC1OErLImgzMWxj0T/4PSPhe7kiPUxdjbVnRSPlPghsmYXl3SyCcb7jd/GMwHTWav
         FiaxeN+Idxum2/fKyWE3P1PDuRUp6IJCgCzayACyi3F98CVe3+6vSnYPVr1+8rtkFAUq
         3aMQ==
X-Gm-Message-State: APjAAAVqwJ9nEYyXRS45XyA0NkTHBXrfdPWb1hQWxem+Uo4iYWYDCLJH
	i7/CtaL3jv/xDVn7t1WhSwLrNxj7hiFX82NATGFbTSmGehlbMMVQ+DGp7q0925f+cw+wePfpYPL
	rj7TAIXZgKCTf6Xhu4o0USSpUnsOCue4CwOQGnOnJf/AUe1OJghNwBK6d3wmzYdc3xQ==
X-Received: by 2002:a17:902:8a94:: with SMTP id p20mr6725363plo.312.1565159717214;
        Tue, 06 Aug 2019 23:35:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymZyBxaR5rv2OaxLR9QM3ZazqgwrBX5rsWhCSPLfrFDz5fu+SNSSqD650DxFAFM0bY9D03
X-Received: by 2002:a17:902:8a94:: with SMTP id p20mr6725318plo.312.1565159716375;
        Tue, 06 Aug 2019 23:35:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565159716; cv=none;
        d=google.com; s=arc-20160816;
        b=0bxvTDFKgBhX56serEThNxdZ1QBoUj67hAG/6i0x5e1UtK0yyNmosYiRlZcb8ehVJP
         jW5G/evmwmOL6Eif0cA+aCZ69l4mHcWFnzVlE09qeQiXBrYn3UbBf+MfMOKGs1Zgo/sa
         FgRIG928L8PLxxJS/kjefiR4DEH1kh7OSA+pkSTnDQZm5LycFS7NwXHNToUq1D3hUbrO
         fyZATn9DdfSoOrXRoMCCdw+DQGWtG4D/0QSAWswnDqDZTQRwb+g5Z5sLlgY6+BEeYEcn
         hKe/dyMihewmp0v9FvoFGhn1cLB8HvEnvLbrbE/Q3g1bSDBh38pah89+s0FZylG19AlJ
         w9IA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=h/YO9E7Kk2GlCfqzWsOaLMxcaYYFJaO+2uQZpeggUB0=;
        b=Q2O1bi7R9TpDo90z4sW6bWxYbNMrJNbZref7Ym9qm0cTGiFmg3L/FP1rtvkN9s4WmZ
         /S+m10ygpRUHni2F8nwIlNPtLHBHNSjHnaFSgBs4je5dpVEpslVs50Pm2+cMJ6TOBa3R
         Pn4G5DWR6iO00FC+XVLl7/Zyw1o0dF0HjOpDNTi6SPuv8lAgCLu2foyd9Gf9mPrleCDF
         ao9uxW5g4iht+wmjJ2fOOuGW2cUptq0EzqHevyAZDDArWAaX6hFSCpW9eNgiQgIuRubD
         zQK3KDK0hpQ7pf6OJc35rSDFLJvaHdQ4kmHJE3RNjd1KOk+3gQlJ7Neb32KKbX+AAeKs
         L40g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=otE89qYM;
       spf=pass (google.com: best guess record for domain of batv+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z72si50219149pgd.34.2019.08.06.23.35.16
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 23:35:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=otE89qYM;
       spf=pass (google.com: best guess record for domain of batv+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ecabc3e5d1f7686a0adb+5827+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=h/YO9E7Kk2GlCfqzWsOaLMxcaYYFJaO+2uQZpeggUB0=; b=otE89qYM9WmETe4AtaYSwZhaVp
	x2hWnzTkK/+H6YrywBw2CCvGkAGS0+cMqYBTGZ1bytkCsNKOywsxuaErRoaQPCJFZ74nyD+BaWD0D
	Fqio4bMq3iSkQd4EZDyn1AS+qiOZ+zvMv6fNRqFHw53t3ciAgH4Z1x8wvN/D7EYKreU7FK2EDXOVj
	PtXuttuf2InvZsTot7swxCxX4U2Gh/2vRud2yGtuCEvw7oeWsTGK9Fxhm2aMTINFjUbhDSIHyQW9d
	1InA9ls8uWP73McSrAt6icdTTX2iY22SDv4qsGs3F3dJNdqSF3NdiMXvEekNoqV5nkE99PNfKXpGY
	TVYojzfw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvFX6-0004to-Ui; Wed, 07 Aug 2019 06:34:48 +0000
Date: Tue, 6 Aug 2019 23:34:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@infradead.org>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>, Latchesar Ionkov <lucho@ionkov.net>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org, linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org
Subject: Re: [PATCH 00/12] block/bio, fs: convert put_page() to
 put_user_page*()
Message-ID: <20190807063448.GA6002@infradead.org>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
 <20190724061750.GA19397@infradead.org>
 <c35aa2bf-c830-9e57-78ca-9ce6fb6cb53b@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c35aa2bf-c830-9e57-78ca-9ce6fb6cb53b@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 03:54:35PM -0700, John Hubbard wrote:
> On 7/23/19 11:17 PM, Christoph Hellwig wrote:
> > On Tue, Jul 23, 2019 at 09:25:06PM -0700, john.hubbard@gmail.com wrote:
> >> * Store, in the iov_iter, a "came from gup (get_user_pages)" parameter.
> >>   Then, use the new iov_iter_get_pages_use_gup() to retrieve it when
> >>   it is time to release the pages. That allows choosing between put_page()
> >>   and put_user_page*().
> >>
> >> * Pass in one more piece of information to bio_release_pages: a "from_gup"
> >>   parameter. Similar use as above.
> >>
> >> * Change the block layer, and several file systems, to use
> >>   put_user_page*().
> > 
> > I think we can do this in a simple and better way.  We have 5 ITER_*
> > types.  Of those ITER_DISCARD as the name suggests never uses pages, so
> > we can skip handling it.  ITER_PIPE is rejected іn the direct I/O path,
> > which leaves us with three.
> > 
> 
> Hi Christoph,
> 
> Are you working on anything like this?

I was hoping I could steer you towards it.  But if you don't want to do
it yourself I'll add it to my ever growing todo list.

> Or on the put_user_bvec() idea?

I have a prototype from two month ago:

http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/gup-bvec

but that only survived the most basic testing, so it'll need more work,
which I'm not sure when I'll find time for.

