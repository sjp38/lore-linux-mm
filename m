Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C736C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 11:30:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 036762087C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 11:30:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 036762087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F6418E0004; Wed, 27 Feb 2019 06:30:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A6488E0001; Wed, 27 Feb 2019 06:30:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 794738E0004; Wed, 27 Feb 2019 06:30:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 495CA8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 06:30:05 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id z14so8827262pgu.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 03:30:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=8FxW49ifiHBCD1yq3H8/PJi17aDNnneDM/F+eNfFFSE=;
        b=bjeHJW4yBouzeXheaIU14EuafYMPBUK7UoST0GHwuR5TkiQhxzdlFJw3/4C42KSNm2
         T4rZASV37BRbWwcag6e08BPmvP758P7zyXITCMHe/EZ6CuhamU4B9GlFIxyGfG1ko9Lw
         6ujBn92cC4Zco1ag+iGFJtpd29MN3hN1ZAwvPBrvQniLtAMAyX3EC+nngf1t6r2wW1Jh
         phobQ7MJDqygDGZRa27EGZY8hNeSBK01VKbJ2CJp0sILPSbYzO59gw17EaqS1sGaLtAa
         mW1VSPGhJDvGObGtyieFdlQ2z9mB4nQi1hwYGRE/TiVOUAU8DINJ1HjjN/FBRs0gJVdU
         wzbQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAuYd5G/ylCrGjXR46GnJLm46L+b12hlMqBaWcUV2R+lI+hj4D6NS
	mCCJ2RbX3XSYTHKIfVKvMUAuhHrVfnQQ+JK8sPE6t8ykFmUxVFc06qEL8WF+t8eEXr/jpTKN7nx
	W8+XU0hon/QOiBLPujMiZlM9j5OL0NI3eNvlQAYxMtLKr4sgWupAKI94bxpUIg1g=
X-Received: by 2002:a65:520a:: with SMTP id o10mr2605239pgp.276.1551267004976;
        Wed, 27 Feb 2019 03:30:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYPzgML7BDM503faziTtZz1jg8F6wMm3F8V2oJiZXAbeBak3CmZ1koB8h8HWmYmUnXRffty
X-Received: by 2002:a65:520a:: with SMTP id o10mr2605163pgp.276.1551267003843;
        Wed, 27 Feb 2019 03:30:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551267003; cv=none;
        d=google.com; s=arc-20160816;
        b=kUGtMlbtSL+/9ifft48EO6pv5d3TXurVIsEDsBEQgj909pZSfhNpWE7ff69VMHJ67M
         5y7SR1dySHrJYTZ+WuztwzKkQSdKArn3YGKp/qzbNVz4ZZPCupztg6kirqWYce6Duoaa
         0AAU9VOxovduPYYmxUBX+H+vjFOCp7pj6kgfDhQp0LHN6rvud7oEU2OFBLz3EbFylFcd
         i4lv7HL4911aZ4cQBfnkUQXYQMceI+b+PJsyYWQD8DETPSDdIBEjA7u3ylmevK+uLBEV
         jnLdxlVTZ2aJqa4DfmYHJayKAOxXNQY3fnGvh3VGpT1QMK54gpjY/+DntyG+BMi01DJZ
         zDdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=8FxW49ifiHBCD1yq3H8/PJi17aDNnneDM/F+eNfFFSE=;
        b=vyCvmNFaGoxLHbjNn6tjFX8sf3xy7lThZUSHzanRAVEdNbwJ++C+oxisy4bF2Yf97D
         pTF3UWj1FuYIYrMPoirTh1mHXP2PiNYyBuswhObEobyU52/zO4XlGxGBrDx4rCJ1/33u
         cQwIZxRjN3VDpUy48JVOvBIydWg4fSLKf2nHVEjQV+csBzpYpfqkTgfBa3p1fmq6y89t
         mk0o+c54WrSpQf4W/uHsZ+abXaP92p4wyoegedtBRM33Lxyk1M/j5xfgiAH3+U9p1RPU
         a41xD6OHGPhZwjS4Pi4dGeoEVv3h7BtZwLHWYCREJBroxUeIKPpVOmwz9fmA/4SxtoqD
         HSTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id n19si10572666pff.18.2019.02.27.03.30.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Feb 2019 03:30:03 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 448YPg3cY8z9s21;
	Wed, 27 Feb 2019 22:29:59 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH V7 0/4] mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region
In-Reply-To: <87mumhtxxx.fsf@linux.ibm.com>
References: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com> <20190226155324.e99d5200cc6293138ac5c6fa@linux-foundation.org> <87mumhtxxx.fsf@linux.ibm.com>
Date: Wed, 27 Feb 2019 22:29:59 +1100
Message-ID: <878sy1h3k8.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
> Andrew Morton <akpm@linux-foundation.org> writes:
>
>> [patch 1/4]: OK.  I guess.  Was this worth consuming our last PF_ flag?
>
> That was done based on request from Andrea and it also helps in avoiding
> allocating pages from CMA region where we know we are anyway going to
> migrate them out. So yes, this helps. 
>
>> [patch 2/4]: unreviewed
>> [patch 3/4]: unreviewed, mpe still unhappy, I expect?
>
> I did reply to that email. I guess mpe is ok with that?

It would be nice to fold your explanation about DAX into the change log,
so it's there for people to see.

And I think my comment about initialising ret still stands.

cheers

