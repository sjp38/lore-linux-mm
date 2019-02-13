Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07990C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 02:15:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9BCC222BB
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 02:15:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="o522v5SS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9BCC222BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A5418E0002; Tue, 12 Feb 2019 21:15:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 603518E0001; Tue, 12 Feb 2019 21:15:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47C6A8E0002; Tue, 12 Feb 2019 21:15:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19AB88E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 21:15:31 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b187so793196qkf.3
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 18:15:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SC33iLOSs9PqXp2KbtE2YvTh5FiHaUeY1DXX8o+1gSw=;
        b=TuxxxbqQTx6AFHrin0zewsO+2Be4jf/PLwvvoWMttnImoNToU8vFTjyHBogxNF3AIy
         UEFfQ1h3XlaWjGXC8Iy2y9iPI0tpT2voQ7j68DOqdrjvoCmOPwVlfGRENMOG7/noHeP5
         Px/6w2WSI/zdctFQTKZ0/3PSv1ZNuoaUPTcUMdv7uQJiyL7UDipU164L75/HltB2sYWQ
         jTj0IRxPDGOrMJ6JjnqbE2HOHXfJJSVO5A1A8Rvt58gLXnJbxiqbTnz2GfJya60Pyujb
         Aqii6HbamD0/OG4WspCeQpOdvYxKxsIIbqFzW27xBimNrxq4M7WMmyZdIArT9DQjcPxk
         meIA==
X-Gm-Message-State: AHQUAuY+ZB7Y1DbVzcOrQS/BFBRn4jGDq9vC+wqhnYqKPVNsPxy2oyJ8
	Mv+3npqS6CMN0mFTd1zPs9ArKSTU5xuOK17NGzun2aGWHgKy1CwcFCQptq3G6sggFzRlSuFxDoW
	e00MGDyu6fPLwwWgWOkZAchzgNjaUn2gaK1Sf33UrJSadGGc/7GC4iU564iwdcLKxWU3biIKWWk
	vFQHPDHP7xdF6KzXobk/BDTSrdJfPuMyQ68+G19j9J9eh1dPszwNI3RdFNNGNFSG+qv6vyZVG/7
	N4VPjVaBL8kB5oyVFYqc6eHbps4fO57ERKsSmKDS7a9I7R0Ut8/CtwF9e7SpkyBhgj+NZJq48bI
	xmkbPaBxg0qDVfQ3ZaZ5lB80lDAmet+V+Z3ePAZbrdmj7NWepJs9fT/r5E6SHDVdlMjZgXcYfL3
	M
X-Received: by 2002:a37:4fd5:: with SMTP id d204mr4931147qkb.90.1550024130879;
        Tue, 12 Feb 2019 18:15:30 -0800 (PST)
