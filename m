Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBFEFC282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 14:31:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A81FB217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 14:31:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="hz72O9Y3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A81FB217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A2718E00C4; Wed,  6 Feb 2019 09:31:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32A1A8E00C1; Wed,  6 Feb 2019 09:31:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CB4B8E00C4; Wed,  6 Feb 2019 09:31:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6B398E00C1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 09:31:23 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id v25so727416wml.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 06:31:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=aCkiqYNvxX1a9nJPU/Nbyv1sM4Ffext0Xrvmi7ouJ9w=;
        b=bfGQJ8lm8InkohLEhwJCBqoYdOzHbDzo04pUc74ac71XMi1bd8sKmr/3NWSec747z8
         VujFPn3Mqr34YNvW78sVWnxuvDchUpJ0CjUI+w/lyS8I2vzLkw6kfX52oPRB1o0iK2jA
         KfZMyfwDsMMjhSmeReo1bf1rbefCy6BWvhYZPjQKiVEZHhiYwfMEbxmjadYcK3rt4LbW
         dYbK5wrLmksRQjqp1qiDndRkDYvv+0CjaUr/koGd6n/s1n32zfBAjfGxyrgOBI7FRlur
         sT+Tr6no9BLqB1WMPdmugQwfQVP4/dZlOOT3VHMzrfAMuIldOQUTbER4lUmR17ehnnH2
         eESw==
X-Gm-Message-State: AHQUAuY2XAOZXbePUnVlTf8AFSaDp/ASWANgQ4no1Oegv8miWt36o7vS
	pB5fv3oY9EGdIPFdlTPV4DqRIjMpYxQft/0vwcPNBW0d+dWvEubnAzzRoqxB3hYFM4A3eZSY0z5
	H8C6xmm03kn3fcGFX2lIP8puKXaqMmS120m8tg0PDI3D4Bddn2Urvk/epViYXNbZqnMVkbJgtP4
	srI5DqiP0HgynThY5NMzxRExAAmbpO+KduH8GCEpPiHIE0rgtf4SjpQUMlkH1bqEj+e+gMTHvG9
	RZ3Kc78er4hioKtBjq9EdAe57fwZGNPnlRFBv9vznwkX1O50r2K5yK0UM8uMSWYfp50Ht3RDroD
	aCDBrrxkQtzuNxfwhTEOYInGzROSNjvegx+xCE8BtZrkd6D8/KFdS+Jx2K+bCLhOuhYW/LFGIve
	N
X-Received: by 2002:a1c:67d7:: with SMTP id b206mr3366740wmc.77.1549463483084;
        Wed, 06 Feb 2019 06:31:23 -0800 (PST)
