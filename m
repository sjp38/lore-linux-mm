Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7924FC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:07:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 393AE2089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:07:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gUrzDU4W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 393AE2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACB896B026F; Fri,  7 Jun 2019 04:07:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA2456B0271; Fri,  7 Jun 2019 04:07:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B82E6B0272; Fri,  7 Jun 2019 04:07:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65BAD6B026F
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 04:07:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id l4so979431pff.5
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 01:07:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KMTOjZOt6BKNdwNx8Ebfe50Na45GQkzWalc7XXT6zV4=;
        b=uW5Lxy2Y/jw82s536P1OZPnNYbVnm3YKUl5lItJYX5JGURJDYXZP8KOpuzvZGDwn4r
         YTnno99xYrkX6xSulenk75+6miXwB89LDt96Kx4LUdpmtS8tGqDbXjmfZdkrpi/LCCp4
         jPEphtX/JqaW05bguZOIxj0V/d6q/MOBDjiy3f7OD9c6g6I+xUH17Kq4czkbD6N49PZa
         0G9YcWXHJ6PZUrk062pVLfEdcPTCfFoikbkCuqYuavAjYAYfVuRL1Rak5l/RGQ7ZmN9X
         8ePMIl/T3LXTq+Zh1ySk7M2/2ETYrK4Xp2kb0W+KSBJIlliJ04/t2WHY6d3WjY0j0swI
         VCcQ==
X-Gm-Message-State: APjAAAWAYQnDvWyxrGxFoZ8T6uW1u862lipHi+ZCrYQZBlyxSI224RzW
	kjfUw+H70IqYzRQ9mZmjwkOge6zKHQLZ6OYEheVW0MjtZUciDoazsxNVhrU1erX9VgBKIN5sUyS
	KYQL2IVVK80LJg6sKtM9PQvlQQ+tFg0L953eq/ckVyRWUKc42mw5BaVMJ9DzB7hVQGA==
X-Received: by 2002:a63:4c1c:: with SMTP id z28mr1657504pga.122.1559894835019;
        Fri, 07 Jun 2019 01:07:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxe+d8QazcW7HdfdobtgBdE/j+TV1RYKO0IqP8hpBm6B7hN7HCrDEK1T3HG1Zv5JRR1dUoI
X-Received: by 2002:a63:4c1c:: with SMTP id z28mr1657464pga.122.1559894834297;
        Fri, 07 Jun 2019 01:07:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559894834; cv=none;
        d=google.com; s=arc-20160816;
        b=WcPxEh5bwsJLjcZB5SJ7tsjjfi8V4Mft7qUxO8jPCT6WHEPbz53udu7nXY1wko19ww
         UR4/lEtqy+3YTkneUqFxhdbxNH+d+dgmDPuKJ5I5rC1aLvLJcqcZL+0aIoOp1GUhHTCB
         3v8DW0/D8tmP4Lh8C2q8PJ6HIo69iZ9t+f6YVSSGXs94DHiLZKcPsnVkQ62qXvmi3d0j
         fooG1E6k1RNkn3vUDTQytb1AS4SG0XqjmprDg86PEJvTSb5TwtO3AZvCvQiMAuR2p6v1
         GxzhBEzsxmn+PC+LoLOcEyEIeusg0kucdJLVh0wXQORc/W6P2B+HuSLcHaK/kgRXcUcX
         dchw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KMTOjZOt6BKNdwNx8Ebfe50Na45GQkzWalc7XXT6zV4=;
        b=s0vnAXsFkOa4ce0ecC6KdumuLuqgkkgJGlAPw1jGWPyXm/PGxyXKq+4VSRo2E/f7+6
         egRu3tRn3h5tqaB4l2WC7lPK4WWXLk6h6CekyoxMNb/3cFT82i1o8IZNu2Nkz3DwrIYR
         RA/XZl1+3gUzuzj6FkDNGoLfTeIGp3xZ47QDutZCARHAUYPxFXYwH5OmSQXk+1erc3Hj
         PGKlw3ePYnHiVQuWbtq1MAH5KQQSz2WkyyFJYsanLO+iY2pLoXo7NzzTVdbOJI3yPsjG
         sUpDQiCgXGXNOEoe8kScON8mPMHSlHpDLK7NJGVxr/MQSY0jMbxm1L2g3sqszv/PoNz4
         sGLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gUrzDU4W;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n5si614100pgj.580.2019.06.07.01.07.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 01:07:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gUrzDU4W;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=KMTOjZOt6BKNdwNx8Ebfe50Na45GQkzWalc7XXT6zV4=; b=gUrzDU4WY3ZDbo8lcxgsikvBt
	Gk/hCRgMJufxg1JP0EiHMgv3rW3FTF5YlIOF5lwojw0Vtmugp/lHlLizM9NRf/e3yKeUqmCd0Zemq
	zx8uNPPPRNfImn+2IFgekQpgFW1/oQy/S2EESOhkYQM/IXXSqv4E/3YDd8nQU8v05iO7ozzW4EGPN
	fwb++MbbuniaJF04HclowhKkT/iaHsGrLExCsLo9SQgROaxNItKKT3ETdE49oHREjTn6pPBhFJtEg
	uAOrOlsb7mWX4fTtopbZirLCbiKs5iuYoa0qGCa8QrZ2hgGEm4z7mb3ANt1nwEQJW5cusG+tB+kxh
	58BwvwZHg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hZ9tz-00013c-Mi; Fri, 07 Jun 2019 08:07:08 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 387A1202CD6B2; Fri,  7 Jun 2019 10:07:06 +0200 (CEST)
Date: Fri, 7 Jun 2019 10:07:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v7 07/14] x86/cet/ibt: Add arch_prctl functions for IBT
Message-ID: <20190607080706.GS3419@hirez.programming.kicks-ass.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
 <20190606200926.4029-8-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606200926.4029-8-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 01:09:19PM -0700, Yu-cheng Yu wrote:

> +static int handle_bitmap(unsigned long arg2)
> +{
> +	unsigned long addr, size;
> +
> +	if (get_user(addr, (unsigned long __user *)arg2) ||
> +	    get_user(size, (unsigned long __user *)arg2 + 1))
> +		return -EFAULT;
> +
> +	return cet_setup_ibt_bitmap(addr, size);
> +}


> +	/*
> +	 * Allocate legacy bitmap and return address & size to user.
> +	 */
> +	case ARCH_X86_CET_SET_LEGACY_BITMAP:
> +		return handle_bitmap(arg2);

AFAICT it does exactly the opposite of that comment; it gets the address
and size from userspace and doesn't allocate anything at all.

