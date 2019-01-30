Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5781C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:18:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D20221473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:18:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D20221473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFF118E0002; Wed, 30 Jan 2019 02:18:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD5F68E0001; Wed, 30 Jan 2019 02:18:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC59F8E0002; Wed, 30 Jan 2019 02:18:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87A7B8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:18:04 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 75so19015145pfq.8
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 23:18:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mmdDNS+DHTyOMjuCvROx/E6yPyWbz3WbKEsTLrej1y0=;
        b=FU99M4W8CyeqApaw6DIdYrVQLzdgPW/XCMyNbjAvjkXvAEvrajH9F08lle3WFW/aE9
         eaOQTFCJNhb2kvMvNuODvZQ+k4MT8yMS87o6xiTp8NmWqtqOlQ7dl3trWLjZMlDvMdFa
         dYs4qkwEXtvdLqdToisaZ5FCOCqrCEkunIYhqNJWnwG78PqHq6Son60+ipv+HLoVHRAW
         QxbcguTTIOEDFUyQbne4c5l1ig8GBBAkbqHdB4hgrdjyoqreMSa2vBrKE0f4CW+nYuFU
         RM3ROMXPlJOqpt6o038ST/AOSrI7lSz1I6qU0tupNpE5us9d7XnDbD43ikpvXnKe9V0I
         6ZqA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdKGUTyaK8NgKZCxjUaRE7ylaOynvjmney1HyGpQ1l1ABLv3EK1
	kyWANiZx1UNFitprLtOw5QTkkhGtzjigMxZ/4VxQdPYL1E5rXN+8CrkVtq+nc+MA7enlCtZcH4O
	2AGSj6kFZrfbf2F0jFcsGKsKeZxyT5VKtQ1KZHP/g9xgLfRyUWYF3aJdR5FKttuI=
X-Received: by 2002:a17:902:a03:: with SMTP id 3mr29529743plo.112.1548832684205;
        Tue, 29 Jan 2019 23:18:04 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7ukgOakcq0Ch7Jj8KnMQ1zPddZnJHAMl43YSZDt89PDG2xGwHa+Q96JJROtFdSemFGAoUz
X-Received: by 2002:a17:902:a03:: with SMTP id 3mr29529714plo.112.1548832683456;
        Tue, 29 Jan 2019 23:18:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548832683; cv=none;
        d=google.com; s=arc-20160816;
        b=CFNFrmGO5mjcA9eNFr8Uko3f9Cs2hyFDUthhOTak4VmRYN91Nt9y4l1nbX7mDEXX3Y
         cdZRKt8JOeRb64pYJuB7h0wM6XYdIgWBOvbEPjGmqbJSjW3Z/Gv6k01Eyxqs14suby9j
         tvDdLEEZPtosIt/rUa4yNiPfxMev7Vd3bVjSsgr2u1JeRaXQ/LKjIzJEV4VzzxsKMkN9
         G1JS4OU5xHkeYDIiNs2t2Fhoc+jU5mmCHuPWAwoMpYN4FDPrUWwLiJuRnJvqz3CzgnjM
         FuAPX8KHosZ2wgQRSeyMLBCKtfDma9Qbh6iFdBu9Vt2EQHxHVEZKd2dITSXBmxyvvZQC
         b3dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mmdDNS+DHTyOMjuCvROx/E6yPyWbz3WbKEsTLrej1y0=;
        b=EzSJdmLCBe0THep/uTmmcvXUF1VHmUL0feZNq3rtn1sVuNiS5bzOjsp07ZMgR9bThd
         Wlps7ObYjZDJzUQs6nR/edBBHhMhMyHgUAtSL0cNJ0Hkd6aP7FocRYFpwqqyThvSQ4yK
         WoD7yzGFyqi9bsZCp61t19PfsAQUSRjSgdqJlrJ4yG5hl2dy99XqFHDF7pKCq81zFjqF
         WOpiFZC5oRFkKMkKjXryTF7JOxYfsFmjowsxMFJvinhn/vnY2KZ+IvY5N6c4GDmMIQVx
         d9rn5C5KxqCCJR1ELZ0sVvHHhSbTOzVLP4bEKh0Df0DlUbTpKSdxh6n896KSzCYESuc7
         VmDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q20si681417pgl.268.2019.01.29.23.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 23:18:03 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CB835AC5B;
	Wed, 30 Jan 2019 07:18:01 +0000 (UTC)
Date: Wed, 30 Jan 2019 08:17:59 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Peter Xu <peterx@redhat.com>,
	Blake Caldwell <blake.caldwell@colorado.edu>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>
Subject: Re: [LSF/MM TOPIC] NUMA remote THP vs NUMA local non-THP under
 MADV_HUGEPAGE
Message-ID: <20190130071759.GR18811@dhcp22.suse.cz>
References: <20190129234058.GH31695@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129234058.GH31695@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 29-01-19 18:40:58, Andrea Arcangeli wrote:
> Hello,
> 
> I'd like to attend the LSF/MM Summit 2019. I'm interested in most MM
> topics and it's enlightening to listen to the common non-MM topics
> too.
> 
> One current topic that could be of interest is the THP / NUMA tradeoff
> in subject.
> 
> One issue about a change in MADV_HUGEPAGE behavior made ~3 years ago
> kept floating around for the last 6 months (~12 months since it was
> initially reported as regression through an enterprise-like workload)
> and it was hot-fixed in commit
> ac5b2c18911ffe95c08d69273917f90212cf5659, but it got quickly reverted
> for various reasons.
> 
> I posted some benchmark results showing that for tasks without strong
> NUMA locality the __GFP_THISNODE logic is not guaranteed to be optimal
> (and here of course I mean even if we ignore the large slowdown with
> swap storms at allocation time that might be caused by
> __GFP_THISNODE). The results also show NUMA remote THPs help
> intrasocket as well as intersocket.
> 
> https://lkml.kernel.org/r/20181210044916.GC24097@redhat.com
> https://lkml.kernel.org/r/20181212104418.GE1130@redhat.com
> 
> The following seems the interim conclusion which I happen to be in
> agreement with Michal and Mel:
> 
> https://lkml.kernel.org/r/20181212095051.GO1286@dhcp22.suse.cz
> https://lkml.kernel.org/r/20181212170016.GG1130@redhat.com

I am definitely interested in discussing this topic and actually wanted
to propose it myself. I would add that part of the discussion was
proposing a neww memory policy that would effectively enable per-vma
node-reclaim like behavior.
-- 
Michal Hocko
SUSE Labs

