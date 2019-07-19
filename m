Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0829C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 16:47:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0BB22186A
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 16:47:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0BB22186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BAA16B0005; Fri, 19 Jul 2019 12:47:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36AF98E0005; Fri, 19 Jul 2019 12:47:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20C8E8E0003; Fri, 19 Jul 2019 12:47:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C58406B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:47:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r21so22429093edc.6
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 09:47:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=tKTNBnQak8KTJlVWIntLltNu7nt/VmpCog4kX4RwnOM=;
        b=NHW2g6FE5FKm4ZdqYXXvpVo9TVRJ7nCLl1qdFQQXEy0hZ6qqUmVOLSz5+dHuW5bfoP
         SidBsd3xOqvfJSVlHVLnbNKleOJdUZLxoCMWeHs6YA3jkpafbOz4iqfCcY7GqaFBTfCJ
         HsNUcCIg+UqqGmHsm19II3vhwxck3+qIqsdd2HEpWW9psLdodRoPM+hk2xam6txxJ77l
         FHDpJd5EDPxpuHfpP0EfyaIhZ5c3xDq3bqS5JoAp4P3PvDWU3yWc/j5GtB6ebOfazb5J
         m4ePRxFHosKs96DjL3OiL53KkJrqBuYpz5+BVZXrGwwRxRjnr4H+Q68BmoWIwW2vS9WJ
         vO1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAXkTEiugL2W4CukBuztJAD5d8iSqRckiz7TAWn1p+D4DtyHEtzS
	RwDH7F04Qh7tnfZvlvUZLu1KvHlLCAUQHPqc4UrE2rq1/PopMFNeQ3iqUBvhiiMwD7lU9vMBzmQ
	IihqG4rMea+WPot3oUd5Z+VtnuPJm4cNvQor5lOc3XoJ1Xe5nEddPTPamF/iKZuUJqA==
X-Received: by 2002:a17:907:384:: with SMTP id ss4mr41937669ejb.166.1563554835386;
        Fri, 19 Jul 2019 09:47:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQDGMOWr0ZKGUP2W8rAnnwA38Z+K+fVgX3DB9NDmNL/UVUr2Ss62bLQceI1BIiF/o5+s+X
X-Received: by 2002:a17:907:384:: with SMTP id ss4mr41937613ejb.166.1563554834317;
        Fri, 19 Jul 2019 09:47:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563554834; cv=none;
        d=google.com; s=arc-20160816;
        b=LGQXy7IXepaknfI+LjP1GHMXfzktV77zbkf77b+o5avG0FmoJcYJn97Z1LLQpssaAM
         A9UWbw5pNEmHPTPpv3DfXxixvCIJdCtGSN/gMAk7EZaiB3xfzwwaoKL4SKP/OoEKZKQF
         piry3bauqEyGdIetqFj+ph6hGYO8PYg3rxj0UxwEDilA2RFXlfqbFOxyFmVYMEdu9FID
         tUJsj5858Ge0kN7ttSEgTe1b7fr7zQ5ZD0ZCJjp9cTlMlocD8vA7xeRGrCZZFjby26rg
         gX6SqeUcoun/6RrjqNqqjgrNZ1j/acRnVZWFTkI6CKund+9jGnXzWh6ffswbdaU03Dz0
         lQgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=tKTNBnQak8KTJlVWIntLltNu7nt/VmpCog4kX4RwnOM=;
        b=ohyn0pTcT+J8uqPiy2imDu3cZHuxb7BLFuVf81fyJznqiPmrHykMmST/VDFj9lMbqG
         fMeUWbUHxjW0FBqV2XDZUTLVzA4+ukahsey4Nl6LdEkFjRpo8b8/tJilW0tQzQSJN7DU
         olnRnuKbzyHdUbcGWdjc9bz5MzG3LI0+IzUEYnIuIUEcQZHnSbOHNN0DDlxf9HnbwKWL
         tXCKTnAKfe8iO6O6egQVDptq7qZL93JltPK5oMRerLA05JOlOpff3oB2ILdiNMMGodAi
         /NM/kWy5iKj6cMNusWLke6oo4uTkT2as+jIIsxsMjcnFScBf2G/mU6Pd4vR6GA8ME6d3
         1nug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y8si1352856edb.251.2019.07.19.09.47.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 09:47:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 80171AF9C;
	Fri, 19 Jul 2019 16:47:13 +0000 (UTC)
Date: Fri, 19 Jul 2019 18:47:11 +0200
From: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: keescook@chromium.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com,
	Peter Zijlstra <peterz@infradead.org>, mcgrof@kernel.org,
	mhocko@kernel.org, linux-mm@kvack.org,
	Ingo Molnar <mingo@redhat.com>, riel@surriel.com,
	Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
Message-ID: <20190719164711.GB854@blackbody.suse.cz>
References: <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
 <20190711134754.GD3402@hirez.programming.kicks-ass.net>
 <b027f9cc-edd2-840c-3829-176a1e298446@linux.alibaba.com>
 <20190712075815.GN3402@hirez.programming.kicks-ass.net>
 <37474414-1a54-8e3a-60df-eb7e5e1cc1ed@linux.alibaba.com>
 <20190712094214.GR3402@hirez.programming.kicks-ass.net>
 <f8020f92-045e-d515-360b-faf9a149ab80@linux.alibaba.com>
 <20190715121025.GN9035@blackbody.suse.cz>
 <ecd21563-539c-06b1-92f2-26a111163174@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <ecd21563-539c-06b1-92f2-26a111163174@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 10:41:36AM +0800, =E7=8E=8B=E8=B4=87  <yun.wang@lin=
ux.alibaba.com> wrote:
> Actually whatever the memory node sets or cpu allow sets is, it will
> take effect on task's behavior regarding memory location and cpu
> location, while the locality only care about the results rather than
> the sets.
My previous response missed much of the context, so it was a bit off.

I see what you mean by the locality now. Alas, I can't assess whether
it's the right thing to do regarding NUMA behavior that you try to
optimize (i.e. you need an answer from someone more familiar with NUMA
balancing).

Michal

