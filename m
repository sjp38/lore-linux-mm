Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD173C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:37:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9705E20679
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:37:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9705E20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 368708E0002; Tue, 18 Jun 2019 08:37:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F19F8E0001; Tue, 18 Jun 2019 08:37:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1931F8E0002; Tue, 18 Jun 2019 08:37:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC13C8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:37:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c27so21091180edn.8
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:37:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ZTO3FXBgkqsk7WlluUrixGCYXS+jrSLdWLWcMjZh3q0=;
        b=acD7XD24Ux2qSeF+MXctQFIU2IpOQRmQjhk1y1zzoro4pWkiMz0I0KRnSbAm9ESH6t
         g/oyRustrsyRbsaIt+ttbqz3hfkIQVw2nkTdo6ySs2ftdJ0vLhUg6EjvnLT4Y0pqlpqC
         3+1VgadwueXrMIwYd2y3SwedRm3UGets8XWX7XjAQNiXN3cUxoq+g2WPtR3jQ9xGNixm
         HXhaVeXWl0N48QFaS7X/x3vrzJbr1y/T/sG/z9LEo4zNObvfKmBQ+TFgN39T3an0Gcva
         jHOI13WU7KRSG45vFgnARNUDJX6psXF8VKUCnZB/nKx8JsRRDBS7QhF05dqULWt/a0RV
         Nc/Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVjcO7VE2n9wRSqBPaEnbOcgpKdZcqFVN3yTJpU/5X2xmVg65Ox
	drDAOo+cGgilmmhMdusr3+wVJgZZ2Z2Dq9JQRp/anbG2Fr00BAPQ+w5ifj5IaU9HukwTIn5M19o
	ZnOiVAhHRV4JOWfc1BWXwE/3cwbk7Y9A9uHhymkgFcpnsNLX5rC1onHeq6clWgNs=
X-Received: by 2002:a50:9451:: with SMTP id q17mr62140503eda.119.1560861473357;
        Tue, 18 Jun 2019 05:37:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9RC0baOWlB/3rp1eNnwMBpv2En40HNxEzBEURO24Vdaf21uNDugNcq/myZM+B/UsaH2ic
X-Received: by 2002:a50:9451:: with SMTP id q17mr62140440eda.119.1560861472689;
        Tue, 18 Jun 2019 05:37:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560861472; cv=none;
        d=google.com; s=arc-20160816;
        b=I8LzoCWSd3HuvrMJi/nJyQuwG5fZNhYRxmnlEYe/0wZDS9venPHUL9M4xPRABm2NTh
         10+KVx8Xt50DwscQJmqdz3IPGjVPHTWHyCKThagR7Q1LMvgwXUnzs3qHgOjC6HFT3uee
         G/Rsip0130oeN6FVW42BeTd9KpmJobMehBlMWkKdxZmMquqCscvspGVHdAH7xTpkPQA5
         5ekyawGf3x/KKq9D/ctUJpaT86HJG6L+GXHeUIwyWhth5rNDxW+c/jR/VEfs3oBYV9Rc
         ryIQE6lQRmdRna4ru0oVv8CRCzOAvYF4TOqewK45s3OfF5fMnrRghtGQ/avUD1WRI1jU
         PyWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ZTO3FXBgkqsk7WlluUrixGCYXS+jrSLdWLWcMjZh3q0=;
        b=AI1t63JeP28zOGPx50i9Cj2ECv18ldi+MFK8QhUpsUQbLL/P5ByRzRBXUNARTMEkHC
         rGbfnYDPmF9OwiI7ZwqdNDNHes55WOAh1PadstGDl3CGlTnBTDo6OsAmtWwjlr7Nh6e4
         MzBm3kZRB1y5de0rOJVc7olHVKkPu925sPAdDzVs9IJdXYp57B0KZfdFqOs5zEZpmWo0
         bDnCC3rX8CXBhBU3Toz7CDSUpQ6I781WS1NBZspoY9FXrPEwGOBNFIKd/t/TEXyR5E2q
         IqPDQO8EI7NGkHz8mciqgAUC+mMuzgP8mPCfcRuBx5WqfHPFTeIGVsd/FGghjeXASZah
         Bibw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si11594181eda.160.2019.06.18.05.37.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 05:37:52 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 425E1AD0B;
	Tue, 18 Jun 2019 12:37:52 +0000 (UTC)
Date: Tue, 18 Jun 2019 14:37:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	linux-api@vger.kernel.org
Subject: Re: [PATCH] mm, memcg: Report number of memcg caches in slabinfo
Message-ID: <20190618123750.GG3318@dhcp22.suse.cz>
References: <20190617142149.5245-1-longman@redhat.com>
 <20190617143842.GC1492@dhcp22.suse.cz>
 <9e165eae-e354-04c4-6362-0f80fe819469@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9e165eae-e354-04c4-6362-0f80fe819469@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 17-06-19 10:50:23, Waiman Long wrote:
> On 6/17/19 10:38 AM, Michal Hocko wrote:
> > [Cc linux-api]
> >
> > On Mon 17-06-19 10:21:49, Waiman Long wrote:
> >> There are concerns about memory leaks from extensive use of memory
> >> cgroups as each memory cgroup creates its own set of kmem caches. There
> >> is a possiblity that the memcg kmem caches may remain even after the
> >> memory cgroup removal.
> >>
> >> Therefore, it will be useful to show how many memcg caches are present
> >> for each of the kmem caches.
> > How is a user going to use that information?  Btw. Don't we have an
> > interface to display the number of (dead) cgroups?
> 
> The interface to report dead cgroups is for cgroup v2 (cgroup.stat)
> only. I don't think there is a way to find that for cgroup v1.

Doesn't debug_legacy_files provide the information for both cgroups
APIs?

> Also the
> number of memcg kmem caches may not be the same as the number of
> memcg's. It can range from 0 to above the number of memcg's.  So it is
> an interesting number by itself.

Is this useful enough to put into slabinfo? Doesn't this sound more like
a debugfs kinda a thing?

> From the user perspective, if the numbers is way above the number of
> memcg's, there is probably something wrong there.

-- 
Michal Hocko
SUSE Labs

