Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87979C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:16:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B5F32147A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:16:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="zDzjKRXB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B5F32147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22F116B0006; Tue, 14 May 2019 09:16:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 196296B0007; Tue, 14 May 2019 09:16:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07F776B0008; Tue, 14 May 2019 09:16:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B04F56B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:16:56 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r48so23272225eda.11
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:16:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MTM1aBzPfSK5tgU1k2RNG5j9nKyYFdiQfhSRyC1AQNs=;
        b=YKKVmuAxk3s7JQzJUdoyLGZ7Cfuu93xfjf+QwBEH7tN0Jj/vZd7ZDcZ+6ytHM1TiRd
         UQ+s44gG1+CaPII5TvJKd063XF6Vbz1RE919qhb0UALt7DhTmEKjNVgNl/d4DcXXFuOu
         jjpjRMCe5Q/6VpkP91gBBl+saiJ6qhrud9kZxhU/3UZdB/wbL1JhrgKtckhoIlRJzfIQ
         cm/S2ekwcQhzoPIWPcnsH2zzq8zP7Sqo5EHmN0iJjw6NQ8Zzd7zo6CAnxwlwtaGgwML2
         evKP72y5ghWZYM5FpMOGwHEYuJS0DHbjN/k8aeeR+Fp0FW9NNmQINW1gekRYLPHzn6Ap
         PXDg==
X-Gm-Message-State: APjAAAXE1uBtR7hJOGA8lAKn4fFpV7u6miiKsTyyDLBWUVRglCUS7OHl
	7lXIuYeCoKLwYErY/jK14z3q/NTiaVagZu1mdf4W9DZLaAHCR7T0WAZxyy5x02BIvVmi40MQlyv
	3+1BeAN65uABUm8bmv7+VWQhQ9/LNGdceKgoRYWQyx6i9029Hj2H0pge7shy1xbK9Eg==
X-Received: by 2002:a17:906:1d16:: with SMTP id n22mr25613164ejh.237.1557839816299;
        Tue, 14 May 2019 06:16:56 -0700 (PDT)
X-Received: by 2002:a17:906:1d16:: with SMTP id n22mr25613061ejh.237.1557839815223;
        Tue, 14 May 2019 06:16:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557839815; cv=none;
        d=google.com; s=arc-20160816;
        b=CCgZvm6Wof8c+oNgqyhHEAUA0v69GtsVOyHf3lDz9cI8GQR/Tm6DTtkNUTKV41W9HR
         PmGTacVeAzfEVGQEIXUYAuL+LfMTDjsZ/awOylYy9sd/ttmN8BSpEx78nQbX+oeiDq51
         LxWmDH3eMUsSyRNKKlK/SXLeIOBeC0JQYSfoFLsrqtjJ66/Q2ZZVd7wnhPlGJioJW5YF
         gdj2KB5Ie+V9sXX2Z716tGiUDsoVr5gQim0MJCWJT9/nAgv4M18AGhx7o4+JTkwIAgSN
         UVs00DAqJwZQrde8ffpHCNzYefcb7DGhdgUunRkXlEGg+Rfo2IS3lJsTFI/XhFsPcwyb
         AdSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MTM1aBzPfSK5tgU1k2RNG5j9nKyYFdiQfhSRyC1AQNs=;
        b=mHYAmdcTLSGV2rK0Z4BXkwnkRjQHtP22bZzlkmiJqMBt4E9/ZOqKdQ+5p9yobw+6/I
         hkAcczFe4TxASptsBJobmRJSkjYtOBQEegNaWxpAm0jaHzEMO/lb9HLDpenMbwpse9GM
         wF+dHCoQ4Baf13YSFqd6X1iG0yTLqZtdRzos3hZ8SzEA3Nina4x+3yVlR/ds+rIu+si4
         KaeZB2wjBgXMWkkZuy3jmbjx+jiPzFXIaxLoOa/7JJW1P5K5YdMiY3ky8pW0NNGie1LJ
         EwiY0hTiBrkzpaqY4FUyOA8IGQ0LArF3GkGm1uqUue0wMOICxniNGc0qPqySGTwUoWqD
         g/UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zDzjKRXB;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id jz19sor5114311ejb.38.2019.05.14.06.16.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:16:55 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zDzjKRXB;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=MTM1aBzPfSK5tgU1k2RNG5j9nKyYFdiQfhSRyC1AQNs=;
        b=zDzjKRXBJHz2yPiLvfNwWdJqq/vB0SaFrHEGC+4tdjK7qgnCrVKdrQGXbzYdw14oyQ
         2FN8i/6zGtMT7lmFJlnRkAQy9xn0Tp8jrpcCjZpMztqBnpJhbPLgLKtBXA5z8CinroXQ
         oUFY0Wc1G6z6gMD8EtLGHoj+izORshYJT61j0WN+f7ynFTnhvncUf8umGzpqVB3Cm+Uo
         tVXzXMPSSLzGbhwbKsIi1DOaLf+pAZVzIsTMvypZUewODOBy3mGMSnUKEn+UfHghHFyo
         n02Y3xxyaGokkB8Wh+M10bEQkurf0e5pdpzJBL1swKYPqDuk23hNfPs5vXLP7F6ulYgp
         ZoEg==
X-Google-Smtp-Source: APXvYqxcAIh9/gohpAQTlGcytkwF0FDILsHXqj2wEvoP1yEMfI5z16TGN2EPlhSbHRGWJA81mLADdw==
X-Received: by 2002:a17:906:74a:: with SMTP id z10mr15167062ejb.199.1557839814937;
        Tue, 14 May 2019 06:16:54 -0700 (PDT)
Received: from box.localdomain (mm-137-212-121-178.mgts.dynamic.pppoe.byfly.by. [178.121.212.137])
        by smtp.gmail.com with ESMTPSA id h8sm678784ejf.73.2019.05.14.06.16.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 06:16:53 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id F1D16100C33; Tue, 14 May 2019 15:28:20 +0300 (+03)
Date: Tue, 14 May 2019 15:28:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Larry Bassel <larry.bassel@oracle.com>
Cc: mike.kravetz@oracle.com, willy@infradead.org, dan.j.williams@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: Re: [PATCH, RFC 0/2] Share PMDs for FS/DAX on x86
Message-ID: <20190514122820.26zddpb27uxgrwzp@box>
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 09:05:31AM -0700, Larry Bassel wrote:
> This patchset implements sharing of page table entries pointing
> to 2MiB pages (PMDs) for FS/DAX on x86.

-EPARSE.

How do you share entries? Entries do not take any space, page tables that
cointain these entries do.

Have you checked if the patch makes memory consumption any better. I have
doubts in it.

