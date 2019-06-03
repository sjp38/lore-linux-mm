Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECD6EC28D16
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 09:32:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4E1528006
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 09:32:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4E1528006
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D2906B026C; Mon,  3 Jun 2019 05:32:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4840C6B026F; Mon,  3 Jun 2019 05:32:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 324086B0270; Mon,  3 Jun 2019 05:32:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0988D6B026C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 05:32:09 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id v1so7477760otj.23
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 02:32:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=nQrYFZQuXpHIts7HfkCIugcFuh4dtWTX7uiujLuGQEM=;
        b=Jaw/hNZJrgl9Qe2Y3CZDlZzqmuDfwom4+aGjQzaa92qbJvl3Hwp0yohLNjGGNMDwIn
         wy/R1FA8Yl0yT9N4OnljnKeoBd3tJswmQQVbB/qkckxk5DnCiggvofZli91R6d/PQTGp
         0lDn2Ft5pce+gx6VSuCG8iJaR/beKuYwHd8LNH9GuYpi85V6KUUzYYfjW3i6hJGvyGiu
         hyHziCbBy664qMVqNLDCTrFXfyuNBqZZCY82hSa2JBnBWHbqv9ZIXsAbHCbK0nGgkiEL
         ce6N9Wnw74MpeY9WP7/nPv/fUF6Pge279jGiiRquiXGyy+UiENcPqRsEThUIYCD0fzLZ
         Nuqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUIuDu5eHRcO+VoyKWuoaZ3W7gCZSmpMxwhVxN/smhR6mPiSqjz
	6NRJrT5j4eiacUqppasYVCfamS6puj1nQhlt/cTwVLY5FYBS8iI0GcCqAdobwhr3IsHZNBurn6z
	7mfxVE+ZwqoJLXDUbZV56+EfGz+bUl3ZD30irlb+m7Jxm8NoYsk73cKKrWR50SKbisQ==
X-Received: by 2002:a9d:2f41:: with SMTP id h59mr433914otb.359.1559554328701;
        Mon, 03 Jun 2019 02:32:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOdNO+8Xoi/SzPC8MDWrSMCeaqigvko4DN96ldzd2Gk0J2S9GRsNvF1EIJPaoKf9aIXXJK
X-Received: by 2002:a9d:2f41:: with SMTP id h59mr433886otb.359.1559554328000;
        Mon, 03 Jun 2019 02:32:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559554327; cv=none;
        d=google.com; s=arc-20160816;
        b=tjoUP6VErqWlUGas9jQmIp1uRXf5U1kyYe3tKS1IZ2zl/tkRFCR4c+YmslfcxLn8/Q
         tZpgGsxT6GQywbxRW9gZEM+evDuFjtyjH3QJmamnuDaSg0gZ8I0y+0kMSfGn9yVEW2BM
         kO4zf+pSKtM1ZZGevK73mDmLdIG5irClfMwsNdW+Lnb4IG2gOtdAdJy0fnd3z09UYvq5
         kOzV0Wgn/j5zVJMzUilQZ/rc89/a4KN+J/tJwyfBBwjYULT/mfOa/rnMAmPOrkf2MKmQ
         qkU3Ijbu4tBj4aIXE7GAn0lJGOYbyYBvLX9pFrPEQrd2wWpuxNn8503dNM7JVx1rq8RO
         5yjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=nQrYFZQuXpHIts7HfkCIugcFuh4dtWTX7uiujLuGQEM=;
        b=TYXgzcDiejDWFsx/sVLud6OkAUrp3UMCRvOLHSqoVyVX3OoMJz0NUQrX+BIgZ7schy
         OZuj3IKruoteuNds1cnNQXDEI+aw0LlcVfdh2Zvpn6guCTx5ZXGEUT4fs/TXxC0DN38W
         gMLSXpBPR//xKiHAJXEhaeUH7m32O4iyOinXoKv4KYQobO+3cu8eGOuVTns+9Q+LxKNX
         zVaIf/DV5Wqchqo2MqB4bpAOwPiFMOH2JH4Mky7AnwGF4MBOHbiCsg29WLkFSgqexdro
         xVAhkPvMhL89TJmaNCj01/DbkRrD4BeunxR6VeLqcU/UECpaGOkhD2tdNHIZIFo0odGv
         R4/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y132si7121102oiy.49.2019.06.03.02.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 02:32:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3FE52308621E;
	Mon,  3 Jun 2019 09:32:07 +0000 (UTC)
