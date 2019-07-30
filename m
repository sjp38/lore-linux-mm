Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE469C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 16:58:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77B35216C8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 16:58:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77B35216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D71698E0005; Tue, 30 Jul 2019 12:58:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D21548E0001; Tue, 30 Jul 2019 12:58:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C37DB8E0005; Tue, 30 Jul 2019 12:58:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA5508E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:58:07 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id b3so6742512uan.13
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 09:58:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VUl2cE77oxzBSJ1flOQE3G5bk1IvBAoTwR8xYW4Nlb4=;
        b=cq+VDomzTwsGbl+QKLRiRK6eAWXhRXADDgb9fzNus0YHcxBIIsucr5vDHATkJ20DsI
         qG2nJiylE5FAH9wiDF9ycgcf0HQ3pRaZGHx2X87lU+SSaPgkdKwdcDp947KBjZG5pPoz
         znq3WrCi8zWHkZBgOnWqSM4mM7/Z3ZY4JMB0S5herfyQ7QhhWuXS7in0xTRF1Jnd8L7Q
         TgI43/5ED2MNRD0zLqO78+IMLSOS8SFWUhDP2U4dHKGLDjMhVK1CveYKfHJHOQ4lwVZm
         iA/mtWLCjLFgIjEEVktExziyhy0pWQ7XjRWBfKIEHA8+26QPkwyGK1A///VsrS25J2WF
         +pyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVHlolDCQX898tfctRfT0SbXM9ZzeMIR/wI209/pLom6MGhYrHL
	FRCA/V81izzKfZ/nWAhTmsweyChZDY9nPRffJ0YvSmopi4Zd2j0Hqiomctp359ArU3kCp9L9tOB
	/NS38wa5qNa5ouHCTtkoO4RQRoNoqX9GLa9ufNZ3/dWEi3WKbTslB9z7xg3505DDCbg==
X-Received: by 2002:a9f:2269:: with SMTP id 96mr71373878uad.80.1564505887225;
        Tue, 30 Jul 2019 09:58:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdl7L2yr82y0DoTCfWKH+8yDmhicPBjcQbLS1vxY9QfrofBshlAnUiPkvuK6Z23Wt+Ag94
X-Received: by 2002:a9f:2269:: with SMTP id 96mr71373811uad.80.1564505886469;
        Tue, 30 Jul 2019 09:58:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564505886; cv=none;
        d=google.com; s=arc-20160816;
        b=GVPgScBWSgo6Ah1+lmlzWc+Dj9DbuTZC4+uSYn3+Fao1O0fkqlSOkKjG/2/cBf4600
         LzSUURCQhbky3fujMFtyrf3kgSjEDPKDpJGb9yVHxU7gNfFM2BAzrfwHdGEvYKCu1K79
         1zmWRTQy9GC06760e8BSXhanY5qeB5qlgJCCYj4zlIiSTEMxWp8U83D+v9Y0WPop2pt/
         ypv1F3wUgOu8iZaWyLM4kR/4J+DPoamDen9fTZ4zMauavxdI2qijHLwU6iRIev+II+Kv
         EHF/VCIUnpHoVZ1u3znL++5CjNJ9enQroWCU0HXscXO5MlkgM79d8AJwVhNuE+/9wrg7
         JXoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VUl2cE77oxzBSJ1flOQE3G5bk1IvBAoTwR8xYW4Nlb4=;
        b=IHn3Vu571w9oMeJUXkqeeXd1vLvR/fQQmDAEh0Lz+oqh8wlBhv6LK2WtXK5f3MwY3S
         K8ngXgVizST32t5kH8Q79h4LwqcOeUTA88rjZScM4j+ScXBIEWFLUEKdVvASrHKRIxrb
         HgpFVhnAa6HsMFhNy8vimvCwe3uO0Nfgn2UbD09OcJfax0eawyEcy4zpST6dE63jTfFL
         1N6btmD0bRrI+S61xd9VPI/RJcMV21q0m/pPFd3lcJsexYPLEtIjwYnp0+0h2iQ97nY0
         7exn/czCDfVwxH7sCfMT+iqmMXYk+9lr1VB1v/t2aiQ+BE3EPdwk3mfiXdYU7OsxOIrv
         /iCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t17si14237421vsq.78.2019.07.30.09.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 09:58:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4C3F930A7C6E;
	Tue, 30 Jul 2019 16:58:05 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 898415D6A7;
	Tue, 30 Jul 2019 16:58:03 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue, 30 Jul 2019 18:58:04 +0200 (CEST)
Date: Tue, 30 Jul 2019 18:58:02 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, srikar@linux.vnet.ibm.com
Subject: Re: [PATCH v10 2/4] uprobe: use original page when all uprobes are
 removed
Message-ID: <20190730165801.GF18501@redhat.com>
References: <20190730052305.3672336-1-songliubraving@fb.com>
 <20190730052305.3672336-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730052305.3672336-3-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 30 Jul 2019 16:58:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/29, Song Liu wrote:
>
> This patch allows uprobe to use original page when possible (all uprobes
> on the page are already removed).

Again, the changelog is not 100% accurate. all uprobes removed _and_
the original page is in page cache and uptodate.

Otherwise looks correct...

Oleg.