X-Received: by 2002:a1c:67d7:: with SMTP id b206mr3366665wmc.77.1549463482009;
        Wed, 06 Feb 2019 06:31:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549463482; cv=none;
        d=google.com; s=arc-20160816;
        b=ZzqFUrufjcCYWUVxXUN06dAwzUxOINOryGtLnQz1kQVF7UMtppILcEFEbtzeelP3D1
         WG9hfzMouL5DeIYANzzr5TJqzmeB26RX4akWyo2LpmSyMr33MTFAxXE9kL75BWP/2hoq
         mrYzljiFndCffsy6Iyq8RX6TZRMdJWOJYRddhS+x9tli0PDqfxyEbwH0ehIrQAmqU7Lc
         Waa2c/1Xh1258Vhk/4nnAO8IrOI7yv4qLbwhmjZUDarMq1TGWnheAu9FLj9bG8q+6Eos
         5ikXheNk7w5s03a0yujipfXkWzXOMP0WKhOoQdZP2W1yEp8VE0A84b625BPJCsMblPSC
         +XDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aCkiqYNvxX1a9nJPU/Nbyv1sM4Ffext0Xrvmi7ouJ9w=;
        b=jpzRPvXsmL2+CqpeIZvBYh9rfS0Gwi8v4WSCID25gXw6Fvdj2wPk4osjmmwe5TomWL
         iJpDblKQ4a0tUsbNyPpci6AcdW4oSOc4lwZozZUe37QKzrBUYFgnNYOgm2HKs39L6oUM
         h48V7e+2/5rfGsI5wEIOzoddkzvjFBI74SlBwTxqh1TGFeyX04DiO8gj1VlQVArKtrfu
         qSzvvaXBG+pI1E09kFXlkqa57MUTd4+5+E+bhtL+Riur4ygDsHNvxKWrLTa73ywAP9gQ
         0i6DgHEECT2G633RuRXPrIybDwUIfL49kYKOM6tIWxkv2P9scC5dF0wUTNes7FKPzByu
         7ONg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=hz72O9Y3;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w9sor15212708wrm.8.2019.02.06.06.31.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 06:31:20 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=hz72O9Y3;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=aCkiqYNvxX1a9nJPU/Nbyv1sM4Ffext0Xrvmi7ouJ9w=;
        b=hz72O9Y3uWIkSfq8uoOTQBadfjKQoIu+JKa5XW82YFIX8YDAvNP66Bge7LiyeLclz6
         iPBBiywri00HnOkmsvfIc/NksPb07HSk8jXer0XE78ZW8L7mFpxmioQ+3EfmHPNsJTF5
         JykLNcbGm7+TicqSMwxXi2uVkhSjTHKf3tRMBTcDtSC2qmmWv0LS2Ns9wLSFiI2qXghd
         i4EHmd1mj1w/ML9rhwhf4shb5qGzH76VAeA1OghmUVOb9Ttn6cUxUKMEv3kneBKuZvWh
         ffvmXiQLHx75vnbCqvd6U/66s1f1zBv9QW353zZVBTPVbgi1gEyY0r/2TMhKQhoHWj2f
         xmrg==
X-Google-Smtp-Source: AHgI3IZvsq1EoXr2gnMPF40TTTg0xT0XGzuZVgnw6PZBuXQ3W9wXhBIbgXA918f8ZY33SV3Qj5Sm9w==
X-Received: by 2002:adf:fac4:: with SMTP id a4mr2062624wrs.110.1549463479578;
        Wed, 06 Feb 2019 06:31:19 -0800 (PST)
Received: from localhost (p200300C44723CCF50E7AC8E3657171F5.dip0.t-ipconnect.de. [2003:c4:4723:ccf5:e7a:c8e3:6571:71f5])
        by smtp.gmail.com with ESMTPSA id h135sm24452892wmd.21.2019.02.06.06.31.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 06:31:18 -0800 (PST)
Date: Wed, 6 Feb 2019 15:31:17 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH v4] mm: Make memory.emin the baseline for utilisation
 determination
Message-ID: <20190206143117.GA30357@cmpxchg.org>
References: <20190129191525.GB10430@chrisdown.name>
 <20190201051810.GA18895@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201051810.GA18895@chrisdown.name>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 12:18:10AM -0500, Chris Down wrote:
> Roman points out that when when we do the low reclaim pass, we scale the
> reclaim pressure relative to position between 0 and the maximum
> protection threshold.
> 
> However, if the maximum protection is based on memory.elow, and
> memory.emin is above zero, this means we still may get binary behaviour
> on second-pass low reclaim. This is because we scale starting at 0, not
> starting at memory.emin, and since we don't scan at all below emin, we
> end up with cliff behaviour.
> 
> This should be a fairly uncommon case since usually we don't go into the
> second pass, but it makes sense to scale our low reclaim pressure
> starting at emin.
> 
> You can test this by catting two large sparse files, one in a cgroup
> with emin set to some moderate size compared to physical RAM, and
> another cgroup without any emin. In both cgroups, set an elow larger
> than 50% of physical RAM. The one with emin will have less page
> scanning, as reclaim pressure is lower.
> 
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Suggested-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Dennis Zhou <dennis@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

