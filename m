Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9966CC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:33:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48E01206A3
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:33:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qw5B+oHg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48E01206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D96446B0003; Fri,  2 Aug 2019 16:33:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D463F6B0005; Fri,  2 Aug 2019 16:33:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C35636B0006; Fri,  2 Aug 2019 16:33:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 900156B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 16:33:49 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so48969649pfy.20
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 13:33:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=76k/NEV4yV518KF6BPeXC0U+XVQr3xgUEZxyw7BoNew=;
        b=i3B+AuB+35aadqGWHa6JPs7pExvkEgYRpFnUyh4RRj0YiZ+VGkdDEYPTFhOW9BDU/t
         fYQ7KCztrbU4I8p4rR1Q1ay8RYj3QJgSmWb0rWNBGqnDnZRQ5ypfeeD6iebb4bKZ4t18
         HK/glrAXv3GrXgEtlvyWOCInyEi1noBc1a6SykUCh8LsyFMNjzx1ogkEew9XsUJreUnT
         Ty18ouxrTyGFS5kFgQvaoY7gnG4Bx9OVyCWJb2GrO3iumpjd9u3o2ivnF3Tf7s61sP8D
         lldatYyIJecS+hrdyrsI5FGdCZDPKn9GvIB+GVw/nYwcVY24piAnRjMrCxwhS8tPyga2
         6yog==
X-Gm-Message-State: APjAAAWjSxOpoNYgMQxyGej7yCPdqMkZIwvOvo6jpGBdcJf1fwOLyjAZ
	8MlSoW0yplqhXUJsyKftOQFF0HpN5cgnNqyAcVT1+25f59w29558PE/Rg4YCPZZ4fPbFEj1Y7lI
	bLCuArJ5ec5sp9R1PrbAXrowenaPJ+mYC8pcYf558J+byyHS3xbukBCkrOIkZyXL1eg==
X-Received: by 2002:a63:3281:: with SMTP id y123mr122801520pgy.72.1564778029094;
        Fri, 02 Aug 2019 13:33:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwW2GbmBwa8N38VegaJPwIDvckwaSV1DhY+FwFKjkK9s1SwkT6eu0hZxdf2vkmKikLf2PV+
X-Received: by 2002:a63:3281:: with SMTP id y123mr122801475pgy.72.1564778028084;
        Fri, 02 Aug 2019 13:33:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564778028; cv=none;
        d=google.com; s=arc-20160816;
        b=Q8QY0Hm2SzTHMAso2W8Q/U6Xm5zhvxrfHg9O4rSsq5XAoLwkMyn//GU5qmAJbXkFTd
         EO3Kl0jXq2W1FgPX+ncOIB+UeirctqqKttnVm6T9JUJDovfmDOvyoEfP0CZDt0APknjc
         GncrbBTdJ6rtKum6Wn5cWE+vD7BN56NtrjjoJ8mqyY/n7fOuB4Xl0c3MlfGCA/Xnp8dM
         76Gw6MalfWRI8gnXbyN0Ey3evP62UQ1khIT/CD/vEr2RBupXA6CZ1c6U2Mj5oOChl7b+
         wNKhN35fxvKdd0GRt2uB7DSta8EbqkJ/8ujOng1SOZw/mo4byXxpQ3XaX6rVXGYIMn76
         HM4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=76k/NEV4yV518KF6BPeXC0U+XVQr3xgUEZxyw7BoNew=;
        b=Te3AgfIzT1oVncyI5vurL8jHPsfJ9we7CrSQM2sKmVNKj1MloOtUwVTQZ8Bq5wUkoi
         FQozBvWRXCAjoODG7cIYgAonWgYXyuPfyhjgI6Wp9PR22D4dDuJDf5wqG9y7Y+TWSQMs
         m0rKTW/2Cs/Vc9r35+9WqStz9dTHe3TED1GEcELrmIRfLGpgxr6/6e3SyBulguNX91xA
         Jgbf4upQdx1P8bB8zu7z4qbzy/mqeoEXpizYkz6C7koudreFerL78dJI/BbATkeb71f2
         ZnX7hI60vk/cko+yxwneNpZrotWxHd6v9gNuuOjUaKXRTGMtdBBwkm+NfDYX1duXKy7V
         hufg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qw5B+oHg;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s17si37557816pfc.237.2019.08.02.13.33.47
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 02 Aug 2019 13:33:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qw5B+oHg;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=76k/NEV4yV518KF6BPeXC0U+XVQr3xgUEZxyw7BoNew=; b=qw5B+oHgG/uhMN22taH88XDhp
	RYDfcsmY7UOyJW7ubedNhxlXQpFF7q6uBVUZawl5Td3WP5lEzmJXzY3+gZuEWd8VB2VdlwjJtQ9hQ
	I1HTX9QtjpmfM3Dai/QTgW4pD4GLm4laSQuEK2tuzWqRMT2rQ4Nk5TkhbKXnkIdnR7O/ZZUVqLz74
	BQKTkwYEzr0Oo+2mtZPnsnCV73JFDrhmQNDZm1q8/HUulDPcUK5ygY6RysoT1VPfdeJqAKYalQTT/
	bgWoc0pbnJfgwXHrtfjRk/R6ymW/UaK9wwVNJGrsvROr25wvI8WgCQsBYdeH3y4tKXwp1N2+q99XG
	HQl9Dt7UQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hteFE-00046N-Fr; Fri, 02 Aug 2019 20:33:44 +0000
