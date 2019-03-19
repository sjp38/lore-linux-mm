Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 662A8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:51:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13B4D2133D
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:51:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GrdKyJkS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13B4D2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A74086B0007; Tue, 19 Mar 2019 13:51:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A241F6B0008; Tue, 19 Mar 2019 13:51:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 912FE6B000A; Tue, 19 Mar 2019 13:51:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 396F16B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:51:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o12so7865426edv.21
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:51:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ZO+ZwteIH+GN4tz9mx+I/xS7VS60SBHJoatRPiKCAhA=;
        b=s/szhBiW8XRfMh9JZpr61GIRs7ldOKS1aObH9qRUa8dpaXNMYfHRxUrM9sXb1tC9mq
         db4Y0YXy99EhvEkiwDHYSTXQ764J7Pm8S77uWIHbIqHhqv1+HC9tzGv3+3CrtDP9T636
         nA1RLTu16TbsuqzAEiVTP7147zaSmkI33m3OGdXyXWunI/gko7H85vi1f1itXHNH8xMg
         7Y7kmZEAS3v46ByvWow6n7xSkijFMvnNVJ36Q2h0AuM7+mpbnj7+aVX+1uCdvIWcmjx8
         0wdFH2t70g4wwoiDXVKhDXj7+GqqZ2uootNzR6LaSY7Cnt01bGja/TVYvK2H3NXf72/C
         j9+A==
X-Gm-Message-State: APjAAAUbQi7JfFpniSKS8ht+AZUgdWQkSRY/5skCc0cz10+N0KMtBImM
	xVoVVISYwC1F0O7o0CwXdrZFBPmBb+3TA4pwMi+lwEZF3BjDMLxSXl209kOfFevKZhrF95SX4ss
	wFP+h57IhvgjCXZGGDKbYG9BhUkoXqN11ir0c01bUBjj65EwUwI0j/YlhucyyqDb8HQ==
X-Received: by 2002:a17:906:5246:: with SMTP id y6mr1784125ejm.228.1553017872772;
        Tue, 19 Mar 2019 10:51:12 -0700 (PDT)
