Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 024CDC742B2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:42:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B99842064B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:42:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mSrNEGpr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B99842064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B1538E0131; Fri, 12 Jul 2019 05:42:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 360C38E00DB; Fri, 12 Jul 2019 05:42:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 276618E0131; Fri, 12 Jul 2019 05:42:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0900D8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:42:25 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id r27so9984566iob.14
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 02:42:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=8/S1+jX16TzxOOIxU/bRAzwTmHAX9u5kySICahCztRc=;
        b=exaN49jwtYc26IwNEnxP3F70PU6hjrS8ndyOIK1XQ1Ku3TlRCtFnPKnaTn41z3yBZU
         sm2J8pYrEnCY4Eh/xM4cgUUR1qTTlCpTQB/CRBhouBzXsqKMjKtwNHDZJWt69K6A28E8
         Pu6ajnBIE3ZzYH0QQzwhiQ3EUyq//ymKp5yurnbf0Njgztwb1OPv2NEl4VrmUqIDIQ1o
         Niy4/4CLv7ckIntgHZffxhfRKmpAXcOHYtu4OUV+gQ6XBWYMOFGPBLAt/l7cQ0dY3zbm
         qjlQUclclPGUVMvh8j24CUHsUKWuMdUILA75/ALQlUVGwn9DbJxz/mxl3kLbDLx8jiM+
         ahDw==
X-Gm-Message-State: APjAAAXpflSGungqvWpIDpAh7IgUtnV2YnXTlP3F/fB454YBLKQExzzj
	hs0W4GxXxd9V08MT8tUcez5wbEZsHkUJ7dSiJl2WyLbv5tsUgxVj3aYhasrEQYt7wmq60Qc1N5x
	AW6yFd5DJydBYEnW8XI44jbo57VLbr7anrwCjFqZ7LRKITr+qaN+OrsiRpspIH2emEA==
X-Received: by 2002:a05:6638:303:: with SMTP id w3mr5739150jap.103.1562924544819;
        Fri, 12 Jul 2019 02:42:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6ZoT8ZLW9cHcrxicIRaDjxu8NfMt5+wQReZ1vmdjHZ1jS2t+Ka1UdzyD2KWYoqGQVf8OJ
X-Received: by 2002:a05:6638:303:: with SMTP id w3mr5739099jap.103.1562924544235;
        Fri, 12 Jul 2019 02:42:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562924544; cv=none;
        d=google.com; s=arc-20160816;
        b=ufM4LQTGn2X8P/KrvY5HXmAHX8Q45sC1VNWbCddYU+AcC4yYvSq7a0yOwpehrHnhg9
         5JjFwULB5t7CWYB2iK7zRomvdOIwmPB+7fWz7SChPRFE3/eG7g0X72yXURqG683ZKWZn
         VBrm9mZadAbyaUtCJ0+IJfgpiZxk5POmmeTb2Hc8Kg2VAvMO2uKSrWwwFMAaN28ucYIH
         uFbBkgQC/8mE6LmDcL72Isvw7T+OlZuYIASwEpmbva5k4f9NfVEIW/KPql2g5/D1WUQg
         2CcrRXTPCwcsSzR9iStyDS/9cP/L7PtqaeB3JxFEJViJDcr/7xhPttOiXayicbVwVKhw
         IL4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=8/S1+jX16TzxOOIxU/bRAzwTmHAX9u5kySICahCztRc=;
        b=J+HepyW/ts8c3uYKN8T3L4WLADmN6VlLi2vjET7OYhFy52ePozEkUc/vwG5ogWygd3
         4Nkcanth5KrbIjJG4s4A/8T+8EKOAtZQ8iw7HQyMLy5WXBweyPz1BYQdWhFACryV4aeh
         euaWW4K6XzlIhGy50bp7cIeCDDx92LyHuGBsZYuonMbV32aaP7UqGMgQJ3Stcnu1ZSWN
         2mxSbdqnHBRm1E94lVulRqLcUpOmdM2/A5tpjLglA+uiP4abC0TeYS++nrBihhdhxTI+
         TGF0tIHcsp2hhX+NqeZBn8HBzBh/2puGSIRzgxDYwOav4zt9rXzURoYvGHDEsg2Ow2VK
         gaGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=mSrNEGpr;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p21si11340224iod.30.2019.07.12.02.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 02:42:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=mSrNEGpr;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=8/S1+jX16TzxOOIxU/bRAzwTmHAX9u5kySICahCztRc=; b=mSrNEGprNQlxAb5b94YQqMyPMz
	kO0qgKwAjdYbQbt4ZLUYljy7WNvo98DtdOjLMkwQcC+18PUw+zCus/8lHAlhzfenlvKk3/Z2vY4/9
	poGaxdm1lKQXL+ObIt2v7JWeRaLtiqVQcLZdQ1GMpReUW8AmwLtxny/yVm2355jnSfECJcJqkElr0
	efFJMK0rpeOmHiLR4LtJhRb00cGecEEyJHgZct4gLmv1Qhuko/MvaUi4iuh7hx96d+cEh7LTSKMrR
	vq7hEteI36agAuTFdorAWUAocaMJg+9QtIMY2HCGkgtIpARgexlahUx3JF76qIbmqIXKBArIUAa4D
	0F/wsyBQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hls4F-0004Df-KT; Fri, 12 Jul 2019 09:42:15 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 4236020120CB1; Fri, 12 Jul 2019 11:42:14 +0200 (CEST)
Date: Fri, 12 Jul 2019 11:42:14 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
	linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
	Mel Gorman <mgorman@suse.de>, riel@surriel.com
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
Message-ID: <20190712094214.GR3402@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
 <20190711134754.GD3402@hirez.programming.kicks-ass.net>
 <b027f9cc-edd2-840c-3829-176a1e298446@linux.alibaba.com>
 <20190712075815.GN3402@hirez.programming.kicks-ass.net>
 <37474414-1a54-8e3a-60df-eb7e5e1cc1ed@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <37474414-1a54-8e3a-60df-eb7e5e1cc1ed@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 05:11:25PM +0800, 王贇 wrote:
> 
> 
> On 2019/7/12 下午3:58, Peter Zijlstra wrote:
> [snip]
> >>>
> >>> Then our task t1 should be accounted to B (as you do), but also to A and
> >>> R.
> >>
> >> I get the point but not quite sure about this...
> >>
> >> Not like pages there are no hierarchical limitation on locality, also tasks
> > 
> > You can use cpusets to affect that.
> 
> Could you please give more detail on this?

Documentation/cgroup-v1/cpusets.txt

Look for mems_allowed.

