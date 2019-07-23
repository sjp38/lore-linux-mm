Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FC56C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:52:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5CBE223BA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:52:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="rduY142V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5CBE223BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 631CF6B000D; Tue, 23 Jul 2019 13:52:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E2E28E0003; Tue, 23 Jul 2019 13:52:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D1658E0002; Tue, 23 Jul 2019 13:52:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16ECC6B000D
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:52:40 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d6so22377041pls.17
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:52:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=KTvDsWJ9nFqYJQpibABtOedABuJ1+9nvhoR6NWwgftM=;
        b=VBG3BEmUnhRqmge7FzhpgK3BN1z15OPFVhAdGZHo/qsXrlLfvXITzrGjekg7As5d3A
         8HbWX7TBuedCFlbpsAxsvq09pBHoTv72JnqadcfNMEPTbCr9E9QBK0T9Jf40a5Rgs47n
         l/LY4hzUY3j4KD4zumr14bRmMyqm4DFIpCFWvMzcRm3T0+gTOa/QerLCjJcidU9F+eSA
         YMaT7RZkqkwDKiR3Nl4ChovSOETsuAsTCINV0Nfnq31QyZNrQUpmywDRyQL/0mrkAbYi
         K92ThlBnpfzHK4iCs1H59SPCoHwx9H+kLCN1Cw710YCI3CdfEM2tlCVImMz1RrW4fe6z
         if4A==
X-Gm-Message-State: APjAAAWVr/jN2C6AJhL/4EOCJrZkR37XiLNC8rKKtbBFapUaUoIjVUYv
	aXz0jz+RpDpJMpjbPqT83JS4JO1wpbwgEyfHkoX9YX2E3oPCy/4RWEpC/VcZQgjlNG+u0N/iK7k
	+u1M/EpwxdMZqR8Z0PRoD1vkaDB5x6KDxO5lJAVHNNwkN1HA0Bkg98jmT6X6EUpEEaA==
X-Received: by 2002:a65:6288:: with SMTP id f8mr72214695pgv.292.1563904359507;
        Tue, 23 Jul 2019 10:52:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznjR7xUEfpmeAX0HRuIEkc87uJaj4cwD7tLqz3C+Jl6D01sR/ObUzxjelDX1+8DQhJBXqF
X-Received: by 2002:a65:6288:: with SMTP id f8mr72214650pgv.292.1563904358683;
        Tue, 23 Jul 2019 10:52:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904358; cv=none;
        d=google.com; s=arc-20160816;
        b=u4blS7UOwOBhZ5n2tlVmuK3iq0E8NH4LSVzyjKyEr6VyB4xkceyQqMHwl7Nm1M03Gl
         G5N5n3zxy0s52AP0c7vNRacM/bleTWpOQpjwXAaksvnxpw1bYqnDj/EpW+YszYVpxDZJ
         Vxa8vA55tIXyKqu8VoFPRSQry+zD7q+FfS2I94ytwgLBayKpcdRxEHofOKnYtfJkzd9e
         Yj5O7FcYnN6w+ivB7e66kKGRK5n1tglS0Acgp18l7km40h7vP297FLDIn90emBPRnXxB
         4w8Q3WBy6SkjlAy60vqh3Y3AV9DLNJv8Mg0e3aR60Uzrar6nanlPJzveBzSXKQiBojoV
         8wWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=KTvDsWJ9nFqYJQpibABtOedABuJ1+9nvhoR6NWwgftM=;
        b=habWYOjsu1LHTBHE1PKgIezux2GR5tx16xt3T6a5EXCflVVWGC393qJMGHag/8gB2I
         uiEvCNOkvuSVE+vR8RDN16+OPT5Y7X22lWuR18Ipx3FVvMUABH3WG8HUgqdbrx+MW7z9
         RvOpoRQdelPJZjkbZtkkqImQWQmajRk1mTTbJZnROxQS/3HJnv8m5E4tcL+r4dVvmOfX
         0LJTq3SDRDYZnXPrXGxBM1YMambUxEgF20+iKuvGHDQJHD2W6LjZRWBb3MVC4VIDeyFK
         N//0Es9nEKjYmxbbQlIbs1yzV8I6TGbQ/d64K7RPWwv4Iph5XkVFyPDc3xBiSe65Pn81
         cI0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rduY142V;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n128si12027715pgn.82.2019.07.23.10.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 10:52:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rduY142V;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 74E752229A;
	Tue, 23 Jul 2019 17:52:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563904358;
	bh=nmc8uaRDy6gzgZmALXLogPzoQsDDnnuylDBBg1jtn1c=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=rduY142VQa1IsnoNlMdQo6TGmPN6qSG3GZUkSwSTd6A59arYA0evBnpSt3fmDAemz
	 CkugF3lhK7nLyByuBN8u6yAmLgwlLNa501KqRSNFgeI5W55M+Tw7sOQqUQ4mptCv23
	 hbqbBoA5xQYu9iVktqkbMIy0z5Q0SabAWFEhYJvw=
Message-ID: <3622a5fe9f13ddfd15b262dbeda700a26c395c2a.camel@kernel.org>
Subject: Re: [PATCH] mm: check for sleepable context in kvfree
From: Jeff Layton <jlayton@kernel.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 viro@zeniv.linux.org.uk,  lhenriques@suse.com, cmaiolino@redhat.com,
 Christoph Hellwig <hch@lst.de>
Date: Tue, 23 Jul 2019 13:52:36 -0400
In-Reply-To: <20190723131212.445-1-jlayton@kernel.org>
References: <20190723131212.445-1-jlayton@kernel.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 (3.32.4-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-07-23 at 09:12 -0400, Jeff Layton wrote:
> A lot of callers of kvfree only go down the vfree path under very rare
> circumstances, and so may never end up hitting the might_sleep_if in it.
> Ensure that when kvfree is called, that it is operating in a context
> where it is allowed to sleep.
> 
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Luis Henriques <lhenriques@suse.com>
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  mm/util.c | 2 ++
>  1 file changed, 2 insertions(+)
> 

FWIW, I started looking at this after Luis sent me some ceph patches
that fixed a few of these problems. I have not done extensive testing
with this patch, so maybe consider this an RFC for now.

HCH points out that xfs uses kvfree as a generic "free this no matter
what it is" sort of wrapper and expects the callers to work out whether
they might be freeing a vmalloc'ed address. If that sort of usage turns
out to be prevalent, then we may need another approach to clean this up.

> diff --git a/mm/util.c b/mm/util.c
> index e6351a80f248..81ec2a003c86 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -482,6 +482,8 @@ EXPORT_SYMBOL(kvmalloc_node);
>   */
>  void kvfree(const void *addr)
>  {
> +	might_sleep_if(!in_interrupt());
> +
>  	if (is_vmalloc_addr(addr))
>  		vfree(addr);
>  	else

-- 
Jeff Layton <jlayton@kernel.org>

