Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02BC8C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:51:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABA0D2133D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:51:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="QjwzuLxD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABA0D2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 320E18E0003; Thu, 28 Feb 2019 07:51:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AA388E0001; Thu, 28 Feb 2019 07:51:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19A808E0003; Thu, 28 Feb 2019 07:51:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6D318E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:51:45 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id i64so3109046wmg.3
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:51:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9abm0vdzy1u8k6t9ZPdWfEHMFX/OS1Bdc2ERO6x3ga0=;
        b=nme2n9BSFPHYj7rRevaqAOBatHJw1nK7QjFeMTENjoTJOE+eoOYRs1ls1BNV2t+n0W
         z9t6M2Z3ipupa6TTV33mWPfbdx9RaJ1HqsfJUiL+pHkt94EjuDYygT7XZVm4TA4lJFDq
         ajJlyLOqjSHwuFX0qHo8hCsBvHk0LxUfUakxtw4IYmFaP9jhJQ2qbRQ1ZLnmfsyM7bh3
         hUtQ9+jkpMwmr7BMDnbSaOIKtKW8xIMpFnSuhE+4Daq9SSw22dv046rlr0pYy/M+h2aO
         F2n4XWWdNmZUzWrjEL/kUFFVZbgXvpsT/+16c3bYi0dl3YdW8ZDpv2MMAj+szfV+Mt9p
         H4xw==
X-Gm-Message-State: AHQUAubY3/6dUEkQKbPydUU0Bevy0n9j1lT3AjQUiVTByCKb48x86+fM
	YOgJwKFVcHXh/THsdPIHuExKM5/bxYKnqtScNRtLTYcbIl74+w0mtN+jHJg2SXZM7v7YLdegwuJ
	efophIATHIo9jFHlDQO51Z9B9LUzCzuT/sZgUY4qoyg/3M/iJEtwzVGVPeKJUgHpi6soEd4jh1e
	/w3qBcYMzoG+y00WNWkfQsaYDqBbmxMI77ofIgA1DywcMagzjKwgzcScKI3kaBbjpjOp18TJsQl
	M/eFX2sOwpL5bCAZk791L2jMmd0oCt+eH/6qbggKjHc2Dk6oGoSKYQv3en+aaCkwqpQBYefAzPB
	Ls7SglEXDN5GN39aocnkZST3IXWV4MEHhkIqg6BVKq1VEDNmcT/ww+ASMhm/uBzereUY28cADAW
	i
X-Received: by 2002:a7b:cb48:: with SMTP id v8mr2750866wmj.138.1551358305299;
        Thu, 28 Feb 2019 04:51:45 -0800 (PST)
X-Received: by 2002:a7b:cb48:: with SMTP id v8mr2750819wmj.138.1551358304344;
        Thu, 28 Feb 2019 04:51:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551358304; cv=none;
        d=google.com; s=arc-20160816;
        b=wrsczce2EY03lA0waxLu8DrXjWbSxTz61NmRvKTyiqhUWWrfee5+IRMmx4Pi9LbDq0
         mZCuIbAFlhXcDMnr64y1RlQ0xO+QAoSvxa8tjuSXAd05V+7ZtJ9KDqrLo/Z9nJf1XP0Q
         /+oUcBPJBvU3EFvC36LzDUOeIon0jna51Qp8IGqpcqwon7C1/mVjTgxrGpwkrX9PLQU3
         G6wY2gFQnmP0jgp0CqSNJQKiPO3mJNpwK3ABTG1gAzEAOWqi3Cyw/3gG/I6ihoPX8YOl
         ymiBE+X16C/B3SplHZdi3VceXq/kCKbkDzhGDZulNyZVI+7BcTlcSr1rjhKhJJNH9lNp
         q24w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9abm0vdzy1u8k6t9ZPdWfEHMFX/OS1Bdc2ERO6x3ga0=;
        b=h4NC8HZm5soqPAZjecSFN87YCY0+gQJdMf2T5gBlCnYXklwPih7c7kMKV9XOuiieAh
         XxkmdzDT49INTGAnENWoJDjwBMTBeg+kjzy4WBcvVgCBmGWRWyds0ilAmu2FeEVPCfCx
         QjlveDAyAZjN8Hngpy9zU/g322tF2WNJCL7xapbcnMM25JsFoqPitJEop+ho8g+4SgEa
         acFRPTuN4SsPEB/Yi+jz03VzhEAVEFdBG3xXZodDqtAyqnxS/jjc6dAW0vGq8/om86lY
         UB6LMvJZquNu7EQWJ86PzKA54plhzYcjbbXIOGdkyK7HZ0Pp0RWT5uWwbsQvo73OR2aj
         zABQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=QjwzuLxD;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h11sor13099344wre.15.2019.02.28.04.51.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 04:51:44 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=QjwzuLxD;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9abm0vdzy1u8k6t9ZPdWfEHMFX/OS1Bdc2ERO6x3ga0=;
        b=QjwzuLxDrl+HPKlwdKfODyAY2mBGwVvTaW9CLwhP32n2Lvx/8GicnuinoOZWPO8NJP
         qsjsDgtvcl/0BePwDn7LlW7Vyc1CI604eY1Jt6o6HWr2VcYo2muKLPsjM/ljuwaBxvbQ
         bOpUhPejtlwVVJHXuL2oF7YeBoiy+i3VrcLRg=
X-Google-Smtp-Source: APXvYqycnvwkVA52YbGqmvi8Gr4mzZGaRSuKwx2AMis/NyMnS1IjehuHd5ENSFRGBC/ossCj84e1lw==
X-Received: by 2002:adf:9cc3:: with SMTP id h3mr6010367wre.47.1551358303852;
        Thu, 28 Feb 2019 04:51:43 -0800 (PST)
Received: from localhost ([85.255.236.253])
        by smtp.gmail.com with ESMTPSA id m15sm14260352wrx.30.2019.02.28.04.51.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 28 Feb 2019 04:51:43 -0800 (PST)
Date: Thu, 28 Feb 2019 12:51:41 +0000
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm, memcg: Handle cgroup_disable=memory when getting
 memcg protection
Message-ID: <20190228125141.GA7365@chrisdown.name>
References: <20190201045711.GA18302@chrisdown.name>
 <20190201071203.GD11599@dhcp22.suse.cz>
 <20190201074809.GF11599@dhcp22.suse.cz>
 <20190226152958.726b921f0cb03ccc50144539@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190226152958.726b921f0cb03ccc50144539@linux-foundation.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
>Things settled down.  Here's the rolled-up patch.  Please review?

Looks correct to me as patch author, thanks!

