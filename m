Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27E55C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:12:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D93F22173C
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:12:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D93F22173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A81C6B026B; Thu, 11 Apr 2019 14:12:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 556856B026C; Thu, 11 Apr 2019 14:12:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 445E76B026D; Thu, 11 Apr 2019 14:12:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC89D6B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:12:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p90so3519905edp.11
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:12:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=XyhUgTGLzLw0fgiqLMBFLInInzzTIEwCaOtG408eCuA=;
        b=VS494rt1xfLK+1qvJaU5eTLcZEXXe642gHsUw8t3lnygSDbLJsnfiTQuZa74ayH7vF
         8GgLvLJoSvkGUKFScjAbEbTDeaeAFiKXFSXaZ7t8xBZVIg6VEbwlkE6PKoPFDYRNFdlZ
         UVzjImeXQjr0Rq5mp1vf577aw9UhZfAVannHOeFRydFaOmQc1bIdxQLBgP7Pwo2QoFCq
         ENstzjVeYuPywCAgkMTG/ZuGUgz72VSvj9bRG5JmKxtkOFIdueTs8IoV9lZXa6SuivmJ
         a1qN5XzO/dQ73lriIIgUuVDijek/G+YZnEHGi2XspYrpotyM/Y73zwGM+qWO7kG+99BR
         F0Ow==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVz7/joGiH5nR0vRWXg1u3pM1nUFjeQmONLKb098vz2tv0XPLNn
	CbTHMMjGG26EsAkWkoQDP3Fi+F9shyXhrYCJn+sVKrYcsmflCxG7oVmskTBhP8+jQA2xZv1kvef
	6MwcQ7JPaHBvc3NcfKlJvZ7ng87GGmb9Hxz64/Hahr/z+GKjo39h8Cg64kw2q7y8=
X-Received: by 2002:a17:906:a945:: with SMTP id hh5mr28472865ejb.108.1555006367504;
        Thu, 11 Apr 2019 11:12:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZarC1F8vKemWf+INAy9BTe5cXdg8C0I2rpXTemeGxzLSUc64F9jrl+caxdlwbihzxjO0t
X-Received: by 2002:a17:906:a945:: with SMTP id hh5mr28472832ejb.108.1555006366704;
        Thu, 11 Apr 2019 11:12:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555006366; cv=none;
        d=google.com; s=arc-20160816;
        b=Fb3g8QAVNZ4mBMxjzQYgLfHezx0JdLAlAxFOP/30Wl78FJvd/sO/5eOIhq4n3yHwtC
         wzaogm0pEqzGic7h4Tphhr7Mva8k8Q8UTT64IpMPcgRpe74nn6mDQKVCd//zUy2PVWRe
         jT47s3YNI8SfYqIrTLMqcNF9YXhCNSbknb/4KsxBDBLgAck1+NwWVmYCkNARufiJMJJI
         9vruNWpdwA2WRuuMeUXU7v3F4y+rU7OQO+1QDtmlJLc8D5SstIgthWOd5HxpECq+Aobn
         y2z1sdqCFbVgyLSuYazZm7jA9Rb3obCdFTYsfM6lF586ogAgVB+8X3vW9xmak5Ed61IC
         WM0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=XyhUgTGLzLw0fgiqLMBFLInInzzTIEwCaOtG408eCuA=;
        b=Pw1GqFwfNeOLM5quwoxvIsV2ndhKmjO+eVhfaTmsvV39cwY5cAATk2wsz7e8bqQ+Z0
         5vIyjfsbIdl7DSyHNR4jZfhP17oiQMDQ7iaAhImCf/0MRHQssCqv0tFSH1wj5HqGkAEo
         rniF3s5JOnkPm4KV2IyEZUCS5LLp05i7ZVg5dyQxottzuKFVYaBwX39iP75s0tm77Lsv
         teTOvuMDqZX5A0/N7zD85RZL0BQINkeW3l6XayontSAbT7PWswpM1fzrb5rnVQuQlEXi
         /dmFb19/lIaij6ICJreF+XUON77NFst3OxquHC63vYuBaK9PYJ11EWcumHWfsYsGGHdF
         mkkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j14si10281231ejf.247.2019.04.11.11.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 11:12:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 89FBEAD37;
	Thu, 11 Apr 2019 18:12:45 +0000 (UTC)
Date: Thu, 11 Apr 2019 20:12:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Joel Fernandes <joelaf@google.com>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Matthew Wilcox <willy@infradead.org>, yuzhoujian@didichuxing.com,
	jrdr.linux@gmail.com, guro@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	penguin-kernel@i-love.sakura.ne.jp, ebiederm@xmission.com,
	shakeelb@google.com, Christian Brauner <christian@brauner.io>,
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>,
	Daniel Colascione <dancol@google.com>,
	"Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Jann Horn <jannh@google.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	lsf-pc@lists.linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	"Cc: Android Kernel" <kernel-team@android.com>
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
Message-ID: <20190411181243.GB10383@dhcp22.suse.cz>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411105111.GR10383@dhcp22.suse.cz>
 <CAJWu+oq45tYxXJpLPLAU=-uZaYRg=OnxMHkgp2Rm0nbShb_eEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJWu+oq45tYxXJpLPLAU=-uZaYRg=OnxMHkgp2Rm0nbShb_eEA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 12:18:33, Joel Fernandes wrote:
> On Thu, Apr 11, 2019 at 6:51 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Wed 10-04-19 18:43:51, Suren Baghdasaryan wrote:
> > [...]
> > > Proposed solution uses existing oom-reaper thread to increase memory
> > > reclaim rate of a killed process and to make this rate more deterministic.
> > > By no means the proposed solution is considered the best and was chosen
> > > because it was simple to implement and allowed for test data collection.
> > > The downside of this solution is that it requires additional “expedite”
> > > hint for something which has to be fast in all cases. Would be great to
> > > find a way that does not require additional hints.
> >
> > I have to say I do not like this much. It is abusing an implementation
> > detail of the OOM implementation and makes it an official API. Also
> > there are some non trivial assumptions to be fullfilled to use the
> > current oom_reaper. First of all all the process groups that share the
> > address space have to be killed. How do you want to guarantee/implement
> > that with a simply kill to a thread/process group?
> 
> Will task_will_free_mem() not bail out in such cases because of
> process_shares_mm() returning true?

I am not really sure I understand your question. task_will_free_mem is
just a shortcut to not kill anything if the current process or a victim
is already dying and likely to free memory without killing or spamming
the log. My concern is that this patch allows to invoke the reaper
without guaranteeing the same. So it can only be an optimistic attempt
and then I am wondering how reasonable of an interface this really is.
Userspace send the signal and has no way to find out whether the async
reaping has been scheduled or not.
-- 
Michal Hocko
SUSE Labs

