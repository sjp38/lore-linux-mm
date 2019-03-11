Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D5B9C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 13:59:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6578C20657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 13:59:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6578C20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EC878E0003; Mon, 11 Mar 2019 09:59:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 075928E0002; Mon, 11 Mar 2019 09:59:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7FE28E0003; Mon, 11 Mar 2019 09:59:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C2E5A8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 09:59:33 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id b188so2969264qkg.15
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 06:59:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=77FPPr8GBQjFVtWgXmaq2v1wGWOsJ9spQIX6jZegB34=;
        b=IXN5/bFitwMvSOQxR+BnAMED6NTxq+jD4ohAroL72LR+zXc96YqJFVYTluXPiNd5dm
         21miNk4vE4kcZltrMEjtiO1/m7n8xBhhi3XXgfqqtsg1P3Byyxa/DEeVIVbmKvattbu1
         fdiYQP7pDqdFnTHWLgSj3dKQmdw0M7f664QF67cOdKcDlPNcPJrR/ep2KpYuDtpG3YR7
         cXuhx4k9OOfNhRoJQJ4P/8mBWdB4/OEY+nVuetVtxPK033Iw57CTASiIVk7UHXtaibB3
         SU3PbDbWlqD+6+vouODmymb1TbuyyPfROPkif1c8E1GS8GMToctuqyE5CppDXXdP+JpP
         5RAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXI+iuQutt8wKYXMGdtOa1Iy6MS9SjjF5+DlGnNygagZd+6mySB
	6A1bKIDoHW744n3rTpQN1eWXA+yFuwniJFdSm6kENzZWgU4mS5GUVlMzn5qLhQPOf4erMJP7R72
	s67Man33/XjH2NEjUb+uVyf+OMhGfG+tuBp2XtnYakoaivIJtVuw1H/uMqtYHCypxHK6YhNCxRY
	BYUlO5RGFt74Ovl1iUXcF4QaT2uoaQVynZ1EqzAFOvQQjtbXN3jNADyCUNdrNAKXcu0KuVkK8zo
	REByUlHBQiw4o3V1t1J6BHD7bw6ksmvbHHiIZ5xFCXTQmIJsRUXx30PpyIu3/oRCfTHRCEMcRay
	pTrniPVIfamNs96uWxo1TRVph6AIalFs0MKJmuhphXgzO9mF/fbvW20EUpPTz9CKmshEIqr2HlO
	7
X-Received: by 2002:ac8:3896:: with SMTP id f22mr25170444qtc.324.1552312773524;
        Mon, 11 Mar 2019 06:59:33 -0700 (PDT)
X-Received: by 2002:ac8:3896:: with SMTP id f22mr25170404qtc.324.1552312772882;
        Mon, 11 Mar 2019 06:59:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552312772; cv=none;
        d=google.com; s=arc-20160816;
        b=PTW382VE92+zo+vnGI+3qUDPFYYQ7kXBwJ4rnVsRJW7iO8/D76sEm5U4lBdY24eHHA
         3i01506BYNPFR1XZiggnZYvqFGmc6PoTnI0Xekb9lE5XHtKsuFGzF4RegYdzkaZewXtr
         s4l5hIUqbejYlSNVqFKIM9/et/Q+RqGt33Ien+Pn4liI4qLwqo/SJVmIqmVKWEbIObcV
         irtozm9LHZKxuYuQhebxMBILbYZN3/fELPk1cu2e3ROt9n69MWtVKWcF7Yt3FPtW7y0H
         YrFUnbq5DyhVo08k1UzKi/O310Glu4XKL7+PzmnHXWPJlShQr+T/30D0/JaO02RU23ER
         7yow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=77FPPr8GBQjFVtWgXmaq2v1wGWOsJ9spQIX6jZegB34=;
        b=EHfbBN9hxprdDCPGwWKdWPdhmjtwomNCXpcsoA/VStWrgyy6mUEmf+phK6b5kGkadk
         4p9lnPuvDZ3lCrgKAcSkPMVyGPtFuiugS41ZFl6nZtDzINy235T6h7Ku53i/UQrpSaUH
         6nlWgB2aftGTb55+k+wD+SB4yjxXzVyH7I5a+82dkdsFkprPLcZ7YEw1ddryGkQm18Eg
         UiXgED8QYY1suaxvNoJoNXPoomwQ8xRSYPfDJcI+ekl0umqt9z/swBc6v4xFUnqUCNJC
         yQVPQz1iwSkCalerCRxZMLJ9nqwtZSsraJIg05WRe4CxzSIG5OukqTYssBlbYzZT+MBK
         sHvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v13sor3321901qkj.140.2019.03.11.06.59.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 06:59:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw9YjGDnhJ+1jlpw7LNXGz4dlHhYvGe+8BN/PnyfIJlcNuYvvhADur74p7uAUvRCtKs8Sg6Ow==
X-Received: by 2002:a37:464f:: with SMTP id t76mr7443872qka.353.1552312772629;
        Mon, 11 Mar 2019 06:59:32 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id r24sm3623959qte.60.2019.03.11.06.59.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 06:59:31 -0700 (PDT)
Date: Mon, 11 Mar 2019 09:59:28 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com, linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
Message-ID: <20190311095405-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <20190308141220.GA21082@infradead.org>
 <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 03:13:17PM +0800, Jason Wang wrote:
> 
> On 2019/3/8 下午10:12, Christoph Hellwig wrote:
> > On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
> > > This series tries to access virtqueue metadata through kernel virtual
> > > address instead of copy_user() friends since they had too much
> > > overheads like checks, spec barriers or even hardware feature
> > > toggling. This is done through setup kernel address through vmap() and
> > > resigter MMU notifier for invalidation.
> > > 
> > > Test shows about 24% improvement on TX PPS. TCP_STREAM doesn't see
> > > obvious improvement.
> > How is this going to work for CPUs with virtually tagged caches?
> 
> 
> Anything different that you worry?

If caches have virtual tags then kernel and userspace view of memory
might not be automatically in sync if they access memory
through different virtual addresses. You need to do things like
flush_cache_page, probably multiple times.

> I can have a test but do you know any
> archs that use virtual tag cache?

sparc I believe.

> Thanks



