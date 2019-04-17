Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FF46C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:46:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 540B220835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:46:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 540B220835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D34456B0003; Wed, 17 Apr 2019 07:46:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE3F86B0006; Wed, 17 Apr 2019 07:46:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFA576B0007; Wed, 17 Apr 2019 07:46:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 71BD26B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:46:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s21so5240156edd.10
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:46:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VqZMGuZcdg9YJNZYsOVbEp4PB4gcial3BzcxpfC/d3s=;
        b=jyxVUPOOIJOIgADplyUwzrSvq0a1rKbffficZuqm8WEVwpXZ8IOegra+kncFeV2pR4
         mGxo/aVho4fMVghaEC8UUKeiYUqQR7Yn7ZnAH5SXhi2R7Z82ZeYcabcQLgvayNX4tCao
         jFxXtwOXDUIvhmAT+IjxJoLUmboFXJsDIND0ZOdQT+jzZyQ69TNgPkh4FndZLVGZUzWV
         yFVQqIWYoYaVtyLZlv+7g5bNAf3qIV2MuI/lRUe6zRo/0ntruZtvYXsJuwwhoGwsjDFe
         Bl42iQ3ihHIC0MYoZ83TvIVg8Xb0hIVftobtPo8kqyfBLK+2iQhoauubcECibvWPQKnD
         UZZw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV1krNQfkjNqmHvAonCyFfE4rxXGyF1g8+ZnUcONiRxL9+T962e
	w/sc28yLBiYxsZ/w1TPzpndbmKmZVqn0Bjryu0Cbs3EugoTX0x/yaYBuYYSscp9OGop0tRv7Sov
	labavJ7Y1m1HhWawdZeS2I2Mfles282i7DyQFmBbBItYCZjCCQaDGKzLpb5J4QJs=
X-Received: by 2002:a17:906:66c2:: with SMTP id k2mr48514176ejp.181.1555501583981;
        Wed, 17 Apr 2019 04:46:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbRj67x9/zZiyp1FzbMD3BVkaFO42VFkw8IYMqsBJO4MB5EZhCSRNuxsM6IXPsG8v1dpF7
X-Received: by 2002:a17:906:66c2:: with SMTP id k2mr48514145ejp.181.1555501583226;
        Wed, 17 Apr 2019 04:46:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555501583; cv=none;
        d=google.com; s=arc-20160816;
        b=PNcz3clDxcMhAV/WI+k4zgsfd8s7VtRz5YzLn6yELyxqRrSweehVTUbGsp0WKuw8gs
         vZkbiHg36QQB8o6yKGs0aLnT7rv3rsgbCQe4xpZayMvZzEtjyxPsoBnahxbLSFD8pPGx
         vx4QHuS83FdiIJLUVu4P0JZ/uU6yXnbL/QgYy1VUpQAQa4IAhiw+cKbqe6gZ4oDkby05
         49EfHswN9Jm55q/go6+oQCUjy8xzk7pyfIv25ox+suDgLeKS3XGMNhjsX8eyaAxC6Det
         o6nBjFFZclDhumMSzQ8f4BHQ1DYx6HNfKOyRLG0+1Chwx18FtNr87R4xDw1DZidzfoZR
         SgJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VqZMGuZcdg9YJNZYsOVbEp4PB4gcial3BzcxpfC/d3s=;
        b=H/pbMgV5lFcUtZzzxR9rfjMI2LxCO/wNXkqEwiJU7auIVDZjFh9Kde4ksd6yeaHaJZ
         ZhLZgVYqpdUmSWnFCmNYMlP0aJBEvrnsHGZm8gvA6Vly+M3cbX62y8drFW4EKMbgASPp
         Mqsuzjf9YtkHggt7YIn+LlW4I4oVqj2n8GAF2zgOxQFWc9MdscAkdGu79NTnFMY/nQie
         Jcyy0GyQqrk8ShEWhxonAuzTl5V9Htz9RzX/Lw8y0ljy1/p9f1UEhyUMPPUoNPWuHcqA
         0PaCDxRBlj7BUbYWmEZSZtluTZGkfkz5cbC6pWBivTggsAFgT2WlxF/7AsXFMCufM2LQ
         RdiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x14si784437ejs.313.2019.04.17.04.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 04:46:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A8FE3AFBD;
	Wed, 17 Apr 2019 11:46:22 +0000 (UTC)
Date: Wed, 17 Apr 2019 13:46:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] mm/workingset : judge file page activity via
 timestamp
Message-ID: <20190417114621.GF5878@dhcp22.suse.cz>
References: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
 <CAGWkznFCy-Fm1WObEk77shPGALWhn5dWS3ZLXY77+q_4Yp6bAQ@mail.gmail.com>
 <CAGWkznEzRB2RPQEK5+4EYB73UYGMRbNNmMH-FyQqT2_en_q1+g@mail.gmail.com>
 <20190417110615.GC5878@dhcp22.suse.cz>
 <CAGWkznH6MjCkKeAO_1jJ07Ze2E3KHem0aNZ_Vwf080Yg-4Ujbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGWkznH6MjCkKeAO_1jJ07Ze2E3KHem0aNZ_Vwf080Yg-4Ujbw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 19:36:21, Zhaoyang Huang wrote:
> sorry for the confusion. What I mean is the basic idea doesn't change
> as replacing the refault criteria from refault_distance to timestamp.
> But the detailed implementation changed a lot, including fix bugs,
> update the way of packing the timestamp, 32bit/64bit differentiation
> etc. So it makes sense for starting a new context.

Not really. My take away from the previous discussion is that Johannes
has questioned the timestamping approach itself. I wasn't following very
closely so I might be wrong here but if that is really the case then it
doesn't make much sense to improve the implementation if there is no
consensus on the approach itself.

-- 
Michal Hocko
SUSE Labs

