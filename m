Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E711CC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB43B2133F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:11:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB43B2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AB0C8E0003; Wed, 26 Jun 2019 02:11:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45A9E8E0002; Wed, 26 Jun 2019 02:11:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34A828E0003; Wed, 26 Jun 2019 02:11:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DADEE8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l14so1460854edw.20
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:11:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=r9quTvPGBEadXUa0/2F6yFqMjk7zVYw/NypaZtUfqdA=;
        b=uF1jbxawSDbq6H8ycA8h/56UdxuAQlrDJhoMzqLdPX3s+g5/LQ40vQEBRO6eyDurWF
         t6JPjqL9dhmyct2YCNB7WJqFXJQYJlMwoZF7AEYBcraJUQuOyq99lsMn55GN1br48hm/
         0WJ+8iZ80hQr/bMehlFtd69GlurOxmo2BFBFP9BVuzF6/0sncfgsyq4YJNLyvJtPemyx
         qfMqmVIqlH6nzFp4QMVSf4n4xAb6Rb+/wk2vX7EmWXvE9+qeE1yn73Z7r4Ueip39N1U4
         ZclLU2/WNAUIkWuZxLeShd05h9NsadvLjLxg1d8S84g1cKYiYxe2l+DoSVFsOf6i1BOT
         d6hA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWIcaCrOK5sw/hfrf7ePSGs1Z2tIJRrgZJleKBYrhUOvCoT+95K
	7/e7zEvlJJHFmnN/TtnHpADNejOVIjYzDOM1COlaRi0ILfGcLQgMNUsniJyzWv38R6JD0T3dsm0
	4oF0fDDMFAvqyvveYIdoP0fQznk1OCrBho+5LnmXIVtK8LLZZLTVRtOhoGM+Ld7U=
X-Received: by 2002:a17:906:414:: with SMTP id d20mr2403174eja.275.1561529498461;
        Tue, 25 Jun 2019 23:11:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhtjTtzBaEEWtpiFKKHlhnNH9rHfGCpiCKMpPQjBHG2lfv6We8bh/yBccpriEmFGYUHn39
X-Received: by 2002:a17:906:414:: with SMTP id d20mr2403123eja.275.1561529497726;
        Tue, 25 Jun 2019 23:11:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561529497; cv=none;
        d=google.com; s=arc-20160816;
        b=KqBSvzqQ/Tl2bzKmWTQHSMgNOrWkhzV+l3FMr/q3hANIKsC/Hr6rS2cXZvblgd1RQT
         JJ0D3w2K4v+NIpdWKzRJzHJXGU8eKMYsQwH6Cxnb3XidMfHR4AKeAotbA2LA/k7f5bLY
         fa9BAmaRBOGIEuNXKsW93ZLptC76c97eSIdYtycfGxhgWi4hTh6HPdVvCV352b44ggp5
         YqoIPFqm5RLm6aARB2/oLNI+oBox+T+KTFxaVPV4W6/pGYBhZbl8YYns+GIkyyRdueq7
         BglGFBAuD7crdw2+YIkWOKw8hvJ6sPNTZZmYpd29A4Zw07QB0ukgreXQdnzuhxzcKNHm
         Z4bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=r9quTvPGBEadXUa0/2F6yFqMjk7zVYw/NypaZtUfqdA=;
        b=h+kydLa0uIokqjTbWNnSmjNaGKV6OjIkZQm21dDcSY4ZJyFU2axTG0Qb/pChD0A8Cc
         yUREdCb6ZIXvSG0URqZjHxXTU2Ns65xVZ1x2L1F70ujdF4Au+Urv6wzsVPiIdG5gNaYG
         1Gn/ykeTbA0eUkfnFGP6vFCtWQFl6xw33bqfhgB60LeEyei6tgNHmhZo2dYEDMFwDzwG
         vrNMCTxg88mXRm2l027XtHIK+BsXkaDLeyIwxMT3jquP6byKy/e/6WQWYQlLmMuGMZyO
         QB3kANCdcf+W+KB9UHHzXLnBoA78Cv9JuLvlEbZpegLGbKyK9cKBRTEedv3pVVWNGM3Y
         brtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d28si2341806eda.375.2019.06.25.23.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:11:37 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 96E90AF25;
	Wed, 26 Jun 2019 06:11:36 +0000 (UTC)
Date: Wed, 26 Jun 2019 08:11:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hoan Tran OS <hoan@os.amperecomputing.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	"David S . Miller" <davem@davemloft.net>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Open Source Submission <patches@amperecomputing.com>
Subject: Re: [PATCH 1/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default
 for NUMA
Message-ID: <20190626061134.GD17798@dhcp22.suse.cz>
References: <1561501810-25163-1-git-send-email-Hoan@os.amperecomputing.com>
 <1561501810-25163-2-git-send-email-Hoan@os.amperecomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561501810-25163-2-git-send-email-Hoan@os.amperecomputing.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 25-06-19 22:30:24, Hoan Tran OS wrote:
> This patch enables CONFIG_NODES_SPAN_OTHER_NODES by default
> for NUMA. As some NUMA nodes have memory ranges that span other
> nodes. Even though a pfn is valid and between a node's start and
> end pfns, it may not reside on that node.

Please describe the problem more thoroughly. What is the layout, what
doesn't work with the default configuration and why do we need this
particular fix rather than enabling of the config option for the
specific HW.

> 
> Signed-off-by: Hoan Tran <Hoan@os.amperecomputing.com>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8a..6335505 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1413,7 +1413,7 @@ int __meminit early_pfn_to_nid(unsigned long pfn)
>  }
>  #endif
>  
> -#ifdef CONFIG_NODES_SPAN_OTHER_NODES
> +#ifdef CONFIG_NUMA
>  /* Only safe to use early in boot when initialisation is single-threaded */
>  static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
>  {
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

