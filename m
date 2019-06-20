Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 915E8C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 07:08:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FABC2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 07:08:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FABC2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FD176B0006; Thu, 20 Jun 2019 03:08:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D0AB8E0002; Thu, 20 Jun 2019 03:08:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F01D78E0001; Thu, 20 Jun 2019 03:08:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A0B956B0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:08:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f19so2953474edv.16
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 00:08:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Rk+vCv5pTjlB6mJr9WQfKgVUUf/TX6MAy/OWqhY87AQ=;
        b=bHjPVc4jRr/MQB9XQ1cPhkjhJuypgDGvc2Dgo2zSTLpp+mXiRna4mGFUcMyLgkW2AE
         PaaEe6kOqDBd4au76y+YdUiW4g7DfQ9NbzBUGDKpbqvhn7V0igvp+Q7OweXdvBnZxVG/
         DojLvqOxWJA68BiVrsbqzwzjGIM61MGCE7hfcucme6BgU44djvMBoX2UxedbApc2NXJ0
         GD/NWxpMoOzf+ww+fcWmsZzF1T3Wew1LZU+Z6Ws9BrDXZy0TXXB4u9wKkiN16PtdVW52
         DffoONYKibCzuXSeI0PSeKnOdW58aJ1FZytLEpDF/DaWfEPsLkssTgFgdcqUE5zy+fam
         g1HQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWv9OSDrYmMMCGyrInqDL+QgL0+1+eBQFwjnP9XO9Mo0Zvx3vwf
	+5iLjIYDlys3JcbZY/BpFcsN3+6x0aUUOccYxGhZcgHJhJUlWx7/QKAOUdit9JcOGklZ7JbVg74
	sHHkKztgzvTldWqD3GwVkJ5j0l1LFiZC+5+b2tacDWy7Tj9G4N+vhaouPPylEJvw=
X-Received: by 2002:a05:6402:1507:: with SMTP id f7mr76595365edw.94.1561014537234;
        Thu, 20 Jun 2019 00:08:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBHS4fJm7t9JH67gTI6uZajyICHlSxNsuDvuo3s/xsFVJIFFg/d5Ygz1KzZPHCoA8OoJSE
X-Received: by 2002:a05:6402:1507:: with SMTP id f7mr76595304edw.94.1561014536603;
        Thu, 20 Jun 2019 00:08:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561014536; cv=none;
        d=google.com; s=arc-20160816;
        b=kDhah4C5cxshn0rX0pvEbiuax1CzZDfqnmNBkrxMe9f6jfmfbqMxTjFzGpSF7HzZ6g
         ZH2jb8eZOdQM9zk5aE4FeLMjplkFJRxfpXzhxZkz3HTp28WxLeFpij7/lJJBDhdZWNHX
         yTB2S/7UbHKtLMtis83y76o9dcnGrrBmow5jFXP1HgAzaPDU0n+ZSIb+sNC+ft61kb+Y
         LMwkx3QgzVxCCtafsESlOAdCPpOT9TQ/BHeoYdPNe9TfbQ4JFsDlTLmcld1mhqBMMexL
         72982Fnc2o8A1L7bZTl9PrwRQUdIrsENQgHdG+hmQRVx4iQvHINpPTqOCp19B2LL1Jmx
         X0ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Rk+vCv5pTjlB6mJr9WQfKgVUUf/TX6MAy/OWqhY87AQ=;
        b=w1jwOU6y1AvE65VvIflSbFilMbeXJaa5F7FLFmwGRPzkEVLtHpuRy4DwgvoNhZpj5j
         jD8/kyue5xpjIUuUinVUKTY/9tAetXP3wvWJmk4Z9MxGJzPDmgT171n7eNhAFYdbjmIS
         KJ3ZZmzJ4DVficp4WuZGgWeTc3q9qkjnAogQBypvMbsTpmE1hmc9745GCZvg3QZ5bzc/
         8YSYEd2V6XdxtIU+PLTHKi3ex9P3FMAy+2oUMqhDF5I1RUoe54eU2QVO5Eih1lcRFmOh
         o3fntajp3+Fa6OR6ZnCEHK/XWKpbErFMuYMC4RJFr53VG0tOeI5dUooR7YFwRRPYrxOH
         GioA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w14si12834343ejv.124.2019.06.20.00.08.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 00:08:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C31BEAE34;
	Thu, 20 Jun 2019 07:08:55 +0000 (UTC)
Date: Thu, 20 Jun 2019 09:08:54 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 1/5] mm: introduce MADV_COLD
Message-ID: <20190620070854.GC12083@dhcp22.suse.cz>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-2-minchan@kernel.org>
 <20190619125611.GO2968@dhcp22.suse.cz>
 <20190620000650.GB52978@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620000650.GB52978@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 20-06-19 09:06:51, Minchan Kim wrote:
> On Wed, Jun 19, 2019 at 02:56:12PM +0200, Michal Hocko wrote:
[...]
> > Why cannot we reuse a large part of that code and differ essentially on
> > the reclaim target check and action? Have you considered to consolidate
> > the code to share as much as possible? Maybe that is easier said than
> > done because the devil is always in details...
> 
> Yub, it was not pretty when I tried. Please see last patch in this
> patchset.

That is bad because this code is quite subtle - especially the THP part
of it. I will be staring at the code some more. Maybe some
simplification pops out.

-- 
Michal Hocko
SUSE Labs

