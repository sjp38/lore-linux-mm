Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7339C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:43:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 842C420835
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:43:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="OmPppWUY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 842C420835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 142FE6B000D; Fri, 22 Mar 2019 09:43:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F2526B000E; Fri, 22 Mar 2019 09:43:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00AB06B0010; Fri, 22 Mar 2019 09:43:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D10C86B000D
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:43:04 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id i124so1851859qkf.14
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:43:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=kpn98ZLdpy7LXxen4zSCSbaN92zrBW9j9CjROHut6Aw=;
        b=ltFhq6tOwXMC0HQn3PPy5yvGxYeD+sBUDZBG9hEvcfMin8oB10lFtI7ILA+O4k8+qD
         WjvbehfIsONa2a6btm0Bt1lqq6+P+bS0R60E5FHR+zdOGxSJxDXxpMa/ez9rW6BdvHGc
         JraJ1lzj5RM9pIY2gt57frJbvQAHm00Mnh8lqyT1PwQAsNdab3zdkJZwIcettC5ADlOn
         WvmeQ3AY6iYW4rHWpZpYBUidzJVm6UOWJKIIe4U1bU2cQuq8lGLMRpxkVnFQD6wzIn0R
         oq2w+gHWPN1vq6NnMVkJtcEhf8uYEi71iFG32Eu+dE8Szxsf/RCMtIFsMsJ5h1GnC8al
         KMbQ==
X-Gm-Message-State: APjAAAU38+qJhiA0iB77QcfBx4cVge05J3q9oydeBgZS0P86VRbozee3
	N0SkGM/zPgOTr/xSfNuqcgpIMTdSLJ5HFHh61EkflsicQ5X8YzQnV1Bv4uRZ3+rYuMUpP6CM2J0
	ig5WR9PBG37Ftuf4fKaKEVBaBDuoLiR242VhohLmuEuvBynr4F5zVF7oWBgP3sHGirw==
X-Received: by 2002:a37:9e8a:: with SMTP id h132mr2088621qke.74.1553262184589;
        Fri, 22 Mar 2019 06:43:04 -0700 (PDT)
X-Received: by 2002:a37:9e8a:: with SMTP id h132mr2088586qke.74.1553262183941;
        Fri, 22 Mar 2019 06:43:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553262183; cv=none;
        d=google.com; s=arc-20160816;
        b=cxCLfzlAJKqjLEvLHAmkYL8Sa5Xs588VE/74iP0Dg+e8w9EkMiAVFylRPBajuvs0wz
         UOlVXjTMAPzJN3bjt0haQAqg1pnsF14SW7vsJV5sHA0ui+xO3duzwvw+TbNpNY+jS2bF
         kAM11PuZiZC2x4ODkzhGT45FMAunU1IjeuTj0SbGEDyJHWzSLxeLQ8piySOZrVnygaJX
         7KtWQrI8BvyosV91xKJkYMJ95gKP+O/RzC8osaPNI5Na+5OlxyAeRBumvSjxnj3vVq2l
         FHvQNgdpZ86gvmxvJ5EC8PfElHwF6hOvwXBcYLk6nXlW7LlPLqktITsaVMnDj3IjJicA
         hD/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=kpn98ZLdpy7LXxen4zSCSbaN92zrBW9j9CjROHut6Aw=;
        b=idMRgHmMgZchnJVLUaVLducx19sFvPE9aAb4gf1UmjKTLQc2wtAftC1uJfOkXqGKJp
         fqG0sULp4PExTkQ/UDvCryWz/yH0rDTtzRLt2sLCOYF67gi1szMUlcDRXPoE2C8thbcv
         eKxY+TaYYKBDRuEhbQfsEmMpnaEmCUyNkDlDOkVuvGZ9id67zxm+CzfPdlT2ufCPjHWI
         e4qspwrvH+ShSzz1Mt0UiJPh0BptjBdpWo1GQ4h4gw0jIslg9wAUayxER5JSi/gaoBhx
         KJDhseHW5S3BMiPAj7sJRPUNDrD9LS8gLPf1xjaxwoS/IU4sxkMNdjMlB9NkyLGvi8tW
         Gd+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=OmPppWUY;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l23sor5586503qkg.56.2019.03.22.06.43.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 06:43:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=OmPppWUY;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=kpn98ZLdpy7LXxen4zSCSbaN92zrBW9j9CjROHut6Aw=;
        b=OmPppWUY8JFDvHB9vahwRrRDeZStEza/JgZekd5pY5XSSd7+vgEjSgGza2HionvySM
         8VUfYGqE4DQpeYTPzA9yLbDkey6ORavmSo/b4v89jMsTCXF9WnioS2ab/wNdYsz3R2mL
         nylUxJEur+Zm/kn9rfueAcphad+V2xnBX/tSf56z3LSMMuyLtwHsU7Xzsuv96dW5aYiH
         Oie8ffKMFyVSg9ew/ZNGxbKEHRJ/lNLAMfrGNgfh2+emw2ZQARvo2XzqWhsljK18eqiQ
         fwFZyQ4x2Wm+TW5SaaUgF4WDQcxNV05XuGywe0jVNu5XCXHwXPg3vcEr7tIwXSz6j+EG
         y9jw==
