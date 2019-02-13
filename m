Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4321BC282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:28:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0CF820811
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:28:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="tgVc5Dv4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0CF820811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC46E8E0003; Wed, 13 Feb 2019 08:28:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4B0B8E0001; Wed, 13 Feb 2019 08:28:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EEF48E0003; Wed, 13 Feb 2019 08:28:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 36A578E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:28:37 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id b8so877218wru.10
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:28:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=i9o4DqUCQ064zKrRPoul8NXb1+SU7ZbGoV/daMhaY58=;
        b=fiyLeL03gp+3TGo0dzmfbHnICG7WHTGZoRwI/jI3dCJVZU26oSOBweWZbbL8Ge/OYS
         7Ir3nbcFmuLQkM2nJtMLrYMs3ESfch20TvasyWqZIkL4dnRQ0NOazfFf4FQRYxV6QTXw
         fVy/Ku8iEde/EurQJ1u7bD2AuvtpVDflFgxbM331lAE8LwgXMt0tv0fbCH4SSscSk87z
         MNqmvQVj0ZQaMevO/JcGwWwF25IoLZZWKstK8U1OG9xjrJHLcc/cDEPPPbIRRTT+403T
         GiFKrW7daKtdNT7YbARnUCc1gxAf3Tz2oYk2AOd7epiaPiPBoJmggtYQLcTD/o5+gGwD
         ZMEQ==
X-Gm-Message-State: AHQUAubupfRAcackOSZAST0po6Mh6+xMvAJp7OD6b0rqfZ9DjXgXZPfK
	RnRDgJv0uBpD1xNFT4+pQwHknaSAwPrJGWx9+SpyY5xiISXi+R/uCTCSuDqD/D0SqcQkH2V49s6
	XSbGVE+6JkL7n0Nw8ZMc6vDSTqUWQp+6bmodibtwQRkfJEzr7fThPonUD3zIbKljYAW+gKJuyvL
	V+TlXqMdbUPopDZcrlf80SAtqpskVOsBhwfwo3N2k2jBAmnpjcadb4EoXegsgtDuRM1OuyM0Kiq
	jOv4oPaHHRALWTPRR6A77HxpVqkLJGG0OIT6EK6XgXx9lRxZleYftcb2VRxt0OQedpRvZLbuhbu
	iqqQfgg2samdL7hcHI0GZ9Z6Bb8pcVVZdi68CbRd4KayT2/jomKrFQrvosz4UUPFoQiCFg/WvSp
	W
X-Received: by 2002:a1c:7a0b:: with SMTP id v11mr307252wmc.59.1550064516729;
        Wed, 13 Feb 2019 05:28:36 -0800 (PST)
