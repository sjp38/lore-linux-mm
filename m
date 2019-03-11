Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74027C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 13:43:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30193206BA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 13:43:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30193206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F9678E0004; Mon, 11 Mar 2019 09:43:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A84E8E0002; Mon, 11 Mar 2019 09:43:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8705A8E0004; Mon, 11 Mar 2019 09:43:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4F48E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 09:43:16 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p5so5285253qtp.3
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 06:43:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Z3EIsUvEIE7G0WMXubY5nFUqlUE4AmhxMu27cHfiDB8=;
        b=s+I2kHNyRQC9vtrxEu4NuZNxqFpFfiAW+i+eOFtO2d/vgsUXHHSSBYLMi+ZcbI/plS
         PxqbCmxs+8yclwVSkFvyKfuO2y31mRO0f42ImVK8zTeOpAb//31LD2xSSh4WPDbHwcTD
         TM0O0rOQjaQM1CGrD+dg9p662gOjGsempIenaNO30IQk6h26arrQ/6wwvCMbaCa91Csx
         tpD0ab6MVxzDRTVxLrd34VB7+cWUkO4kKYhARv+EHsjNztvP0FKbc9/KclVPrVAytoXG
         ySaeqx9+hInIqtGCnX8aMCv+rVXpZyv21dcEgXV918mZP0VfS9p6d27ly9MgVCAQQQXd
         TIZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVcJH7pP64b5afLFYP0na3VVimRdjv24HZ2EvE/VjYt8NVlDkqc
	saqG9gEtZ5tjT6FfDYQcJNJOZJK2XEOYbT+fVmJtuY5ngaNgMwiNLxykoEZIoJQ/i9S+ODC4zDF
	J6zyLca4lxk8ZMXEyJIfjwRQnby4OYQOx7eERJdBHbjwZR7PVGhgcC2XE0qYKvV7UEg==
X-Received: by 2002:a05:620a:1288:: with SMTP id w8mr1821988qki.338.1552311796156;
        Mon, 11 Mar 2019 06:43:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsaAC1B4F0FYJH6djMdFzQ8JWSaKiOC2XOORJg5bp3UdneLGQot8EtAbHqLvkMo5IpRAAB
X-Received: by 2002:a05:620a:1288:: with SMTP id w8mr1821921qki.338.1552311795131;
        Mon, 11 Mar 2019 06:43:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552311795; cv=none;
        d=google.com; s=arc-20160816;
        b=agrGgGRvB0u3gclJKhg/g+blfWcepoiLQxhqvOivaBz1r3nW5olxfRb+bqT36PkAaS
         kB+RzX9u4JObXd5jWIRZTwqda8EigjhodKFtiq81zgYPZqTsc0n1EPjYBKXLNOhnmdq9
         aeDDadH3LYkt5oFCRpIevnsJ6Enkx37uc8q25Jzr+GOU1AWetLH3lJWbdxtp+N2BUtDg
         yqqMrYzgc+5fkxTUL+FxIJplqSOLg+YgW1hql36EZk2L3ygfVqQ1+fFbGBHz20IMvSNs
         lpeEmAHl447xlTlUWAcNwksERc6Uj3HeCFdpaQC8hOa5/OtxctVlPmutkwGQ2Co+7s4X
         LPfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Z3EIsUvEIE7G0WMXubY5nFUqlUE4AmhxMu27cHfiDB8=;
        b=peXJW5+D71WSnCZDBKWzc6XRMSoscAQkScUNztSiKEV4C82r1FmslZe+4xRPQtufrc
         Q25I/RftR7BU4nGe/VCvU2sT61KzNd8U8bPqZNLcM/Q6/6G0Xajt5BVhTCBLqVDl2bWX
         RC+emVEpY/MRe1JTI2UOh66TYBQI/FTpKTWXExuPUgoYXU8RP2Y0keCY+Md8bRRdSNeb
         guqtTxK64rkK11O1+QTN2ezGuTSsYbQXHTNcqmyttEd6tArSn8YBj2IENN3oxh9/Q1GT
         dmNG8uSwTrEkkkncFdI9qI1iG+0mdHwxV2Sq/f67+4katr+h21OQ/jlQGTKu3oPKnWt/
         fBqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r30si2099322qvc.94.2019.03.11.06.43.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 06:43:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 64A5430832CF;
	Mon, 11 Mar 2019 13:43:14 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2AA7D8BE63;
	Mon, 11 Mar 2019 13:43:06 +0000 (UTC)
Date: Mon, 11 Mar 2019 09:43:05 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190311134305.GC23321@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
 <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
 <20190308194845.GC26923@redhat.com>
 <8b68a2a0-907a-15f5-a07f-fc5b53d7ea19@redhat.com>
 <20190311084525-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311084525-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 11 Mar 2019 13:43:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 08:48:37AM -0400, Michael S. Tsirkin wrote:
> Using copyXuser is better I guess.

It certainly would be faster there, but I don't think it's needed if
that would be the only use case left that justifies supporting two
different models. On small 32bit systems with little RAM kmap won't
perform measurably different on 32bit or 64bit systems. If the 32bit
host has a lot of ram it all gets slow anyway at accessing RAM above
the direct mapping, if compared to 64bit host kernels, it's not just
an issue for vhost + mmu notifier + kmap and the best way to optimize
things is to run 64bit host kernels.

Like Christoph pointed out, the main use case for retaining the
copy-user model would be CPUs with virtually indexed not physically
tagged data caches (they'll still suffer from the spectre-v1 fix,
although I exclude they have to suffer the SMAP
slowdown/feature). Those may require some additional flushing than the
current copy-user model requires.

As a rule of thumb any arch where copy_user_page doesn't define as
copy_page will require some additional cache flushing after the
kmap. Supposedly with vmap, the vmap layer should have taken care of
that (I didn't verify that yet).

There are some accessories like copy_to_user_page()
copy_from_user_page() that could work and obviously defines to raw
memcpy on x86 (the main cons is they don't provide word granular
access) and at least on sparc they're tailored to ptrace assumptions
so then we'd need to evaluate what happens if this is used outside of
ptrace context. kmap has been used generally either to access whole
pages (i.e. copy_user_page), so ptrace may actually be the only use
case with subpage granularity access.

#define copy_to_user_page(vma, page, vaddr, dst, src, len)		\
	do {								\
		flush_cache_page(vma, vaddr, page_to_pfn(page));	\
		memcpy(dst, src, len);					\
		flush_ptrace_access(vma, page, vaddr, src, len, 0);	\
	} while (0)

So I wouldn't rule out the need for a dual model, until we solve how
to run this stable on non-x86 arches with not physically tagged
caches.

Thanks,
Andrea