X-Received: by 2002:a17:906:5246:: with SMTP id y6mr1784088ejm.228.1553017871651;
        Tue, 19 Mar 2019 10:51:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553017871; cv=none;
        d=google.com; s=arc-20160816;
        b=rkVjnWF/8ZJ7qUbnQBsoloX95an6Y/3/OixGgPehlTUP5xXRHZ7S1y52dK/z5/tMlU
         P3I9ISCcM6dZNOpC+/ga/xbUiGFFj4AMF8BW5kEgoMIssWllS19oWC5J5S0da34YuS5y
         DBCIu5hMkTKzMEWLk+xE5PSyUk3IBvOl2QvC6US4qckvktnQGena0/+7ml4B1mm6xZgQ
         mTccyS1Gn+tlG8GxSzo/OPO7DNjlALvNFWTDW9LnAe+d8wfEqW8xoZxOQTR+MN07WhC5
         hwyxInG6AvDZubHbqC7GXVWQGyB3yb7LdbKLW+HJtMu0YHQ9Hxfj/aPXxE0ZtkNMm/8V
         g7xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZO+ZwteIH+GN4tz9mx+I/xS7VS60SBHJoatRPiKCAhA=;
        b=IUxJAaMkR8T1LB52ak/lo1LPgsOjckAySVeeDwOQwZSSplRP1OBhVqfZpD06FLERv1
         V56fkyBz4u751qr5mVciDADpimy21eXN6eXRrwmDODFYjH4pTVw3Dua4lU8EaaoR5kWr
         AB5rHIb06bbFQYSl+EtAcvnVX/5DODqGCkvu6VkMjeeqx53KEgkGJ3gDCo/Q9RC3oS1B
         QuUutuH3s8r0ebntzUVv+a02HyMgzeSq26YcDi5XDUYVtEBCCj+7XxXWlQlZMVszn379
         9yVujF2CuQZolLAwGnJt20WAqMK1h3egz/lz7RQhjvADwYz18ouNuTDe722/CpLHQ6Tb
         fpRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GrdKyJkS;
       spf=pass (google.com: domain of luc.vanoostenryck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=luc.vanoostenryck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z43sor4915702edc.27.2019.03.19.10.51.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 10:51:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of luc.vanoostenryck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GrdKyJkS;
       spf=pass (google.com: domain of luc.vanoostenryck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=luc.vanoostenryck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ZO+ZwteIH+GN4tz9mx+I/xS7VS60SBHJoatRPiKCAhA=;
        b=GrdKyJkS7Z5/5sccKgmn0an8u7nSZHCACOQalJ/giU9wpaS71yxBZRuuBXHlhzTJxp
         T4diMEqn6dyMshOWc+OhBeGNJnMvAuepPJcMSrvJunb6TpERV8LO3lgaVevg8eXGGYpb
         XhgsWytdhZNzhMlCFuLuYxk+wdYROA4KF6yLJSg3b/rfUNxBfA40PN2qdc6tt8qy/SwV
         Uwrly9tQIXh9fmf7VGjZOn0mEC0PKSgcybsoYr+aV8w5oPsRXJnw5bEaziruHnwhbtF8
         k4G64WavznRIIe4xRxGANlWjPAET1pPC1BCHuCe/b6tpBhDVoSqu2GhqATzguXbtdG71
         ZG0A==
X-Google-Smtp-Source: APXvYqzKWM8caSHFb5XhB9hERoHdRy158DJujuJrWp2otQRhqD/H1tqDYwsgJ3+6lDuuTHqmKTXGwg==
X-Received: by 2002:aa7:dd0e:: with SMTP id i14mr1409148edv.172.1553017871345;
        Tue, 19 Mar 2019 10:51:11 -0700 (PDT)
Received: from ltop.local ([2a02:a03f:4049:a600:52:6fcd:af3b:582e])
        by smtp.gmail.com with ESMTPSA id w8sm3238240ejj.27.2019.03.19.10.51.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 10:51:10 -0700 (PDT)
Date: Tue, 19 Mar 2019 18:51:08 +0100
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org,
	mike.kravetz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-sparse@vger.kernel.org
Subject: Re: [PATCH] include/linux/hugetlb.h: Convert to use vm_fault_t
Message-ID: <20190319175107.oxwjf72hpcqqmo3l@ltop.local>
References: <20190318162604.GA31553@jordon-HP-15-Notebook-PC>
 <20190319032022.GR19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319032022.GR19508@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 08:20:22PM -0700, Matthew Wilcox wrote:
> On Mon, Mar 18, 2019 at 09:56:05PM +0530, Souptick Joarder wrote:
> > >> mm/memory.c:3968:21: sparse: incorrect type in assignment (different
> > >> base types) @@    expected restricted vm_fault_t [usertype] ret @@
> > >> got e] ret @@
> >    mm/memory.c:3968:21:    expected restricted vm_fault_t [usertype] ret
> >    mm/memory.c:3968:21:    got int
> 
> I think this may be a sparse bug.
> 
> Compare:
> 
> +++ b/mm/memory.c
> @@ -3964,6 +3964,9 @@ vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>         if (flags & FAULT_FLAG_USER)
>                 mem_cgroup_enter_user_fault();
>  
> +       ret = 0;
> +       ret = ({ BUG(); 0; });
> +       ret = 1;
>         if (unlikely(is_vm_hugetlb_page(vma)))
>                 ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
>         else
> 
> ../mm/memory.c:3968:13: sparse: warning: incorrect type in assignment (different base types)
> ../mm/memory.c:3968:13: sparse:    expected restricted vm_fault_t [assigned] [usertype] ret
> ../mm/memory.c:3968:13: sparse:    got int
> ../mm/memory.c:3969:13: sparse: warning: incorrect type in assignment (different base types)
> ../mm/memory.c:3969:13: sparse:    expected restricted vm_fault_t [assigned] [usertype] ret
> ../mm/memory.c:3969:13: sparse:    got int
> 
> vm_fault_t is __bitwise:
> 
> include/linux/mm_types.h:typedef __bitwise unsigned int vm_fault_t;
> 
> so simply assigning 0 to ret should work (and does on line 3967), but
> sparse doesn't seem to like it as part of a ({ .. }) expression.

This is the expected behaviour. The constant 0 is magic regarding
bitwise types but ({ ...; 0; }) is not, it is just an ordinary expression
of type 'int'.

So, IMHO, Souptick's patch is the right thing to do.


Best regards,
-- Luc Van Oostenryck

