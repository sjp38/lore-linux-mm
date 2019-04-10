Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0121FC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:07:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B231221971
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:07:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B231221971
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 356DA6B0289; Wed, 10 Apr 2019 07:07:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DDE06B028A; Wed, 10 Apr 2019 07:07:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17D1E6B028B; Wed, 10 Apr 2019 07:07:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id B8ABB6B0289
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:07:39 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t16so1259317wmi.5
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:07:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=GM8pouCWb8dl0P5mgzAxyQWZ7NjtNOadyAII46HDyMY=;
        b=mkn8nBEIdy4+gyxVSRAF+IcuAqW4JeB2Buy7GzPhOtbeDk2D/j7e8qyJqirfjoVh5e
         7WtINbs1/ksxPcIiwt9ovZNhHpfLTEm9KfOLGMSO3oBhdsY314QVBuXbce3xntoh/X56
         DqzHwGkIMd2qhBj731uhDnTyI1a/rOoFMCrHJCGMf3IuvRrEETdjPA90AJSUvfFS37oA
         fQYIxYUDXNUSUG5USTFMndA4uTxLGzueMmVU2JPIfbHyANfztbxO9pPd0EZO/KmhMyco
         lDbh+NJokiUf6BVvgS9FVuHaZi7+JIiKqVJZb3VoQLe934J3xMlqKCku9SWPwbiov2lL
         mP5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: APjAAAWci3tfx9DjYhUxvWEgSIqbj0VwPZe5fS6gP/uXbk0FySMyqtHr
	zHzMo2OMSQ3uJRyWhFr+RMEUgW/V+JN+585WLsCl30vSgd7J+YwJooYb3jEfTFGFQuHh4GQiPi0
	sOHPZx8MTIzmv1pt3VqeLXpCTzD3tXWCw5q3LdKx94gsEQNADM4nYMhVg0OwWFnzU4A==
X-Received: by 2002:adf:db0c:: with SMTP id s12mr26825753wri.184.1554894459289;
        Wed, 10 Apr 2019 04:07:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOBqMeGWzz8KMEekTBDOozlYOq+glBzvUXI7WjlEb9YVK4u/OlonTMrA6hY5u/lxKR//oE
X-Received: by 2002:adf:db0c:: with SMTP id s12mr26825713wri.184.1554894458605;
        Wed, 10 Apr 2019 04:07:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554894458; cv=none;
        d=google.com; s=arc-20160816;
        b=BbtDRBHN91oW5IvxuRuuPxEVNAbNNZRLTxAlCmABY1t3p3cLh1mp61486PekPOKr/N
         4WCYXVPkmlk+0I6yhC2drykoepeu+Ke2JP+KafsfMGwHvRcMuUvqq2UXk5F9XtNhd5cY
         lI3MNCsGZTROabtpuBztwY3QXQPpCYOGurKbf7bSDN9BAJ2b1xN40DKJHj4ybsJVaJbF
         P/MDBWGC5mwSz87W3cVvdXUoTuyNzwT9tdWpDKAhmBkw7dnKOIFv5Ep11+6t+ypvYYcg
         zGs7rizVKruIE0/Xali9f3oj+a8SM6ABTiACVZF8uo5rIyqGd6evZP/AL72bD9MAMGAL
         I+5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=GM8pouCWb8dl0P5mgzAxyQWZ7NjtNOadyAII46HDyMY=;
        b=pxd0J29zP8dELMPbWg7fP9Lewov5y1lxhPzdoj3SPfGRb2tWyBaOV0iYnuTO3RLPjm
         SlvVy6gibXCgAa1fKA5gDE1VrJ1B5yttmKdM4GzIit4UhPLjESKmVY0g8qYpv+ogM6LK
         mrhn3RlFPK3N90CX5Gtz4Mcn2tAaDMDqzXhPY8rwr618WHM1XbsGGZr0vhzVdhUu2rqR
         c7IlgaaX1YlTrJhygWCpjMaHNqxwjlf069cf8dj2ORSqrSIQo7ILNpWTWbkMlF0rVRlI
         kHkD5eqXNGMDTrFahJCSszplA3mC/jyPJy6tNblXaDIPuPiZ2c+d6nKcba/oNoxo7yc/
         KP0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id a187si1230269wmh.176.2019.04.10.04.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 04:07:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) client-ip=192.134.164.104;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.60,332,1549926000"; 
   d="scan'208";a="302419625"
Received: from unknown (HELO [193.50.110.222]) ([193.50.110.222])
  by mail3-relais-sop.national.inria.fr with ESMTP/TLS/AES128-SHA; 10 Apr 2019 13:07:37 +0200
Subject: Re: [PATCH] hmat: Register attributes for memory hot add
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
 linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Dan Williams <dan.j.williams@intel.com>
References: <20190409214415.3722-1-keith.busch@intel.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <30db4768-5dc8-d493-1bac-03f382e867e4@inria.fr>
Date: Wed, 10 Apr 2019 13:07:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190409214415.3722-1-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Keith, this solves my issue.

On a machine where node4 (PMEM) is close to node0 and node1 (1st socket
SNCs), hotplugging that node makes node0 and node1 appear as initiators
to node4 (and node4 as target to them). Same for the other socket. And
perf attributes look good.

Reported-and-tested-by: Brice Goglin <Brice.Goglin@inria.fr>

Just one minor typo below.


Le 09/04/2019 à 23:44, Keith Busch a écrit :
> Some types of memory nodes that HMAT describes may not be online at the
> time we initially parse their nodes' tables. If the node should be set
> to online later, as can happen when using PMEM as RAM after boot, the
> node's attributes will be missing their initiator links and performance.
>
> Regsiter a memory notifier callback and set the memory attributes when

Typo regsiter->register

thanks

Brice


