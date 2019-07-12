Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B501BC742D1
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 17:30:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 634F820665
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 17:30:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WHv3WsVc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 634F820665
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02CF38E0160; Fri, 12 Jul 2019 13:30:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF8468E0003; Fri, 12 Jul 2019 13:30:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC2008E0160; Fri, 12 Jul 2019 13:30:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A58D48E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 13:30:20 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d190so5922060pfa.0
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 10:30:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=fliyxzDfAGBMmN1oXsqyomaZR3XENMW0vd2GXXQScuA=;
        b=N4nQ04IF1MqxkmvcAkwNLyDS2yLtY91j9KLrWHDVshhmg/UFqLE5KJmIJKlJHVY17v
         jqNE3m2RIsP727Ca/7rIhUFusFydKkTvACsV4dq+Dt+LXHb5BR2oR5VLDbjrANyLP4m2
         sLXFz+joIRjbGXUorIn2pd9POu070dCEqXX8+KGqggHFPTfFbwK3vwsybgyQRJlc9Itd
         gVQo2JTWmAcXGbvjL6klTKcdHSfaaB1G8nh/i2uZXyX3viwZv+H0urGcXY6+GqmuElk3
         Agu+zrxkCtTUdHOEZBk00huDFwxlFUDEO3HxbayrQwPpUhhtLwwLCvwZohqGEcN5sQys
         Lzdw==
X-Gm-Message-State: APjAAAVpsulxTeX70ZGPmhn25rGPu985kfK5JylqPqe2LLGzL7u9Rp7/
	eg32NxA/ie9ElXEV4rW+gGOeCmttKAaU+7YbCcxk8ow2cTnci2AtihtWTFlZbjxbaCGstc1Guk4
	EJUww5+pRgJz7LyKoiQf/SOJanUHyKuL23xI/YqBoAox2YBvwdK/7MXNI3SEyaS1lwA==
X-Received: by 2002:a17:902:bcc4:: with SMTP id o4mr12591284pls.90.1562952620192;
        Fri, 12 Jul 2019 10:30:20 -0700 (PDT)
X-Received: by 2002:a17:902:bcc4:: with SMTP id o4mr12591154pls.90.1562952619255;
        Fri, 12 Jul 2019 10:30:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562952619; cv=none;
        d=google.com; s=arc-20160816;
        b=YHIa0lMUdk++aGhJKiBq4oBZe72nJNtFTNj1f/Oq4hivROTQQ7L3AOAZKyTeoF8Wvt
         nRXHRKhTGu3spECLjqMlbdmXDuc7H6IaiREUI10N1HmUtvoultb2DU+cCY2dDS+liDfn
         kCpGdiYLxB6snvcGauuWxjhOrmvb0mlMnB7YfhWbwDWFSxx0uVfamUWk4Bd8banqpGB1
         /AeK+9IZhBYxx0q0knNHChKSsG2tcR/MRUiHZTfvytQLlcZUIIb1p7DSdyxK9HxUZFtm
         Rjs8dtgyLMT5SDzynQbZfYAnxHlC77BP9u/1XWmIPy+VosAQ06i/atoFnR2YaJQhgpko
         oHsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=fliyxzDfAGBMmN1oXsqyomaZR3XENMW0vd2GXXQScuA=;
        b=RRTuqyMe18UBFNGlN3dWMT+eg/JAN6hHzZ9sMd3vDSVmOhDwLgfgjFMKqoyuYSrn/Y
         a/+Lv3Gmqb7S3vRzTX0lcnj96cgkNRLFd4wrqwEAtYHuEPAe7z8MxoqjZG44YeOk60Cw
         7BmA2WY4bMJe27tXOxNj5VDbfEr1Y69n6uHe0Fw2Q5rlHqSwTZAsD52rvKyWm2tXwCj9
         mrhn3eNF61m6oaeZiPvROFEDF7q6SlCQqNbupbazkzBFNkzKlfoWMOKsYGkL0+kiXQkO
         znZRha9ftKpdje+wjBuCOpXSFfI5O4LycZIWW0+VNMGzu5YOSAD28d2/vVosth+HPqLi
         1maw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WHv3WsVc;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b64sor12120091pjc.24.2019.07.12.10.30.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 10:30:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WHv3WsVc;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=fliyxzDfAGBMmN1oXsqyomaZR3XENMW0vd2GXXQScuA=;
        b=WHv3WsVcfVvezkKKS3H0aawILgSQZgZE2JrppFVVLLcybTbjvszHp0YHwdEC8Mf8eo
         JzxgpasgG5Kxq8s70uaXFGQwXCn+ZNp6bXxCYCYHm3tvKGeeeKApuaseG/7BdcZluyVt
         tEnoDzmgETCjXgOnUchBlcdeExxDDA9aXuRU9ET0a8kLQEMR7SrFpRC/HVhVPAKSxzId
         NT26/oYZHx6T4E4JDMsaL1qhRowsZUv76rpP49r0WACj4E05JY8YPi9rBPXhIE2FuyZt
         TczgW3dgHLYaGMpEBmIDg6jZRBL6mFGK/4L+ao21+6sqhrKuga8q3qawuZSb3J/F/fLZ
         h+BA==
X-Google-Smtp-Source: APXvYqyFRe+9t9oI9OuMUg/uWyyqVPA9eQjdSu5mEYBvFWkkDunZWJTVzidpDAc5NnLVlkAKLyul+A==
X-Received: by 2002:a17:90a:360b:: with SMTP id s11mr13024964pjb.51.1562952618502;
        Fri, 12 Jul 2019 10:30:18 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id v5sm8405051pgq.66.2019.07.12.10.30.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 10:30:17 -0700 (PDT)
Date: Fri, 12 Jul 2019 10:30:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Arnd Bergmann <arnd@arndb.de>
cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Stephen Rothwell <sfr@canb.auug.org.au>, Roman Gushchin <guro@fb.com>, 
    Shakeel Butt <shakeelb@google.com>, 
    Vladimir Davydov <vdavydov.dev@gmail.com>, 
    Andrey Konovalov <andreyknvl@google.com>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, clang-built-linux@googlegroups.com
Subject: Re: [PATCH] slab: work around clang bug #42570
In-Reply-To: <20190712090455.266021-1-arnd@arndb.de>
Message-ID: <alpine.DEB.2.21.1907121029590.128881@chino.kir.corp.google.com>
References: <20190712090455.266021-1-arnd@arndb.de>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jul 2019, Arnd Bergmann wrote:

> Clang gets rather confused about two variables in the same special
> section when one of them is not initialized, leading to an assembler
> warning later:
> 
> /tmp/slab_common-18f869.s: Assembler messages:
> /tmp/slab_common-18f869.s:7526: Warning: ignoring changed section attributes for .data..ro_after_init
> 
> Adding an initialization to kmalloc_caches is rather silly here
> but does avoid the issue.
> 
> Link: https://bugs.llvm.org/show_bug.cgi?id=42570
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: David Rientjes <rientjes@google.com>

Let me followup on the clang bug as well.

