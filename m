Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E5E1C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 07:09:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29EB32083E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 07:09:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eKWMXOQZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29EB32083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C2236B000D; Wed, 10 Apr 2019 03:09:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 898436B000E; Wed, 10 Apr 2019 03:09:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AF0B6B0010; Wed, 10 Apr 2019 03:09:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 32B786B000D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 03:09:19 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f16so827959wrs.6
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 00:09:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rmMDhL7r3scJSdYXt4VYgbOoqXnNnP5oEXQavWWJBJg=;
        b=gqSk3FqkRRqbImquV3jiOo+ah6Yr468ox+1fYlHnE28tiB1IvJRZxxMl+cixCDomJG
         6F9eqxG/h4K4rteKRALWqKGWypPQ/uvdgA6PikQXzgRhe75vi0djD+PBraRgC1hAFKZV
         b9LJPuBYiTGgepPkWmdGO/aRz/I5A7EQEk4I3B7SWpKko9s0Cl5Tx3GGr1QUzqsWyIIz
         vpwD8wYf+INozAkb34l6MZrfCoWnyYTPhzTJerZqb/qYGBS7TOGCbWRo/7yYtpeEY79z
         1rmfwsrqg79HSljs2i4mF1z+lkXZ5FtbYaU86mPOmeteArPwVlyNXvuQ6YFdqxhVwmqJ
         pacg==
X-Gm-Message-State: APjAAAVRTZ3emY+qK07LOk8VW2x1HQElqxDsOm7FsUeyXRG1Qyr1l5vm
	1AC4j3amELE8ATtXYwPVHVPYrK1AvHtFjfVHPSVSqy9rFTaeg+e0c1TiDospoR8+gNIe2e61Ug9
	yl0mrkpWZjG678QFc2aSEzVZsLj2abNtENCDCwKsfWsZ2RO/fc1qn6om6Oji+LOg=
X-Received: by 2002:a7b:c5d6:: with SMTP id n22mr1549135wmk.112.1554880158690;
        Wed, 10 Apr 2019 00:09:18 -0700 (PDT)
X-Received: by 2002:a7b:c5d6:: with SMTP id n22mr1549096wmk.112.1554880157897;
        Wed, 10 Apr 2019 00:09:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554880157; cv=none;
        d=google.com; s=arc-20160816;
        b=Eie4Z0cE0RTTZLNCLkeFdm314epVwgRgAqZ1YtxTtUWkz64qs1/wWunoY1IVIgapls
         R0DeXxdKDNC26Pfsdt7WASc+Q7zNL3jkhcws1l+UPPhBeLfbbLa/KSWaEwMwb53P9Kza
         O9jEy9LYWY+wyKI1fLe7ky6i3VyF435ngEgngNLSq7wZBAi9kszsuYPD8L6GHlUP0lCX
         7Ib4e50QIUbkRDCd7ETxNDIV3UTSI2W+WVhgXEmRnMYh/WoKP854ZQhKOEfWFOgIzoYX
         6imTQsYTC9goVP0p2f7XxLlH1m0DudgK8Keg7lJ48WMsaxv1jK+rhbZQwbsxGZPPBdYH
         tsNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=rmMDhL7r3scJSdYXt4VYgbOoqXnNnP5oEXQavWWJBJg=;
        b=gVzH+ztU0cNvTsnr1xpl8NVqXrBe4Lu+vsPZL9fipPuQSD247gcK8OaKTE/1jMvhux
         rYHWlA8pTB8j471s3ReA+XfIP/XXfm1Soo7Yw4cn3oyZtVz5NcLbcBi2YYj5EkG73A0p
         Ylr/MBjkDJaHrBeChXyk048Uo8n3Ju1kSVZ4NRUHz+3MsExuclgOBDWe1S1dlJBUWZrg
         E5MK7lcW8aHzcHVORXnc/EUa32VtFO1gcM9qnCTW8OokckY8iqImAIxi/CC2UkKgcUm5
         fC9l07cmdWByO9W05G3FoEdSFf8xHvTZB8LhsdnTD1WDBokbIiy+OAwNgbRaTlkrKY4k
         dnYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eKWMXOQZ;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j124sor796045wmj.11.2019.04.10.00.09.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 00:09:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eKWMXOQZ;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=rmMDhL7r3scJSdYXt4VYgbOoqXnNnP5oEXQavWWJBJg=;
        b=eKWMXOQZ19nAjBnGVrqRsm3NI7CyC60pLIl+iZm5ImplTuNblxkkoRZTsBzj92VKNi
         bVYnWYYHYlMkTKfQQXaQB5beQmLamUVSmqR+soSNCsAklnUZzMmY1j+YIWYurlg9KuFe
         lVJuFjkflfsHNizmSmZQy0n2ClMtKWByRYGMUOverKT8BXHBEOYmQG4G7fcIYUL0JGtf
         EpqncWMb37xf10yx358iUt5Fgvan10uZE4lSHlBFJ8KL2zqEGuOei/fnQLmplHmM5eNt
         YY4H9usBNPYrCL1soealdiyFDq3bBjGn6+kSIVQP10uKfbKKZKh3C3FAWLFNW5/J0JWe
         1tQA==
X-Google-Smtp-Source: APXvYqzMXxCIca1Iui6iiU/slOIXjvkFFL+Ohx11GWbcd2WQAF/Mp32cTqA2HHUhaVYYcY+1O3MZTw==
X-Received: by 2002:a7b:c5ce:: with SMTP id n14mr1665337wmk.18.1554880157596;
        Wed, 10 Apr 2019 00:09:17 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id b3sm36823698wrx.57.2019.04.10.00.09.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Apr 2019 00:09:16 -0700 (PDT)
Date: Wed, 10 Apr 2019 09:09:14 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Chen Zhou <chenzhou10@huawei.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
	ebiederm@xmission.com, rppt@linux.ibm.com, catalin.marinas@arm.com,
	will.deacon@arm.com, akpm@linux-foundation.org,
	ard.biesheuvel@linaro.org, horms@verge.net.au,
	takahiro.akashi@linaro.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, kexec@lists.infradead.org,
	linux-mm@kvack.org, wangkefeng.wang@huawei.com
Subject: Re: [PATCH v3 1/4] x86: kdump: move reserve_crashkernel_low() into
 kexec_core.c
Message-ID: <20190410070914.GA10935@gmail.com>
References: <20190409102819.121335-1-chenzhou10@huawei.com>
 <20190409102819.121335-2-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190409102819.121335-2-chenzhou10@huawei.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Chen Zhou <chenzhou10@huawei.com> wrote:

> In preparation for supporting more than one crash kernel regions
> in arm64 as x86_64 does, move reserve_crashkernel_low() into
> kexec/kexec_core.c.
> 
> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> ---
>  arch/x86/include/asm/kexec.h |  3 ++
>  arch/x86/kernel/setup.c      | 66 +++++---------------------------------------
>  include/linux/kexec.h        |  1 +
>  kernel/kexec_core.c          | 53 +++++++++++++++++++++++++++++++++++
>  4 files changed, 64 insertions(+), 59 deletions(-)

No objections for this to be merged via the ARM tree, as long as x86 
functionality is kept intact.

Thanks,

	Ingo