Date: Fri, 2 Aug 2019 13:33:44 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: petr@vandrovec.name, bugzilla-daemon@bugzilla.kernel.org,
	Christian Koenig <christian.koenig@amd.com>,
	Huang Rui <ray.huang@amd.com>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org
Subject: Re: [Bug 204407] New: Bad page state in process Xorg
Message-ID: <20190802203344.GD5597@bombadil.infradead.org>
References: <bug-204407-27@https.bugzilla.kernel.org/>
 <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 01:23:06PM -0700, Andrew Morton wrote:
> > [259701.387365] BUG: Bad page state in process Xorg  pfn:2a300
> > [259701.393593] page:ffffea0000a8c000 refcount:0 mapcount:-128
> > mapping:0000000000000000 index:0x0

mapcount -128 is PAGE_MAPCOUNT_RESERVE, aka PageBuddy.  I think somebody
called put_page() once more than they should have.  The one before this
caused it to be freed to the page allocator, which set PageBuddy.  Then
this one happened and we got a complaint.

> > [259701.402832] flags: 0x2000000000000000()
> > [259701.407426] raw: 2000000000000000 ffffffff822ab778 ffffea0000a8f208
> > 0000000000000000
> > [259701.415900] raw: 0000000000000000 0000000000000003 00000000ffffff7f
> > 0000000000000000
> > [259701.424373] page dumped because: nonzero mapcount

It occurs to me that when a page is freed, we could record some useful bits
of information in the page from the stack trace to help debug double-free 
situations.  Even just stashing __builtin_return_address in page->mapping
would be helpful, I think.

> > [259701.549382] Call Trace:
> > [259701.549382]  dump_stack+0x46/0x60
> > [259701.549382]  bad_page.cold.28+0x81/0xb4
> > [259701.549382]  __free_pages_ok+0x236/0x240
> > [259701.549382]  __ttm_dma_free_page+0x2f/0x40
> > [259701.549382]  ttm_dma_unpopulate+0x29b/0x370
> > [259701.549382]  ttm_tt_destroy.part.6+0x44/0x50
> > [259701.549382]  ttm_bo_cleanup_memtype_use+0x29/0x70
> > [259701.549382]  ttm_bo_put+0x225/0x280
> > [259701.549382]  ttm_bo_vm_close+0x10/0x20
> > [259701.549382]  remove_vma+0x20/0x40
> > [259701.549382]  __do_munmap+0x2da/0x420
> > [259701.549382]  __vm_munmap+0x66/0xc0
> > [259701.549382]  __x64_sys_munmap+0x22/0x30
> > [259701.549382]  do_syscall_64+0x5e/0x1a0
> > [259701.549382]  ? prepare_exit_to_usermode+0x75/0xa0
> > [259701.549382]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > [259701.549382] RIP: 0033:0x7f504d0ec1d7
> > [259701.549382] Code: 10 e9 67 ff ff ff 0f 1f 44 00 00 48 8b 15 b1 6c 0c 00 f7
> > d8 64 89 02 48 c7 c0 ff ff ff ff e9 6b ff ff ff b8 0b 00 00 00 0f 05 <48> 3d 01
> > f0 ff ff 73 01 c3 48 8b 0d 89 6c 0c 00 f7 d8 64 89 01 48
> > [259701.549382] RSP: 002b:00007ffe529db138 EFLAGS: 00000206 ORIG_RAX:
> > 000000000000000b
> > [259701.549382] RAX: ffffffffffffffda RBX: 0000564a5eabce70 RCX:
> > 00007f504d0ec1d7
> > [259701.549382] RDX: 00007ffe529db140 RSI: 0000000000400000 RDI:
> > 00007f5044b65000
> > [259701.549382] RBP: 0000564a5eafe460 R08: 000000000000000b R09:
> > 000000010283e000
> > [259701.549382] R10: 0000000000000001 R11: 0000000000000206 R12:
> > 0000564a5e475b08
> > [259701.549382] R13: 0000564a5e475c80 R14: 00007ffe529db190 R15:
> > 0000000000000c80
> > [259701.707238] Disabling lock debugging due to kernel taint
> 
> I assume the above is misbehaviour in the DRM code?

