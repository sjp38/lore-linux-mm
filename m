Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29762C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:45:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E13252171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:45:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E13252171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 776FF8E0004; Mon, 28 Jan 2019 13:45:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FD5C8E0001; Mon, 28 Jan 2019 13:45:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C7208E0004; Mon, 28 Jan 2019 13:45:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3D308E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:45:30 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e29so7033731ede.19
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:45:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+hyK1kkrZLEaW5era3XGIMlLgINvsnAGJTe4TSc7YJg=;
        b=d5RgdK9ru8kULA6dZzq7yZnVTJ3rF84uHeMkX2xNrOyGFLoUMfhoTMTZEb4UcDvrAx
         32u2rBbJLWuF5KxqaVFG3UV9mlpmY/P9jlVH6m+cvXFKsOWZRvCZNqVuae4gexmI29nC
         bIUjDzk538OQmzCEVQyhP5pcZvoSQlG+FTXEHpyb/xLctFEgFdp+hdMGytrvUHY39WWZ
         NTJdg31qJm0rZjPFNEHu+dqfqUiV8rw2odiL+H0xU+FGuI2pDl/R3MJiQcnEXgPqPCER
         TPBjdz/RI45OUGgU8PEhFezIWGxAG/9m8sext2uU8bZQTu4jbEix4dR4pNmQ4711QvKV
         UsbA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdWYqR86hyStGYOok5gtYmeGUBIXSAp3ry4KGlU+b97/ie10Zr6
	Nk4j3wLtgYOnmJ4Xeaa+/iw/lhU34QXl8jQ4pjLQgEVXQkMlO3uCNa4npZpWtva8ggOifavn9yj
	rVe2UvgIufGAHox/vO4Qk3fLB0/oWg08CQ/NSOKrAynpZ13W07lpM98nHI0bUswA=
X-Received: by 2002:a17:906:49c2:: with SMTP id w2-v6mr20070094ejv.117.1548701130500;
        Mon, 28 Jan 2019 10:45:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN53VLbG/8xN7nYvf3HWnXZKjZBiitsWu/SW+PqMxnZf5HVbkm54xYj/QxuqoeFDKZDtDBNA
X-Received: by 2002:a17:906:49c2:: with SMTP id w2-v6mr20070065ejv.117.1548701129713;
        Mon, 28 Jan 2019 10:45:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548701129; cv=none;
        d=google.com; s=arc-20160816;
        b=hP996t9mmMFF7QfmI0fy1Q/DrC+9UpxXteRYVDexZsHPSvzLpXeVQp7bzDCqq5FFn+
         ByTYIrWpEFRyjnknbrmYZUcgeCkIHaojzMdmQI04d15wyMSxgbNx04W9nNm4q2T9nkv7
         D33YQB7iEsJfV6tVoAd/EGCk09Z01UqtexvH4n/09LrKkBgKbYDMFC5dGmz1CG06SHj1
         /SbeAnw31XRF+48ZXazx9GEHKGJSMlCa6FT0iZeiGukUaQy/E8MYTtcOZDBCezrobrgx
         /XPcKr5jwXyG3imTgpWfaYmiZGba/BUr3DeBtC789Qv5TJ8fRl99CFKEnDhMgpOdatxf
         JwXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+hyK1kkrZLEaW5era3XGIMlLgINvsnAGJTe4TSc7YJg=;
        b=dSMsFDN02fNXflKg6dzYqeAJbBOJA/iUzLjcTsqM6wVdAO6C4KKLAikm33GCxTm55i
         calqOjkD4pjWvhM4orfLnTV6faSG4z/lQ5gq/KmpEDSYP7ZrgcHlzEEvMz+YIll87tXZ
         c1SQCcMn9fa/CUGjpyj1+0yCAgHlNrV3tDwsZHqUhUGAHPIQXPDJ/GXtNo604vHY1vLb
         K95f8e4UboP3mm0B0JolNATWPbt9lGoHSAQkaFPpK8GjsyIHW3SKC3sSiaSXb8SPVQD+
         cvUwp60Wxdadjem9TBV8rcBNHHGG/ifB6xA8Lvw3jfjxeMHXTIsI4xqf80VoET/oXhQD
         bNyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m29si511702edb.245.2019.01.28.10.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 10:45:29 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3FFE7B00C;
	Mon, 28 Jan 2019 18:45:29 +0000 (UTC)
Date: Mon, 28 Jan 2019 19:45:28 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages fallouts.
Message-ID: <20190128184528.GU18811@dhcp22.suse.cz>
References: <20190128144506.15603-1-mhocko@kernel.org>
 <20190128095054.4103093dec81f1c904df7929@linux-foundation.org>
 <20190128184139.GR18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128184139.GR18811@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 28-01-19 19:41:39, Michal Hocko wrote:
> On Mon 28-01-19 09:50:54, Andrew Morton wrote:
> > On Mon, 28 Jan 2019 15:45:04 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > Mikhail has posted fixes for the two bugs quite some time ago [1]. I
> > > have pushed back on those fixes because I believed that it is much
> > > better to plug the problem at the initialization time rather than play
> > > whack-a-mole all over the hotplug code and find all the places which
> > > expect the full memory section to be initialized. We have ended up with
> > > 2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
> > > memory section") merged and cause a regression [2][3]. The reason is
> > > that there might be memory layouts when two NUMA nodes share the same
> > > memory section so the merged fix is simply incorrect.
> > > 
> > > In order to plug this hole we really have to be zone range aware in
> > > those handlers. I have split up the original patch into two. One is
> > > unchanged (patch 2) and I took a different approach for `removable'
> > > crash. It would be great if Mikhail could test it still works for his
> > > memory layout.
> > > 
> > > [1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
> > > [2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
> > > [3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz
> > 
> > Any thoughts on which kernel version(s) need these patches?
> 
> My remark in 2830bf6f05fb still holds
>     : This has alwways been problem AFAIU.  It just went unnoticed because we
>     : have zeroed memmaps during allocation before f7f99100d8d9 ("mm: stop
>     : zeroing memory during allocation in vmemmap") and so the above test
>     : would simply skip these ranges as belonging to zone 0 or provided a
>     : garbage.
>     :
>     : So I guess we do care for post f7f99100d8d9 kernels mostly and
>     : therefore Fixes: f7f99100d8d9 ("mm: stop zeroing memory during
>     : allocation in vmemmap")
> 
> But, please let's wait for the patch 1 to be confirmed to fix the issue.

Also the revert [1] should be applied first. I thought Linus would pick
it up but he hasn't done so yet.

[1] http://lkml.kernel.org/r/20190125181549.GE20411@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

