Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF542C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:51:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AECDB204FD
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:51:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AECDB204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B8A98E0008; Tue, 30 Jul 2019 11:51:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3427E8E0001; Tue, 30 Jul 2019 11:51:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20A768E0008; Tue, 30 Jul 2019 11:51:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED5188E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:51:42 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id t24so6681203uar.18
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:51:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=zFm98YUZt8SSxDLWbzkJjLxO1K6BQyYHVwPwen6Oeho=;
        b=llVUNzWGVu0rMmpa71NkbLnvEAWgFCXy5pr7fk1flQi2+Lyszs3Tx3DSwS4V22QA31
         9RuMuIWSFbIaAOk1WU6SuhiIbyiMFZ/w5tpU3ByUpqiV80PF78oRFZI01ZggXVRZvaig
         I2MklXKVxJbbDppP0LlFOshAgQGpW9FvdLVWIVA6leKIf9KdudDsFZmPobxuP27VeNxf
         mDP/0bnFrHadhrcQjVU0i/49LXg5hIsDSqKYB5ypBcTv2wGzbuhIl4B+aJ65amD9VRDb
         ASKfKHyRA0sFd/p0GqkPnG6q5VoTC0B51RVrxnEOPge4DAAfHcco4X654SFEYjaI3E8z
         w2KA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUzQSEszwugKZ+YDNQMXESSQlY8Wi8k0ipF75UPKFWoq2a0TDTd
	m27PZJAuGImmPORXFjC1zZhtlhZiZb5F6GdqjQwy0hyGxeVOYTweklEUZagaGVnV5rBRUluNLAY
	jyNxIMAwmshTYVE1rcgdyJcU96USSrk2GVvQSYVr1FZ2znHxyr3gcTVgIWFNcWr+XXA==
X-Received: by 2002:a67:f1d6:: with SMTP id v22mr70903290vsm.178.1564501902721;
        Tue, 30 Jul 2019 08:51:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzf5PNXL6gMSNAUUgL4eEEw0ZGIgRtQ8h2aZMM2WdYX+ki7uZfAXMH438Uik+jA9CLd3OdO
X-Received: by 2002:a67:f1d6:: with SMTP id v22mr70903215vsm.178.1564501902151;
        Tue, 30 Jul 2019 08:51:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564501902; cv=none;
        d=google.com; s=arc-20160816;
        b=i0qMhldk4Ir/tNsRl5FHFe6zELzir6hw/5YwShchQR1ybn/fACdb7aPtbtWSqSSHYK
         RTcwc+iypmP6e4O0dDw96iK7soJtgZsEv/hgC+6iUwyV9wSp8xsl72QxDmgTsUOu2Wnm
         gHjFoKguCbzzU/l7DoAKA9NOr54WC8VJraCaRgTzJcy3QU4Ut7dbDiJ5hf6IhINNmSAm
         WV1Jy6ITgA3yv/Shnv2jeRGwJcZeTfnMQQqRAC/8CA4mgZwKjWlJ3Tx1DIYz2fl2hPed
         hXIno9ubNWWM6xZdJQkhEpk/fmSygW/Ow1aAvwgd020h0bykP7m55d1L30hYZJKPJBrs
         uNFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=zFm98YUZt8SSxDLWbzkJjLxO1K6BQyYHVwPwen6Oeho=;
        b=ZRKViM71Nr//q7PtNo2bO6wUSTZJaL2xxSHDfuRn36MGPrzvC9GVuG39x+VC5MrOZT
         Bl3pXA0+mMMdChrrOZGULmW4LV/S4fv7ifvYP6l5xUdhfBr2p6Mx1vd3tUKXZwNHQ6kv
         Ic/wOvQs4Bsfh79eqjcs4x06KETqVQEf9XnzMCIjgysd5+xf1Z92N12pz1wpZhH36IT2
         MBhOUl+N7z4u6KiMSltRoEq3yHuNWOJrMyxnKHgTN80Ejx5gPy+9CATufYBVVenuqTmw
         9MH9dKmezZeSzj8NNdQ/gzH5+zlPDwY+m22ZOeicJB7o/B5dfy705xFSOuVhcv1FhiIw
         TkmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p12si9907570vsn.368.2019.07.30.08.51.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 08:51:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BBA843E2D3;
	Tue, 30 Jul 2019 15:51:40 +0000 (UTC)
Received: from redhat.com (ovpn-112-36.rdu2.redhat.com [10.10.112.36])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DFACB608A5;
	Tue, 30 Jul 2019 15:51:37 +0000 (UTC)
Date: Tue, 30 Jul 2019 11:51:34 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 9/9] mm: remove the MIGRATE_PFN_WRITE flag
Message-ID: <20190730155134.GA10366@redhat.com>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-10-hch@lst.de>
 <20190729233044.GA7171@redhat.com>
 <20190730054633.GA28515@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190730054633.GA28515@lst.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 30 Jul 2019 15:51:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 07:46:33AM +0200, Christoph Hellwig wrote:
> On Mon, Jul 29, 2019 at 07:30:44PM -0400, Jerome Glisse wrote:
> > On Mon, Jul 29, 2019 at 05:28:43PM +0300, Christoph Hellwig wrote:
> > > The MIGRATE_PFN_WRITE is only used locally in migrate_vma_collect_pmd,
> > > where it can be replaced with a simple boolean local variable.
> > > 
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > 
> > NAK that flag is useful, for instance a anonymous vma might have
> > some of its page read only even if the vma has write permission.
> > 
> > It seems that the code in nouveau is wrong (probably lost that
> > in various rebase/rework) as this flag should be use to decide
> > wether to map the device memory with write permission or not.
> > 
> > I am traveling right now, i will investigate what happened to
> > nouveau code.
> 
> We can add it back when needed pretty easily.  Much of this has bitrotted
> way to fast, and the pending ppc kvmhmm code doesn't need it either.

Not using is a serious bug, i will investigate this friday.

Cheers,
Jérôme

