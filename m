Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89842C4CECE
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 11:37:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F23421881
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 11:37:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="XWv86CDH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F23421881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C968A6B0006; Tue, 17 Sep 2019 07:37:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C211D6B0008; Tue, 17 Sep 2019 07:37:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0D616B000A; Tue, 17 Sep 2019 07:37:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0206.hostedemail.com [216.40.44.206])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7166B0006
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 07:37:58 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3514752B4
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 11:37:58 +0000 (UTC)
X-FDA: 75944213436.06.curve44_286d709d53f59
X-HE-Tag: curve44_286d709d53f59
X-Filterd-Recvd-Size: 4002
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 11:37:57 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id p2so2965950edx.11
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 04:37:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=U1A0a3EcW6JDElv8WwGfEykKyOhc9EqlTK9V4ESPbBg=;
        b=XWv86CDHMt5iXBLXM/QKNfJIZRGCpFVPdS3DpVF5KaSetpqFB5BaVh6fl2nna9jyrA
         K0F2DHsyOARlKS4Acu+W4WFdJcsjCSj2dN7cgBJmE2V8IFPNZoLJemdH2owu7TX/FsWs
         iqppPlYWGaQSLyGzyGbSu7ZT7yhJ+PcHLvprahFA7qye0IeJziOm1thq8xMtuYtIAU9G
         z1LURwGamEvtsG2ax573fNanzEYDsZJp3JGVxU6tPjEaNNdro2YuuIMHQEeHnANMIOeA
         Z1fdOBI0U08ASyilbwTuF0EjYptbfGc6Jr400FKLxyqzlYj2TLkslrSAIkepMK6zWwdU
         7PcA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=U1A0a3EcW6JDElv8WwGfEykKyOhc9EqlTK9V4ESPbBg=;
        b=e5gi/ExjKd227Z0HrAZorrCA7Di52yuVkqlLbu77g93EYt1YuW3KuhuaYnCE9akm0i
         g+07u5kp9+ubEO6zSxHpXQkDmKN3Mm/FufJiJ0sLIlVmTX7cBumdE0oDchJWdIbz109f
         L4OKV7NxHOfVwEOqIOzAeuoAmqs+HsUYpEuGTp5xKW62Ov3JDGrKmOUQFMZaXmhD4Jbz
         NUNt+w6v7EbV0gD+afyksAh4m+1lJbmYpjUi3Penmz4WtSYUREAZplIMqikDh8XKuscz
         WqDL3gz2x05UQXmyyby6wq4irclhoC5+L9yhTlPWR31DXB3ZOpSoIIfLlq5UmU2VhUYk
         GTLA==
X-Gm-Message-State: APjAAAViJNOSsPo0R0b7m1RmgEroC+i3RdvGmjmYvZmNHxifqk5foj3k
	MGpP2dZletJCrYpVvHCkrefT2g==
X-Google-Smtp-Source: APXvYqzdODeQqVLPPkso+9i3OZhYRgK4DZMBSRS1n0wGRLqb9BdWPSkpSmiE3sQFKqQTEfUMk7CbaA==
X-Received: by 2002:a50:aa96:: with SMTP id q22mr4067132edc.179.1568720276610;
        Tue, 17 Sep 2019 04:37:56 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c1sm384678edd.21.2019.09.17.04.37.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Sep 2019 04:37:56 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 7A08D101C0B; Tue, 17 Sep 2019 14:37:58 +0300 (+03)
Date: Tue, 17 Sep 2019 14:37:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Lucian Adrian Grijincu <lucian@fb.com>
Cc: linux-mm@kvack.org, Souptick Joarder <jrdr.linux@gmail.com>,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rik van Riel <riel@fb.com>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3] mm: memory: fix /proc/meminfo reporting for
 MLOCK_ONFAULT
Message-ID: <20190917113758.kfcbagaz7nlbqnco@box>
References: <20190913211119.416168-1-lucian@fb.com>
 <20190916152619.vbi3chozlrzdiuqy@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190916152619.vbi3chozlrzdiuqy@box>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 06:26:19PM +0300, Kirill A. Shutemov wrote:
> > ---
> >  mm/memory.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index e0c232fe81d9..55da24f33bc4 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3311,6 +3311,8 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
> >  	} else {
> >  		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
> >  		page_add_file_rmap(page, false);
> > +		if (vma->vm_flags & VM_LOCKED && !PageTransCompound(page))
> > +			mlock_vma_page(page);
> 
> Why do you only do this for file pages?

Because file pages are locked already, right?

-- 
 Kirill A. Shutemov

