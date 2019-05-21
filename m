Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20834C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:07:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3C76216B7
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:07:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3C76216B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DD5B6B0003; Tue, 21 May 2019 05:07:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78DC16B0005; Tue, 21 May 2019 05:07:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67CCF6B0006; Tue, 21 May 2019 05:07:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 161CA6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 05:07:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z5so29746602edz.3
        for <linux-mm@kvack.org>; Tue, 21 May 2019 02:07:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iFTUHFmgtiGzvN19St5ee/oHBMyKgoEoF5VVcqVSvpE=;
        b=YN5a8P+u6+unSXd5cvy6koGKer1H+JYRYKlgOkUAUf4F2Src0wa1LTlqsdkOfvp1yL
         bxvsbVS/HpKYELoFeDNQr/BgiobgdLk6JIOv55VTFYWpdKBlKCZWbWKaktTKqdEGaSsB
         xZjc1ijVRnDtzf3y47WrsGRw9aQUm/79JPJe4sqJ+6kVSiggx+uiLmmC8h5nX4xa8Can
         WR7ynstgEQ4EjBp+w6qygxK2ys5lXELQMfHsLSumpAlc/rWxpdsD15cwwfWkmWTKjZtP
         35sn0ujaC02v1N/Y5gICK5qQuxt1b8vxBvDeFcNVhecene5Jilhi9e+99Ao1uygMSlse
         W6Vw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Gm-Message-State: APjAAAVPgm2yCkn2MshN7mXjsiIcQ78duBKfGka9DuNGqi2/CaBHQMmi
	0RJ2Pxj/FUp6TxeTxv0t6+3KUq8IgviU1FBJy/UYeOmw5F26lbeaGhEgJJB/yyv9rLM4tkPkSyL
	ky8iXBfMTOAmzdMe3VVUkBNkbPzQWRc5KBksYaHg29ZPK20JQQGlo5YDCeCQPyTo68w==
X-Received: by 2002:a17:906:eb97:: with SMTP id mh23mr63947779ejb.69.1558429656649;
        Tue, 21 May 2019 02:07:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYkHl24oBoCKXMH1htPGV22OOM3FtCcdzolicNFvmVQXI3U+Rj6nLy9qRnDKTbXCv4jNny
X-Received: by 2002:a17:906:eb97:: with SMTP id mh23mr63947732ejb.69.1558429655904;
        Tue, 21 May 2019 02:07:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558429655; cv=none;
        d=google.com; s=arc-20160816;
        b=qPfigYg9n01uAneaxqxjAcqtM+S/Sa+dtkIJuyeM8WweUdNMAtggoHxZc841jU3R6q
         C3v21Tct51aSiQU+NK3aRR+nYEn58ELJhA8q2l/qaA99KKjTl6r25kahdzvPAKRbePAi
         VoQQCXSM7wTlQ4EORCEP7l/bj3FeqjTckBatAoXWkHbkxJ8sMfgbLg/xdoG2Un/PZi8g
         W1zbEJj1TxTNqiA/bAHxJ8QVMjuApYTfTf5hzgYf4e6zEkjOa3VC5cZshCwUf1kI//2/
         pfIzWurwp/CwYZusUs2p4925GJOpVvAC/Qv99fmrHGW+6gf34xwLsXBpf/kT5OS/sLhH
         AZjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=iFTUHFmgtiGzvN19St5ee/oHBMyKgoEoF5VVcqVSvpE=;
        b=lrCFEkqLC5je/7aTyOKMsRH8UxRTmk4KXTUu8yAt16NX4z388/ZdfZQnrU0FbYCqLa
         34h7zvQUqCMEsj57H5U5K9Rrjp3H2avvOVdBz3FiaYH5LgcS+P6mcfJ3rmMW/aeavA4l
         Em6TTkwHqqwSs+tibcCorU/aA0aMx6pyQskwolsYhy96ecagGzqgNbo/iQy/FtYXzCl3
         9WIioaKqQ0wj4IqYyySFzbUUt3oaVsp2PDDWHIHhQyT7ySrm+sDaZ1HzyuLex2jXMLWD
         M94Y+svsMX3EfuJ3OiqwbVtiifMldQ3grlVjT1p24WmzzUiSXG91yTQouLksz2ZwnGMC
         /SBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s21si9263011edd.100.2019.05.21.02.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 02:07:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 42ADAAD43;
	Tue, 21 May 2019 09:07:35 +0000 (UTC)
Message-ID: <1558428877.12672.8.camel@suse.com>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
From: Oliver Neukum <oneukum@suse.com>
To: Christoph Hellwig <hch@infradead.org>, Alan Stern
	 <stern@rowland.harvard.edu>
Cc: Jaewon Kim <jaewon31.kim@gmail.com>, linux-mm@kvack.org, 
 gregkh@linuxfoundation.org, Jaewon Kim <jaewon31.kim@samsung.com>, 
 m.szyprowski@samsung.com, ytk.lee@samsung.com,
 linux-kernel@vger.kernel.org,  linux-usb@vger.kernel.org
Date: Tue, 21 May 2019 10:54:37 +0200
In-Reply-To: <20190520142331.GA12108@infradead.org>
References: <20190520101206.GA9291@infradead.org>
	 <Pine.LNX.4.44L0.1905201011490.1498-100000@iolanthe.rowland.org>
	 <20190520142331.GA12108@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mo, 2019-05-20 at 07:23 -0700, Christoph Hellwig wrote:
> On Mon, May 20, 2019 at 10:16:57AM -0400, Alan Stern wrote:
> > What if the allocation requires the kernel to swap some old pages out 
> > to the backing store, but the backing store is on the device that the 
> > driver is managing?  The swap can't take place until the current I/O 
> > operation is complete (assuming the driver can handle only one I/O 
> > operation at a time), and the current operation can't complete until 
> > the old pages are swapped out.  Result: deadlock.
> > 
> > Isn't that the whole reason for using GFP_NOIO in the first place?
> 
> It is, or rather was.  As it has been incredibly painful to wire
> up the gfp_t argument through some callstacks, most notably the
> vmalloc allocator which is used by a lot of the DMA allocators on
> non-coherent platforms, we now have the memalloc_noio_save and
> memalloc_nofs_save functions that mark a thread as not beeing to
> go into I/O / FS reclaim.  So even if you use GFP_KERNEL you will
> not dip into reclaim with those flags set on the thread.

OK, but this leaves a question open. Will the GFP_NOIO actually
hurt, if it is used after memalloc_noio_save()?

	Regards
		Oliver

