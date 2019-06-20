Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1738EC48BE1
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:49:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2B2B2084E
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:49:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Q8dvbg7Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2B2B2084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EB016B0006; Thu, 20 Jun 2019 11:49:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 674358E0002; Thu, 20 Jun 2019 11:49:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53C5F8E0001; Thu, 20 Jun 2019 11:49:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0387F6B0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:49:21 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id r4so1355096wrt.13
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:49:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DEHl/heRoFE3pmtAOs3jRbe+EMJIxlq4+fAPJDAKNqA=;
        b=PA7q2Nrt23sUD1ZTEc1DEJc/rebfIoll60ZE4CSa/1IOKasMAB73XvJTNZ9cFbs/rF
         ug9dP+4lMZfVRSRvVvdvtNdpmZ+GRg24N89LaoF/XAtS/d5vM47HTzH5DxzV1oaOZd7b
         3kPA5LR8ypMNjkJhWffi7ZwK0lpkwWrIx8W+iF/xW/daVKAAQD+zuP/QM3V5+IrDKofM
         0EkVEZ+EFmx9rCjbER6xDPsIqTrVMa3Gsfo10FZn+P7zI0XXUl6ZV6AHWD2Q4Ba8dGrQ
         wtwlaMncjkbY+y69zNwozMZYEOVgPc3Z4oeevWeOkzM2FSu2GltQEY4F8M6OBKlp/4lu
         PnNA==
X-Gm-Message-State: APjAAAX6D9CivZiWB8GBQgoDURWzwvWwde9Go3eshPAPp5bnDuknFovH
	v+XmjXemDnGAr2a2CIdE27sBf/pCHy0ZvgqI8UKgdsVrKD2iaPzEeznprGI6Jqw+3C7A2Cf5zbV
	PSMxvvn0rNRCcIeGc6wOaaQYOQRVj0aaFuPnJ3KBhXV4qiHx5uNr92SbF486IIPDSCw==
X-Received: by 2002:a7b:c301:: with SMTP id k1mr187674wmj.43.1561045760430;
        Thu, 20 Jun 2019 08:49:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKaR1rZMZKvyJVIw6LQZhu466h2oyT5++zQbx8YLHFNchLdWlEjcebMI2h+KtcuOCgodHG
X-Received: by 2002:a7b:c301:: with SMTP id k1mr187645wmj.43.1561045759665;
        Thu, 20 Jun 2019 08:49:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561045759; cv=none;
        d=google.com; s=arc-20160816;
        b=rS4lTsgw/A99YwZOfNa3wDk4XVLuKTVtcnwhxHVVcEoWJU4+j7+NNW3/867IbwV0Cd
         QE+o7QakaOnaVmLhdhuaiZsFwJSI3D/zQ8jnHJFyfJr5x4gcqQkNBnp7AUcqhztNqLNZ
         sz8lygMj9MKH3JZi8zSzbLm3a39zma7bLKL6OPQ1G9bqYOD+oORy0ReX8P70FY5OLwrn
         J3IDc47FRBavYzruKdZw2q3YeR/cmWy8l9AVX+kJTWWoNq8nP1rsMVdyHZ60o+NNAtuY
         f04Vz7xHX7HunqPx4iDFuR3ueiM0lXXNR9pXwhB/8RfjoAq8zJPD/t25AQpbGDkDWXgq
         fC1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=DEHl/heRoFE3pmtAOs3jRbe+EMJIxlq4+fAPJDAKNqA=;
        b=A0LK7BtS48by6nlPMiex4q5xS/JawetWHog48hl53FsYn4hy3JUpE6YAYWz1sLOTow
         fYZyx8u8/D2kzgsNuDali+3uFrnpPO+mX1llKtt5SurQVN67kBAOmNmIAIX3XYs0RyxM
         yFm2ndjsv6DZNhtYyizhpW3032FisPoBBRnSWfVieoX7gt2jUgxtN5ZaoRncfAiituzA
         8xO2nn4z6BAvEAKY/d0XZvaX6OzINhHLT0WmEdr+9tlDH2xN8EaoUnFKv6oYTyhYbNHU
         KE7n5ySYGBI4Ub/PpVhOESdppDF+1HVxiEAvIrWEPlMshaPR3QVYTUqUFfYUyFu4iq4B
         0dYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Q8dvbg7Y;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id v15si94571wmf.136.2019.06.20.08.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 20 Jun 2019 08:49:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Q8dvbg7Y;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:Subject:Sender:
	Reply-To:Cc:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=DEHl/heRoFE3pmtAOs3jRbe+EMJIxlq4+fAPJDAKNqA=; b=Q8dvbg7Y3KEguFux87Tlx8c4nI
	TzRU0UFrSH0P5s98Ir4S7dS3oFK63/wyKX/EX9awC86Z4Lp/RmiDXdS/rWlSXwuz8FpMlJqT97jzE
	8BgOhI3ManVmb4M15/4DF851rnD+ujzuR7FcZVkUKPU4StnexKlSXhp3F7yX9fifgd9BHu9mgc/l9
	Rm8jaiQ+3L1+e4ExkTlf0yQ8G8NiOS9o537wp1iWcdguBUqtBW1oUSLtGWdPNvKqMmHIcOMG/h1Me
	jU/P1a3P6/0bgnpPWPJGSXH3yUdmgSVkoc+q+jL0vmermx/de1lRLpX4Fny6RGoDoaYx/WOfOHylU
	v94QgEpQ==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdzJ5-0000MQ-Ia; Thu, 20 Jun 2019 15:48:59 +0000
Subject: Re: mmotm 2019-06-19-20-32 uploaded (drivers/base/memory.c)
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 David Hildenbrand <david@redhat.com>
References: <20190620033253.hao9i0PFT%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <bbc205e3-f947-ad46-6b62-afb72af7791e@infradead.org>
Date: Thu, 20 Jun 2019 08:48:51 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190620033253.hao9i0PFT%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/19/19 8:32 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-06-19-20-32 has been uploaded to
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

on i386 or x86_64:

../drivers/base/memory.c: In function 'find_memory_block':
../drivers/base/memory.c:621:43: error: 'hint' undeclared (first use in this function); did you mean 'uint'?
  return find_memory_block_by_id(block_id, hint);
                                           ^~~~


-- 
~Randy

