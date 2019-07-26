Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 879A2C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:12:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2147321880
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:12:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2147321880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0A438E0002; Fri, 26 Jul 2019 04:12:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BA526B000D; Fri, 26 Jul 2019 04:12:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AA988E0002; Fri, 26 Jul 2019 04:12:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0A06B000C
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:12:31 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so33616192edc.17
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:12:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8ApdeafqqhYLSV3RveuUEVHBv3MRzCCCr7qPTV/4xNE=;
        b=ZVwihrAAWfQiv2bAhgVtMU6vi4p58Og9jjHjJDmnuYZQKIFSioBgk1mt7+jyE6JDFS
         y3/NC8iw7IW7JOwAiTn9jRNEEvYdFEZkJPZ8uaG07vbwT2H0pOFTkMtk/3sb7Ex5d9MS
         MiCJnTILUCzNWNuBwpy7pfbntiCv3hLx7d52FTrdQbozFWTLzPcIXZof/go4CMu3hq6F
         beoioW0Xe6Cm5QrB2cbE3DaxbxVn6Ex4sP9rUSlzgJzKEZfyT9USbpI4q2aze3HlN/+n
         Bof9hg8KtaiLDP8wgi+xMYqgKlvGNJIPYWk8ExYCrtuqKJLIW5cexdFyS5l3/Q1VqExF
         GQvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAWVkm/iZ8fjm14zg6+Qnmjo8wmrz9v9SHasP3ydDddeMLTZ7m8I
	3UAsHW5FlU7ksdOywLDBSqE5oV+3IhTTzoQIZcxAY9Xv/RmwIB9v8eeYdN4Nek/mQjjv3lsaGub
	kv7qpwjYtMR3LhoB6Ysb5xtCtGwMOzlBwb7Pc3YtiZMWeis5SL7ESTPwpn4d0hw+QTw==
X-Received: by 2002:a50:f410:: with SMTP id r16mr81766613edm.120.1564128750811;
        Fri, 26 Jul 2019 01:12:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJCoA07Zp7Jv0H+7HJD0lYEeUuCOn+vFW1/ySDsGPWjDS/Ut7t6LEG/Zq5+WhtHlSS1Sg/
X-Received: by 2002:a50:f410:: with SMTP id r16mr81766568edm.120.1564128750154;
        Fri, 26 Jul 2019 01:12:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564128750; cv=none;
        d=google.com; s=arc-20160816;
        b=JV0wNsqp4te08jIDspejC8RUP7jqi8IHzJ7StmMPJShDI7VkWWI82Brn2vGU40jZT+
         1JYbQ7lrpZ9+jSjracKcVZpo2MSgUkcxrMrTwjvm6aX6oxoJ+a7kK11scYOzTxJFR8Y7
         YrBU3pZ217QS9EQqUZDBWYJBzs9J0bCphBNpTUSEAB1i0wW3jWJAXu2rxS+V4NEnUL20
         mujk47cSyqBkPBWrE80ds8d26TLIyFn+IcYuRfTsb9NhKYkgrXHVkoJRmpXEawxqKxci
         aqCAdYsArN58sqSP8RkbeTeDBMH1PjUZ0tPJJx95YuwbzB4/e/fj4UOXW9rK6JFTVLqw
         UJdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8ApdeafqqhYLSV3RveuUEVHBv3MRzCCCr7qPTV/4xNE=;
        b=JBunjUsOajZP9wZik/WlNezSfVeAG6hmw1Ol2OULJo6K5qlLM3rakt7TaDdS0isrnB
         2VHaKSwfk9ZnHK+N2y5YKizVZvrKj95gxXM14n34xjEC1cpQWSYp4Q4qlxEjdgPk8Gmy
         ewXL8VJJZ5+/t+BIBthV3thQdwi0TRTrIN0gNVPA0+fX7B7U6l9JAv3WVE1sUvdCu3X3
         uTL/FgRns3q27Q9l/9pED9caN6L8RX/UjLa7ieQ5F45+HSXBS5oiJY2O9SKlocs+x2vC
         nTtT04sv/639YyC5Or5HLresPT+LhdO1jvDI0NlSXbB4XtMIlhTbp0ETFqC4vFxEDUtw
         bIUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v30si11428128ejk.208.2019.07.26.01.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 01:12:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 206DAB62D;
	Fri, 26 Jul 2019 08:12:29 +0000 (UTC)
Date: Fri, 26 Jul 2019 09:12:25 +0100
From: Mel Gorman <mgorman@suse.de>
To: Hillf Danton <hdanton@sina.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim
 perform dryrun detection
Message-ID: <20190726081225.GF2708@suse.de>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-2-mike.kravetz@oracle.com>
 <20190725080551.GB2708@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190725080551.GB2708@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> From: Hillf Danton <hdanton@sina.com>
> Subject: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim perform dryrun detection
> 
> Address the issue of should_continue_reclaim continuing true too often
> for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
> This could happen during hugetlb page allocation causing stalls for
> minutes or hours.
> 
> We can stop reclaiming pages if compaction reports it can make a progress.
> A code reshuffle is needed to do that. And it has side-effects, however,
> with allocation latencies in other cases but that would come at the cost
> of potential premature reclaim which has consequences of itself.
> 
> We can also bail out of reclaiming pages if we know that there are not
> enough inactive lru pages left to satisfy the costly allocation.
> 
> We can give up reclaiming pages too if we see dryrun occur, with the
> certainty of plenty of inactive pages. IOW with dryrun detected, we are
> sure we have reclaimed as many pages as we could.
> 
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Hillf Danton <hdanton@sina.com>

Acked-by: Mel Gorman <mgorman@suse.de>

Thanks Hillf

-- 
Mel Gorman
SUSE Labs

