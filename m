Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2694C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:46:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD55D20851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:46:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD55D20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FFDC8E0004; Thu,  7 Mar 2019 13:46:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5875B8E0002; Thu,  7 Mar 2019 13:46:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42C308E0004; Thu,  7 Mar 2019 13:46:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1771B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:46:21 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k5so16180787qte.0
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:46:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=2u7BP1Ui3tuNwWQLTQcvYHKSwz32ntxHiRkj8rks4cs=;
        b=WP3wQgiGMFBbwAs3AAtRg7gE6NaCTIMy6wLrSCQY9i+shN6gaPS3Tow/1OJPT7AjrR
         QRgd9uV1Mw0NSgiN0f6LTXnF5/Q29qeFPWC8vIE92yIL2Pm5HYnBx/f2xqS40itMefb7
         uJ7ANNZ0wVR2kcdxjyJMYPvqoLsvnNJmcrH6J32vB8Pw51K9YHkezoosRM4Ox565wgrw
         kSvOyORtZYfivyjfwddNOO6ckx9/Dg81RrIK5fcbjdGhJr6p3lMw/x0om7Cp3GRvx1Ou
         1IyzaYrND6dbBdOUIWhJICyY1fvCFlDMMZ21jnJzwYyFOty4b62Qvk2dJkUTXrjiSLet
         MnDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXV12RSm81JCLAtDXTM/RjRgiBvw3vVDAcjtH5QezzU6vDsSJex
	DuO0qOJXwRvVD21g1y0+icUzozKVGQBZOFItvCLMtz0jZFKW6F1nHy8As2pcfteDDy3uy7avSW7
	jpL5DzKmp/w85xZ2PSo9yW/R9Qxy7ZKJX7KhXQFXp0QIigLTC0c2KyoiD3SYuF7lpV09CQwCsls
	H0hfksiq01FSR+z5AurZyivInBWjtSf+e0pMKh5/Q4mOHabIAzn4+0ueaI0ZbxMb3/VQ/SxzVpg
	M9b/rycxwpHyCJUrCy9ykwOoCad+BqQq/jlFsYf6DH3qnegqbCQGHpIAzhCo2ghFodgY4XGpgKI
	xI+8UeBB15LJw5nkDFFD6AdTkjv0QETcBV32EBfOvf3peXFiWar0l+0B90t4wEvrpRB0S/bRDdI
	7
X-Received: by 2002:a37:3541:: with SMTP id c62mr10842502qka.240.1551984380828;
        Thu, 07 Mar 2019 10:46:20 -0800 (PST)
X-Received: by 2002:a37:3541:: with SMTP id c62mr10842470qka.240.1551984380208;
        Thu, 07 Mar 2019 10:46:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551984380; cv=none;
        d=google.com; s=arc-20160816;
        b=tCch5IjpTj1NirWkotLJLWp8piYhSz9kY4c7A0QboXgF4QSS5lU7LSFAd68XcFeh9w
         wW4hXhelujwDLzgiLx1M16FVC6Hs4JAyWkN2IosM1LLbaWE8pW5geh6MR6MibT6d6r2j
         JB6DXQZTW6ms35cJdQcGsYGRw/MWpe3fGH4GUpgx+XvytJnHStS31MLqXJtLqLyl0N5G
         x5IFWUNsSSeB2r/Uk4r9DjczC948jTQpKFq7yor5H6ORibHnavNFbhECJQMOtTDoR1q2
         rIswxBLwTxxVOqKOxi36/4YVqu0/mXHBG7nNWaSFAOcS9Q6PjZXNKRqGvrNpHoVd/Cau
         8Wow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=2u7BP1Ui3tuNwWQLTQcvYHKSwz32ntxHiRkj8rks4cs=;
        b=fnNyFWAH7IrUxvf2XoJoEYH5jaGTXMlQzqbFrZvaZDw7MnuyGjWBa0L7WQy9JH6RrM
         m9/EhOXt53gQ+DOWaQL+jMe8Qe4aPS1IvKw6rv1xtSmOM1xR/1epv3SsfXoE7vCucmxo
         z1E8gjvx2fRs8Z/GRUNLlmk8T4JvlXXdpAtoCRYlsslOQvhh/T9Bu4sU/JrScSKUOFZw
         LNiT1BMRUELWZ8R/N603DZlwbvQGt6VJbPo7GRaotXfBxWpqmb54X4v0B+851ncWW0DX
         eqRCTCIj8e6Yzyo3QVRpuasoy2DwGhLDLhwIXZjRhkmxQle9EMeZGze1yDZj1vlhw3TV
         h1ZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1sor3407696qka.119.2019.03.07.10.46.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 10:46:20 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwgo2MGDFDKita4Pt3kdeWKS1YwgR61gSXoAaqc66X2e+GMqH9GgtEtnl5cyDENN/P+vwyYrA==
X-Received: by 2002:a37:b105:: with SMTP id a5mr10850516qkf.298.1551984380034;
        Thu, 07 Mar 2019 10:46:20 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id h52sm3711686qte.78.2019.03.07.10.46.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 10:46:18 -0800 (PST)
Date: Thu, 7 Mar 2019 13:46:16 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
	pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>,
	David Hildenbrand <david@redhat.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
Message-ID: <20190307134455-mutt-send-email-mst@kernel.org>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 10:00:05AM -0800, Alexander Duyck wrote:
> I have been thinking about this. Instead of stealing the page couldn't
> you simply flag it that there is a hint in progress and simply wait in
> arch_alloc_page until the hint has been processed? The problem is in
> stealing pages you are going to introduce false OOM issues when the
> memory isn't available because it is being hinted on.

Can we not give them back in an OOM notifier?

-- 
MST

