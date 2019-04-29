Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99400C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 10:17:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 613AA20656
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 10:17:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 613AA20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCF996B0003; Mon, 29 Apr 2019 06:17:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7C306B0006; Mon, 29 Apr 2019 06:17:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C46676B0007; Mon, 29 Apr 2019 06:17:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA856B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 06:17:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t58so60146edb.22
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 03:17:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=agbBFHXfOi1GGUJw9k2j3BKA4XZhYMNmCIwUC1zcAHQ=;
        b=lW0v0VQ/Gg7dCy0koO8LA1HhVITqvebACuDx46R3DxeeOBFYjvCGqt7RCMBpvk9stf
         DqZcF72d2YcofTso5VEhOA5jyfhrOC5k0bJhUkZQpZpbz3ZCka0e4GOd8FR5s6eqrmpi
         c4QeaN0VKvUH97n5FLhr/o4LTxpl2FhwFFoJm94mi157kg7ApIP4Mp1VHg+MgCWPxxTQ
         N3zID8YbaGCkx/G2975jS6tzwrXJRq9mQl/ALZmXJN9zfnbjVi009FlhvKs1bSQYcSa4
         rddpYiHZuQwEVm8DS0h2RHRTw+uIQjp6Q0Va36TDxVQSNXI+r+LH0kQRxDTGYI+q8ZnO
         FiUw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWfTv2u13adPQ4NVIg2QP5s28qwlkDt+PESBlpmSF7ULmyf2TzA
	FlVkTtKqGPMKcUybtNWR7PncCUuij4GeZnWIUmnaGEMaVzp5nI5urJxnF7313T7YvElKzjpUU0t
	3dK/5vZ5vWpHILc9fUYX7xNn4UPy8ji9c08zzp00mjvV5+xLrhSpAYrO9dd0d0fE=
X-Received: by 2002:a17:906:288f:: with SMTP id o15mr18839740ejd.282.1556533057101;
        Mon, 29 Apr 2019 03:17:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEzapWb+YZZs8Gdf4F1egEI71weHYT92pQfivl3kJ/XJK60TSmPeTL7Mzuh/EZuwR6PRhI
X-Received: by 2002:a17:906:288f:: with SMTP id o15mr18839708ejd.282.1556533056394;
        Mon, 29 Apr 2019 03:17:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556533056; cv=none;
        d=google.com; s=arc-20160816;
        b=J6lCWqn79BvSJ851N5ZJArynLPSOFw3pu/hm6bun+/S6UXrwAkWeSiiaUsfCr3cczZ
         Y6ffXLiqV7PUD6W1mu2r6b1AOgIkzS09adpj4W0W9CKD8md4rgW44OXvnveE9VfrBpbT
         1ChLVDB3rbmCwTkXyvOkGW9grOgO4KdBJNqPYKrxnaEOGJpaAcVoLwG4ZAjDaFsbtREK
         wwCptZrS1gTdlWQxUnh1O9p8jeEEyaQEDxv8UNuvYkSxOPzxaEI6TpL4amdfe7PXGrKG
         TYI1y85EbhjoMyKvMFELkdmfipGN+F935G2xe+ZAXwQ1qs+cJuqmi57KGpv5iJ98QOL/
         nV0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=agbBFHXfOi1GGUJw9k2j3BKA4XZhYMNmCIwUC1zcAHQ=;
        b=GqFB/KEYvDWdJ2EWwhQz+SV3y3ZOVAoTqgwvBfnPLA0yLTAKqRqJtqGdkMe2NEEzOU
         dt4Cm19Naf+47YYavOvbV/QsB7DkUFTWCFhpX8xODVgQSUrbJOu6zzJ17asnwMgyUZtC
         HIJ4NFAcY9Cd0psAjDywxeSvBczms0XNqjU+x1/+K6Nmm8JfaNHimvzVLYbb7cQ5ugE3
         2gwOBuN7CqMarJe1f6k1bpb/MzHCecr58GQLp2xLfNgLR4QsK5t2TxKSBFzhuJOKB4K3
         twrVKhbPKrlV4016SeJQzy7JWA59UTOBkFGI1xdLe3VgmOz6WH84ZmYb5Wy6WYSW+hxP
         7mrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 49si2152372edz.359.2019.04.29.03.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 03:17:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A8327AD22;
	Mon, 29 Apr 2019 10:17:35 +0000 (UTC)
Date: Mon, 29 Apr 2019 12:17:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	mm <linux-mm@kvack.org>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>
Subject: Re: memcg causes crashes in list_lru_add
Message-ID: <20190429101732.GB21837@dhcp22.suse.cz>
References: <f0cfcfa7-74d0-8738-1061-05d778155462@suse.cz>
 <2cbfb8dc-31f0-7b95-8a93-954edb859cd8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2cbfb8dc-31f0-7b95-8a93-954edb859cd8@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-04-19 11:25:48, Jiri Slaby wrote:
> On 29. 04. 19, 10:16, Jiri Slaby wrote:
[...]
> > Any idea how to fix this mess?
> 
> memcg_update_all_list_lrus should take care about resizing the array. So
> it looks like list_lru_from_memcg_idx returns a stale pointer to
> list_lru_from_kmem and then to list_lru_add. Still investigating.

I am traveling and on a conference this week. Please open a bug and if
this affects upstream kernel then report upstream as well. Cc linux-mm
and memcg maintainers. This doesn't ring bells immediately. I do not
remember any large changes recently.
-- 
Michal Hocko
SUSE Labs

