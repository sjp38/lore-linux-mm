Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BEB6C46478
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:36:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D14C218AD
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:36:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D14C218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B19938E000C; Wed,  3 Jul 2019 13:36:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACADC8E0001; Wed,  3 Jul 2019 13:36:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BA278E000C; Wed,  3 Jul 2019 13:36:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79F018E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 13:36:08 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id t19so1709720qtp.23
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 10:36:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=v3o2J2mBzvZ4QH8AbUS/eqHi+Nl0ZZgQOQwAS1EfJp4=;
        b=Zv4IkVUz93Oe86+oeAWELA+2m67gJMaYt7tKrDeXgVjyBdRMVbdnqIYcE3IIxGBxyi
         hSZ1GqJOGpKHordU8fLk29kknwE14L2rZud1fH/FKblvHsymkyALymmDwkgFgiUput7G
         VNuiEcq5cQKsz4L/1SzEQHNvzaKA4UEAvUlzLpH2Cc5K4MrhVrO5hg27ONmgc1ImW/DI
         afteb6ZWCImS7GvxrSRS+WA+EnZAVw9pfj2C4fw1V3xPbsADXoPyARRZyyMRVB5XZCrv
         /1pDXRmeA6nyOVeE8eNz9N8e2Yc+k3n+eorOpX5h652NT2DyucWNE9CFbSCSMvgRxHdH
         KX/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUPVLVDzJBr48PxTz+azBdQVdXnLxvg/RSw6GuHZcB7jNLSZsJj
	R7hce1B7cykzPXm3dDGnTrpo07wpoJmPLeh9gHaeWjCOqYJJuA6d5ZQPN5X8cSE7AYP2/rLyF2a
	uaerigV+hIsO66OA68+rteilkHy5ZN4THoRtDlsd8ryniFPo0FhFuOOwznaPGV3eDGg==
X-Received: by 2002:ac8:2774:: with SMTP id h49mr30492759qth.97.1562175368316;
        Wed, 03 Jul 2019 10:36:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZza6q3D8wrVNyXvdJ7Ad2f03AuWj1kta4gSunoYQu6AGiEC1+6101mEFCEz4CEjokYDSC
X-Received: by 2002:ac8:2774:: with SMTP id h49mr30492732qth.97.1562175367755;
        Wed, 03 Jul 2019 10:36:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562175367; cv=none;
        d=google.com; s=arc-20160816;
        b=O8K7a+5ltQDvSdrtv5/VQTfmKp0pNSLODJvW3wbk/chUwaD57k7f2kPjmx4HQsr6y/
         kbgdcFlwibsxm3nsV2p8fczSinqBhhjekYlc91zSdStQCzVZpAyLQH7dugXogqkSyP6F
         zizVF6RPPGRYrKPe5xA4UXeZpzDhOjU1E8KaJuJk4pHItL6LubttC4+33mL2goyoGVyk
         C725Mil1bxS155AjHLMeodMbZlrXZBUBQNEiyXJjIlRKA0aw3wIlxJ4c41ozHzBi6qED
         xvEpDrnqVffxiyMZCpMoGT/NxqWDTkDgxLvLhBlBcsLbT8Hb1s9bVJAQc+F+OO3wVGeG
         mb/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=v3o2J2mBzvZ4QH8AbUS/eqHi+Nl0ZZgQOQwAS1EfJp4=;
        b=DDwt8IiUf3cUcO/6CJZcGA6B83F8gaE/IcZRPBr0o/OHUcnOF6ERKgH6nIeMKQN4iR
         sfyyTa72pQBF5ZIGfZBwLlw4xeXrlB4SKJRWLmgrrj+ttbip4rwKwJjjZqoiCeARgmAO
         +XOGns/VehXt1fS079ZkIBbTfUuGo/ORBg+WdhKvGCvSVb/Oh06+OrlX1UV5sie1kjPi
         1HjMlKj92QfVBTEIO37NdMLAWD8ru8cMnRI3GSOei5Bmeg2iWjjt5uS4VkqPnZM/3Uo5
         7mSEKJ/fo3r5MPgB3LpEnFtr8z3aCoSkeGzWGxfgnKZ6Y2NKZQ/h45AvGjRA/l0tuTa7
         oqpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t54si2261591qth.352.2019.07.03.10.36.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 10:36:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 838887FDCA;
	Wed,  3 Jul 2019 17:35:52 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 8F1EC1001B35;
	Wed,  3 Jul 2019 17:35:47 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed,  3 Jul 2019 19:35:52 +0200 (CEST)
Date: Wed, 3 Jul 2019 19:35:47 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <axboe@kernel.dk>, Hugh Dickins <hughd@google.com>,
	Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
	hch@lst.de, gkohli@codeaurora.org, mingo@redhat.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190703173546.GB21672@redhat.com>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
 <alpine.LSU.2.11.1906301542410.1105@eggly.anvils>
 <97d2f5cc-fe98-f28e-86ce-6fbdeb8b67bd@kernel.dk>
 <20190702150615.1dfbbc2345c1c8f4d2a235c0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190702150615.1dfbbc2345c1c8f4d2a235c0@linux-foundation.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 03 Jul 2019 17:36:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/02, Andrew Morton wrote:

> On Mon, 1 Jul 2019 08:22:32 -0600 Jens Axboe <axboe@kernel.dk> wrote:
> 
> > Andrew, can you queue Oleg's patch for 5.2? You can also add my:
> > 
> > Reviewed-by: Jens Axboe <axboe@kernel.dk>
> 
> Sure.  Although things are a bit of a mess.  Oleg, can we please have a
> clean resend with signoffs and acks, etc?

OK, will do tomorrow. This cleanup can be improved, we can avoid get/put_task_struct
altogether, but need to recheck.

Oleg.