Received: from [10.36.117.0] (unknown [10.36.117.0])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8C56E1B465;
	Mon,  3 Jun 2019 09:31:52 +0000 (UTC)
Subject: Re: [RFC PATCH 00/11] mm / virtio: Provide support for paravirtual
 waste page treatment
To: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
 kvm@vger.kernel.org, mst@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <09c42bc7-ddc7-6b34-44d8-ffb5e63c7c6f@redhat.com>
Date: Mon, 3 Jun 2019 11:31:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Mon, 03 Jun 2019 09:32:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.05.19 23:53, Alexander Duyck wrote:
> This series provides an asynchronous means of hinting to a hypervisor
> that a guest page is no longer in use and can have the data associated
> with it dropped. To do this I have implemented functionality that allows
> for what I am referring to as "waste page treatment".
> 
> I have based many of the terms and functionality off of waste water
> treatment, the idea for the similarity occured to me after I had reached
> the point of referring to the hints as "bubbles", as the hints used the
> same approach as the balloon functionality but would disappear if they
> were touched, as a result I started to think of the virtio device as an
> aerator. The general idea with all of this is that the guest should be
> treating the unused pages so that when they end up heading "downstream"
> to either another guest, or back at the host they will not need to be
> written to swap.
> 
> So for a bit of background for the treatment process, it is based on a
> sequencing batch reactor (SBR)[1]. The treatment process itself has five
> stages. The first stage is the fill, with this we take the raw pages and
> add them to the reactor. The second stage is react, in this stage we hand
> the pages off to the Virtio Balloon driver to have hints attached to them
> and for those hints to be sent to the hypervisor. The third stage is
> settle, in this stage we are waiting for the hypervisor to process the
> pages, and we should receive an interrupt when it is completed. The fourth
> stage is to decant, or drain the reactor of pages. Finally we have the
> idle stage which we will go into if the reference count for the reactor
> gets down to 0 after a drain, or if a fill operation fails to obtain any
> pages and the reference count has hit 0. Otherwise we return to the first
> state and start the cycle over again.

While I like this analogy, I don't like the terminology mixed into
linux-mm core.

mm/aeration.c? Bubble? Treated? whut?

Can you come up with a terminology once can understand without a PHD in
biology? (if that is even the right field of study, I have no idea)


ALSO: isn't the analogy partially wrong? Nobody would be using "waste
water" just because they are low on "clean water". At least not in my
city (I hope so ;) ). But maybe I am not getting the whole concept
because we are dealing with pages we want to hint to the hypervisor and
not with actual "waste".

> 
> This patch set is still far more intrusive then I would really like for
> what it has to do. Currently I am splitting the nr_free_pages into two
> values and having to add a pointer and an index to track where we area in
> the treatment process for a given free_area. I'm also not sure I have
> covered all possible corner cases where pages can get into the free_area
> or move from one migratetype to another.

Yes, it is quite intrusive. Maybe we can minimize the impact/error
proneness.

> 
> Also I am still leaving a number of things hard-coded such as limiting the
> lowest order processed to PAGEBLOCK_ORDER, and have left it up to the
> guest to determine what size of reactor it wants to allocate to process
> the hints.
> 
> Another consideration I am still debating is if I really want to process
> the aerator_cycle() function in interrupt context or if I should have it
> running in a thread somewhere else.

Did you get to test/benchmark the difference?

-- 

Thanks,

David / dhildenb

