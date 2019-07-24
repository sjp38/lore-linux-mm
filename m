Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 226E5C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:18:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2F0D22387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:17:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gGQOCJFz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2F0D22387
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FBC28E0005; Wed, 24 Jul 2019 02:17:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AB588E0002; Wed, 24 Jul 2019 02:17:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 672858E0005; Wed, 24 Jul 2019 02:17:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2228E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:17:59 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n3so17768333pgh.12
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:17:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1Xa50e3c+n/XgLreEXAZzM1/Dusmqf3jal/tdBSMEUY=;
        b=hh0gge+WI06proTsf5TUGU2ufJFGw/fNHeCZ6ep45u/T54smaSEr78aDVagZNS05zW
         Zubka8Xoc6C3IG/Rakutzh31UcHAdH1FXFVLnrxVNpscUuODFMmBdwNdNUup3vIDHtd+
         FLg0yz36daGYb+/GlRQ2Z6TPrdrtjNL/kEC+VoHpWHny8lmyo5rPU0kMGLv3op2MxXli
         U2Do4ynnaOKyINGygiAtFvFilf7hmYLt1P+Fq/Hf3MzJcRcGH/bSHkZpWyIYDvvQ5Ty+
         Hin9OOVu6x8013xEOz29vhmYpw+MA+EiAdQgSIE+BsQ51ECTU9M4/V6LT2jitL6AxSmH
         WsoA==
X-Gm-Message-State: APjAAAU8TmHOOQVlef+WKTq1GmIMzs+f1DD2coSWLNm58++FOaRl4aJ1
	kBjA/0ONJFfCVf97gC9sRXuWy74G1kiJfIsrbh1v2Xeep86xd9yvVImO0if/Vv/OZWUB2U2RdBE
	wqYHRsiAB3oYB+dLiKMdejgOLLFdzlG5zAT079cZhFiIoohRABmrJhTg432cUNzx9NQ==
X-Received: by 2002:a17:90a:7148:: with SMTP id g8mr19130860pjs.51.1563949078775;
        Tue, 23 Jul 2019 23:17:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKv1EoXNcG1IL0duggJLh7Qx6jlg/BNjTIiitVk32/jsJAR9Si8kEwvE0JT6PzJ7wHekam
X-Received: by 2002:a17:90a:7148:: with SMTP id g8mr19130816pjs.51.1563949078077;
        Tue, 23 Jul 2019 23:17:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563949078; cv=none;
        d=google.com; s=arc-20160816;
        b=cp1oCd35tNzVjQqBhdOy+TLwzYVmsGoggN5lx6UhhfXzjqNOWUDxeI/d/XHpMB6zGt
         7FBS3VEYeIDZ0hkNkUzflsYUYjgPfxedWUhBG+CcyhC98/kRhwy13lxdIJKSFMiOBu98
         JR7eh2M1rr/KhLogu1UuKmfjvnvxULBruPTKwdYEvv1BmEa5bhbZaGGWfmyjiQ2iHUKN
         iHzDsIGXFndt4AiTkemLU3ubo3TVh5WkPKFsU3gYoxSAjN43v+cUzU2WzkyBAWceZYvE
         thlnlFuO15R/dNORToSTpW2zetMf/Iq2Xioiv11Ob00OjJQQQKtlba/JMN/9RcdXId5x
         w/ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=1Xa50e3c+n/XgLreEXAZzM1/Dusmqf3jal/tdBSMEUY=;
        b=zQdnmERkl6oUIk/SJ8w+L/CfVWy7okalhlVzdKCQNSmep5VNi3nUZGVJgCnMYUiPLy
         +smRYnzyPyLsQhKeJrVJ7ruaU5YziinM2DU0t97K+Sag4XTw62lm1vnpEtiW/cQZRpYf
         xFD8wYRX6b5YEqPDkh5dQ/BjhPzXjTJ7o7i/csAq8K6SIDPLzkCt6jnmm7pO/cTYv3Pt
         MpcB3Wm+QFwC2Bd94aYZVRko1yCpEJJj0wfwNvqyZusYJfH33tJ82t3U3mEahzn157Kb
         +epPTSGw4lUQBTZs2+CtGEwakFBYWIJ2YRJZAyNZ675MifCxKgBxv6TengAxcTyfyOO4
         2LhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gGQOCJFz;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 67si16341590pfv.74.2019.07.23.23.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 23:17:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gGQOCJFz;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=1Xa50e3c+n/XgLreEXAZzM1/Dusmqf3jal/tdBSMEUY=; b=gGQOCJFzwPHRaT0Y5VpwBtWJoQ
	7N90/JQMzvZNdlZpfiJ/+4M5wIFkAFW6SLRu80CqjgQtsuC25Bn72Ra55U98FUrqDgFJii1g2Pk+v
	XPvWZXVP7/4TvQIWdHMJJsTBcEyaiNbtoPg+JOyeFN2/iHN+j8DiH//YTyjVYst2eZdJNW8GDmmaH
	1tpuC3lNNf/w0GceJkPRPaBB6JdiZZSZVJOlr+inma1SfS2sXWO/g3eKnofUKFN7B7pQL3769+3TW
	jCOEK61cTU+A0p4axGitNuC4cMeg/ZDpW3Ry+2Ff0HYkYs0+KxmpPcvICLo1Gula2Bgy/8Zw4ackm
	7GUAhyFw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hqAb0-0007QP-TP; Wed, 24 Jul 2019 06:17:50 +0000
Date: Tue, 23 Jul 2019 23:17:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
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
	virtualization@lists.linux-foundation.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 00/12] block/bio, fs: convert put_page() to
 put_user_page*()
Message-ID: <20190724061750.GA19397@infradead.org>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190724042518.14363-1-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 09:25:06PM -0700, john.hubbard@gmail.com wrote:
> * Store, in the iov_iter, a "came from gup (get_user_pages)" parameter.
>   Then, use the new iov_iter_get_pages_use_gup() to retrieve it when
>   it is time to release the pages. That allows choosing between put_page()
>   and put_user_page*().
> 
> * Pass in one more piece of information to bio_release_pages: a "from_gup"
>   parameter. Similar use as above.
> 
> * Change the block layer, and several file systems, to use
>   put_user_page*().

I think we can do this in a simple and better way.  We have 5 ITER_*
types.  Of those ITER_DISCARD as the name suggests never uses pages, so
we can skip handling it.  ITER_PIPE is rejected іn the direct I/O path,
which leaves us with three.

Out of those ITER_BVEC needs a user page reference, so we want to call
put_user_page* on it.  ITER_BVEC always already has page reference,
which means in the block direct I/O path path we alread don't take
a page reference.  We should extent that handling to all other calls
of iov_iter_get_pages / iov_iter_get_pages_alloc.  I think we should
just reject ITER_KVEC for direct I/O as well as we have no users and
it is rather pointless.  Alternatively if we see a use for it the
callers should always have a life page reference anyway (or might
be on kmalloc memory), so we really should not take a reference either.

In other words:  the only time we should ever have to put a page in
this patch is when they are user pages.  We'll need to clean up
various bits of code for that, but that can be done gradually before
even getting to the actual put_user_pages conversion.

