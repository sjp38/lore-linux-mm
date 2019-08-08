Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61A2EC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:51:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D81C20679
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:51:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D81C20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4E566B0007; Thu,  8 Aug 2019 14:51:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD86C6B0008; Thu,  8 Aug 2019 14:51:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EDDB6B000A; Thu,  8 Aug 2019 14:51:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 556D56B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 14:51:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z20so58812816edr.15
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 11:51:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sghXZSHC0Xud5ECfy7tiTNcVVFX4jpjyj2brc/S5i/I=;
        b=LounjSFpZw/qpJCzr7G+8GVv0LUXVij+jRcopDmHKA3aDpAyC1U4xRAmE5IFUOi/1A
         SSOdPIC5OQgcGZD2V5eTpjLcPoBss0n1Ie19NRCPC1HhDyc0lGneacG1/GpJrStTUDj6
         UnvFA3REOzDGeFfpOD0kowGXC51oof77ORRdMYgeTiu8abPaYfTa0cMOxEt/ChgofMqV
         5IMQObGsqovVD/ya0FzXtMFMkhFlKUkfqDyIFhaNRCi9lIqEf2ncruMnryH5ZFyogCMB
         b3T4cE6jf1BgDzkuZoCk3uHZoziQ9l60obNU57hxqfv1CQb5Pxr48EBBY3U5Z2FxKQHN
         xOjQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUvZFjthJGBN/thHWRD1qF6rvF84b2atEk+1MIsaSxAwPOSGBPC
	Wq/GMTw0nWHxb0BOA8FbzXUVt7xevjI4DOhSVCRELSCAlNr8UH63ymZw8OUxt7/PKh6kbAU9yZT
	8Gf6uqVc535VdycT6UQBtE3jpPpdjx9yGqTtK0fm+a211SrxTSNVVLm/ewKSOuFQ=
X-Received: by 2002:a17:906:cec9:: with SMTP id si9mr15210673ejb.38.1565290283935;
        Thu, 08 Aug 2019 11:51:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkE2Whz2B4aqSaMhH5oYTnHiqFt5pRlO3CJhfnqDlb+geoZ1QmKE8al/LwfwFKcTBAvBbg
X-Received: by 2002:a17:906:cec9:: with SMTP id si9mr15210644ejb.38.1565290283250;
        Thu, 08 Aug 2019 11:51:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565290283; cv=none;
        d=google.com; s=arc-20160816;
        b=QwkVkfxIYVF55sJSpjAkqg5Ys5iIjDyN2/zxj+WI3hRYC9A4cpD0FIl3FoRHulWIGS
         3MQXMARgmukLkpo0x0vR76vMIdWQyxPaCYL5buRvEZkq5CTB/C4liZwjNOBI/cPJQmS2
         nmPNiN4Wjr7UDZHEqKGstkynIFVB/XRjQFEMWt4ggz7o9GM11qqy487A6D838cE+a9Zw
         SYqvFJ/8Q+N2FlNEOmCAGUlqlARSMFMt5a4qUAFu6AQHnk7uZx3Up43EPicqA4eaMb9X
         E5nYihrGGUHxR2VTu1pGOhcBiRGCneMS8p3ZhGm6O6PFUkLGvMn5/gzxqiJfoVOGo2Wl
         0bRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sghXZSHC0Xud5ECfy7tiTNcVVFX4jpjyj2brc/S5i/I=;
        b=pcGPIzUqmAKW+2ylsMkcjETn+KuYJ3gbTR9UqVx1WqmqrMtQMJznPQwV75lllL8N4p
         ePgie1qgLkIikSAl5APJDBjuWxTMa3cHVl+3Eyn2r4c3seY4A2gtfThJW8vJJfB5IWqr
         aXlkjK3OClAofCVAPyexQpkyX32uUjkehqWGCP85AF3iIIR6gxJA8NHkacGlRdMAch1Z
         C5UnWp8/yMntL7qsEyBAXTiEVxFs2Zj6c/3xJPLV8iKDwmub9/82o/WhEPUHub19pGzm
         yCs23x2/2Rquq0zPcWNuoz3O0wJ/Q7Y5D0z6rh4BmWhekVdrzC0mcj2nUJ4JDQKAYH6+
         vpBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o25si31663800eju.237.2019.08.08.11.51.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 11:51:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3E4BBAFA7;
	Thu,  8 Aug 2019 18:51:22 +0000 (UTC)
Date: Thu, 8 Aug 2019 20:51:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Edward Chron <echron@arista.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, colona@arista.com
Subject: Re: [PATCH] mm/oom: Add killed process selection information
Message-ID: <20190808185119.GF18351@dhcp22.suse.cz>
References: <20190808183247.28206-1-echron@arista.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808183247.28206-1-echron@arista.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 08-08-19 11:32:47, Edward Chron wrote:
> For an OOM event: print oomscore, memory pct, oom adjustment of the process
> that OOM kills and the totalpages value in kB (KiB) used in the calculation
> with the OOM killed process message. This is helpful to document why the
> process was selected by OOM at the time of the OOM event.
> 
> Sample message output:
> Jul 21 20:07:48 yoursystem kernel: Out of memory: Killed process 2826
>  (processname) total-vm:1056800kB, anon-rss:1052784kB, file-rss:4kB,
>  shmem-rss:0kB memory-usage:3.2% oom_score:1032 oom_score_adj:1000
>  total-pages: 32791748kB

A large part of this information is already printed in the oom eligible
task list. Namely rss, oom_score_adj, there is also page tables
consumption which might be a serious contributor as well. Why would you
like to see oom_score, memory-usage and total-pages to be printed as
well? How is that information useful?
-- 
Michal Hocko
SUSE Labs

