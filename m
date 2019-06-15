Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A613AC31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 15:58:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4796421473
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 15:58:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="XkyL4uWd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4796421473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6FE66B0006; Sat, 15 Jun 2019 11:58:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F8EF8E0002; Sat, 15 Jun 2019 11:58:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 872B08E0001; Sat, 15 Jun 2019 11:58:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61BBD6B0006
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 11:58:36 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v6so87644pgh.6
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 08:58:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3UEdf7L10rlDvutzhQ5oN7IH73FXQkj8yTdma29U82E=;
        b=Rzi/yinIXcnjPjhn1/0R+tfcw6IWXROiNJ2zxaYWyJtEMnTc/i1CfjCEcwG7GcOvON
         /huSiw+pPthTWNnpi93OVya+osxSogELdwjLVBjrf6zX3L92TuPWFU2iR38nHOoVAqSb
         9CU2RvMI5rnTYXUSd/OMNkZX0Aw7wxBOose3ZayO4nF6h++HbkwMrhYmDoRD07JdY9+Q
         7W2ubbwdtBfMHBkKLNvf9Qzr4X1+o6ndFDSVq6+AFmbfkc5WrOgNcwYgCXqCO/g/K6NW
         4MqdgUsed1VSL6skxk5LuI9uEuuP3+nF4jKkGDBiwcaqqh36PHW3G2CKU3Sv+jrZ6sQM
         u4Cg==
X-Gm-Message-State: APjAAAWb4z0DEep38AIuoasUNQl2fsmCD6bHVmDsrPt0DaGlWDNv9diw
	umW/WNKm2r4O+ITpi17RCFul9MnKdSHkemP+CkInToyqAewfhgLm1ogdSwTq1V5DSpEmWuPO6yI
	FlrY6ucE+/BfV/HlaepHIw7d6CKCtPMWBcKFQwiKvozFM9dYj8OueHyLpfbLDOxXbNA==
X-Received: by 2002:a63:490d:: with SMTP id w13mr32175768pga.355.1560614315952;
        Sat, 15 Jun 2019 08:58:35 -0700 (PDT)
X-Received: by 2002:a63:490d:: with SMTP id w13mr32175725pga.355.1560614315160;
        Sat, 15 Jun 2019 08:58:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560614315; cv=none;
        d=google.com; s=arc-20160816;
        b=c6QY/JxsWfjtnUECegmk2Llsc1mbCzquv+HqDnFfYbl5KIfA7hGRSecJtvpiRuc7fE
         bjTmB8z7LO9uHk3CCdTFlWg91ksQJgqXXT51JgoKcbMT7B3KPepZzcc8+UzjGMl41hK+
         ZrR+fVlIHj0NzRvxjFZhJqMKuOI6SYMjbmKMJquWFaegvV/7fTRuXQdp/F98+BOS2ywf
         3WyNRnviOAipfsieegEeZBWuGrtUVZS4mA+OUzshZFczWtZqbej1nH2FFTQ7SHufTOlj
         QzqD1GXa4pybGM78n2XcqsXwaQCOaJvnyNOYCdUEfccHc+q6h0LNlclz1neUguSNLw7u
         v8JA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3UEdf7L10rlDvutzhQ5oN7IH73FXQkj8yTdma29U82E=;
        b=i4qxSMSennBhfuqqabajmT9r1oPaQPSUBN0H+6FXTxwWvrVVhurTh/MX+4lIyiEcoa
         O31KTXsJPGd2JY2GZk8xMOLye98F8UuVoTkAIxiqJj1S+83Rpm8xROi45AzI58+gAHAf
         c/5juY30APtXPT+cMbKc+LUNeUC0uAe6+7+ipdCvbKeSdZGIbeaVpP3nggGny5ZIcCh0
         rQEUiBWvD9e/ppppNYR7pQih41PNQg8EszfgtRt855kxBkSVeUWInanvFWHDC8pgBVto
         Pfx6RYNrNkkuEZhXuRaN1md/aB5uDRkMThzAU+DbhYHWAcTDxrgPnsMMbnFFFa8UMUyf
         aHAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=XkyL4uWd;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d37sor7786905pla.2.2019.06.15.08.58.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 15 Jun 2019 08:58:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=XkyL4uWd;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3UEdf7L10rlDvutzhQ5oN7IH73FXQkj8yTdma29U82E=;
        b=XkyL4uWd3z3bLemMqav9h6r4cxQjATGvT6nrLhY1yRSxw+QOo7/ixS91nRkv7T5pHZ
         ygciPYZ3p4au9mHIUYBFJFcheawDvU2ZfcbDSLexM7mBnSbvzcbm957GXSGPBODlinPN
         VzLZVxx8U7/Rur2+zKhPoPSglFf29mPLk5sdI=
X-Google-Smtp-Source: APXvYqwfY314uRro4dsc54oOetfpJqc+ffBY+G0B6BoAGGAlJaMAITXdd1MDQTxvCLR47/tBL2uq+g==
X-Received: by 2002:a17:902:724:: with SMTP id 33mr96737215pli.49.1560614314543;
        Sat, 15 Jun 2019 08:58:34 -0700 (PDT)
Received: from localhost ([61.6.140.222])
        by smtp.gmail.com with ESMTPSA id p7sm14713756pfp.131.2019.06.15.08.58.33
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 08:58:33 -0700 (PDT)
Date: Sat, 15 Jun 2019 23:58:31 +0800
From: Chris Down <chris@chrisdown.name>
To: Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] psi: Don't account force reclaim as memory pressure
Message-ID: <20190615155831.GA1307@chrisdown.name>
References: <20190615120644.26743-1-xlpang@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190615120644.26743-1-xlpang@linux.alibaba.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000008, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Xunlei,

Xunlei Pang writes:
>There're several cases like resize and force_empty that don't
>need to account to psi, otherwise is misleading.

I'm afraid I'm quite confused by this patch. Why do you think accounting for 
force reclaim in PSI is misleading? I completely expect that force reclaim 
should still be accounted for as memory pressure, can you present some reason 
why it shouldn't be?

