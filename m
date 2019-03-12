Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A91BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:18:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E373E214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:18:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E373E214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 132018E0006; Tue, 12 Mar 2019 10:17:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E2E48E0002; Tue, 12 Mar 2019 10:17:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC54E8E0006; Tue, 12 Mar 2019 10:17:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F40B8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:17:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i59so1160275edi.15
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:17:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eJKFa3iQ9wzRhsBkVsOwREmdd6mCiC4+ZQKFPMYsXNA=;
        b=tY/dFl/CZsYr01OeCZbbnF/IMLzKc02WiGyFQAyzBjDffTMdmhXSLdY/eP+u9Gh/+k
         60ZxyZB0pyg4O5io4e8Yvlz16B2fsfIMhBwERJ0RGmixydNK1e04BSAjbijIvcPP8yb5
         7YTh27Z7giKK6o98zxqllKPoE5u3DzQD7uAYh/3boOm3LPazD590iIVQITNoNDEzr5LF
         2V3UeCaxG3vY3RTN/WJWMsCcUnMYJYQvhpuA38vUfIz99Dyi/jZj+BwHieDrSnRkQnjE
         mGniAAA3DgEpMDB1PbsbCgzSzgjuUppuIe3DxGWIaFTgIkOClseb+XPgy6d/TMQbpYcS
         OSUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUQyhanIbpK3a1PF76polfSppa3XcabWEsO4oYQhCOFaprw1dvQ
	D7tXzxLa7gKleSiKpUcpmVmjmFgdCRu+wIX3loIXCBJ6hL+hxjd0qbErQxDJ4uIYcop+3k/Z7HJ
	bSSW4PrhB1v2c8iudHVBa1vLCAnS48/pJctBtcYknWJugCiQZwqyEtur3v1j/Cu+gGA==
X-Received: by 2002:a17:906:2297:: with SMTP id p23mr3722468eja.34.1552400274828;
        Tue, 12 Mar 2019 07:17:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwOtlRUTIq2LU4QIsD4lWm/OJVrltBL9Eyt6pZ2ybjZZ+lJu67rA1QN6Qova2F0jOFs3jm
X-Received: by 2002:a17:906:2297:: with SMTP id p23mr3722400eja.34.1552400273537;
        Tue, 12 Mar 2019 07:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552400273; cv=none;
        d=google.com; s=arc-20160816;
        b=Y11T8+pzLmuSTbCYIiB8Akcw6wvc3ZhYXKaVicK7eShLr4oTCpbuAGE9LXnW9F0KBJ
         AbAO/2xcPKnv7GkwZ3Y5k7a5iUqVMt6g4UhgZTUBehgWGfPmszZ1wY0dfM8IL4WPZmDx
         x526FbgpxY7r0sG/on9QT+WXqOyOMFwWO1Nhn1uY9k5beHJ0xjx1ccjTXXJOTK3yAeSf
         KvwkScMqUGvTwmJq2rhczon1FPtuYWlQC1tdAXOC/gupbBxSBlwPtDgBhDx75zM15R56
         LGPSN3wx3CtGJoXufI6aLPJUDIQKNVVOgE9meLV6arxYOKW6WcL/zvsdJftK7uBkzMzh
         EmEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eJKFa3iQ9wzRhsBkVsOwREmdd6mCiC4+ZQKFPMYsXNA=;
        b=AoTH+qzjsdJshJ3ZtBJ+X+tRrysno4VMd6S+nXYRCHMIMPijEHgrozbI7r3wVlk6wh
         uh0RktPXqGwDuYfxW3+hMPwg68AYVbl27r1GqRcC25vPrGHjHqlzXAjXA55G7BTAyQ0N
         Qj7+tXrUw0p7xFOB+ZHWB2WNxFcDHJ5cz33ozEuaMdMAQRD/liA/PGy+GMBoP6j7DTTc
         Mdssm8MpGhgr2f1/jjOO3aZqpyzvmMQK4MuXlHzL/L6tsUu/t0ImfUhOgJCiaJ/k5Z3J
         x6PqVUIufWSYDpQvr1JXlRxcLljBmBbfnv4vN4ddj59/PGhyOb3nE8NNCZX0bXowZdDS
         4s9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s4si1756606edx.79.2019.03.12.07.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 07:17:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A6765B642;
	Tue, 12 Mar 2019 14:17:52 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>,
	Andy Lutomirski <luto@amacapital.net>,
	Cyril Hrubis <chrubis@suse.cz>,
	Daniel Gruss <daniel@gruss.cc>,
	Dave Chinner <david@fromorbit.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Jiri Kosina <jikos@kernel.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Josh Snyder <joshs@netflix.com>,
	Kevin Easton <kevin@guarana.org>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 0/2] prevent mincore() page cache leaks
Date: Tue, 12 Mar 2019 15:17:06 +0100
Message-Id: <20190312141708.6652-1-vbabka@suse.cz>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190130124420.1834-1-vbabka@suse.cz>
References: <20190130124420.1834-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a new version of the mincore() patches, with feedback from Andrew Morton
applied. The IOCB_NOWAIT patch was dropped since David Chinner pointed out it's
incomplete. We definitely want the first patch, while for the second Linus
said:

  I think that's fine, and probably the right thing to do, but I also
  suspect that nobody actually cares ;(

Whether or not somebody cares, we should hear of no breakage. If somebody does
care after all, without second patch we might hear of breakage, so I would
suggest applying it. It's not that complicated after all (famous last words?)


Jiri Kosina (1):
  mm/mincore: make mincore() more conservative

Vlastimil Babka (1):
  mm/mincore: provide mapped status when cached status is not allowed

 mm/mincore.c | 80 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 68 insertions(+), 12 deletions(-)

-- 
2.20.1

