Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DFFAC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 21:17:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50E0020665
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 21:17:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ivOSZ6tI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50E0020665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9C336B0003; Fri,  2 Aug 2019 17:17:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4C1F6B0005; Fri,  2 Aug 2019 17:17:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3C0C6B0006; Fri,  2 Aug 2019 17:17:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A56D06B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 17:17:34 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c79so65940881qkg.13
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 14:17:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=RVTQ02iVRQpTjOR6GTqSpU7hzhiBP+qZzmy99EzkJ88=;
        b=fwtPPglYLq2rBYWmYs0cTJA24kE+GgVkW953HP5210NwOXgyvFaGKNpkZYgFQb4jOW
         izlc1CApWr5C6ihrYURUfZQzeCuQW0ydzQ/ov3ATj+OBsb4evJdL5GS3ix235YT/Chs8
         +tSk+rLaLN5b+E1RTAWJrBhvCEFQWZhSZO8hCkthac07K4zwd0esgO5N/vdmHrvTtAmL
         OJrqFtbt+EszhgTpxshOcsvgP7/ND4RNRLR9WjtLw6nqP7d7Wz+ypq9OJj7TnS2jqPrP
         /7p11/OHzg3+eaAlPb1wgjkXqxEr2zxH5eMi8VyH7DUwmEtwoMiDZPAJYfhVXwtBpdn3
         GTfA==
X-Gm-Message-State: APjAAAXeAf6i4CREOuXztaZRuucF4QAnq2OG97+qKgNaAmWlfrNZVBUU
	fkEKvMGM58ayzWkTEZ86jioDx7j+w1oykwojp2RnIXfCPgJy3MjBGcKpBl2j73/Z1hT9lNar6PD
	aC1Y47fuYVYT4HZvIWO+uevn+MEKfUyNH13coBg3t0yeYebYAtDNklTzH6Zn3IyE/UA==
X-Received: by 2002:a0c:afeb:: with SMTP id t40mr97313377qvc.28.1564780654385;
        Fri, 02 Aug 2019 14:17:34 -0700 (PDT)
X-Received: by 2002:a0c:afeb:: with SMTP id t40mr97313324qvc.28.1564780653526;
        Fri, 02 Aug 2019 14:17:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564780653; cv=none;
        d=google.com; s=arc-20160816;
        b=JyNsjO8+MO5P8N0JNCwImNmmquJvWma6Z+eDqzj7de8nmM/BL+Aa3DIMX9zqQf4hDC
         MamF8u+F1dH1MwTGVF/vQDMmydMlWgRMJEyhPGbw0FCyYYHwliOGCG7f3AUpL67iW639
         35N+sRelAkZ3HrapwsjAuw4mto8eZjedAhaHH0zlVfxTgHuVni5WPqYCrmUzJ7YeWwDd
         m7AMtn8+GDxGo8G+LXY9n0o6xvAbhVRu1oArkrSZ8Z68IJ700TN1nUy6N443qwL2bddy
         emdKwFucgjlDGAa0FV7528lK4Y/WjgMA/5GxbS846OLtj6n0j80CDF/IJf/XloLh4esO
         LYLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=RVTQ02iVRQpTjOR6GTqSpU7hzhiBP+qZzmy99EzkJ88=;
        b=A3bR+LrsSsRq/O7NSmrSCMdq7fpDjf+x9IFft7bsWw+1K+3RD1+zcGUrlv5hiJzVIg
         1dm3bXgjZxdQ7afiX+3Gk2h2esmmWMdWUNjW20foOOsUoURK5D5Vnd4c02rgnhoGoa8j
         +qSHXFUMRpGnjI/6COZ8i1a5YtVuztuVdBabvNyBJ6+COEi/yj3CJmtXoRl8iDIvOKAu
         kPIxLTC8rYnJZbWZxaKqILCX7k3pF5WbdvFyGsgS7FbfghygcxH2CF4joPMGe6gbS0yx
         oBXlbj4j1st0Kzg1bT0zpOj/bzv8En+83VAjCs0SI5GqChIXwwZzkQYAXG+Uq6RdHQPr
         FfMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ivOSZ6tI;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor43604709qkg.82.2019.08.02.14.17.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 14:17:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ivOSZ6tI;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=RVTQ02iVRQpTjOR6GTqSpU7hzhiBP+qZzmy99EzkJ88=;
        b=ivOSZ6tIYTANNW9b9aYCoAB5LDc59jUBtwIJ0Um/e+qkGwPOlOnYkNDxygF/GpEP8P
         wmIEOPtmBcqwtsJ2OHFRs1y804vo68YLJLLBGFafTzh5TPv7g6eMiPTtniYSqHBb4z04
         sSYjlL0/q+bxGmFcC6UPv+DakK8EKOhh0akls9REboq4MTqVQFKWG4HhKz2FvPW4A1IG
         EmmVrxLEJep29xlIF+4c7SKlOsTxw0eh1k2fRCBi598+DYI6lLC2Jr+nbdIULvl50rgO
         0+fP5nprKC/cp2r0ibrVAxgIC5hMs4YwVq1gpUwYPtVL1VMzqjdsyyvLfqXi7OV/8h8x
         jTjA==
