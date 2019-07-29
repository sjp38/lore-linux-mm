Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23B7DC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:33:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4E77217F5
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:33:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4E77217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 716118E0005; Mon, 29 Jul 2019 17:33:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C6068E0002; Mon, 29 Jul 2019 17:33:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 590C28E0005; Mon, 29 Jul 2019 17:33:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 09EA98E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 17:33:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z20so39022030edr.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:33:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6Jl9DS1EKc0OjCFMJqDd7SL7yh8rMk8qwq52fLhcChE=;
        b=LKZXC29Gb6Zg3RvyA+NGPjHYo/VxiioB0XJSHViOXhRLC1nsW74/I0VU/OM3XrH0+l
         XBBWZwA3rRVosN1eLnAzx0pHtrDMomPV/AnOx6p6idoQSNHr4AlEJU9og4Vh0Wi9JXGu
         NmPaf220AcM5H+eza2hlWJSUVTykTuHwfrvrgWr93T2E5z2wqD+hKaNHl7OdctMplF68
         l/NPOVxzmy5McSczg6cPbf9PkmpW8w+3lLOviIRrRQec+UAK2vggO6DYzDbOXSW+Eflt
         nTmMhmeRdOrJDBeMABEV5KE601Vd0o6V7CL8cAcEepV1fuj6LuZ9kVNoHjG+J+04pHg4
         gsow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of qais.yousef@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=qais.yousef@arm.com
X-Gm-Message-State: APjAAAXGhHK4VtCW4k52T4c7L5JDtLmO8DY/ggttQ2DUCdmDT8NlFghC
	+zQqEe2Frr97mJ9a+M8mjVItUs64ppBshpfTYBJ6u/YbnxOTfzv+ovhULKsKof3hx5YOwvelVM/
	M1brQ02hefxP1BgENWXJboQO3gHbjlXbqyemxuTuHzbIQvtQtDbyU3pynO8walmpsxg==
X-Received: by 2002:a50:84a1:: with SMTP id 30mr99133426edq.44.1564436026622;
        Mon, 29 Jul 2019 14:33:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkU9TmN05u9aTsW9jrDkWIt/7oZzKq6DShrNX+5bEa48yUGrnMujycYWzXYviQi/rHvBCX
X-Received: by 2002:a50:84a1:: with SMTP id 30mr99133380edq.44.1564436026014;
        Mon, 29 Jul 2019 14:33:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564436026; cv=none;
        d=google.com; s=arc-20160816;
        b=w62Srqtu12Jm8p+AjMHVT0hJLRkZzHudlC08Uebya81Dj3aeOFKTz1jFXVgWqcCT4l
         tUTSdHD7ASzTPJK/SkvGQx22y3eG86VXRQEx5prnSWl8POtC4dmLVUJ0tv75IBNnaDVy
         AKYGMwnUdxjRSW0EPC23wujd/6VDRzK33QwIOVsKDaXcYIGluYX7YqOs8HmLHUE7ATkh
         gySINdZUsii+mK4XdU5Lp3kRoTGBqiMDQZIRdDswCYRd3ec45v+GfMnJMtq5GZhWj0x+
         KPGRHlTPADKfgu4/XCXgtiPPOL7bBfc+BkHqU2GE/DFYuMzZmY5sCnRCU1k+ZwgBdStz
         FAHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6Jl9DS1EKc0OjCFMJqDd7SL7yh8rMk8qwq52fLhcChE=;
        b=pQ9FjBGjKBKl1GJXdwzOVzYcNF97NOQyRv0MxNOhNMoGNmm/NAcfRbh9W+2FfsPaGg
         RdzFUP1qiQ/E+GKKdlDTW5M4KiY40BmjmDD2sT8+ted3QEnH+IRjchaC4d84Pd3CDA8V
         lCR4luS3jQtWnEK7ptWTWwV6GNpd27E9Vs/l1HRPHiJ8WxpEHn7MPV/8qgwFJbUbG86k
         F/l9Wizc23PS9eCfq0c1Ttvcf3QiiWk919DZ7GZPvO6KGsBX8XZOOzCXKOTBwSpv9KK5
         rwVAAoY26UJyhjVhyBM+gCvba26VThkLvUS+YOyvVMKlf0x/xoJHogW0ZeVHfJGC2b4W
         hL0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of qais.yousef@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=qais.yousef@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id gu1si15842474ejb.131.2019.07.29.14.33.45
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 14:33:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of qais.yousef@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of qais.yousef@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=qais.yousef@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CD299337;
	Mon, 29 Jul 2019 14:33:44 -0700 (PDT)
Received: from e107158-lin.cambridge.arm.com (e107158-lin.cambridge.arm.com [10.1.194.55])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C95423F71F;
	Mon, 29 Jul 2019 14:33:43 -0700 (PDT)
Date: Mon, 29 Jul 2019 22:33:41 +0100
From: Qais Yousef <qais.yousef@arm.com>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190729213341.pacbqtcsdfmkdbsr@e107158-lin.cambridge.arm.com>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729081800.qbamrvsf4rjna656@e107158-lin.cambridge.arm.com>
 <be28b3d2-3f94-806b-874d-db2248a2c3a9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <be28b3d2-3f94-806b-874d-db2248a2c3a9@redhat.com>
User-Agent: NeoMutt/20171215
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/29/19 17:06, Waiman Long wrote:
> On 7/29/19 4:18 AM, Qais Yousef wrote:
> > On 07/27/19 13:10, Waiman Long wrote:
> >> It was found that a dying mm_struct where the owning task has exited
> >> can stay on as active_mm of kernel threads as long as no other user
> >> tasks run on those CPUs that use it as active_mm. This prolongs the
> >> life time of dying mm holding up memory and other resources like swap
> >> space that cannot be freed.
> >>
> >> Fix that by forcing the kernel threads to use init_mm as the active_mm
> >> if the previous active_mm is dying.
> >>
> >> The determination of a dying mm is based on the absence of an owning
> >> task. The selection of the owning task only happens with the CONFIG_MEMCG
> >> option. Without that, there is no simple way to determine the life span
> >> of a given mm. So it falls back to the old behavior.
> > I don't really know a lot about this code, but does the owner field has to
> > depend on CONFIG_MEMCG? ie: can't the owner be always set?
> >
> Yes, the owner field is only used and defined when CONFIG_MEMCG is on.

I guess this is the simpler answer of it's too much work to take it out of
CONFIG_MEMCG.

Anyway, given the direction of the thread this is moot now :-)

Thanks!

--
Qais Yousef

