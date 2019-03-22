Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9226BC10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 11:16:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59DEA218A2
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 11:16:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59DEA218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1E2B6B0005; Fri, 22 Mar 2019 07:16:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECC916B0008; Fri, 22 Mar 2019 07:16:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE42F6B000A; Fri, 22 Mar 2019 07:16:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF1536B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 07:16:52 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x12so1964851qtk.2
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 04:16:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ep08GtGtwgFzxgtaVrL5TR9YPTyDrVwTgR43/DxOErA=;
        b=SPTRgRdcCExG19jmtlMcZ+WVtKf2UlJ5eQwamV2oS9Q/kNI6HVwVa9DIdjNnsvJYo6
         7Z3ubacljwlEYk9FAbVMpiTjyLVh9F7/gRmh3BnaoOf9870WFimcisZBn7DwMwKLX62L
         sy/Bvz1p+TkJmXPd4mQ3BJdOtf948rxx2kVoiISN48799Np+Svu3kT0KzweAm5p0+JWP
         jpPDvCrgDyzmzw3bSGBYr/ESmHm2/+4IXUSo8aePlMJUP8XRXY3Kn3WDB1XiORWhz2bu
         BKUaCBepfEf8W3WMl3nRkfcAQlk1HKAiNNx/O88NVUINbvUTHkZr8jdOhSHKWj1yGX8R
         Ptyg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU4TuO5O96oaCC0neKH1Fa5LoeSHFYEmevmPVDaZ2YEZqMbFumC
	0MA/OtxKLaRiwxvh0deD3tEOevp7xVQJ3BI58gfvlsBpeqoMsADJhhm9027PS5UfySnJDFloSf7
	4+DHsqjSb+Dt+7jOf3AJfGE/BOB/zvpmU3H14BOtPiMOqfpi1CdcXsUDuwnX+A+GXJA==
X-Received: by 2002:a05:620a:144d:: with SMTP id i13mr1238352qkl.3.1553253412465;
        Fri, 22 Mar 2019 04:16:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz64pW8jbodR3MSwbhfQD8+Zcjct4/sBodxjkVi4sQyzBuIMhMLBqXC2DjEB7UCakN7bv6i
X-Received: by 2002:a05:620a:144d:: with SMTP id i13mr1238315qkl.3.1553253411784;
        Fri, 22 Mar 2019 04:16:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553253411; cv=none;
        d=google.com; s=arc-20160816;
        b=G4Q+TaR7OljZqZrR1ACTt0l6h8FlA+8kz9OSeu4QKahJUoYVdC6aQxLkJsW4Cu58Qr
         fGx+PoIlKjx56Axi4Od2nrxFr2X2aGjyTduyuaMzuam9f8lkpl4aC46xPIelTPgtUqDy
         OHvtXM5O0sv+ZZ6fTpnFYlW5Kb+8geo1qqVW8zKqH+by+0d8bI38rNP+9D8z2UAY359Z
         VRZjqLMmh+9s05odfzCD71k3KzWQVeBOmuzO8CgHfcnfAprkbbyroP4QLOlY55lKayl5
         v/zXq0qDzx0lt+s5b3HG2fQtxQjtjVUJNFBqw/+sj6IVSEilaZwC+WdXrTeCtrzUaFMu
         pa1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ep08GtGtwgFzxgtaVrL5TR9YPTyDrVwTgR43/DxOErA=;
        b=F/UcFArjYgcOqmAkp4Y930oEgezCzk23zo3sDPO0EGNstQCI+VjBce6k1Kll+io5Vw
         zjmCbpJNdoPgA9gbNV0SMgkRXT3GhlwKyGuLqbsqRKVOcpCkr8wVP4wkLURhQvi5gb1o
         YY5d9JUSSXuSEpyWLI/3Hq1CVkciQmpNzj9EshD1cceR5uwxxtsfb3JZa4vIb88VbI/F
         hIZ5kHsIGvmCqmYlx8uMeupE6Q1GaI9cbbLgPsWrOdclZodm0YG5unM8NCwlY1OeRz1c
         e/f/coAIqw/v2t23tXYfKmpAVFmaBpbKBZhk2xzrZqlL3Egn3LAukbE739GqAU/+0leh
         LS6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p67si4618041qkd.272.2019.03.22.04.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 04:16:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BEC5B3083363;
	Fri, 22 Mar 2019 11:16:50 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.32])
	by smtp.corp.redhat.com (Postfix) with SMTP id 41AA71A914;
	Fri, 22 Mar 2019 11:16:45 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Fri, 22 Mar 2019 12:16:48 +0100 (CET)
Date: Fri, 22 Mar 2019 12:16:42 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Waiman Long <longman@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
Message-ID: <20190322111642.GA28876@redhat.com>
References: <20190321214512.11524-1-longman@redhat.com>
 <20190321214512.11524-3-longman@redhat.com>
 <20190322015208.GD19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322015208.GD19508@bombadil.infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Fri, 22 Mar 2019 11:16:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/21, Matthew Wilcox wrote:
>
> On Thu, Mar 21, 2019 at 05:45:10PM -0400, Waiman Long wrote:
>
> > To avoid this dire condition and reduce lock hold time of tasklist_lock,
> > flush_sigqueue() is modified to pass in a freeing queue pointer so that
> > the actual freeing of memory objects can be deferred until after the
> > tasklist_lock is released and irq re-enabled.
>
> I think this is a really bad solution.  It looks kind of generic,
> but isn't.  It's terribly inefficient, and all it's really doing is
> deferring the debugging code until we've re-enabled interrupts.

Agreed.

> We'd be much better off just having a list_head in the caller
> and list_splice() the queue->list onto that caller.  Then call
> __sigqueue_free() for each signal on the queue.

This won't work, note the comment which explains the race with sigqueue_free().

Let me think about it... at least we can do something like

	close_the_race_with_sigqueue_free(struct sigpending *queue)
	{
		struct sigqueue *q, *t;

		list_for_each_entry_safe(q, t, ...) {
			if (q->flags & SIGQUEUE_PREALLOC)
				list_del_init(&q->list);
	}

called with ->siglock held, tasklist_lock is not needed.

After that flush_sigqueue() can be called lockless in release_task() release_task.

I'll try to make the patch tomorrow.

Oleg.

