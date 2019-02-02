Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49E90C282D8
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 00:50:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E963A21479
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 00:50:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E963A21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BF618E0010; Fri,  1 Feb 2019 19:50:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6482C8E0001; Fri,  1 Feb 2019 19:50:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50F488E0010; Fri,  1 Feb 2019 19:50:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 205B88E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 19:50:27 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id j125so9154935qke.12
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 16:50:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=B8Qw9O7dySqpKIga9yf6UI2bdKwmugZYXHOvSM/4LIQ=;
        b=Q58CEm4iTYlCh//SvUJRlVMpU9bMpAwiG4pG4hwigFYz4158oGRqcalie+/TT4T7I4
         hoXFdmmKciB5Y9UP4bu8wPKEhhrnFZDHDT1FgLBc8evMzGM8lYW8wRt0swZ70otGn7mV
         rCAp2/lh1o+NbETkVKetajCZeQ5SsgYpocXQJg+wRKJyAqHuLzqeKodkcS26J8Pljgal
         FmuR5Iz3ZgYCoJ2QVhvZMpEDJXZk1tKbl3Qk5ELt1qmVVHBYGbPTonE+iJilMpilRZWT
         +wp7MTdro8G/NHMZG6ucivscXeb9WCTxDcSd0+eVIBmjNFlMqcljtQMnPudVJcZKLs2P
         N00A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukccs2YfwoQqPYf4t/JQ5fFCD6me93ggbu2zkhiipVNXNPIyEYn/
	k3rZqy6r41Apl04cF5VwbfYd0QPutnA06jA/E1qjmck/0kvuwqhWiRmuawP5nJTRahfvgI6NUfq
	UM6X3AEkK0R705U+mmRqjr9k31Su6YssCouZKQVJUii5PS/MoX2LpUBsvSrZmbhN3WQ==
X-Received: by 2002:a37:52d6:: with SMTP id g205mr38604792qkb.335.1549068626883;
        Fri, 01 Feb 2019 16:50:26 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Q/0xXyhErcrgKXOYNbw0BDn0yHD0uDcWIZnHfFzeuEFmhxGNQZ4958RJGhSCp3xY8kL9V
X-Received: by 2002:a37:52d6:: with SMTP id g205mr38604777qkb.335.1549068626351;
        Fri, 01 Feb 2019 16:50:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549068626; cv=none;
        d=google.com; s=arc-20160816;
        b=VLrYTEgWO2ZmjSkW1aSHzsKZhRmWIAIpNz6kJRt0+1boun5LDP/4pXQQoXmZfsVINr
         dD4x9xDf/oHGuXQ9/YKw9FmXvpC2vsAnpq91UIP+qLxU97GIZvk6SUJPRIIp0JCFyPsh
         EsYAKsxSPzkATVAdZUAfFD9++BW1TadmPQjnAy+vlfA99ZJiRDB2cBnFKeNyBiQRWE0z
         2MDBQReVX7ZeShz29cHnSJoM+JVkgFTZ9UGPXFfayzWICZlad5XzbzvbsWVlpzcnTsqH
         jEroyXZEr9ehUnPt5IT9DTIKU4VQRjyGiIP+3bsydcs20FCFPK0q+YWMptUBQEL+alie
         e/AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=B8Qw9O7dySqpKIga9yf6UI2bdKwmugZYXHOvSM/4LIQ=;
        b=Ye1YpxXGAEvpayPoUeM0y7aSJXzvosDRFnJXbNBbASG56Qf+6ZRjUFsSwUv2Tj+Mze
         LExiMqi6jLMwCjGAJ8WES5ONA+6Y693CW+Nxiz3khcIgBMBjS+WFJ7hsusf69ygdfc+3
         DgJtgqINB4sjrhkwAYqEb8lupCZ9p6Yv6Pf0Cvn1Eb3JIlxfRsGKtpIW4fMw9TFXJwcC
         1tGb8Nyb9zmiyBT65PDCp4GOW1szCCNT5bihYvcFsolDy3uFrt93+3rcfxrb/H+NLWED
         lSc7YDtWYj77B1J/CJQs6TY3uzSPemoryY0mnbTxbS9kLRZoOFRQnMXm4QKBRoFLeQuU
         2e+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l45si4517701qtk.229.2019.02.01.16.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 16:50:26 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5D6C4C0495BB;
	Sat,  2 Feb 2019 00:50:25 +0000 (UTC)
Received: from sky.random (ovpn-121-14.rdu2.redhat.com [10.10.121.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0296E608DA;
	Sat,  2 Feb 2019 00:50:23 +0000 (UTC)
Date: Fri, 1 Feb 2019 19:50:22 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Peter Xu <peterx@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, kvm@vger.kernel.org
Subject: Re: [RFC PATCH 1/4] uprobes: use set_pte_at() not set_pte_at_notify()
Message-ID: <20190202005022.GC12463@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190131183706.20980-2-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131183706.20980-2-jglisse@redhat.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Sat, 02 Feb 2019 00:50:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 01:37:03PM -0500, Jerome Glisse wrote:
> @@ -207,8 +207,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  
>  	flush_cache_page(vma, addr, pte_pfn(*pvmw.pte));
>  	ptep_clear_flush_notify(vma, addr, pvmw.pte);
> -	set_pte_at_notify(mm, addr, pvmw.pte,
> -			mk_pte(new_page, vma->vm_page_prot));
> +	set_pte_at(mm, addr, pvmw.pte, mk_pte(new_page, vma->vm_page_prot));
>  
>  	page_remove_rmap(old_page, false);
>  	if (!page_mapped(old_page))

This seems racy by design in the way it copies the page, if the vma
mapping isn't readonly to begin with (in which case it'd be ok to
change the pfn with change_pte too, it'd be a from read-only to
read-only change which is ok).

If the code copies a writable page there's no much issue if coherency
is lost by other means too.

Said that this isn't a worthwhile optimization for uprobes so because
of the lack of explicit read-only enforcement, I agree it's simpler to
skip change_pte above.

It's orthogonal, but in this function the
mmu_notifier_invalidate_range_end(&range); can be optimized to
mmu_notifier_invalidate_range_only_end(&range); otherwise there's no
point to retain the _notify in ptep_clear_flush_notify.

