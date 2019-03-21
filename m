Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 468EAC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01D0821916
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:44:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qZRSNs7d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01D0821916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 918E36B0003; Thu, 21 Mar 2019 17:44:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C9FF6B0006; Thu, 21 Mar 2019 17:44:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B84F6B0007; Thu, 21 Mar 2019 17:44:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 373BF6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:44:05 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o24so151801pgh.5
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:44:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i7m++E+Xib+uDsp7WuM+xF5x1nfGX9p80KlO1ZOhiz8=;
        b=DdSpafFxJr+IYOsX6JkvcPfUatqotX4s1brIccRY9ZtSk7NMA3ldEQQsutKTdWKB/D
         iMwXOnw6RWkLr1Q9YlO0QbI1c9c0Poi4NmtYpVjpGjt4BMU5xr54tK0xQpqD1CICD1f/
         Gj64TI3XkRp1TpNIPw+yGHdj/fl+adOBSCLx8IQFb9I5HF/FREYeTKOVnOPbhkasssBa
         rv2kDAZtAlqHv+EuPbPfnDWS1aluEysjdHLSXDCl9ILBBKbCeTYZYPhxV6vo/YcGe7Ui
         59HWjtCHjaBa+NYkHfPl8J8UG4AvuC1MQfatFb79Ik95V3gYk+Yxl9jJsMb4cwCd8sYv
         UBHQ==
X-Gm-Message-State: APjAAAU+bOGT61p2Hr4Doc6S4F+bMKVbeR2ISB5u7gToQxTMqgMiffMo
	LZMyO3K8yE2mRWNQBBukLNScJhh7Vk0LiEfjyRPfvTClR8Io27SdtrBCLQ9+tCiKFfUYX6BE9tW
	rCt2FVlTIlfjeRk4v9l3BIW7d5gvGaXE28ra6fRQkhNGWmvTSl9sRydq+9/I+Kdf9jw==
X-Received: by 2002:a62:b508:: with SMTP id y8mr5629478pfe.140.1553204644890;
        Thu, 21 Mar 2019 14:44:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkCdSCq4L2JJOqQOwChMr/LSyxffZSR+sf6vb+QgOlE7zj3grNcexx/iaEW163dLLhZUUL
X-Received: by 2002:a62:b508:: with SMTP id y8mr5629404pfe.140.1553204643789;
        Thu, 21 Mar 2019 14:44:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553204643; cv=none;
        d=google.com; s=arc-20160816;
        b=WpvW9ZtjgSlfXGae3Y3ooqkvIAFcDi5R/R4u9ZIrJjXwKZ6Ydu1fL207fiPVW7D/GZ
         c6G2LVpNaMuN5JwraVy2+1b0d3o584lSnoYQtZ92cJU3VudpLe7l70iosYuJwbThTIhJ
         kLXdxbiNca6FDl0ctc2o3S453FLCufjRjUkoSuz/l3Zvm/PLcAWiZ1rkCqwIJz6nokzY
         Jftw27g40uV72KTgjWcuf4CYBkgIeEq/oaZtH8IdA5CvZjb+8Hfc/bFLHvjjRIXJAgnQ
         lrOylniS9Y4hWbhBKsOZmhD5PmMwTNjqiBAy5zi9vhZK5uQ05m4S80Xlks7TAuLu1Mpm
         WbAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i7m++E+Xib+uDsp7WuM+xF5x1nfGX9p80KlO1ZOhiz8=;
        b=y+OfcWSCtpGZc/u6LgyuMqY9SY/K/6v6HDROFFHwiPqnRJlrmlSJo4GEkX35ZoaCLy
         BAPLuRW36H47mZK2krJ5BxoQii+1hK0VxfKx29BZ3H6cJ3rZByPpwSJSCDoEzzcCvdf7
         4cW2D6lKB53+bsFB9r78y6sKQtV8Bk6Em6tJV7LkT2z1SDvdXiYQlVk+u8LU+gcatj0S
         quUX0sDEC8FSUYmqAH8e9QxktzYiQ0HBdHap5D2VdOiPMOphGYZIDHBRoOhaMKXkl1xd
         2+Bz8a927RHgKneSE6F0SBWeJmDTFZwXnYqtJSBXad7RTIBKWUIKclFr84cYbo8bMFYu
         tmkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qZRSNs7d;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k1si5292336pls.208.2019.03.21.14.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Mar 2019 14:44:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qZRSNs7d;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=i7m++E+Xib+uDsp7WuM+xF5x1nfGX9p80KlO1ZOhiz8=; b=qZRSNs7dCUzn/FgvE+RBp5GcE
	PyFCIgy9sr+dhqNHb55IbM6O7+1jai0tmbHue06hJi1edHn1UxaaRKm4DFMYlL8CpYyYeysf5KeUn
	B4vUDi80+/c0e370T4+Ulq24ijI2SUc4O+ZJDXmVnL60LUBPr+8tKW4pgkUbMv2pF1nHIBgDJkeel
	+x2ngxtknSWuHspHItqADpzmtfxqjHz6LByUJd4+/TRSpI5BKRQHS3eHFhQ/rPj1nL3/+wjOUUG3S
	e7i8rOk++iorCbY3nYIjGRlsHLrYTPoOtmvHjWT7xQXsJpOa3PUK8lw23o+BU6XEzyeijCOp9NV+u
	jxcQYknxQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h75Tm-0002fY-4W; Thu, 21 Mar 2019 21:44:02 +0000
Date: Thu, 21 Mar 2019 14:44:01 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	mhocko@suse.com, rppt@linux.ibm.com,
	linux-amlogic@lists.infradead.org, liang.yang@amlogic.com,
	linux@armlinux.org.uk, linux-mtd@lists.infradead.org
Subject: Re: 32-bit Amlogic (ARM) SoC: kernel BUG in kfree()
Message-ID: <20190321214401.GC19508@bombadil.infradead.org>
References: <CAFBinCBOX8HyY-UocsVQvsnTr4XWXyE9oU+f2xhO1=JU0i_9ow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFBinCBOX8HyY-UocsVQvsnTr4XWXyE9oU+f2xhO1=JU0i_9ow@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 09:17:34PM +0100, Martin Blumenstingl wrote:
> Hello,
> 
> I am experiencing the following crash:
>   ------------[ cut here ]------------
>   kernel BUG at mm/slub.c:3950!

        if (unlikely(!PageSlab(page))) {
                BUG_ON(!PageCompound(page));

You called kfree() on the address of a page which wasn't allocated by slab.

> I have traced this crash to the kfree() in meson_nfc_read_buf().
> my observation is as follows:
> - meson_nfc_read_buf() is called 7 times without any crash, the
> kzalloc() call returns 0xe9e6c600 (virtual address) / 0x29e6c600
> (physical address)
> - the eight time meson_nfc_read_buf() is called kzalloc() call returns
> 0xee39a38b (virtual address) / 0x2e39a38b (physical address) and the
> final kfree() crashes
> - changing the size in the kzalloc() call from PER_INFO_BYTE (= 8) to
> PAGE_SIZE works around that crash

I suspect you're doing something which corrupts memory.  Overrunning
the end of your allocation or something similar.  Have you tried KASAN
or even the various slab debugging (eg redzones)?

