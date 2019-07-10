Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 562B2C74A3E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 19:44:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 275B12086D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 19:44:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 275B12086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B46268E008C; Wed, 10 Jul 2019 15:44:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF6438E0032; Wed, 10 Jul 2019 15:44:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E4EE8E008C; Wed, 10 Jul 2019 15:44:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65D7F8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 15:44:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b33so2289628edc.17
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 12:44:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PESIESDa1LKCYTt63jPv3LDj5bQv+KBzFK/nZVh/JdI=;
        b=XStQcVzvNQRJjRcYg6R+LGjAjt9P0R4GNpbuIGJm4ttGLlbm8Q3V2zv/h7vyeRKAGo
         ZDe/rxyf7/8o+cNN5DQkeheNkdq4Zj+YKIXleCBFw1KhkyBtjr+kyQpTFL+fL/3XV/jj
         Mq35BN2V4l1MQTPvpMZMl0NXGKvpEUJrHlXolEbt8Kus03r4ClnRrdXLq2Fx+mkXlczl
         0LBpIwd192QX6YMOzoCuRfbJpe7m9YoQjaRAqsyrPJGXGwq4f6RRol6FUsyYjTOuukMA
         MBRausv4CDZ9EFSBOFotMC+P5uSpbn/nffVDp6c9uJL57NMCUpN5unBFYaaA9ILi4wPX
         dt9g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUEgyZHzB0Ts1tS2k3u5+RMOzqy22f6cRgWetrkmTLiu9zKPnNE
	Tns+NlGWVKsQ3vqVfQv6XcFUG1EOWz0F9hIvnryT+CALvl/sKcSXYRqH3Ae50YRZ4RmJNNHIxf1
	FD/6S1/bvs+lL6QHmmibgs9gnPZ0lXpdGaPM8L8je5sk9Y9SftU6aWFZHxFiTAEE=
X-Received: by 2002:a17:906:b2cd:: with SMTP id cf13mr25314753ejb.197.1562787847953;
        Wed, 10 Jul 2019 12:44:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5WMHcEA18Ek7WuNkYGDuUAF4bsYbFyc8+8a1cPPkrwnEKGWfK8K63lH+8rZ6eKu2EPQW5
X-Received: by 2002:a17:906:b2cd:: with SMTP id cf13mr25314713ejb.197.1562787846978;
        Wed, 10 Jul 2019 12:44:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562787846; cv=none;
        d=google.com; s=arc-20160816;
        b=sd+g49Z1/F6xbRiU/RZCx6kpxdIdYvS6ZykZlLhfbEZAkWcrZKJsmlk1N3vaTaQadh
         Da3HtqYz3NnSKNZm0eCjfoHq9k2fvqc0uR+iagbAOwnuz3ucrBLDztG+1ilx8nGTTA2c
         JDMnnwgbx2es4ogk2iCBUNKLc1VnT07Ug+WhkRbwBVx1CHRQM+WyQetwqJKcZkDDK4dA
         i2PQkPlJqZl1SGs6m1BSwN+hoQVXmtBVNrpdmdTesTtsCiehhWF/bCLaktdKPCrOgSlw
         RS2EDeO83pzcLzZ1MuQupvq8x5Abn1IwuWECvL2M1n3M0vywdViV9ICo44chsvtLys6a
         fjtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PESIESDa1LKCYTt63jPv3LDj5bQv+KBzFK/nZVh/JdI=;
        b=OX65soMuXBy2Pv6/nyHvJispJpQrvpjFDdNlZb7y8aee/897AtnzvBNbtuvr4p0GaF
         uZ9EX04u5R7NXp9vwd7kDTYli6iWmqZ1Jtif6wIMmIy7YGwx5WhMgS7XB2F0nrG0ztnz
         pMtssWbGjt3SPPj1ORBpinekWFkZjrkC+Lsc9850Quw/wKKlYBY7MidyiMzKn7JEO6TP
         +rK6OdCNFw2Dj2p9YUqvFpahqHBPPZ8RrEw+NyIOChEEqZijRN6d/Y1L9GHXM9+uTPLl
         ktQsA+Y4dYprjC7MbOPeJ6Ck3hc0b11oWYz7nCcKr21PwmjEhsNlhnV5dADqs0mya0bg
         udaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c31si2081406edb.418.2019.07.10.12.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 12:44:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 15100AC37;
	Wed, 10 Jul 2019 19:44:05 +0000 (UTC)
Date: Wed, 10 Jul 2019 21:44:03 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@suse.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Question] Should direct reclaim time be bounded?
Message-ID: <20190710194403.GR29695@dhcp22.suse.cz>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
 <885afb7b-f5be-590a-00c8-a24d2bc65f37@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <885afb7b-f5be-590a-00c8-a24d2bc65f37@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 10-07-19 11:42:40, Mike Kravetz wrote:
[...]
> As Michal suggested, I'm going to do some testing to see what impact
> dropping the __GFP_RETRY_MAYFAIL flag for these huge page allocations
> will have on the number of pages allocated.

Just to clarify. I didn't mean to drop __GFP_RETRY_MAYFAIL from the
allocation request. I meant to drop the special casing of the flag in
should_continue_reclaim. I really have hard time to argue for this
special casing TBH. The flag is meant to retry harder but that shouldn't
be reduced to a single reclaim attempt because that alone doesn't really
help much with the high order allocation. It is more about compaction to
be retried harder.
-- 
Michal Hocko
SUSE Labs

