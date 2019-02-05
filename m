Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 974A8C282D7
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 04:27:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49FF32145D
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 04:27:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="xHNBcEmw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49FF32145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9A618E0073; Mon,  4 Feb 2019 23:27:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D489B8E001C; Mon,  4 Feb 2019 23:27:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0FD18E0073; Mon,  4 Feb 2019 23:27:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DEE88E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 23:27:01 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id f6so754083wmj.5
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 20:27:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=513oF+ATFNhhmUeGw8GvAD+0D2t0iAj0G4FjhtwBt3k=;
        b=ALSWONgs+DHqyrmUnTQzv3G7J2QeJkMdhbfo5r44bJScIHLf5rvnOXDoxx+0/+qCT1
         R7w7iOGfLaROIwSiOTQ9LogwNUH9aqXC4zZQh+fFSs8q+oCiCtGjRlBjeEcVhK5S3JNl
         g2WpTNfPlK7qnaZjSURJcnvPgWcLc3eLAEy33bPNZT545Dvl2L4ABfgAE/BDaRHNjFui
         wUMi/N9czJG7z3IlOL82oT96NPOuMDAVnK45rZw8WuR2mSAblGIXNef9e6307eOoeCf4
         vZkZlcTyP753IaEPhBX/qkpxSt1xH6tLfRRYH/7QtAvt+k7PN/Mblx2xRXb2zsaGPN1S
         9W3g==
X-Gm-Message-State: AHQUAuYBqry/ranivOktZQk1q1x/lzYBA6iSOq5t86sjoP6pX/S27qHT
	zlSin2y6SqlZv85tOZ0dY+US7g1hN60q3E0OBosbRAch6z0w8SKvg+bw2u8J0mJLgZOWLxcCpi0
	djfngp0WjgmXENPRBOrcn6YAz7UGO7g8LFoIJPIBBBmZhAzShZSg2NuAfeVvUMET27w==
X-Received: by 2002:a5d:488f:: with SMTP id g15mr1862605wrq.15.1549340820806;
        Mon, 04 Feb 2019 20:27:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYGW3TAatmRXCxjjxykOrGA1TSoHjiYuWD20nxU9Q7XLZTnkAQAwKKvjAYcQa3m02bbKFgd
X-Received: by 2002:a5d:488f:: with SMTP id g15mr1862576wrq.15.1549340819613;
        Mon, 04 Feb 2019 20:26:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549340819; cv=none;
        d=google.com; s=arc-20160816;
        b=unadnjPtLOsw/nDNzO9GOrBbOKVuB8G9IsRyPPMpNEfTBkhUcp2m2+BQ1kRrp1yumG
         cQj7v+2GnkUIW/P+99Az6uXwFJaR/j4Nqmr5P0e8WKdvbHjEL5fD5KdEyQnfmniwkk+Y
         z/7X+QepIu0aKBdBTO8HDtXfbTN4w7rmU2D60EvI3kFN9Jo/QO2iyNqvHiVAc1FRQm7A
         88bYGDE98E5K6AlhgFnKPP5zsusxOGMRoj4IjjBW9sagyeWl9tLdS8HEZdiXiXJAuFSN
         E9OABOktr5LLpBzd6hTT6RwfWNpzcmj7GUr4IxyAgj6g6ev+ACxI0L98QSznUT0aMYsD
         /HIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=513oF+ATFNhhmUeGw8GvAD+0D2t0iAj0G4FjhtwBt3k=;
        b=i1Ee2EvGlpF91Cedqhz5XWMVcpegkMaB55eKMvzOmjA/FHwiUuK60K97tXzFlteU4V
         3V5jTsW1JV1birHOPhcQmnzoLyTvf0Jg3E/6mwI6QqS1wau5ttwf0tq66QBfpc+niVMD
         LSEdHOe38F5Jxq4hMLeKhuNJ22y3Mh0DCHbHACDw35Y7HO5Dkp2Uf2Q2rjSS8K73TAm1
         YFNH6r7eU/mQny4R+Ahllb7GQX6GiXL7ONvIyj984Ua7UMpItPSY3nNHIHNBzU74mFH+
         FAL9SW2Q4pB5D1UwTfR09TgvQvmhSzH0RjzM9/Z6pr156zbwpyCL0fbhiA+02llrw67b
         KJHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=xHNBcEmw;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p17si3204500wmc.93.2019.02.04.20.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 20:26:58 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=xHNBcEmw;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:Subject:Sender:
	Reply-To:Cc:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=513oF+ATFNhhmUeGw8GvAD+0D2t0iAj0G4FjhtwBt3k=; b=xHNBcEmwlJkahQnUTsbH73Vw0/
	HRol+3uUGAq5VaSZJ66oeXJ2IfZqpuMtUZz2VdbmfvOcAVQD9zixI/lGTTZu2f23mzJvI8xRe82Gp
	ogHugBZF2W7Mgg8FyAYlmwDpBUZNTLxgBOB2ay6Hw8cjJtrv4YNoRpLHfpFjcvlFgXR7mgXyHYps+
	9Ypzg/KXnIOYE74MggAmPPuceiv1KuxDgBA/I4/Zyk8vk7wbcgS6aa2kL+IxtZfrCZtjKkG2odpCU
	Oi0Cle8Bk1jzZk5TNoEajpEbeW5I/xdb2doR6kEnnMkAJWkRRJWb6F3QN56f7Io+CWd0wsMYMEGcm
	SR35IgBQ==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gqsJr-0007gu-QH; Tue, 05 Feb 2019 04:26:48 +0000
Subject: Re: mmotm 2019-02-04-17-47 uploaded (fs/binfmt_elf.c)
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 sfr@canb.auug.org.au, linux-next@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org,
 Richard Weinberger <richard@nod.at>, Alexey Dobriyan <adobriyan@gmail.com>
References: <20190205014806.rQcAx%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <08a894b1-66f6-19bf-67be-c9b7b1b01126@infradead.org>
Date: Mon, 4 Feb 2019 20:26:43 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190205014806.rQcAx%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/4/19 5:48 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-02-04-17-47 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 
> You will need quilt to apply these patches to the latest Linus release (4.x
> or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series

on x86_64 UML: (although should be many places)

../fs/binfmt_elf.c: In function ‘write_note_info’:
../fs/binfmt_elf.c:2122:19: error: ‘tmp’ undeclared (first use in this function)
   for (i = 0; i < tmp->num_notes; i++)
                   ^



-- 
~Randy