X-Google-Smtp-Source: APXvYqwJX80vQ+ze1W/Y2wkiXmS5WBRnD0s33MQRrVtX67kH4hTohMtMiwGzCQHFbFk93RRhMJNpMA==
X-Received: by 2002:ae9:ec19:: with SMTP id h25mr7812847qkg.122.1553262183647;
        Fri, 22 Mar 2019 06:43:03 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id v24sm4568489qkj.40.2019.03.22.06.43.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 06:43:02 -0700 (PDT)
Message-ID: <1553262181.26196.22.camel@lca.pw>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
From: Qian Cai <cai@lca.pw>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, 
	mgorman@techsingularity.net, vbabka@suse.cz
Date: Fri, 22 Mar 2019 09:43:01 -0400
In-Reply-To: <CABXGCsMKQfHjOekpbDgNWXNThdBy8UfxxEddEqPMMJZvmygGhQ@mail.gmail.com>
References: 
	<CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
	 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
	 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
	 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
	 <1553174486.26196.11.camel@lca.pw>
	 <CABXGCsM9ouWB0hELst8Kb9dt2u6HKY-XR=H8=u-1BKugBop0Pg@mail.gmail.com>
	 <1553183333.26196.15.camel@lca.pw>
	 <CABXGCsMQ7x2XxJmmsZ_cdcvqsfjqOgYFu40gTAcVOZgf4x6rVQ@mail.gmail.com>
	 <1553195694.26196.20.camel@lca.pw>
	 <CABXGCsMKQfHjOekpbDgNWXNThdBy8UfxxEddEqPMMJZvmygGhQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000230, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-03-22 at 08:41 +0500, Mikhail Gavrilov wrote:
> On Fri, 22 Mar 2019 at 00:14, Qian Cai <cai@lca.pw> wrote:
> > 
> > 
> > That is OK. The above debug patch may still be useful to figure out where
> > those
> > pages come from (or you could add those 3 pages address to the patch as
> > well).
> > They may be initialized in a similar fashion or uninitialized to begin with.
> 
> Strange I modified patch for catch all 0xffffXXXXX07ce000 pages
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 03fcf73..8808e2a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1273,6 +1273,10 @@ static void free_one_page(struct zone *zone,
>  static void __meminit __init_single_page(struct page *page, unsigned long
> pfn,
>   unsigned long zone, int nid)
>  {
> + if (0xffff00000fffffff & page == (void *)0xffff0000007ce000) {
> + printk("KK page = %px\n", page);
> + dump_stack();
> + }
>   mm_zero_struct_page(page);
>   set_page_links(page, zone, nid, pfn);
>   init_page_count(page);

Those pages are not initialized at all which likely mean that memblock did not
even allocate them at the first place, so Mel's patch might work.

