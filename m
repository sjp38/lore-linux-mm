Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF7A6C0650E
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 11:26:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 907AA20989
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 11:26:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="tAKMZiRf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 907AA20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B0458E000B; Sat,  6 Jul 2019 07:26:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 160148E000A; Sat,  6 Jul 2019 07:26:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 076898E000B; Sat,  6 Jul 2019 07:26:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE8FB8E000A
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 07:26:19 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id i2so5031742wrp.12
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 04:26:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OM49BpAdnzvrpDwsLEkj6E8wRKIUTEsST/MpMEgc2Jc=;
        b=Iuo8dAJiTTMjaUl7KtbVDtpowK8DoSTP+9XqneVYMf7lmdUpVcI07wxeq52l4F467L
         poe1mB/hqICHM2IzBVj2/Bw+mid8vNmcX38U2pOvucf0b/B1zAcUkLXCh/LWXjDMzdPb
         hhEqF6EdeUjgaeyA1YnVNuC9bU7pO9alsXbfZK1VRqq9NXgoi3BHmzMeogxAcdQLoEu2
         dCU6d1PN4fMsFylErZz3tEDkFxnmKxoTNWD4pkyv/zpnkg+KKS/9V+gwZnyCZ13QwgaG
         fK4AiYIx0EAsZm6KYtbSzvn+UTPIdKc1BRk8I7WvdRdkwKRh4cvRZvc+QgTthE66A6RK
         ewcA==
X-Gm-Message-State: APjAAAUOOeN9u36ouHX9hMUDrbubJUjyCC1c6yeu3X+UlyoibRxAxN6q
	6v7RaEZo7ZXmrsFoP1GD8jiYHQmnjlwrjrde4ywGtQWsfp9RKOfA6f7BFP4l4h3j6pwVWPDEKMY
	LScLB/sQBdn84gSAekM+NxNyj171H4MKV3RJPHeZcHYclcrGx5xf0auJviRyBt+qyeA==
X-Received: by 2002:a7b:c251:: with SMTP id b17mr8209641wmj.143.1562412379176;
        Sat, 06 Jul 2019 04:26:19 -0700 (PDT)
X-Received: by 2002:a7b:c251:: with SMTP id b17mr8209580wmj.143.1562412378401;
        Sat, 06 Jul 2019 04:26:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562412378; cv=none;
        d=google.com; s=arc-20160816;
        b=DNS3p5LOZmFhg88Nlen6Qv+RqBIszPYK31tixHLLkkZs282f7cGTW8f4sVNiH3F+1S
         VLynsYIr9l1RpgZM7oNrADn/faB4E1hQSOIEfsz1BBVmMrdtEEVNfYHiOeF1wlzXhk8u
         2/AFAZ/x5OfZyEO4UJlMh/rZIJ7vg8ASo4+QJutpOJ1ofybU/bvw/nbQpCav0uhwD5Sr
         3UBxb0u6VCUluF6PLRg7tI8YbK8z7bawAzHhLv/i54lYqwnbcLHxbJ0hjXX08ScmKBbP
         tGWO5eGYDldnN6fq7ULv5YEtUjVdPJK+9GYTJXlDxFRiNdCzfVtJPyAkQyLKz6AOo/Is
         oXzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OM49BpAdnzvrpDwsLEkj6E8wRKIUTEsST/MpMEgc2Jc=;
        b=T5gSCF+QhRYdHYWP/EfS5ROhN2jG2uobnzepPB+bN2G/Z9nDhRWE0H9W6KNWk0wIUR
         Q5VEuYF5bOHz0p2kCt4ykCwTJ41rJY3vB9MUPoU6iNrxnQfDzL6TidgsyOTaCKEcV7O+
         qOI7guz/IK92A3/Co7qJD0Q+DQXR1UDvL9YLk0eJcyKOPbC35kRPJAqu4B67YN1DxG85
         QutkatMoF2El5nL9htqKBS6hrM8ykEJqS223N4UuhzmCg0rApSxmtlZ3kcbVunwUJs+V
         EBJF4l2exzFb484wjf6CBbf4ZWAM3+PQoz9msnXjgEkxc9lXrxPlTSRnLLMiPX3PWW65
         65Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=tAKMZiRf;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y127sor8624659wmd.1.2019.07.06.04.26.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 04:26:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=tAKMZiRf;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=OM49BpAdnzvrpDwsLEkj6E8wRKIUTEsST/MpMEgc2Jc=;
        b=tAKMZiRfwWQp/kay69XYGdCwDCqfLH0TrI/wVedRt+GsmZ+ILfOxq168JyrsF5snL2
         xukFIZ4bOA3qgF3BqeyEeFAySnREtioo3Q6UTKXYWLNjLyeGfz/rwXqmki7XdW1SmnxV
         W3MHFsiMUHek/x8Ux5Ycq2cZC/+tnkHjaO5Eg=
X-Google-Smtp-Source: APXvYqxjsq2xUCkUaCNFHghtwPdwf3b/8E45ZDom/BLRGstJS7F1QzoD5Z3AohrxnUt6TLQApcTLIQ==
X-Received: by 2002:a1c:dc07:: with SMTP id t7mr8225563wmg.164.1562412377886;
        Sat, 06 Jul 2019 04:26:17 -0700 (PDT)
Received: from localhost ([2a01:4b00:8432:8a00:56e1:adff:fe3f:49ed])
        by smtp.gmail.com with ESMTPSA id 91sm5502444wrp.3.2019.07.06.04.26.13
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 06 Jul 2019 04:26:16 -0700 (PDT)
Date: Sat, 6 Jul 2019 12:26:12 +0100
From: Chris Down <chris@chrisdown.name>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in
 cgroup v1
Message-ID: <20190706112612.GA20696@chrisdown.name>
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz>
 <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
 <20190705155239.GA18699@chrisdown.name>
 <CALOAHbBTwas6+rrYAO+OB9R74Ts94T17wojoyOe2+M0CqEbnLw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CALOAHbBTwas6+rrYAO+OB9R74Ts94T17wojoyOe2+M0CqEbnLw@mail.gmail.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000100, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yafang Shao writes:
>> While it may superficially work without it, I'm sceptical that simply adding
>> memory.low and memory.min to the v1 hierarchy is going to end up with
>> reasonable results under scrutiny, or a coherent system or API.
>
>I have finished some simple stress tests, and the result are fine.
>Would you pls give me some suggestion on how to test it if you think
>there may be some issues ?

My concerns are about introducing an API that requires propagation of control 
into an API that doesn't delineate between using values for *propagation* and 
using values for *consumption*, and this becomes significantly more important 
when we're talking about something that necessitates active propagation of 
values like memory.{low,min}. That's one reason why I bring up concerns related 
to the fact that v1 allows processes in intermediate cgroups.

So again, I'm not expecting that anything necessarily technically goes wrong 
(hence my comment at the beginning), just that it doesn't necessarily compose 
to a reasonable thing to have in v1. My concerns are almost strictly about 
exposing this as an interface in an API that doesn't have qualities that make 
the end result reasonable.

