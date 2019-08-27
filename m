Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70B57C41514
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 15:23:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1284B206BF
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 15:23:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="figx/Q98"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1284B206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59CC76B000A; Tue, 27 Aug 2019 11:23:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54DC86B000C; Tue, 27 Aug 2019 11:23:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43C796B000D; Tue, 27 Aug 2019 11:23:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0252.hostedemail.com [216.40.44.252])
	by kanga.kvack.org (Postfix) with ESMTP id 214C46B000A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 11:23:14 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 75442824CA0E
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:23:13 +0000 (UTC)
X-FDA: 75868576266.15.cover79_392409670b51b
X-HE-Tag: cover79_392409670b51b
X-Filterd-Recvd-Size: 6054
Received: from mail-io1-f44.google.com (mail-io1-f44.google.com [209.85.166.44])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:23:12 +0000 (UTC)
Received: by mail-io1-f44.google.com with SMTP id j5so47183752ioj.8
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 08:23:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=EialagdAgnBtYjzH6H0eO9CyoHJZ48U2U5aIVIJeUoo=;
        b=figx/Q98kEpCBkqo3lxQ6atjRtKnOZ/vizqGhR6ya8V3vn3+aFl2oTLswEK1VjnEMg
         An75CIk3RkB52JqKH80uhifoZiBjBgP+rPZNgE/8ipmRd77Ok9Xb6Y+4IeWDeVn8lmKd
         ySMOZk1uc2qMWNtBcJuL843WNs9SFPe/F1JQBw+7MCJe3UdkDKvttcuwKgwAi9oppUSI
         vRtaD9Uy56A0NEqyv6qNzLxcz1F6B3uV/Dp3f7ve6N1FqXtz+1EzyKNRy7GFif41nKI3
         nQoC9QQViIIaBRegMiHx06KhObDFDXWzNvmgR56X0UTpzB2kBNE2KFkzbQ9//Alh90Yc
         O4RA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=EialagdAgnBtYjzH6H0eO9CyoHJZ48U2U5aIVIJeUoo=;
        b=c7EhVgPTdnBlolTR3ewRPKEpvp5MBe7e6xMgU//HyLowLnS/ea7HdWuOhOmTWMyPCs
         yrXwwn2E7YMEzdLAmYukE/9PZ4fNJRYgZx9cLvh/8Tu4NeumE0cCad3l8ExNmUCf2bXj
         E8D1aKUtzzuaVwMsFkcLnaoY121dahP2U0iUY09FvbNEW9Sd3RKzVPWAl9hhptCsf2m+
         jkZf15H/zJ/WAoPykW+j200gYbI2/XlB4EdW3loDPo2MMoLsfVq4r2nRmkA6RqH3Pz4I
         dbMs6Co2XOs8EhKrGoXXY1kmTDB8K1HwpgPJvuDkw3PTOgPBPX4dKcKsCz995OztwGRg
         j51w==
X-Gm-Message-State: APjAAAVfrPaIDqpgv662+svQgGXO6cN3/06inRfkmgqFo8ECBJV2vH1f
	s5/UVKagyDBTtXEBjOT4G/HfPA==
X-Google-Smtp-Source: APXvYqzTjEDUFcepnEf1WEiRSh5mor0Y5ZzBDG+MemPieFRR8sXBVkJz4+O2iILrDrCaJ4x8THmZFQ==
X-Received: by 2002:a6b:3943:: with SMTP id g64mr24044809ioa.225.1566919391746;
        Tue, 27 Aug 2019 08:23:11 -0700 (PDT)
Received: from [192.168.1.50] ([65.144.74.34])
        by smtp.gmail.com with ESMTPSA id u24sm13275659iot.38.2019.08.27.08.23.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Aug 2019 08:23:10 -0700 (PDT)
Subject: Re: [PATCHSET v3] writeback, memcg: Implement foreign inode flushing
To: Tejun Heo <tj@kernel.org>, jack@suse.cz, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org,
 linux-kernel@vger.kernel.org, kernel-team@fb.com, guro@fb.com,
 akpm@linux-foundation.org
References: <20190826160656.870307-1-tj@kernel.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <15a5a6e8-90bf-726b-f68c-db91f1afc651@kernel.dk>
Date: Tue, 27 Aug 2019 09:23:09 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190826160656.870307-1-tj@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/26/19 10:06 AM, Tejun Heo wrote:
> Hello,
> 
> Changes from v1[1]:
> 
> * More comments explaining the parameters.
> 
> * 0003-writeback-Separate-out-wb_get_lookup-from-wb_get_create.patch
>    added and avoid spuriously creating missing wbs for foreign
>    flushing.
> 
> Changes from v2[2]:
> 
> * Added livelock avoidance and applied other smaller changes suggested
>    by Jan.
> 
> There's an inherent mismatch between memcg and writeback.  The former
> trackes ownership per-page while the latter per-inode.  This was a
> deliberate design decision because honoring per-page ownership in the
> writeback path is complicated, may lead to higher CPU and IO overheads
> and deemed unnecessary given that write-sharing an inode across
> different cgroups isn't a common use-case.
> 
> Combined with inode majority-writer ownership switching, this works
> well enough in most cases but there are some pathological cases.  For
> example, let's say there are two cgroups A and B which keep writing to
> different but confined parts of the same inode.  B owns the inode and
> A's memory is limited far below B's.  A's dirty ratio can rise enough
> to trigger balance_dirty_pages() sleeps but B's can be low enough to
> avoid triggering background writeback.  A will be slowed down without
> a way to make writeback of the dirty pages happen.
> 
> This patchset implements foreign dirty recording and foreign mechanism
> so that when a memcg encounters a condition as above it can trigger
> flushes on bdi_writebacks which can clean its pages.  Please see the
> last patch for more details.
> 
> This patchset contains the following four patches.
> 
>   0001-writeback-Generalize-and-expose-wb_completion.patch
>   0002-bdi-Add-bdi-id.patch
>   0003-writeback-Separate-out-wb_get_lookup-from-wb_get_create.patch
>   0004-writeback-memcg-Implement-cgroup_writeback_by_id.patch
>   0005-writeback-memcg-Implement-foreign-dirty-flushing.patch
> 
> 0001-0004 are prep patches which expose wb_completion and implement
> bdi->id and flushing by bdi and memcg IDs.
> 
> 0005 implements foreign inode flushing.
> 
> Thanks.  diffstat follows.
> 
>   fs/fs-writeback.c                |  130 ++++++++++++++++++++++++++++---------
>   include/linux/backing-dev-defs.h |   23 ++++++
>   include/linux/backing-dev.h      |    5 +
>   include/linux/memcontrol.h       |   39 +++++++++++
>   include/linux/writeback.h        |    2
>   mm/backing-dev.c                 |  120 +++++++++++++++++++++++++++++-----
>   mm/memcontrol.c                  |  134 +++++++++++++++++++++++++++++++++++++++
>   mm/page-writeback.c              |    4 +
>   8 files changed, 404 insertions(+), 53 deletions(-)

Applied for 5.4, thanks Tejun.

-- 
Jens Axboe


