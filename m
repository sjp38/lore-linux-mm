Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2326C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 19:12:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C97720811
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 19:12:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C97720811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50F4B6B0273; Thu, 28 Mar 2019 15:12:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BAD66B0274; Thu, 28 Mar 2019 15:12:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 384236B0275; Thu, 28 Mar 2019 15:12:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD1836B0273
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:12:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f2so1495165edv.15
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 12:12:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=z375LGGTzt0HVG9Pc9345rYUyhpZDXPWI/hzQAVImYE=;
        b=t7VowK8SriCI0S0Am6W+JuDEu8d5jyh6BWj57IS9mohjcqTMZycveI4L5TO0TvNtH9
         Oq0pXahMI0DdZCqtoXeoZmoKlP0Qcqbp+Mx03iHwggh7Z9hii0IVjNKLIW7bfHMXMzNO
         SVX8vzPG2g2dkRR43ohbxIdbcI6UryC9K92qUN6BCbZVTgmtyydloV+Luni2yPqIvaTH
         6Rs5MIYDAN+azd9/E1xc+fLiAplGeeJ+edi2artZs2qda52+kaxRi0fD6r5YGn6JkSK+
         wa11L6rfdTnRy8MYEN28qtZUx/bbrNYFcVY35UqU9ZMCx/ElihcUOONK/OSYz3QMaqkD
         Q+Ww==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWFYE4PduUxa0Euz8CjNs/0tSQUyBd+mcpDU9tgUVnJXRK1lHnU
	uZilPZU7KyEjlNLUmY2KQosX1P2sEwcJk1sBkCOmMrS35QeF0b1GrzLuW6XTbpe6/Ld+a+7HjeL
	eWWDdxxy4nrOJXUJfvO3GseHegaUs00F+JNIok96UHeWF1kKB0cwo556qDC2KhkA=
X-Received: by 2002:a17:906:3c5:: with SMTP id c5mr24921868eja.24.1553800329460;
        Thu, 28 Mar 2019 12:12:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRXgIIJNG22M/IDMteEpRvfo2wv5jYlxaZukVmvzKlgy3qMvsTXKfHhPCrYuEK2qNfMUbv
X-Received: by 2002:a17:906:3c5:: with SMTP id c5mr24921830eja.24.1553800328528;
        Thu, 28 Mar 2019 12:12:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553800328; cv=none;
        d=google.com; s=arc-20160816;
        b=S6qnDLf78oTG1RVrpzuEk3laxRkdfW0SpQXIWEs8PQhTF+MCyHONQMJ4jHQi5EqU2u
         n4YZPiESsvCrUfPCJW/VitypenF35L7ZN5qWs6LtrDTsLDxrMyOefFZIMSZRkE9GsvE+
         CX6r28zSKjWyGv7NThh+OFuFmlXZ8rGsYwwpjjE/jmmry+WJwS7o5jZp0KVZd5eVsvs9
         fAA3HLN2Dj76Fle2DZ4B+lqrFQ1yyC86kThI11e1PrVfsnkCWK1bzX5q1RG4HU4cWXVU
         +F8mn76L/tu7VzIwxftLov455zILlGzfb9Cn4F2sNQ+Kvz083DV7kbQqCGrodZrmllkV
         x3WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=z375LGGTzt0HVG9Pc9345rYUyhpZDXPWI/hzQAVImYE=;
        b=XVJ/MdGwn3YPIVuVNELyQsHHwt4HTdj0s6CMB38lGnBT+0q5W4iDH9UA3rNxpoyDuA
         3+mmcfhC78osPZduEFtm5UspjI5IYHloa19SKN/WHLLjr/wU966Fh3GHsvcaA9I20R0D
         23gNDxGEqw2fdvEjK4dTOB7X9idORppnxY0fzsRSb5kUvNT6LR0Jok9Kp42CpOGDQUyY
         okI4zKC+YhNYI8JJ7KR/GqWNHdNf6ixo/NOiZeEYkJCzHzhpJhlWnBg2AwjRuBG7kJlJ
         nKveVAU45Vnni0DVOkYZTtRTFNPcLuPxdjxXwpLUA/GMz645WhhQ1sBhTtoBXaAUbprg
         GNZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z19si847049ejx.279.2019.03.28.12.12.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 12:12:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EB39DAB9D;
	Thu, 28 Mar 2019 19:12:07 +0000 (UTC)
Date: Thu, 28 Mar 2019 20:12:06 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
	"Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190328191206.GC7155@dhcp22.suse.cz>
References: <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz>
 <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz>
 <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
 <c3690a19-e2a6-7db7-b146-b08aa9b22854@linux.alibaba.com>
 <20190327193918.GP11927@dhcp22.suse.cz>
 <6f8b4c51-3f3c-16f9-ca2f-dbcd08ea23e6@linux.alibaba.com>
 <20190328065802.GQ11927@dhcp22.suse.cz>
 <6487e0f5-aee4-3fea-00f5-c12602b8ad2b@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6487e0f5-aee4-3fea-00f5-c12602b8ad2b@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-03-19 11:58:57, Yang Shi wrote:
> 
> 
> On 3/27/19 11:58 PM, Michal Hocko wrote:
> > On Wed 27-03-19 19:09:10, Yang Shi wrote:
> > > One question, when doing demote and promote we need define a path, for
> > > example, DRAM <-> PMEM (assume two tier memory). When determining what nodes
> > > are "DRAM" nodes, does it make sense to assume the nodes with both cpu and
> > > memory are DRAM nodes since PMEM nodes are typically cpuless nodes?
> > Do we really have to special case this for PMEM? Why cannot we simply go
> > in the zonelist order? In other words why cannot we use the same logic
> > for a larger NUMA machine and instead of swapping simply fallback to a
> > less contended NUMA node? It can be a regular DRAM, PMEM or whatever
> > other type of memory node.
> 
> Thanks for the suggestion. It makes sense. However, if we don't specialize a
> pmem node, its fallback node may be a DRAM node, then the memory reclaim may
> move the inactive page to the DRAM node, it sounds not make too much sense
> since memory reclaim would prefer to move downwards (DRAM -> PMEM -> Disk).

There are certainly many details to sort out. One thing is how to handle
cpuless nodes (e.g. PMEM). Those shouldn't get any direct allocations
without an explicit binding, right? My first naive idea would be to only
migrate-on-reclaim only from the preferred node. We might need
additional heuristics but I wouldn't special case PMEM from other
cpuless NUMA nodes.
-- 
Michal Hocko
SUSE Labs

