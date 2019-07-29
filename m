Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D21BAC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:03:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92AB22171F
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:03:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="e8QOlcrR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92AB22171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30C1C8E0003; Mon, 29 Jul 2019 11:03:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BC5B8E0002; Mon, 29 Jul 2019 11:03:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15D808E0003; Mon, 29 Jul 2019 11:03:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D513C8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:03:42 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o6so33282485plk.23
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:03:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/ETHf94MjVCsWoGJmgma/XCP9Q3AJ/2BeOPSWh2RAN0=;
        b=Ejo0+k0NfStdJDBG9SJNsDxeIitiJcFvX7EitJn5HpmtL8pwAOxxTJqyHz49I2BEYg
         H+ewgvlKpP7T3dyIZi3WNm8b+bkOUZHcWousWEJsg+VmRLP5i7R4V8FMIzKPEczpQzOX
         YD3khgFLbYKI2ngT9GJHAKao/Ls3ZHG+Xi2tH3LQOrcHoeFkdnkooNskWaUkY31ISi1y
         lrPp8UqtrSebKoVtqa2HKtjn4BAqVc4Lqi73Q/f7N/AXJSKbWH+mfso0x3HlMkDNAdp5
         /Gj6o8q1edQ+LUFGXcaiYdqN/MKGge+jMXYd1g1uLeecy864eNKR303kH8j9gjQsYNY0
         8oUQ==
X-Gm-Message-State: APjAAAWXmRd0ykYZZwoksyde0H+tq+dOVel7uNrNTy/yuhSmOfRneJnv
	whUtFS0Wt3rS+xWXpceq1F7FQm1mACM1slCyyXBujHOkQO3h7I6ApTySlkB6dolaQQFp8deeZaO
	1Uw259BuF5yh4SfyENZNRDj496mfXyglb8RRMchZ451L6eZeC1lAzcFMZgMeayJ8Yxw==
X-Received: by 2002:aa7:83ce:: with SMTP id j14mr2135256pfn.55.1564412622475;
        Mon, 29 Jul 2019 08:03:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMaD+ZN2bZvem7f4KXvKgs+voW4MC1HimqrR/TTewtHfQISgI3Lhoh0T0QtuZOSnMpJz+S
X-Received: by 2002:aa7:83ce:: with SMTP id j14mr2135178pfn.55.1564412621687;
        Mon, 29 Jul 2019 08:03:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564412621; cv=none;
        d=google.com; s=arc-20160816;
        b=QDUGtbEaTP37uukLCYAVuj9rzHACvrPMsks8OwrB1IAaORYz3G2T8UNe2ptYHUhyen
         xQLre5Wp4tZuRMEYPZpaxlH7UAcGeX5yoUV+t30Wamd7WuwRAi68bcnfz9EShYHb9CmO
         bpOEN2rQfpgNIK08PxRZKupVZ/+xBP0Dadrw+k25thXLUEGnGuOVxqBvWt+3ZjoCB+3b
         68hn6TvUGn2920NQiaanJvzbyk5Dd7fHw9aS+ZMcwDmuxQhofaq3KL81V0GfuCT79g5B
         rmtcTed3W2ZjaqSN5GZCZD10lyVlYxna/JKToSPIB7xgkNCL+PkRJcMKW9rJaiIjCXQJ
         CSgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/ETHf94MjVCsWoGJmgma/XCP9Q3AJ/2BeOPSWh2RAN0=;
        b=Nnt2A029b0YnbG1HTTOU6XpVQAOaUjmO/9sNq/B12LZhT0EUo8vQ1aovvMmM8nEmUX
         bUUBZrxRUY3JdResWTR9ceGcGoxgN0UPrtgQbFTYwMpvRqG4GZGPqK4IzoZmqPykOIoi
         ciVcI1IbnkRm8tT7udPD35io3/rkxp4yBpxeM87K9wU7fqJjGZrJ0rbplvTro8sMeifz
         a2WPr93gc1BILCwC8Ey7QeDrRTPnGokNfkOyYVbdaYDpbfGZGik9AITExsDGBVcGSi9K
         ZqeibhUL4UWSSI7NIHqGO/eT37BwZu5tbyIoXaFPMygMR3qtNKWo082NMgDmluKHtepc
         NY8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e8QOlcrR;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q100si26990922pja.87.2019.07.29.08.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 08:03:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e8QOlcrR;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/ETHf94MjVCsWoGJmgma/XCP9Q3AJ/2BeOPSWh2RAN0=; b=e8QOlcrR5gXbft+ShFMb4+YS4
	rBL0ALsF9M+9MNxs0Ya0+3kn28QWVH01B+T5M8QN9a4XxGOK4RtCQVjhEeVv/q2NUltmBov90qUlo
	SjXcHbwNkXLoDw/iBM5riNlGFNlsG2T/bHGkbD0ULfU6asner3o9yiBuA7R6bdKq6XhPw0heiEiuT
	6NkZ6uF9uU3e2E9eQQdCtyVCM6/BWmaCf6IdpECaYLr/0WshUQ3I2hYU1lGWaDvsdrASxE9CxDIVL
	1RqFDZwbdslIqQ6VdLf4h4o8N7tvACdOnaSJPmWMXAjn646Mq0/V+uJfRbGwcNxwfZKaAj6iz4CfO
	Uz3JqkB/g==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs7Bc-00052G-Ff; Mon, 29 Jul 2019 15:03:40 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E260F20AF2C00; Mon, 29 Jul 2019 17:03:38 +0200 (CEST)
Date: Mon, 29 Jul 2019 17:03:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>, Rik van Riel <riel@surriel.com>,
	Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190729150338.GF31398@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
 <4cd17c3a-428c-37a0-b3a2-04e6195a61d5@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4cd17c3a-428c-37a0-b3a2-04e6195a61d5@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 10:51:51AM -0400, Waiman Long wrote:
> On 7/29/19 4:52 AM, Peter Zijlstra wrote:
> > On Sat, Jul 27, 2019 at 01:10:47PM -0400, Waiman Long wrote:
> >> It was found that a dying mm_struct where the owning task has exited
> >> can stay on as active_mm of kernel threads as long as no other user
> >> tasks run on those CPUs that use it as active_mm. This prolongs the
> >> life time of dying mm holding up memory and other resources like swap
> >> space that cannot be freed.
> > Sure, but this has been so 'forever', why is it a problem now?
> 
> I ran into this probem when running a test program that keeps on
> allocating and touch memory and it eventually fails as the swap space is
> full. After the failure, I could not rerun the test program again
> because the swap space remained full. I finally track it down to the
> fact that the mm stayed on as active_mm of kernel threads. I have to
> make sure that all the idle cpus get a user task to run to bump the
> dying mm off the active_mm of those cpus, but this is just a workaround,
> not a solution to this problem.

The 'sad' part is that x86 already switches to init_mm on idle and we
only keep the active_mm around for 'stupid'.

Rik and Andy were working on getting that 'fixed' a while ago, not sure
where that went.

