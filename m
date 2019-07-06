Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E20FC5B578
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 22:45:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB6C620830
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 22:45:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="L2olCuuA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB6C620830
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46D546B0003; Sat,  6 Jul 2019 18:45:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F6B48E0003; Sat,  6 Jul 2019 18:45:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E5C98E0001; Sat,  6 Jul 2019 18:45:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E88E86B0003
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 18:45:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j12so33272pll.14
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 15:45:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=KZuwwpEDFFidTZvCB013aANFUOOg31tF9n5M77JSn6w=;
        b=l0X9G6W4o4RLdWcPRGrCqyZI/o6i57O87aeqweoe/cKcp8w/fWs1ZHuuc+Blv+YZzs
         gZtqxhCxtK/NDkwB+gccvraOC1esV0logczvDbc/TxL3lpjSqXDBZU97mJF9YbWH2hIY
         A7MPZMAnQqTo0YntIHsLd9mbvWm5ByJaw/pjgnxqwitQWYQROIAl7B8IYNQHTSm0aGTR
         0qx9SR/gqnD37Iu5as8G/u4nw6GLAnrbzUHnMdGTpP0wAcnnD4UHRIQxUlSQDxb6NKrR
         RWXW6sziKsWxxkRa//XUcsYNee6a5EF9XqX809hfkj3fscln8RBEncTnXn64mfoQP3q1
         wq4w==
X-Gm-Message-State: APjAAAXYq/xEuZ4Yu8EkI3TMGKeKcjOouLrnXy1qZ/xRDdvntfEBJBQq
	avsNJfwupDqOzaT1r6C8SH5L3hUBm6QGVmALUBaS7deIjNTAYOdB5JDJ84Jtn/YBG5Q4gR/F7GD
	xTKqH/+gk2d/r7H+1nGEaxeuBmyABFdVClVhJuReD4Cq8zZZ3HU7FiMhuJM+LTG5lUQ==
X-Received: by 2002:a63:6b0a:: with SMTP id g10mr12855513pgc.295.1562453113373;
        Sat, 06 Jul 2019 15:45:13 -0700 (PDT)
X-Received: by 2002:a63:6b0a:: with SMTP id g10mr12855457pgc.295.1562453112443;
        Sat, 06 Jul 2019 15:45:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562453112; cv=none;
        d=google.com; s=arc-20160816;
        b=ZRjPEwCj5wyWatBLh+6iajzszF15Egfv+HIC1SDuNoUXGNFue/jKxpgpUc2eR8Woe+
         ZWqDXBAyxOc+Bub8zojAwtqIyj0RhtA0lcuMO7rdIycTn5Z7peLK/xTcURKRrFwOK9y1
         GXuGOqoaS6G5lFWAGbkoO3fhBHq3fbaGYvi4YrQ3+pJTGQezAUIVseaOaCmeRphA+y6D
         8BiPbg1HETRLVrSgPXPoqO9J5QAeGqwvgbiYhu9QJfvZLrqGxHdwMS4pI/Tq5N+G+3Hx
         mu5dBksL3fxqpnP1mOUq3s3ncIphL18kDHFnDdwLN0wqyDV5nYxnGrtjDdGAy+HPx4dy
         x/og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=KZuwwpEDFFidTZvCB013aANFUOOg31tF9n5M77JSn6w=;
        b=h4qmLU2jfmKgOHfnocrZcnFuG4stN14XKKZek8/efi6ZwQ5v6sSBhE2+x7oxyLD9X5
         byC1p0KlNqGvLAnZg+g1V+7hnHUUC1w1iZ06nY43X2HC99vAs7S9ugO94/ISDrenPSVb
         UGya5Ti2JPY21o9y8368xWsp5xpjBLLlz9YP97yNmHlDZaGxdB5SzBKPhSpFQxH90xNR
         CUYvQdG0soCK0yOSHcRORcFNCuUh7D7xmtxCvGoX9VO8m168cKFegpWjxwZ1/8CbFMiA
         Z9HauRQWam+zm3jXZ/cFv6Zsi2OIzPRwmRgKFIDTvRUvRgv64w7iSxu6liVeqNu66/7t
         yWxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=L2olCuuA;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s5sor15769840pji.24.2019.07.06.15.45.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 15:45:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=L2olCuuA;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=KZuwwpEDFFidTZvCB013aANFUOOg31tF9n5M77JSn6w=;
        b=L2olCuuAvGq0806TGK59wMZhuTO9EVAfk3ga/cDt+R/5EhMP0+heHReCNlnPQDSkGp
         zGOPzi9ERGBvpgjYMxEVfHRrpbbXjbg9Tumnson9Aj9d9S6tOlEMiXFMwzktp7ZoFa3j
         3V4SxfHzDv2eIU000+5AZUoa1Vtg/lRF68Rlt5ugGh4CRwA4IKmmpjhUDLoci2ZaePqX
         HSR3SKOK5gu0GgWUlM9Rx0PxavwGWVtiwv6Ta5AOjENY0n47KgVxkOLu73lQUOx9c9sL
         IpfijZ2PChnxS65QjOoFAk9wJ0S9i/zj+e2Oc8PK+C/M1rSSj52DmRST89qhWX1QIG1e
         nXpw==
X-Google-Smtp-Source: APXvYqy99zQ1u6U2AvHd71woEPV1gm8EDjjXuQvomJnzfLlJWwx2tPqF1zsuElqnQVfiPN3ciDpYHg==
X-Received: by 2002:a17:90a:d3d4:: with SMTP id d20mr14263697pjw.28.1562453111723;
        Sat, 06 Jul 2019 15:45:11 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id n17sm13000168pfq.182.2019.07.06.15.45.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 06 Jul 2019 15:45:10 -0700 (PDT)
Date: Sat, 6 Jul 2019 15:45:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Christopher Lameter <cl@linux.com>
cc: Markus Elfring <Markus.Elfring@web.de>, linux-mm@kvack.org, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, 
    LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org
Subject: Re: [PATCH] mm/slab: One function call less in
 verify_redzone_free()
In-Reply-To: <0100016bc3579800-ee6cd00b-6f59-4d86-be0c-f63e2b137d18-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.21.1907061542480.103032@chino.kir.corp.google.com>
References: <c724416e-c8bc-6927-00c5-7a4c433c562f@web.de> <0100016bc3579800-ee6cd00b-6f59-4d86-be0c-f63e2b137d18-000000@email.amazonses.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jul 2019, Christopher Lameter wrote:

> On Fri, 5 Jul 2019, Markus Elfring wrote:
> 
> > Avoid an extra function call by using a ternary operator instead of
> > a conditional statement for a string literal selection.
> 
> Well. I thought the compiler does that on its own? And the tenary operator
> makes the code difficult to read.
> 

Right, and I don't understand the changelog: yes, there's one less 
function call in the source but functionally there's still a conditional; 
this isn't even optimizing DEBUG builds.

