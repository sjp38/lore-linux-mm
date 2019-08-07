Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7247DC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 19:58:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05B962229C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 19:58:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NKiybbKg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05B962229C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 654AB6B0003; Wed,  7 Aug 2019 15:58:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 604B66B0006; Wed,  7 Aug 2019 15:58:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F32E6B0007; Wed,  7 Aug 2019 15:58:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 185256B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 15:58:31 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b30so71524pla.16
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 12:58:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0khcKVDc1M1qvkv6DyyrH2FLY7iQ9qgNyVVoVFfpCEY=;
        b=ctZVzfgBcFsbQEN/DmDRVX4ShCercGL9OtKgF2nv6DOnvMm6eJGC0GwbJBYZfqI9cP
         0mBxKvfb/AybKBp2X7HQq85d5ZeRj29V6eZI+A3CC6XmBAneWHDfwo5PftOVLlgMKn0s
         LtHWu/jr0OqRPmR5t7sY/7lSdNc/j7EWbiFyj2s6uslr+U+Ezj8RAZXyfS7qhqyeyDOe
         k+0Yje4D3wBwLzEU87ubtyxBPCRUaB9Xk5I1uUSTdZIlt+Hr6MlZn+WIEJjWp+WXwdid
         hZTymBc7hOTcgwY060Fnu60yTTyTW/vqe9WF0zkHItQBsWU5A8tT2FqSE7wO3gCNXyw+
         hJ1w==
X-Gm-Message-State: APjAAAVnhxeKKCf/fDxkpIwlz6Xhgu5qRPi8yWgTCplTLNC6Lww1p1Cc
	SZQLHVvWc7no1I7y767p4BksoigakJBXWHYsrDQw73+iUCuuZjXwQr6UxB1a4GtctaSCrnXbQvV
	aN9ZnY1EyTsMiWy8CqTVku7ULyome8iiG8//MAlix3eUPLlUme2rXxipUzBSUxCsG3w==
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr9404410plb.139.1565207910685;
        Wed, 07 Aug 2019 12:58:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbViP+qZDS7Q2BS5RX32iS7TJHgrRjmc3auhWIiDirLmXT99DBjkWUs4JW3mE5yJurdRrP
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr9404356plb.139.1565207909849;
        Wed, 07 Aug 2019 12:58:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565207909; cv=none;
        d=google.com; s=arc-20160816;
        b=rMU7IHGxVD8dHLB9SO1AlZby2v9oidDmO4P5kxd5UN1UuEBkoJDRy5d1qciBzoZx2o
         viw1/foSHgR2ux33xbDxKHZ0Aa+52kVDTK8SI8DXwri/OHD8m41EOcWw44nvzKbzYu28
         5/C2BPtCtAZr1ipi08iuYh+LQ1r3Orv7ECpBzjnbldCsvOk0Wlj/KFDXlzVCmxOjNss6
         KvSYJVDKzZU6MAbapYPGAPQBRloN3ozyrIaV4WeQJ2qoLEDKZg11N9BeovT0jlZLzw19
         SizuGFuEXeqVSyo1tJDUdKyBUuyGXzmgtg6OlU1Vjw7Dwi3kTUzCxBosBqXFZWzE86zj
         M2QA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0khcKVDc1M1qvkv6DyyrH2FLY7iQ9qgNyVVoVFfpCEY=;
        b=NlOFpcRtHe5w6svWI485RQObD1XfHmUXaJJyrbUpptEH9iAubmikpnjP18l+tSHhjt
         zXcNYJ1FAdmcfH2lAto53x1beTRzMjj+cVwioTlL3UyRP7pkZ+naXmzb4CV7aJdOuanJ
         LNFBT2uQPOSMRw6h7QdfSuSRzJOsioejiqLiLjYh3wxLWNETgAPOXfvrjRFCbthuvw6C
         GXAUuns8GIqNYIACd5czwm4Cs+uebLRJEMDPRXR3WRwd6ZYrY2AzrLd2g9F2FjaEB3Zt
         g6Bq2oyq6+v0ck9ZVxU4EobDDjnooXC3M+easbvlIPEXdsHei4i1O7cEP9cj2JBc7s5k
         S0Pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NKiybbKg;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g98si43212pje.92.2019.08.07.12.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 12:58:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NKiybbKg;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=0khcKVDc1M1qvkv6DyyrH2FLY7iQ9qgNyVVoVFfpCEY=; b=NKiybbKgcU+q44Ei2Q7De+6iG
	ztSVcmsSn3guhAcPw69spDGchYJkKSr1zXigAqS6E+/ezF9+17Tb+bACFAXyPfUqF/uFE0MY485Tg
	fB+PtHAnG4/yAHlBfyE/FFeAvsWT+B00FogAwQYkPKzKvRauSfgXOcvkb9Koh/u9Gb4PI1GoAEOES
	3Anly3YV9QI6OjClj93Ke5Yz6q8JbpuvvuNMDrJ6Z2XOrTA3dWNiKylx+0PaB+GYdZpDq5oPLm6iz
	QyUpcCEL7SDOvTvaiyoK7SPkfuTN/IJHhdVmQY2GbhB0lXBj28pRQ9M1sw38VJgN+0meBi77p0wAu
	t0Ume/Jnw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvS4j-0008Gx-Ai; Wed, 07 Aug 2019 19:58:21 +0000
