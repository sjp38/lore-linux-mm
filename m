Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06B5BC5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:06:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CE2E218FD
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:06:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2Yz+9eRy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CE2E218FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F02976B0003; Tue,  2 Jul 2019 18:06:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB28F8E0003; Tue,  2 Jul 2019 18:06:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA2628E0001; Tue,  2 Jul 2019 18:06:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B045D6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 18:06:18 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x13so218059pgk.23
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 15:06:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8LU/7rCLrmtvZBU8AB95Ua1hH10HOkilvSKL72/YHOo=;
        b=dMc+QK8Yu9HxuL5ZqCQ/Yb79GpdB9D7E18JJCHPp1e3S9zR4xKHqqf5Pd+RI8Dvei7
         Upq9klWoYGiG+2jr0qscmO3iyf3JDct/G2ITC0tE+YKZtCGc6Z4KuOuqHh/3aNGSj+6f
         djaOPKYqbwtRZDHCb1cQeGLxZV/l84Jjq1tltbZvwlAt+BumdNnN6ry3+4fN/8d6NaSX
         pPOIiQZuL+4rFXixu9gPwymKOrMAqpwDdnJ0KoXCdi11Y5qGt1wuvhy8AXTk+2NBy+CK
         KXEg6gDy2R3aA6N3iRcvPbTD6n6ImtfkFRVVx+cYDAHFeFfhS0XhJtEDxGShA5NxshJV
         NSFA==
X-Gm-Message-State: APjAAAUUif3r23vGQdQIjJzytxipYTfxDQu5BnZCOvVgdwadRbGR6t2y
	5I4dnT6DKbYr0rB8+RyTRzC+stuxd7S+ycNpWhhoMUQSjq71b4K9rgijriZTfdUixLw1/2guXq7
	pSDQSFleIhSwtYBhn8o8Knde7DPPOnFx7jMfGL3m5biScMJZ7yzd6YpBndGMYMEWBGA==
X-Received: by 2002:a63:790c:: with SMTP id u12mr14617875pgc.424.1562105178116;
        Tue, 02 Jul 2019 15:06:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3NlQVcPUwGo46XGsv6eS9wYOYjRGJHkrsuqbOZbn3JirA6Xh+FFdIhocmEKTtO2JlyZP9
X-Received: by 2002:a63:790c:: with SMTP id u12mr14617830pgc.424.1562105177356;
        Tue, 02 Jul 2019 15:06:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562105177; cv=none;
        d=google.com; s=arc-20160816;
        b=k2vs5DA16fZJyY9FVCM4AGia8k6KjVT9S45W5HziNKgC6T2iwIUX8yAQQN4by7jmep
         oR8I1XZUOlL7XzRPk799gzcgN2UCXBe/t/wNcd10w9NZ5IOdbMCPc4Q1xJ22JL+21tkn
         enR8wHSrBCZpbL9QrUIkLQJzdOD/wLzK2Ku5UKmCJqLAFK586RSZ3ygkxCBAVclsg6hv
         NbEmKeQenpV0puEDUxPDi+AlsfA3KFHTlFek/mIzwJoG6mOhl+Zux5ujz6lgj6T3A/fO
         50CJ8Hg3mF2+ybrz9fkgd6UGSJZEO6jxC8ddBJDq+tq1UdkyCS7awcFbbHFP/lg0ZJ8w
         +ICg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8LU/7rCLrmtvZBU8AB95Ua1hH10HOkilvSKL72/YHOo=;
        b=dZ+dJCYiODh6Ji71Bhhd4oc+j2GEOuyLE94rdZA/K85d7gwPO8iSPBYDEl35ekfW3d
         dfB/TTUVZpBg6Q5rTpyUt1+9gDLydy5XrIg11osZ26F7zi2JMa7fknxnu2NBs9LIGSNQ
         85JVmOMPEi9H0iBSNxTshs6Muy6i+1CAEh4iP4vQSmIRTTxAc0UnitxBfB0dbGWw7Z5Q
         sW3mTyj/x6i0RGdJWwGuGynA34jpJzldRAiTsdhgEqc7BcGSKF+ekzmoQZADSjhlfAbA
         nErFm1nNw9ripWtTJ96kxtpiOk3n7UCkrLoGyLb1+fVHukX6g7DVnwa2HYk2xz4+RzAW
         Gr6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2Yz+9eRy;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j4si60617pgh.209.2019.07.02.15.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 15:06:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2Yz+9eRy;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 38662218EA;
	Tue,  2 Jul 2019 22:06:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562105176;
	bh=hVh0DP1hDzK9QjloJIO8tuHaop71NPGQzlf192YHV08=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=2Yz+9eRy1/q9tDqMxLekJDOLDaMWutxNFfTn2WV7xifEmMRAIIRiecyoCkbX/Nva/
	 Q38IpeHfCxE1sIhNQWjbuPDfPM4mQH9Ku6M/Ou2v255ShPbmo6EN5UUKyVjY8WzN9G
	 zMqBtv0/5P14Fdaxs0zMCFWI9YM1aSM/LHCl9GRQ=
Date: Tue, 2 Jul 2019 15:06:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Peter
 Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>, hch@lst.de,
 gkohli@codeaurora.org, mingo@redhat.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-Id: <20190702150615.1dfbbc2345c1c8f4d2a235c0@linux-foundation.org>
In-Reply-To: <97d2f5cc-fe98-f28e-86ce-6fbdeb8b67bd@kernel.dk>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
	<20190530080358.GG2623@hirez.programming.kicks-ass.net>
	<82e88482-1b53-9423-baad-484312957e48@kernel.dk>
	<20190603123705.GB3419@hirez.programming.kicks-ass.net>
	<ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
	<alpine.LSU.2.11.1906301542410.1105@eggly.anvils>
	<97d2f5cc-fe98-f28e-86ce-6fbdeb8b67bd@kernel.dk>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Jul 2019 08:22:32 -0600 Jens Axboe <axboe@kernel.dk> wrote:

> Andrew, can you queue Oleg's patch for 5.2? You can also add my:
> 
> Reviewed-by: Jens Axboe <axboe@kernel.dk>

Sure.  Although things are a bit of a mess.  Oleg, can we please have a
clean resend with signoffs and acks, etc?

