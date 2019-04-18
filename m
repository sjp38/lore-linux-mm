Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 934F2C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:34:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 543B120652
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:34:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="ab1gt2ub"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 543B120652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9C496B0007; Thu, 18 Apr 2019 09:34:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4E066B0008; Thu, 18 Apr 2019 09:34:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3D156B000A; Thu, 18 Apr 2019 09:34:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B037A6B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:34:55 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g17so1997216qte.17
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:34:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=tGKbg7T4m2hja67VSnD+5sN45YQjy0gEHiOhoXRYwnE=;
        b=Qpt4Ce0TMBVydiV/UQSwD7GG0g/1RHnDJx7xhauogiIDhifmR8/q7uieLxTgodFr6B
         zJ5R6/yZbvtNQ6YAxQDg/ldeZ4SC4XkuWM8Qwd9KHq8xsQRfA2/IFo18Be37bmndK8bM
         AjkNg4uiEk6/io034VwW8xWdQJDiKdcXbt1qrAfftZDMgT+AOyYlvifDYYXRZQiJuzs3
         i9PhQ1vlRq6DwMsnODv+GOpYndEHfoLkgZbXyLFwcsnlG9PS87CI1Mkng3oSSkUNkXU8
         51dP17M8zM44f3SgfF/O8vsWlYahKGsvKYtPqno8CBBO3LGR950DPQbtlA2NaPu4GVtd
         NfQg==
X-Gm-Message-State: APjAAAXKQTpI6SBFdw42zZUYlBOGSKM4Q7csuEelrcVL58eRM8oyl5nh
	vi+f/PcrxPKf+dSQ8QCgBbn8DZsxqaJg5GOygEl9Zqumgt8LGD+o59LmgoZgP67hk+PMb8sDiK6
	fjl1RQZWMmoCpdE/Jh51/FmTCWcJtWByMfn50/wWpM1SLsttahmZU3IAYPkgYBZk=
X-Received: by 2002:a0c:9baa:: with SMTP id o42mr74312215qve.184.1555594495375;
        Thu, 18 Apr 2019 06:34:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkrl+YmiOPkhycavKLUCQ33xY5g0zWQo/hbqmHuYlnD30WsSmfIFXF/j4JG/avZ7UgzpSm
X-Received: by 2002:a0c:9baa:: with SMTP id o42mr74312054qve.184.1555594493641;
        Thu, 18 Apr 2019 06:34:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555594493; cv=none;
        d=google.com; s=arc-20160816;
        b=t8HfXq2rUInqnr2is0d/yND6eIOXmm3mxuMhi+Dyev5USG/Z4uJXa9wczVYa+OeF+3
         K7d/FE1RP8mDgIfF9915dW2LRtwv2+DqNH3qz27H0Dswp0QvWeqjn1++G+9N3CfL/yQs
         IU8fDs6mr93d+Q2CsMAzjFwhIJTV3tUh0CAbCJxr9Sy0mPEmLlDHMxS1vr6qbsQO1pBv
         vLz47fTrzYOCWXV5tA7t+kQwmgOVd03Ih7Cvh5zCk5jw0sVcoi2DfdahZzFIDnDrWs9q
         YeO87zr+WirUswH2EAOuuj87x7TNjNuq2mODpI8xYlYX8E574O4IFWB4ydkT8D8fNicz
         FbDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=tGKbg7T4m2hja67VSnD+5sN45YQjy0gEHiOhoXRYwnE=;
        b=vzq3RPbksFLXWt+KQ7LKxcM5kAdHQfTuNqgo9vOB5gOnpczFX7BE9MBR+ymPNHOpKj
         vMesc85hzV/cM8nMD0TIrppEqj6ggkseJ5aF/C77lLzhBh71l9qkdjDwvTjoMCbL9xVN
         RYpiLHYAatvTsF3WCLkSy8TPhKCOpyXBVkWnEFQKkn2kS/iQBQn7JJLdI63iXAWNv0Bf
         T96aGQmej62DC7RTu81pGyZZzaEg88H545/noyOCUKxz62w7bexrkcrJ6wT0P8aaQ8RX
         kLGdGge9MQASSTJ9EtOeAnEglspY19bm0cJRC/UjuASEckZaLiZkjTfo5k3RChkNgClx
         1oyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ab1gt2ub;
       spf=pass (google.com: domain of 0100016a30a83bcf-7f99039c-77ec-4c48-a1c4-92e398f8f185-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=0100016a30a83bcf-7f99039c-77ec-4c48-a1c4-92e398f8f185-000000@amazonses.com
Received: from a9-33.smtp-out.amazonses.com (a9-33.smtp-out.amazonses.com. [54.240.9.33])
        by mx.google.com with ESMTPS id h3si1216026qtr.376.2019.04.18.06.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 06:34:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a30a83bcf-7f99039c-77ec-4c48-a1c4-92e398f8f185-000000@amazonses.com designates 54.240.9.33 as permitted sender) client-ip=54.240.9.33;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ab1gt2ub;
       spf=pass (google.com: domain of 0100016a30a83bcf-7f99039c-77ec-4c48-a1c4-92e398f8f185-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=0100016a30a83bcf-7f99039c-77ec-4c48-a1c4-92e398f8f185-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1555594493;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=tGKbg7T4m2hja67VSnD+5sN45YQjy0gEHiOhoXRYwnE=;
	b=ab1gt2ubDBnvlERvCSi1ce9rbtCoG/YS77M3OGWWcVMUjDZG7kdCTAIh3pFVU73u
	JBYkidNGYMpwtlzEcOGCrYV7+GGxIkApxsJL4FIYB0Sro4vm00cQ7klrHZkK5gkWFTd
	+5z2ftsGtTwkIdbIkR74gay/PBi7mTjrZi0orids=
Date: Thu, 18 Apr 2019 13:34:52 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Roman Gushchin <guroan@gmail.com>
cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, kernel-team@fb.com, 
    Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
    Rik van Riel <riel@surriel.com>, david@fromorbit.com, 
    Pekka Enberg <penberg@kernel.org>, 
    Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, 
    Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 4/5] mm: rework non-root kmem_cache lifecycle
 management
In-Reply-To: <20190417215434.25897-5-guro@fb.com>
Message-ID: <0100016a30a83bcf-7f99039c-77ec-4c48-a1c4-92e398f8f185-000000@email.amazonses.com>
References: <20190417215434.25897-1-guro@fb.com> <20190417215434.25897-5-guro@fb.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.18-54.240.9.33
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Apr 2019, Roman Gushchin wrote:

> Let's make every page to hold a reference to the kmem_cache (we
> already have a stable pointer), and make kmem_caches to hold a single
> reference to the memory cgroup.

Ok you are freeing one word in the page struct that can be used for other
purposes now?