Date: Wed, 7 Aug 2019 12:58:21 -0700
From: Matthew Wilcox <willy@infradead.org>
To: syzbot <syzbot+3de312463756f656b47d@syzkaller.appspotmail.com>
Cc: allison@lohutok.net, andreyknvl@google.com, cai@lca.pw,
	gregkh@linuxfoundation.org, keescook@chromium.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-usb@vger.kernel.org, syzkaller-bugs@googlegroups.com,
	tglx@linutronix.de, Jiri Kosina <jkosina@suse.cz>
Subject: Re: BUG: bad usercopy in hidraw_ioctl
Message-ID: <20190807195821.GD5482@bombadil.infradead.org>
References: <000000000000ce6527058f8bf0d0@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000000000000ce6527058f8bf0d0@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 12:28:06PM -0700, syzbot wrote:
> usercopy: Kernel memory exposure attempt detected from wrapped address
> (offset 0, size 0)!
> ------------[ cut here ]------------
> kernel BUG at mm/usercopy.c:98!

This report is confusing because the arguments to usercopy_abort() are wrong.

        /* Reject if object wraps past end of memory. */
        if (ptr + n < ptr)
                usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);

ptr + n is not 'size', it's what wrapped.  I don't know what 'offset'
should be set to, but 'size' should be 'n'.  Presumably we don't want to
report 'ptr' because it'll leak a kernel address ... reporting 'n' will
leak a range for a kernel address, but I think that's OK?  Admittedly an
attacker can pass in various values for 'n', but it'll be quite noisy
and leave a trace in the kernel logs for forensics to find afterwards.

> Call Trace:
>  check_bogus_address mm/usercopy.c:151 [inline]
>  __check_object_size mm/usercopy.c:260 [inline]
>  __check_object_size.cold+0xb2/0xba mm/usercopy.c:250
>  check_object_size include/linux/thread_info.h:119 [inline]
>  check_copy_size include/linux/thread_info.h:150 [inline]
>  copy_to_user include/linux/uaccess.h:151 [inline]
>  hidraw_ioctl+0x38c/0xae0 drivers/hid/hidraw.c:392

The root problem would appear to be:

                                else if (copy_to_user(user_arg + offsetof(
                                        struct hidraw_report_descriptor,
                                        value[0]),
                                        dev->hid->rdesc,
                                        min(dev->hid->rsize, len)))

That 'min' should surely be a 'max'?

Jiri, this looks like it was your code back in 2007.