X-Google-Smtp-Source: APXvYqywXaTJhVsrTGMTx1+T9sEYk2fJfeee8YhdWcSDuIFnrmC8f/A4061EUHzmjTKYluWIEGzpqw==
X-Received: by 2002:ae9:f016:: with SMTP id l22mr92931142qkg.51.1564780653184;
        Fri, 02 Aug 2019 14:17:33 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id o33sm36437909qtd.72.2019.08.02.14.17.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 14:17:32 -0700 (PDT)
Message-ID: <1564780650.11067.50.camel@lca.pw>
Subject: Re: [Bug 204407] New: Bad page state in process Xorg
From: Qian Cai <cai@lca.pw>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton
	 <akpm@linux-foundation.org>
Cc: petr@vandrovec.name, bugzilla-daemon@bugzilla.kernel.org, Christian
 Koenig <christian.koenig@amd.com>, Huang Rui <ray.huang@amd.com>, David
 Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, 
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org
Date: Fri, 02 Aug 2019 17:17:30 -0400
In-Reply-To: <20190802203344.GD5597@bombadil.infradead.org>
References: <bug-204407-27@https.bugzilla.kernel.org/>
	 <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
	 <20190802203344.GD5597@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-08-02 at 13:33 -0700, Matthew Wilcox wrote:
> On Fri, Aug 02, 2019 at 01:23:06PM -0700, Andrew Morton wrote:
> > > [259701.387365] BUG: Bad page state in process Xorg  pfn:2a300
> > > [259701.393593] page:ffffea0000a8c000 refcount:0 mapcount:-128
> > > mapping:0000000000000000 index:0x0
> 
> mapcount -128 is PAGE_MAPCOUNT_RESERVE, aka PageBuddy.  I think somebody
> called put_page() once more than they should have.  The one before this
> caused it to be freed to the page allocator, which set PageBuddy.  Then
> this one happened and we got a complaint.
> 
> > > [259701.402832] flags: 0x2000000000000000()
> > > [259701.407426] raw: 2000000000000000 ffffffff822ab778 ffffea0000a8f208
> > > 0000000000000000
> > > [259701.415900] raw: 0000000000000000 0000000000000003 00000000ffffff7f
> > > 0000000000000000
> > > [259701.424373] page dumped because: nonzero mapcount
> 
> It occurs to me that when a page is freed, we could record some useful bits
> of information in the page from the stack trace to help debug double-free 
> situations.  Even just stashing __builtin_return_address in page->mapping
> would be helpful, I think.

Sounds like need to enable "page_owner", so it will do  __dump_page_owner().

> 
> > > [259701.549382] Call Trace:
> > > [259701.549382]  dump_stack+0x46/0x60
> > > [259701.549382]  bad_page.cold.28+0x81/0xb4
> > > [259701.549382]  __free_pages_ok+0x236/0x240
> > > [259701.549382]  __ttm_dma_free_page+0x2f/0x40
> > > [259701.549382]  ttm_dma_unpopulate+0x29b/0x370
> > > [259701.549382]  ttm_tt_destroy.part.6+0x44/0x50
> > > [259701.549382]  ttm_bo_cleanup_memtype_use+0x29/0x70
> > > [259701.549382]  ttm_bo_put+0x225/0x280
> > > [259701.549382]  ttm_bo_vm_close+0x10/0x20
> > > [259701.549382]  remove_vma+0x20/0x40
> > > [259701.549382]  __do_munmap+0x2da/0x420
> > > [259701.549382]  __vm_munmap+0x66/0xc0
> > > [259701.549382]  __x64_sys_munmap+0x22/0x30
> > > [259701.549382]  do_syscall_64+0x5e/0x1a0
> > > [259701.549382]  ? prepare_exit_to_usermode+0x75/0xa0
> > > [259701.549382]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > > [259701.549382] RIP: 0033:0x7f504d0ec1d7
> > > [259701.549382] Code: 10 e9 67 ff ff ff 0f 1f 44 00 00 48 8b 15 b1 6c 0c
> > > 00 f7
> > > d8 64 89 02 48 c7 c0 ff ff ff ff e9 6b ff ff ff b8 0b 00 00 00 0f 05 <48>
> > > 3d 01
> > > f0 ff ff 73 01 c3 48 8b 0d 89 6c 0c 00 f7 d8 64 89 01 48
> > > [259701.549382] RSP: 002b:00007ffe529db138 EFLAGS: 00000206 ORIG_RAX:
> > > 000000000000000b
> > > [259701.549382] RAX: ffffffffffffffda RBX: 0000564a5eabce70 RCX:
> > > 00007f504d0ec1d7
> > > [259701.549382] RDX: 00007ffe529db140 RSI: 0000000000400000 RDI:
> > > 00007f5044b65000
> > > [259701.549382] RBP: 0000564a5eafe460 R08: 000000000000000b R09:
> > > 000000010283e000
> > > [259701.549382] R10: 0000000000000001 R11: 0000000000000206 R12:
> > > 0000564a5e475b08
> > > [259701.549382] R13: 0000564a5e475c80 R14: 00007ffe529db190 R15:
> > > 0000000000000c80
> > > [259701.707238] Disabling lock debugging due to kernel taint
> > 
> > I assume the above is misbehaviour in the DRM code?
> 
> 

