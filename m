Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45537C10F07
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 09:43:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2336A222F0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 09:37:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2336A222F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2DBA8E0002; Fri, 15 Feb 2019 04:37:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DBCA8E0001; Fri, 15 Feb 2019 04:37:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F2088E0002; Fri, 15 Feb 2019 04:37:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 376178E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 04:37:52 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so3721966edi.0
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 01:37:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XSRpsJKR7v44qgM2zYLAcCI2deG7k8pMSF+E09YP9yI=;
        b=V+Z7NChopWAK2PvsvqD/IbkTj8MtXdKV5JlbnhU9RSaAeac3RO4xJzjmC8DneFZ+Je
         qJPVRo9/oAoXADf/vO/MJYd6tMVRkqFBm5QF1bE1K1MkjL+/IAME7Sq3peSvE4RylPfS
         l04zqtK6vm4qNDJGdSgb833xe71zSm60SMuQ7E7x080Da1Wba+7X2vXBZ5OUGXac+FOq
         P7m186rS34pzh/gMoNM+vcNX1P9h0jAUtxJvbYl54YJe7UixUtd/QuhjUW5LEI9bFBMi
         2oflazrzpJHUAFNSglRN6NFZvuyGiaOtye4gMEA8C+hqo9cUEXDsTlFOU+pWyBfDmxi3
         NsyA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubpLAB0vKFLpsCnftNAMc9PRpUPjXlIar9xF9MG7RQF/VWEIona
	oI0gjf/mgDBKw5C8JExvthcqmUSFJjjOctww2fOU/w+g2g3fFtyzFWPeGLC4359xHod4BCNWoCV
	9GIDznRn6do2QX2VENuiQBBzPTBBGBWsWvmSJw66i1vunZ2bxNtGASRxDPa2jpSg=
X-Received: by 2002:a17:906:13da:: with SMTP id g26mr5919926ejc.114.1550223471737;
        Fri, 15 Feb 2019 01:37:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib4K4N4m6/BkZW+ImIXzTRr/5NajW852ZOEYRXhAAZqbnTAIYxmX8RhJikQFRcOqN0UQS3Q
X-Received: by 2002:a17:906:13da:: with SMTP id g26mr5919882ejc.114.1550223470708;
        Fri, 15 Feb 2019 01:37:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550223470; cv=none;
        d=google.com; s=arc-20160816;
        b=SRzPThmtnJCjd4Jj4hJipJaBDmjOBQGwZY9VnXchH1PylqpfDenDoJ7I7baDPnmDL0
         q33w/yPxDmVMsmdhpYAS/273dVaoIehyOu4JSTBWYnm4vXdk+Yu1bY86nF38nnPuRZD7
         lrTDTlRG/oBvrYwWFhjP4Ew0vwwnCcNIgQVMw76n6QE2Jdzd/YQOAzibEYMByCEA8LlG
         RyInnN9TbHVuJ2TOi74W8BnMvZpPDE8Hr8+XDJVq67wRm6FsmheTgQwWxR3+sA57+pUr
         5nnIhTwmBbWLbPkhfsUBAkxZNxYGCn/tEOdL/t3njXG6buMIJGGCGxMmfHINK3c0Loye
         Ld4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XSRpsJKR7v44qgM2zYLAcCI2deG7k8pMSF+E09YP9yI=;
        b=nx6tTDBEefzR/D5wcGg5KVpKSzRurxiiU1U904sVH5KPQivERy6qa4Dp1aPCKDcPDc
         KhyeLtuRzo+CGPuF+Z+1A4voe5l3FBTmDzrL8SZnfpIvJ8lU3CJS5UJ8aVfC6rAL5g5X
         KhEhA7z7M3o+BetxQZGXm/7KQGa1WnDfhdlCBxImcoHm0VLuycow0Xu7bLGqRDChRtDv
         lTfS9XDlyKKfIcsLESUuzEzwLSUCHTjLD4idWzfrknkB3r+UNjj9BVyomYO3b6kb3kdK
         XeX4vy56vyR91F1kgrH2cwWtJPxmeAjAX0/PXnjWas10mALEa1mOpb7FQWjV2HXe91Tv
         8WbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x34si271309edb.147.2019.02.15.01.37.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 01:37:50 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 01C71AFBD;
	Fri, 15 Feb 2019 09:37:49 +0000 (UTC)
Date: Fri, 15 Feb 2019 10:37:48 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] proc, oom: do not report alien mms when setting
 oom_score_adj
Message-ID: <20190215093748.GV4525@dhcp22.suse.cz>
References: <201902130124.x1D1OGg3070046@www262.sakura.ne.jp>
 <20190213114733.GB4525@dhcp22.suse.cz>
 <201902150057.x1F0vxHb076966@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201902150057.x1F0vxHb076966@www262.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 15-02-19 09:57:59, Tetsuo Handa wrote:
> Sigh, you are again misunderstanding...
> 
> I'm not opposing to forbid CLONE_VM without CLONE_SIGHAND threading model.

We cannot do that unfortunatelly. This is a long term allowed threading
model and somebody might depend on it.

> I'm asserting that we had better revert the iteration for now, even if we will
> strive towards forbidding CLONE_VM without CLONE_SIGHAND threading model.
> 
> You say "And that is a correctness issue." but your patch is broken because
> your patch does not close the race.

Removing the printk as done in this patch has hardly anything to do with
race conditions and it is not advertised to close any either. So please
stop being off topic again.

> Since nobody seems to be using CLONE_VM
> without CLONE_SIGHAND threading, we can both avoid hungtask problem and close
> the race by eliminating this broken iteration. We don't need to worry about
> "This could easily lead to breaking the OOM_SCORE_ADJ_MIN protection." case
> because setting OOM_SCORE_ADJ_MIN needs administrator's privilege.

This is simply wrong. We have to care about the OOM_SCORE_ADJ_MIN
especially because it is the _admin's_ decision to hide a task from the
OOM killer.

> And it is
> YOUR PATCH that still allows leading to breaking the OOM_SCORE_ADJ_MIN
> protection. My patch is more simpler and accurate than your patch.

Please stop this already. Your patch to revert the oom_score_adj
consistency is simply broken. Full stop. I have already outlined how to
do that properly. If you do care really, go and try to play with that
idea. I can be convinced there are holes in that approach and can
discuss further solutions but trying to propose a broken approach again
and again is just wasting time.
-- 
Michal Hocko
SUSE Labs

