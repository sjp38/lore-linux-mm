Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90874C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:19:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 436DA2077C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:19:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 436DA2077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C53956B0003; Tue, 23 Apr 2019 03:19:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C03426B0006; Tue, 23 Apr 2019 03:19:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACBB26B0007; Tue, 23 Apr 2019 03:19:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFB86B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 03:19:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f7so2266596edi.20
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 00:19:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=42ugvElMVoGqu/m8MSC5tnYu4AH/sC8WY74C7nB6B6o=;
        b=N62Cv9/fBkZRyf+5w4wSBxV/r1c6mhYT9/xSukItnII5T0AVDwmZyUIMfyTh82fFYm
         MXl4zQpgsFJ7fXyLxExwAkSZrw1xC5ar7KRYsW9kGCjTiH9ViC1tkYKglupRMJ+roUDj
         BPAn01yoqNGKl/Bs/CNW2bsCHfY0t9Dzaj8dHXBT7x9IX3+EU6DKMoRuVa0CIkOaQ+Zr
         Rm8V5CWYOZHiQs+X4euSUzVf6T3aHYISJ41ez3019QRD1d96oRyUXtW5cdbsnwo8T+r+
         EEVEN5vHO9VfCfmC5PP1JlI/Oo3oxUeIh1dbJ6phvE77aPBAanj0dQ8HWY6Ic677Jm0s
         dI9g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXyB1U5Q+ibEGcq9z7ul0b5IAYZ/366R3At+WamVzo4MRyBgKwZ
	UOt67zpC9vTMe9XIPHnrabH3g8FD298Hdn2Bzk6yFpi4gKDMcVsoPU1xIIot1xRPTIDn3AJBhV+
	YQh5sTaMQn4vAeFNRDY99PEBY1VRa5yHLYly0SqfGKU81j1bWzK+8wmApg72XeWQ=
X-Received: by 2002:aa7:c510:: with SMTP id o16mr14240382edq.277.1556003995917;
        Tue, 23 Apr 2019 00:19:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPlIiKM71vRxLsozXqh05lMMwY0uFZpbcRCSFZf77KvYd2qeQtyz/5b1BpbcqYk9kIT9G/
X-Received: by 2002:aa7:c510:: with SMTP id o16mr14240341edq.277.1556003995096;
        Tue, 23 Apr 2019 00:19:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556003995; cv=none;
        d=google.com; s=arc-20160816;
        b=N2zZ1vpVkPHRZnrRGt4vONXChz2pQbrNFCSRVzK4h/bGmkeABe7hAcZMwMhOjztbFQ
         TTYj0S4IL0zDgO/UCkvaKwUGAWrIGMQtQhxuRsHSTof7iWT8qFk1e2WOKyGl4jixHQnz
         NhKAMnhC68+l37Tw7PoR0dSvp2qUwE33MECYbhZ2OsG/F1pyUObWZNd+PZpAbwSaiZN7
         pVuaa75xGJhb49Fno2frzuqn4bQcl5M89EAqbicxGGsQr85cRSQcE8lljO0GVnj5QAl5
         BgHKnK+rOOdN1uFCHlHswRpAaJ0BzqjXTsl5/lEy2pSeK2+A3c27wGEnoVggVUrlvjzc
         X/2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=42ugvElMVoGqu/m8MSC5tnYu4AH/sC8WY74C7nB6B6o=;
        b=ud6C6731IhvcLTMcSHYRknJBq3C7bNo2bN2C6XHx7I6XfFQB/vVY9fOQ+F0JzTGLoZ
         U3MvMpSgfcRYpDnn8xk//OVtQ4tc4uqE5O7MA+e5k8jxudkXyIengvbHNBBoyLGxusI9
         vXU4AFQlCY33SWjM7rhUx/NMUD/MpOuA3tq+IFEQPB9ykb/Ojg+UzS/0YKhY+Admb0ZO
         25LPfqkKqGwC3xSRatqL2kUOdlU7LYY8vn5QrAhIrVhTehS8GqXkBDgTXm/NywVZ/3Mn
         Oid1l7nJ/tl8KpwRdK5TdNMHOCd8VQgEFlxbMZC+mjD8oAZp4rvHDDkikZKPJxUd5pH/
         3AWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si935438edy.227.2019.04.23.00.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 00:19:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8EE12AD1A;
	Tue, 23 Apr 2019 07:19:54 +0000 (UTC)
Date: Tue, 23 Apr 2019 09:19:53 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Question] Should direct reclaim time be bounded?
Message-ID: <20190423071953.GC25106@dhcp22.suse.cz>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 22-04-19 21:07:28, Mike Kravetz wrote:
[...]
> However, consider the case of a 2 node system where:
> node 0 has 2GB memory
> node 1 has 4GB memory
> 
> Now, if one wants to allocate 4GB of huge pages they may be tempted to simply,
> "echo 2048 > nr_hugepages".  At first this will go well until node 0 is out
> of memory.  When this happens, alloc_pool_huge_page() will continue to be
> called.  Because of that for_each_node_mask_to_alloc() macro, it will likely
> attempt to first allocate a page from node 0.  It will call direct reclaim and
> compaction until it fails.  Then, it will successfully allocate from node 1.

Yeah, the even distribution is quite a strong statement. We just try to
distribute somehow and it is likely to not work really great on system
with nodes that are different in size. I know it sucks but I've been
recommending to use the /sys/devices/system/node/node$N/hugepages/hugepages-2048kB/nr_hugepages
because that allows the define the actual policy much better. I guess we
want to be more specific about this in the documentation at least.

> In our distro kernel, I am thinking about making allocations try "less hard"
> on nodes where we start to see failures.  less hard == NORETRY/NORECLAIM.
> I was going to try something like this on an upstream kernel when I noticed
> that it seems like direct reclaim may never end/exit.  It 'may' exit, but I
> instrumented __alloc_pages_slowpath() and saw it take well over an hour
> before I 'tricked' it into exiting.
> 
> [ 5916.248341] hpage_slow_alloc: jiffies 5295742  tries 2   node 0 success
> [ 5916.249271]                   reclaim 5295741  compact 1

This is unexpected though. What does tries mean? Number of reclaim
attempts? If yes could you enable tracing to see what takes so long in
the reclaim path?

> This is where it stalled after "echo 4096 > nr_hugepages" on a little VM
> with 8GB total memory.
> 
> I have not started looking at the direct reclaim code to see exactly where
> we may be stuck, or trying really hard.  My question is, "Is this expected
> or should direct reclaim be somewhat bounded?"  With __alloc_pages_slowpath
> getting 'stuck' in direct reclaim, the documented behavior for huge page
> allocation is not going to happen.

Well, our "how hard to try for hugetlb pages" is quite arbitrary. We
used to rety as long as at least order worth of pages have been
reclaimed but that didn't make any sense since the lumpy reclaim was
gone. So the semantic has change to reclaim&compact as long as there is
some progress. From what I understad above it seems that you are not
thrashing and calling reclaim again and again but rather one reclaim
round takes ages.

That being said, I do not think __GFP_RETRY_MAYFAIL is wrong here. It
looks like there is something wrong in the reclaim going on.

-- 
Michal Hocko
SUSE Labs

