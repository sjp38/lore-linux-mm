Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9231BC4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 20:08:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5343B2171F
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 20:08:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TSdkOPQ3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5343B2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D883C6B0008; Tue, 17 Sep 2019 16:08:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5FD36B000A; Tue, 17 Sep 2019 16:08:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C76596B000C; Tue, 17 Sep 2019 16:08:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0226.hostedemail.com [216.40.44.226])
	by kanga.kvack.org (Postfix) with ESMTP id A52EA6B0008
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 16:08:38 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 44196181AC9AE
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 20:08:38 +0000 (UTC)
X-FDA: 75945500316.04.cook76_8590b883d251a
X-HE-Tag: cook76_8590b883d251a
X-Filterd-Recvd-Size: 4322
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 20:08:37 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id q7so2779155pfh.8
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 13:08:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=3rykt/1KJ5ehZkESnXZf1dXhmnmIju1zBiNgI4nTTZY=;
        b=TSdkOPQ3dnS7XsEBM4T8FLGSJbblBcQ8CqeHpDRJRWz6kGM9Y/BwnlNO5Cnbeqz5kr
         mhDWfTq/aVmkEiyNfxDKdk/EFBPhLuI3Yw3H/t/AvVYIcfNULTN1DlX3YV5a2mxQOz9g
         AzAnfV3SBZx4x93pTefjHnmpefg8ZIBHmgiLEJMArI8P3rGC0XMlPj3iaQEyZ66SibQH
         hlDls4klP/AOVVUD0VH3q/Ovn0EgyXG7F2CuT0JnAr1iylPEfFyo0LwW8vxbXDKLwXKW
         hN3XLeKaAOUQvQScru+RI1YpJNtFzOSDEPZ+HkIN0in29GnIRKwT1ldIHrFR8Tjf6VGT
         XSPQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=3rykt/1KJ5ehZkESnXZf1dXhmnmIju1zBiNgI4nTTZY=;
        b=GC5zsWA97t0YEZEjVyHGXv/VJeuEk2F1c404pvzNBnEypSYyW1K30PUXZ5h2eEvd3c
         quvUmbHObsjR1gN4Qngp6Y3MoxsN+6Ds4Tl6TepAjMhajCwhl5b46a4M6z5pg1YMUf2b
         gxLvHHtAo+xLByN9DjGJHZOJ50GnyeqA+x+pmjxng5aEGbwVQGaT8Q3jcTfRwcdc7Jii
         JL7Z4Nmd7RdjKgxzxOSu3zWdJzxjwdDQQT0hZo3MJ4MOYUnXe6wS5ny8o5BzGdO31UTa
         iPqGHQrUQFdN0JxO6rDncl/pV58KJq+LTeBdgVaw1QX8hijW3ttg1jT7TUqXLE5j/dnx
         UpMA==
X-Gm-Message-State: APjAAAWEpevkOi0K6tvogKgKUaChwgUkuSmLQLNw+BKmQaZfMZeHsdnR
	0B2n8Mk1hX4AbtuYJoPtkSBjVA==
X-Google-Smtp-Source: APXvYqw0iQ01weHB0V+XE0PsNIiJpkwp5Eu2QPcBhYaQn2v9FppqNME4WfMGjuvWDaoJGBtZ8ksTng==
X-Received: by 2002:a17:90a:154f:: with SMTP id y15mr6896302pja.73.1568750916333;
        Tue, 17 Sep 2019 13:08:36 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id w187sm2875155pgw.88.2019.09.17.13.08.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Sep 2019 13:08:35 -0700 (PDT)
Date: Tue, 17 Sep 2019 13:08:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Qian Cai <cai@lca.pw>
cc: Pengfei Li <lpf.vector@gmail.com>, cl@linux.com, penberg@kernel.org, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] mm/slub: remove left-over debugging code
In-Reply-To: <1568727601.5576.160.camel@lca.pw>
Message-ID: <alpine.DEB.2.21.1909171305260.161860@chino.kir.corp.google.com>
References: <1568650294-8579-1-git-send-email-cai@lca.pw> <alpine.DEB.2.21.1909161128480.105847@chino.kir.corp.google.com> <1568727601.5576.160.camel@lca.pw>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000050, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Sep 2019, Qian Cai wrote:

> > The cmpxchg failures could likely be more generalized beyond SLUB since 
> > there will be other dependencies in the kernel than just this allocator.
> 
> OK, SLUB_RESILIENCY_TEST is fine to keep around and maybe be turned into a
> Kconfig option to make it more visible.
> 
> Is it fine to remove SLUB_DEBUG_CMPXCHG? If somebody later want to generalize it
> beyond SLUB, he/she can always find the old code somewhere anyway.
> 

Beyond the fact that your patch doesn't compile, slub is the most notable 
(only?) user of double cmpxchg in the kernel so generalizing it would only 
serve to add more indirection at the moment.  If/when it becomes more 
widely used, we can have a discussion about generalizing it so that we can 
detect failures even when SLUB is not used.

Note that the primary purpose of the option is to diagnose issues when the 
CMPXCHG_DOUBLE_FAIL is observed.  If we encounter that, we wouldn't have 
any diagnostic tools to look deeper without adding this code back.  So I 
don't think anything around cmpxchg failure notifications needs to be 
changed right now.

