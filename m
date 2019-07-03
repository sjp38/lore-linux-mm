Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00CF0C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 07:06:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABC8A21880
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 07:06:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABC8A21880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F1968E0003; Wed,  3 Jul 2019 03:06:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A0D88E0001; Wed,  3 Jul 2019 03:06:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3914D8E0003; Wed,  3 Jul 2019 03:06:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBBE88E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 03:06:42 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so974071eds.14
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 00:06:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7SWnH9NrRRczAv+3cW1awM16lLKoys2yJl1RzA9CTDQ=;
        b=cN1zjEqRRZLcc9wCU2VPKfePkIcUvz7HoxVIfkN/l+oSgl9Ec71r6rfjh83nF5SuwV
         lYb/NFbxCBb5mLkfVI2PFKwvZwXC/Fj3ePKNYeKuy0gZyUhJIg8+LSMZKCXaF1WI5pd0
         WD/SE18uLF70ifK/ORxjzYppLHDccENPVs+ZLSrkJWiRlbdH+NaossbY87g9QwuV9oFl
         AvzRW5RcUXwVtP4W5lYcRkejYbGxScBIQg1jyL0F+XJfGwZ17riMdmm635UJhbhhNLoz
         LDMhTuCdqidzQpOTdn/x6eN3v00QnHByzVcng9QD6yis808Ihs1NXZ3S4c1MObxxfmkT
         88BA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUiW+4MdGLF8gmWiahYaVFQi3/P7PAPEllMHQA60UoB0OHf2gts
	Ixy1jf7iu+jIgDOx7ACFdFd+JcVGLwdbo18XULI16YPxuSx1BualKsabp/wSMPNagqnwJ4jagpc
	CA2GlkUsi8mYTdVHIdt8ex9hzvEo455SvkwBXPts3j4/1PRtgq8WXT2FzOwl+U90=
X-Received: by 2002:a50:f091:: with SMTP id v17mr40343051edl.254.1562137602463;
        Wed, 03 Jul 2019 00:06:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9jxf4/CEQRMPJ2gBYOWEm9b06lqmWBK8tx9Pcd7So2hI+4K5XLcEpvvdPT1/SzbcZ46R/
X-Received: by 2002:a50:f091:: with SMTP id v17mr40343005edl.254.1562137601843;
        Wed, 03 Jul 2019 00:06:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562137601; cv=none;
        d=google.com; s=arc-20160816;
        b=Oh6waE60PKIwYawUJPrTCjy2LT4lsvbICRqCWovFTX+oXcnDSC4jNwFYF3OCUWcwIa
         iilF3LUtJR+81cj6cBl5bkC7OEwOdaoxLZdc1hgxd1yR29Vg65TMLcO4EOutwgXzdmae
         4l+F/PWT1fslyp0ZLebZ11L8UHSZqkLfZ3cIlKdsczGZPw8XL2tdH55BejeFl8hMVd7n
         uteOo3STiM/0OJ35FwbiSbm498pfErWe3e57EUHhO6y+93PpvzTW/ba5/v9reqBj4F4d
         WCfH/1GBKkGMF53JRgO53PSmiOnaJi7uXz7LJ5WsJVtooMssdmisQrRVMND4g9xg0Nnm
         M+hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7SWnH9NrRRczAv+3cW1awM16lLKoys2yJl1RzA9CTDQ=;
        b=aOW9SnpgmePO/QCW1nNyEuwjpm3JTKoCMEg45ZKhmU0ZJoM1CafvFbl84665MeUdxa
         0fxK8DhBv3+wYg5zQzR0/eXfdtxIMuqN/GQilQ9VeVf58CnwBamYrt8Tx9MrE5fl/TW7
         bS0Z+6GHUgYkEQSjep9Idm+YhSdLdMJWoWKC21RwjnrjZSnBLIENZ8nRY14KAFlmzWua
         jT73ROCg1hs4+HHeyqatoQrnh26PDnz5RB4J2gWw4+W6/lrTM9TGDVSZquO9D7OO8VjV
         u86QIR6slut8AgCyYx96eT1RvGvu9MyKqae8zgBQDvsgHX1h0Z4xIjsCvZVAP7PQi6hR
         bUXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y25si1341651edc.377.2019.07.03.00.06.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 00:06:41 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 420BBB12E;
	Wed,  3 Jul 2019 07:06:41 +0000 (UTC)
Date: Wed, 3 Jul 2019 09:06:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
Message-ID: <20190703070632.GL978@dhcp22.suse.cz>
References: <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
 <20190701131736.GX6376@dhcp22.suse.cz>
 <ecc63818-701f-403e-4d15-08c3f8aea8fb@i-love.sakura.ne.jp>
 <20190701134859.GZ6376@dhcp22.suse.cz>
 <a78dbba0-262e-87c5-e278-9e17cf9a63f7@i-love.sakura.ne.jp>
 <20190701140434.GA6376@dhcp22.suse.cz>
 <20190701141647.GB6376@dhcp22.suse.cz>
 <0d81f46e-0b5f-0792-637f-fa88468f33cf@i-love.sakura.ne.jp>
 <20190702135148.GF978@dhcp22.suse.cz>
 <0c26d2d5-19b1-7915-e47e-60d86a946d09@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c26d2d5-19b1-7915-e47e-60d86a946d09@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-07-19 06:26:55, Tetsuo Handa wrote:
> On 2019/07/02 22:51, Michal Hocko wrote:
> >>> I do not see any strong reason to keep the current ordering. OOM victim
> >>> check is trivial so it shouldn't add a visible overhead for few
> >>> unkillable tasks that we might encounter.
> >>>
> >>
> >> Yes if we can tolerate that there can be only one OOM victim for !memcg OOM events
> >> (because an OOM victim in a different OOM context will hit "goto abort;" path).
> > 
> > You are right. Considering that we now have a guarantee of a forward
> > progress then this should be tolerateable (a victim in a disjoint
> > numaset will go away and other one can go ahead and trigger its own
> > OOM).
> 
> But it might take very long period before MMF_OOM_SKIP is set by the OOM reaper
> or exit_mmap(). Until MMF_OOM_SKIP is set, OOM events from disjoint numaset can't
> make forward progress.

If that is a concern then I would stick with the current status quo
until we see the issue to be reported by real workloads.

-- 
Michal Hocko
SUSE Labs

