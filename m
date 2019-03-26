Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB7D3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:36:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7512A2070B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:36:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7512A2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DEC46B0005; Tue, 26 Mar 2019 09:36:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08E6A6B0006; Tue, 26 Mar 2019 09:36:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE7486B0007; Tue, 26 Mar 2019 09:36:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE8976B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:36:15 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g17so13505041qte.17
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 06:36:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oBzqVXXOS16NvlFk14QPKS1+AWDX9qa0M3QDhL3KWfE=;
        b=ASsmSk4VXwf7f9lzSpw1Swzvdk+BoI83G2AjrDOId26aNO6yodR1ErJ2SlvWqYM1Hc
         sI8cw3PPD/aHaGUd2MMcH0GO9N0YIr1rgRq9ojiTS2WEajQS4NyLNWZjfftmzs0ZZcmR
         BjKm3fvb2/EfX8eveIcONf/HrPIMKmTr2sHfYauuXtaNkWA3NCMx6EqIQFButzUBh7aY
         Otwcp5rx6o1x6Ey/zt0d1KVfqivpXauNI1dDysHvW/Qbor//L012ZZXhSplgTKdcWbSW
         eO5R48d/L+oxc6ADyaEyqvbV27TjCFAXMaYcVZWT7ATeF6krNjtFlFMW1mql+QARWx+R
         M7OA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV2X03VFZZiZ00C+jcvrOAtfOJ40SjXDAwBv8UjSkVg1Tdw8MAb
	ihBK+ZmOXig36AXGZFzqPZ9O3GGzXCltWaIHux+jXwM+M3RDONHP/2uVjwTG/BtVdTam15fmN6q
	T6iu8uv/3QZZyxhaVuX3DK6u6uCsadj1hQxV6VzIYEcYCmR03wMEdRLxIP/SxYzq2PA==
X-Received: by 2002:a37:614e:: with SMTP id v75mr10138206qkb.27.1553607375652;
        Tue, 26 Mar 2019 06:36:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlIcmLnBeoYjlPZM/wStC+fwmxf+qQn3Wifea3Mo/Qhs9D2XreH8kAcjzSCXxU5djJdtYq
X-Received: by 2002:a37:614e:: with SMTP id v75mr10138149qkb.27.1553607374946;
        Tue, 26 Mar 2019 06:36:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553607374; cv=none;
        d=google.com; s=arc-20160816;
        b=r6Kk6m/2Wsa2aR77OuoizqDK+/PKVy3v4+1WyhducMTRP9uUZFRltXV5tHg0X4gfU5
         OzeCdfx8M7o3NOmflXEncnmFUBUZtdhHJ2ti1DRQxS47VwzT4aN2+sEVTUIiUh3wyg4w
         nQR9XiIv57RgZKJQMrM0twsswuAHiW7MdZomFXe7iNyzKy7e9lBcnzGc82cMtpwYPRmQ
         VEEmJWGtZEEi+1rrti118cgEfNx6WOd6beK4hmvsM4sSa9CAtqwuK/LmLJCZ0dXP3ieL
         DBCi4oqIC2RK7BK8VmrTsNdVPHfmU8neE41Svz7iVfYAUHxNHLe028Hyfa8k50YCyUsX
         u1tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oBzqVXXOS16NvlFk14QPKS1+AWDX9qa0M3QDhL3KWfE=;
        b=upYGkR9Stg5E9CF4hSnYO7DSjxQVE3gBbUsfTxc/UKDGrz3V3XAELYVyo8Nmu4tBR+
         cljTY9IXF2wCD3QCiTNEDk2cOT6BRxAvi118UOTP33NVV4/M/bjESRopGhcZUqnhfXsO
         IM23LzlrftgebSlR2PejNfX4Y4cEObrplr/31+JRK8N2cc/lbR7eRp0QWLCBcjjqc3iU
         JaLRBoBVJf3rvFAKHRoXI4ACjfRr51ytP7Q5ucqLA9AzO4jsOWIL3sp4eUfQB6PBiNpR
         HgXTJCRzzzWsCdrwnmslSMnCKvqBaaso5PUyFzOLhYQvlLhI70beSZJvZVThs+mkjukb
         lTzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j14si400704qvj.157.2019.03.26.06.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 06:36:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5E10C308403E;
	Tue, 26 Mar 2019 13:36:13 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.68])
	by smtp.corp.redhat.com (Postfix) with SMTP id 4758A17A88;
	Tue, 26 Mar 2019 13:36:06 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue, 26 Mar 2019 14:36:12 +0100 (CET)
Date: Tue, 26 Mar 2019 14:36:04 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Waiman Long <longman@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
Message-ID: <20190326133603.GB16837@redhat.com>
References: <20190321214512.11524-1-longman@redhat.com>
 <20190321214512.11524-3-longman@redhat.com>
 <20190322015208.GD19508@bombadil.infradead.org>
 <20190322111642.GA28876@redhat.com>
 <d9e02cc4-3162-57b0-7924-9642aecb8f49@redhat.com>
 <01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@email.amazonses.com>
 <93523469-48b0-07c8-54fd-300678af3163@redhat.com>
 <01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@email.amazonses.com>
 <20190322195926.GB10344@bombadil.infradead.org>
 <01000169b534b9e8-31a2af2c-c396-47f9-8534-4cbd934ef09d-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000169b534b9e8-31a2af2c-c396-47f9-8534-4cbd934ef09d-000000@email.amazonses.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 26 Mar 2019 13:36:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/25, Christopher Lameter wrote:
>
> On Fri, 22 Mar 2019, Matthew Wilcox wrote:
>
> > Only for SLAB and SLUB.  SLOB requires that you pass a pointer to the
> > slab cache; it has no way to look up the slab cache from the object.
>
> Well then we could either fix SLOB to conform to the others or add a
> kmem_cache_free_rcu() variant.

Speaking of struct sigqueue we can simply use call_rcu() but see my previous
email, I am not sure this is the best option.

Oleg.

