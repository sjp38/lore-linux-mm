Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92003C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:38:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F91320883
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:38:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F91320883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC9606B027E; Tue, 28 May 2019 08:38:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E798D6B027F; Tue, 28 May 2019 08:38:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D41CE6B0281; Tue, 28 May 2019 08:38:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 874326B027E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:38:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so1917904ede.0
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:38:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=j1H5hN0ECR8O/VgEtS6C5vu5GCauoDumcQmnoNuETdU=;
        b=NL/RbFthl3v+lCe8Ughq1rYz1RL9SKSCLMYkV3wpvuouyb2jDhKFchP6n5RboenzFm
         292zJEL3OpX23w3+7GiqL4vOlUVKRVaEt6cCn3qg3XJzREJq17H4MhprWyJKjtEEox5b
         sU5OHTUZtSBKzyKVR94Kfwg4l0pkGGttLpLTaGktja0hQKH8DerFCBvelnna7+AHU65N
         d7NEOoDZx7xUjE9XpznMqAj74KBB05OP/1w2ZY4u8pk7AIHmpppNeEUdQ/Ye9zPc4tN2
         6sIbzZTsDhK2jcJk0xPaw4jW9xn7hxQ6pb9ZTH9mk4lXzYCRZDShxoSAXIStEh8KgiE2
         3WVg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUOkpdHNsFki4T5PN2eKV5KgrNbAQKwTOQKV45YnPMnW7dJPJVd
	3923862LmJ/O12zb3LwEkD/fgSJLBEr5mfI0+MVJtqzwEpCjj9aK4IxyE84T34igqo64UP8HcVh
	GCC0QOTnLEDeDnUG2xe+b6PvKqlT3F1LxH3mPlTy6cWkH51/6M4z0Rj3kH2YwpQs=
X-Received: by 2002:a17:906:4d4f:: with SMTP id b15mr41607439ejv.116.1559047115114;
        Tue, 28 May 2019 05:38:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqys25NLWRA2nJ7Nas32+3wBDd6uiLmROqWVByf5ezQrgy10S2883bANZnRvEcS2XXwcowSt
X-Received: by 2002:a17:906:4d4f:: with SMTP id b15mr41607394ejv.116.1559047114417;
        Tue, 28 May 2019 05:38:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559047114; cv=none;
        d=google.com; s=arc-20160816;
        b=en+PTd8QBizM1CrA0G5cA8ad8DaNs2tiqwaPjjSMuP4czuJPyM4K7Q7vue9Q7M9Fqi
         afqXxPs2vVN6D6yhrpAgLK/oHm4FvFEToX8G3l18I6NN7+sn3t6uNXpXgqF+dvpw2G98
         o2wqXccOzaqxIbM3eO2a24zWNrrtej/3JIw9kFFjXo291Mp5gwkzjluRWjQT2vAMMbI4
         povnH37yatHbt+/74yJAxwHJnFcM6AYGuPzqypt8xRQJXBUF/OZZd3ioYpcofT44o0nt
         x5DzGmFMaIQ3mwOcWSx3vembD3BVnGUH32UN7+Hk37+qnbpv6FxcJF0qZYiM3SeKy2IL
         vUlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=j1H5hN0ECR8O/VgEtS6C5vu5GCauoDumcQmnoNuETdU=;
        b=jovzsg8CIrIqgwgqAuakaPwdrSSVpIvNJiOu8rpAb6U7ROa6qDiApN4RTqm+UAhKGB
         fwJzXweQ6a0LlTUQuE0gTxQuhciY9mgsPO3VVht8A5Wl5z5jXJsXjY/a25OZcmSQ/9NM
         /sGCY1w+mmVqUHg7cPHvO7vOVt+cdpxPQo+hMzkkJxJmBbz9qvGlnpVu35nfsPgHkTUT
         VdRQxzLV7XEl+Jn9UtR+xlgAecGxX6+H7KZ1CPx+COWpCH+9UhhANb44Q0uUaG1nLwqU
         oKygiUh5ypxPK4WWC9AAvinymltIcBOPz+UVBvTD2aSZWtpAo+5BJMOAt6WHEqj1Owza
         Gq2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p10si920384ejq.287.2019.05.28.05.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 05:38:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D83D5AE86;
	Tue, 28 May 2019 12:38:33 +0000 (UTC)
Date: Tue, 28 May 2019 14:38:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Daniel Colascione <dancol@google.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190528123832.GD1658@dhcp22.suse.cz>
References: <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com>
 <20190528104117.GW1658@dhcp22.suse.cz>
 <20190528111208.GA30365@google.com>
 <20190528112840.GY1658@dhcp22.suse.cz>
 <CAKOZuesCSrE0esqDDbo8x5u5rM-Uv_81jjBt1QRXFKNOUJu0aw@mail.gmail.com>
 <20190528115609.GA1658@dhcp22.suse.cz>
 <CAKOZuesnXGAsQgkB45n=jqwDRQ4_aoPiydmZxfxPmzO2p=cTow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuesnXGAsQgkB45n=jqwDRQ4_aoPiydmZxfxPmzO2p=cTow@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 05:18:48, Daniel Colascione wrote:
[...]
> The important requirement, I think, is that we need to support
> managing "memory-naive" uncooperative tasks (perhaps legacy ones
> written before cross-process memory management even became possible),
> and I think that the cooperative-vs-uncooperative distinction matters
> a lot more than the tgid of the thread doing the memory manipulation.
> (Although in our case, we really do need a separate tgid. :-))

Agreed here and that requires some sort of revalidation and failure on
"object has changed" in one form or another IMHO.
-- 
Michal Hocko
SUSE Labs