X-Received: by 2002:a1c:7a0b:: with SMTP id v11mr307204wmc.59.1550064515903;
        Wed, 13 Feb 2019 05:28:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550064515; cv=none;
        d=google.com; s=arc-20160816;
        b=qKtv/vSJl56jkADdIqjAshOrgBWq5QK+LwG3kF7W+TMo0XN1kQmpqKdpavSBpUNC76
         hy6fw4b1mVcl8QPdXC3Kmq6A6UK+kIjNYUsn6WxOTYnsF8gl1OJBdTX3vJloC7sRf3/K
         meal5cHzutbda/FzsgwEQo2TOSqM88SEsl5HG6AvUjS3Os9AUcoreMhhJ14z2UaN4Rmj
         pz4wBYUpMDso9/C0J3uJYbBywNCyOz3DRXEf2+Z6jeSnX9k/77QRjj7UBs44fEIIj6w9
         sIQVh7aNxo2q3goGInqdgMcFXx9YCeGjADBvyOZVqg+IL+gl4kyljV+bWcJUXnKqxCEC
         iAMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=i9o4DqUCQ064zKrRPoul8NXb1+SU7ZbGoV/daMhaY58=;
        b=WAc6RtK+u89SCm5sOis+JhjCA2VymxYuwkWK/G/AsitIg1zyZu2zGviho5CisqnWkG
         oMh1czmhHc71d1Fesybq88uS+lCdishm8SRo1frvGUoZuFR1OiAokc5Kht97U4VKWX0s
         bfNY+/h/Z+AEBpfw8WHaaIMKW+HqkD5O+J4OAQTeN2JnpTPy710c2wpHyI+E1eSZgW+X
         ulMnJz1Jb593uhJfvuaTTXR6uNfX4SqBjn386lrB8+/XPNadO0lOOkE4LmKZaVmu3Gkx
         8/UPy9f0z8N4yFgipVMseDQ7yIgPyGXCd/Ptw+brLWYpkd1pKb3/P5TVbxYCvfOjmLQU
         Di7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=tgVc5Dv4;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17sor3928872wmg.10.2019.02.13.05.28.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:28:35 -0800 (PST)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=tgVc5Dv4;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=i9o4DqUCQ064zKrRPoul8NXb1+SU7ZbGoV/daMhaY58=;
        b=tgVc5Dv4hEY7lyna2aHflwOA9joGrHmxd55hgh+/uuhjS7gWqrqjSkWdyP+M143eX3
         SBC8zBIfywCN6VLopKgXomVIs72byMXJp+XP9OAtco2ywcTP0ni5mYCWQPgT0qXxr5v2
         vcytiKa3zIBFA6O7PGeSp3E8NNQ4k+H7lraE32wzJjDYBu15hC36WKs299XkUTWasvj5
         T9rRbhmCFDj9kkXXlshKD8fsH/OVTbEAowv/5FtqxWGEHy9fLkEU2JebUlznGysWaGvv
         XMDL3AcjMoXz7tlTUOtLCZ+lMaaVchm2L85g1hLaN+1jyeEVJLapNSfO7xqxnKJmggz+
         mhFw==
X-Google-Smtp-Source: AHgI3IYOYShdNWrBo9WLCcQPQjNJDR5XjZyTSju6bLJMQfS4QoGxCSwl4eBKNPTRseXx+ON3/FIk3A==
X-Received: by 2002:a1c:a941:: with SMTP id s62mr361881wme.16.1550064515364;
        Wed, 13 Feb 2019 05:28:35 -0800 (PST)
Received: from localhost.localdomain (aputeaux-684-1-27-200.w90-86.abo.wanadoo.fr. [90.86.252.200])
        by smtp.gmail.com with ESMTPSA id x3sm22841195wrd.19.2019.02.13.05.28.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:28:34 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: linux-efi@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Marc Zyngier <marc.zyngier@arm.com>,
	James Morse <james.morse@arm.com>,
	linux-mm@kvack.org
Subject: [PATCH 0/2] efi/arm/gicv3: implement fix for memory reservation issue
Date: Wed, 13 Feb 2019 14:27:36 +0100
Message-Id: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Another attempt at fixing the chicked-and-egg issue where the number of
memblock reservations for GICv3 LPI tables overflow the statically
allocated table, and reallocating it involves allocating memory pages
that may turn out to be the ones we were attempting to reserve in the
first place.

If this is accepted as an appropriate fix, something similar should be
backported to v4.19 as well, although there, we'll need to increase the
memblock reservation table size even more, given that it lacks a later
optimization to the EFI memreserve code to merge the linked list entries.

Cc: Catalin Marinas <catalin.marinas@arm.com> 
Cc: Will Deacon <will.deacon@arm.com> 
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Marc Zyngier <marc.zyngier@arm.com> 
Cc: James Morse <james.morse@arm.com>
Cc: linux-mm@kvack.org 

Ard Biesheuvel (2):
  arm64: account for GICv3 LPI tables in static memblock reserve table
  efi/arm: Revert "Defer persistent reservations until after
    paging_init()"

 arch/arm64/include/asm/memory.h         | 11 +++++++++++
 arch/arm64/kernel/setup.c               |  1 -
 drivers/firmware/efi/efi.c              |  4 ----
 drivers/firmware/efi/libstub/arm-stub.c |  3 ---
 include/linux/efi.h                     |  7 -------
 include/linux/memblock.h                |  3 ---
 mm/memblock.c                           | 10 ++++++++--
 7 files changed, 19 insertions(+), 20 deletions(-)

-- 
2.20.1

