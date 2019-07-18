Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A777CC76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 05:48:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 573F32077C
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 05:48:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 573F32077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D39676B0005; Thu, 18 Jul 2019 01:48:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEA976B0007; Thu, 18 Jul 2019 01:48:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD9E28E0001; Thu, 18 Jul 2019 01:48:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8990B6B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 01:48:53 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id p16so6595133wmi.8
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 22:48:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=UQF7IGphZoaiBmzhSfcvEE0RNSyb/WlizD6AcQSSVh4=;
        b=g+N57E6AyKACpN67pTbZYLUBaG4/b2f1kAU7OSgcgHofbfSSvSiI1AywAXvjcOGuya
         3UkJ6DZ+vic3xO091oJRcZ1wMYgY706Y6XkrNF9ufyGMSetPxnJBglEcmTsvqsLHbFMt
         Woy0RZrbnRXgPRKnXKMNPFq40mEBKBI1N34iofrXYH9u2U0pnuoSOmdqZrCg7SBHk+iO
         XH3tbcluTtPDeoJKYvjkQw4hRi+SulL+IkNPEnXkbI0uUmb8wS8cPp47xYP+q9tBFpNi
         kYuLTE8T1X7pB0kwmcJ3fJ3RCDxSvF2BpYheVimmLhuD4s4/Kz6viLAbPKayURNYXURU
         z9TQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVdaZlqt4/Tta49pZQ4YA9oFWYYPxiUmioU7DTmW+lIVk3Iz8Gy
	cQe0BhNQODNtZJOSUMGRvoM7oFwW3RXDreFFGrJjJH/RiQej8VfPRd/jmVL/kn/68izvk0Mqp5j
	e9D7GjPHsopPBwe1dgHBXpIgnbQkVMDiHG70rGPiyLAfrrSwfY6QX/F9QzDgRlFuEOA==
X-Received: by 2002:adf:e947:: with SMTP id m7mr48191558wrn.123.1563428933121;
        Wed, 17 Jul 2019 22:48:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzk28GsHWMuo/b2ACTynlWRk0mGBO/MG3tKVGbKVJHWor9EqQ+z8sAvpWcjxLdqz3oq+THl
X-Received: by 2002:adf:e947:: with SMTP id m7mr48191480wrn.123.1563428932417;
        Wed, 17 Jul 2019 22:48:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563428932; cv=none;
        d=google.com; s=arc-20160816;
        b=uTWlxXabYUCQsVVoOO+O57ZoNucVovBXb4Ws7+frCvyE9E6t/UOIo5t5aFoIc8uldB
         Vrm0FototLDdTwoUU6RkIDNKLBRKxVbgUwQZs4EWY9NDXP9tDMFAsFL5yVQ41mjDjKTV
         3ZwIlcLt0dQCWldnrbjvBwRQSTgGdToOnXJJRGGenf+4jOhJdZZjuY4neFd6SThl2ub6
         n0CkgBZOmq1vg1hsCO8fVVCbn0PIWm7m7a8JynRMsU5Ic7/c3Wfn/BmqHYJ6rXlqdaOs
         lv4MbsX0m8kqpgQB7ZLRxX46Pj1ZUDONGNb5KnmnOPh5XQMA8lByi+KlX3lrM7mhKpE8
         bXpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=UQF7IGphZoaiBmzhSfcvEE0RNSyb/WlizD6AcQSSVh4=;
        b=KcNIDyPcF5CAOABnYKLL/0NtuZQSp7hC4PSxgr8B+60Ou0SZpJmvdyeMAjjR/xxsoX
         kLMBcdrdEphKb6Ry+I9W6gu9kSkEId7JpJspKLORCl7eQUpTMthAIdwyx8U3HLDxG/kH
         gwYhKJxL9D0M479Exsd9Jceif3FUDGRjngX1QLpdstaOFTKUoR9idiC7aGGwiI8bGqpl
         V4i+V08TN7ss4jZf49AyEASWNYR1+VFze0oncxDYHzrjBbOoJxdT03Td+7HVQJHbJyoL
         Sp1NUybk1YK2kkh0dcal/k8x6sQKWVdQp9g8jGr170lpUwj0b/ovHCCY2PBcjMWbCvri
         5BbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b16si24988469wrp.196.2019.07.17.22.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 22:48:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 74C6E68AFE; Thu, 18 Jul 2019 07:48:51 +0200 (CEST)
Date: Thu, 18 Jul 2019 07:48:51 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: RFC: move kernel/memremap.c to mm/
Message-ID: <20190718054851.GA18376@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dan,

was there any really good reason to have memremap.c in kernel/ back
when you started it?  It seems to be pretty much tried into the mm
infrastructure, and I keep mistyping the path.  Would you mind a simple
git-mv patch after -rc1 to move it to mm/ ?

