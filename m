Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D975C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 22:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0481208C3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 22:37:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0481208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 758966B0003; Mon, 13 May 2019 18:37:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70A836B0006; Mon, 13 May 2019 18:37:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F8306B0007; Mon, 13 May 2019 18:37:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4352A6B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 18:37:08 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id j15so14121348qke.18
        for <linux-mm@kvack.org>; Mon, 13 May 2019 15:37:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P75sRUYLI27NZtg7mkJ56w9o4ebRNoI96nvNkzLaJRs=;
        b=ijH7is1oIvGisjU+sTLQVbC8C7ozNInwpuCXS43LdLhDKVlh64kqrzdd9kPDjA4//l
         L+nev69UEX1Y4+kIT8a8DsTRCgQhbyE6D4qOsk40TwMYt2nnxOekrEp3ZPlPcOyiKgSP
         JNcV5Ow8Eo55S287sFyxQH2+teoQmEji8RFtKVwqTX5eEqLaJz6zOyItmbQoFcLvVjwP
         /sSeceTRjJMAcYkBd+of9Bb3/RSB5Hga5hfPLO/81jyWtjGdaZpfFRwSfXouXjkbu6s2
         hui6W6reVuNiiahAmSML9sazoDsGGHHnehdMiVoizZGbmI/FAleIriPTy3KvlES1k+8w
         5EWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUCvq3bxluD8oDq5pyUIxv/7ZVYVyhISCyrseQrmrHni5pJr1sE
	+d/xol1agvwWn8VKvs7DGkghdPZXIr1nZGC7pjvUS8NNjANjTFKFQtRDEosyiR5+wz03/ln8TBR
	ooqjbEFmHXj2Ga7JoeKaNDP54rL9PcrNEk9lCVyiffE3RNnLlh0RerY0ztYuuRlLM8w==
X-Received: by 2002:aed:3fa7:: with SMTP id s36mr26421724qth.124.1557787028079;
        Mon, 13 May 2019 15:37:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZlsNi5w0p7GFEjriEEI7dK0GgTnzMgeu6UXduNAo9ntGwAsTuzkWckLhf9aSY8WB+MsBm
X-Received: by 2002:aed:3fa7:: with SMTP id s36mr26421691qth.124.1557787027554;
        Mon, 13 May 2019 15:37:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557787027; cv=none;
        d=google.com; s=arc-20160816;
        b=t8FZ1039ROJmLnPF6GEgscS+UudKMz2Ve4hI04gXMz4mvfg2fCJIiFX6s9W24naP0H
         XS+g6UIRaABKMxvXnJ/XuxcFEzK0z1akgF0J6484KJ4o3ob8c2mAfYOWv4a31nsp8Xrd
         uzzNWg/jeLBBIfJSFuiDkyGKjULtjLup6R3X0KuV+uv1D3/bu5leeyBS1wWivjdVa+Is
         X/BWBHtVi5Gz49/vP7tI1R86FqL45AaxjlaYnAGJHxX19z79HKj70V7OlhqJAH4U1mgy
         zyRMYnP++U+HNwQiC+mF43vCbCRjoAKyBvd9SP7E0s87qRo0jkzS8ztnzVZUH+SQ1ea/
         UC3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P75sRUYLI27NZtg7mkJ56w9o4ebRNoI96nvNkzLaJRs=;
        b=XrxnbqrG520JCq/K5qzRMt2yJhM7xRcr5jOZKsuLrFxyNSJciusaSesajVDYVVs4+V
         dGtq8vRgSfJV7SPvQ1wpcOdSApbC426sfEXFEnvQ32zigoLKFvkVmzMXAh1A/cWP3r12
         V/En4cgRhkqB9n5GOI/1RtcP/imJ17a1Za7Kfp3oDHYE908mCWLIvW5DqTRo+4CeULko
         ldbSNda/sN9fLLosLbfLeeFeM6qLmW7ms1jsDZ/TXpK6aJ7HziLOaZeK9SnwfnIrqiT0
         PoP09mCmeg2YCjSVYte/oaB69uD/3mLEuzHxJhH4BGtWrJSrm2e9xGRO8S4urtfAnGZs
         7DEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c41si4237111qve.63.2019.05.13.15.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 15:37:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3FB3D4E90E;
	Mon, 13 May 2019 22:37:06 +0000 (UTC)
Received: from redhat.com (ovpn-112-22.rdu2.redhat.com [10.10.112.22])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B73AD60856;
	Mon, 13 May 2019 22:37:04 +0000 (UTC)
Date: Mon, 13 May 2019 18:37:01 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"alex.deucher@amd.com" <alex.deucher@amd.com>,
	"airlied@gmail.com" <airlied@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"Yang, Philip" <Philip.Yang@amd.com>
Subject: Re: [PATCH 1/2] mm/hmm: support automatic NUMA balancing
Message-ID: <20190513223700.GA673@redhat.com>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
 <20190510195258.9930-2-Felix.Kuehling@amd.com>
 <20190513142720.3334a98cbabaae67b4ffbb5a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190513142720.3334a98cbabaae67b4ffbb5a@linux-foundation.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 13 May 2019 22:37:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 02:27:20PM -0700, Andrew Morton wrote:
> On Fri, 10 May 2019 19:53:23 +0000 "Kuehling, Felix" <Felix.Kuehling@amd.com> wrote:
> 
> > From: Philip Yang <Philip.Yang@amd.com>
> > 
> > While the page is migrating by NUMA balancing, HMM failed to detect this
> > condition and still return the old page. Application will use the new
> > page migrated, but driver pass the old page physical address to GPU,
> > this crash the application later.
> > 
> > Use pte_protnone(pte) to return this condition and then hmm_vma_do_fault
> > will allocate new page.
> > 
> > Signed-off-by: Philip Yang <Philip.Yang@amd.com>
> 
> This should have included your signed-off-by:, since you were on the
> patch delivery path.  I'll make that change to my copy of the patch,
> OK?

Yes it should have included that.