X-Received: by 2002:a37:4fd5:: with SMTP id d204mr4931129qkb.90.1550024130382;
        Tue, 12 Feb 2019 18:15:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550024130; cv=none;
        d=google.com; s=arc-20160816;
        b=KswBjROJszsdPpTpFrJ6+w6i/ZeKUZhv01QQnvIKPw7e3og4tqPen+FvW8L/bkU1Zs
         e/uqe6/pFlGr4xWPh7yRp+UazWgWeKvm6bunjStlQoj/mxPli+VlTwh3Ca5zuw4Xla20
         nsEA2/irja9PujWqbV9aimi9EUJO+vGpE6qzkFulaCBszQ4lhqzLlkXaekTQ+5t8XLOA
         /ByFATnz2DH5jif+X6RFyc7VlUb5ieGaSPnKUR+fJkLz9AXoWdyKEbZ9j26i5+5jhKaj
         m63D1OfDETj1M+b+88emPDI1q7pRbM5VMJraawZ4mybTR17lWgdGgCVVcJxPMvQUwgUG
         vVdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=SC33iLOSs9PqXp2KbtE2YvTh5FiHaUeY1DXX8o+1gSw=;
        b=DJgicZzUJKyZdTETnz9H9qOGlOs4vX+iXUlHQNUA8wg8yRyA7KYBzGyD0CHJQCSP7/
         6bcH/cIkUmcz4iEnCaVbT6+yalMEnZIB8z56pjwPPjSQS/xBQQ4W+7/CCjkAMCvLG9CL
         Fz2gYnQje0d+mGDZsperLZCnadVQzNFQdHeYIiDjnDRawoUXp3/KSlAzWkLIV9EGRoT/
         11HV/M4Gc4F400oIwVL0hwYBl0mS03JnEsGMc/oo+QNX0r/dDDWqSQQUkOurcIvVxA2W
         zQABOlaChosbjfNA/yIUqsZnQn1E0+NQLJPMZKHPPX552RheCTVK+LiOxPrYhOhms82i
         RG8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=o522v5SS;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k4sor486030qtj.64.2019.02.12.18.15.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 18:15:30 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=o522v5SS;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:from:to:cc:references:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=SC33iLOSs9PqXp2KbtE2YvTh5FiHaUeY1DXX8o+1gSw=;
        b=o522v5SSRw7eM1Hu/o03lkjHZPVpMpjFeQCfoQPNu1iPoia2Ybq9JnK5a0P9jSSOUm
         WJmdGqDCi2PtF5Mi5Xm2aTq4uGXEOggOpl4jFkPT7XMivx84yDYHKI8ugABOIC8uHiI7
         lxHF2x3xA/A48g0UxU60f0SPBqpd/MFeei+H9YLBvx2G28vZWN1HyairJyzh435nIYiL
         ZLvWp7JlCg7ZFalSQGMp6AWyYiRNl38MQe/Bzm25UBfAuQX3gzI07pbY15Dw8voN62G3
         FLUsgaHtLiUGooQW+zrNRfpBxi/mG1PXFUizhgrlHtkyKATZUD9y/SReApFFtDpimAXk
         oBzg==
X-Google-Smtp-Source: AHgI3IZ54oqz1LKhCjGSXiloYfAOeDShGCL7wagWggVrRp6mWyIKK/3KWQ/NEaWrs5vCdBRkasE+uQ==
X-Received: by 2002:ac8:2c82:: with SMTP id 2mr2808437qtw.347.1550024130166;
        Tue, 12 Feb 2019 18:15:30 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id z207sm15686303qka.57.2019.02.12.18.15.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 18:15:29 -0800 (PST)
Subject: Re: [PATCH 5/5] kasan, slub: fix conflicts with
 CONFIG_SLAB_FREELIST_HARDENED
From: Qian Cai <cai@lca.pw>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 kasan-dev <kasan-dev@googlegroups.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Vincenzo Frascino <vincenzo.frascino@arm.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>
References: <cover.1549921721.git.andreyknvl@google.com>
 <3df171559c52201376f246bf7ce3184fe21c1dc7.1549921721.git.andreyknvl@google.com>
 <4bc08cee-cb49-885d-ef8a-84b188d3b5b3@lca.pw>
 <CAAeHK+zv5=oHJQg-bx7-tiD9197J7wdMeeRSgaxAfJjXEs3EyA@mail.gmail.com>
 <c92d6890-a718-a968-9937-13bdfeda773c@lca.pw>
 <CAAeHK+xDYvjMxrkczTQaDbMSu5u3GsxW_mFi1=9OAjCi2Q-6iQ@mail.gmail.com>
 <a9d73c21-744c-84f2-78db-a32773b83ddc@lca.pw>
Message-ID: <493db265-01f6-3901-3416-1ac5bbdd1194@lca.pw>
Date: Tue, 12 Feb 2019 21:15:27 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <a9d73c21-744c-84f2-78db-a32773b83ddc@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/12/19 11:07 AM, Qian Cai wrote:
> https://git.sr.ht/~cai/linux-debug/tree/master/dmesg
> 

FYI, I just send a patch to take care of this.
https://marc.info/?l=linux-mm&m=155002356527913&w=2

