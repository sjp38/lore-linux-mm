Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00D38C31E44
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 00:55:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF5B721734
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 00:55:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NiAwzvuW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF5B721734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39D676B000C; Tue, 11 Jun 2019 20:55:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34EBC6B000E; Tue, 11 Jun 2019 20:55:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 216FA6B0010; Tue, 11 Jun 2019 20:55:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7A8B6B000C
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 20:55:53 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t64so8480299pgt.8
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 17:55:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=JNCR25wKoUF8GmXR1+h5Qxc2sputayqDi9OAgx3GkdA=;
        b=Fa4djVfAA4QoGFBCl7cDIaJVBEIh10FMg1Kyp0Z0abnQpntYSylp/ZQEez85WbQWOT
         xFKaPx6zyGJYrtoODjnvtJQfaXHjCau2mc/aS7gn9vIc94pUUf0wHLEquW2q06bv26Qk
         pLWMo+bubycN39FCX8nnGl03HrVx8ldf5AcSQNklzs5gusY5gorCALxclprZRMd77R3E
         PxurlrYOnL/5d260mGQoP579rnwSYwFicCMGnYbNQMM26yvQIP8eiM2RanfMp/AJ59o/
         8BIxxXaf9gmoSY4VnZj1AuG+bzvP3e0IxmMIigTTN7IEvSfDaN8R8l2w+6GkEnHP6mau
         a9kg==
X-Gm-Message-State: APjAAAW1peYgHW6A7MeccWo0efUI2V1vDqJAJC6tyHOejg5RnjaIqhyq
	J5KbpjzxDtVEaow5YcpEWTB0A5cq48eThJRxAWtGY/6dVpWK25TOnpPe0CQM9PAgQMhknoDi/ij
	+YcLDCvRgu3h2jjxQhYvVIJPEOWqLBQETWLu6iBF99ESQOsuvJhT72nkSBL4BiLuNVA==
X-Received: by 2002:a62:e815:: with SMTP id c21mr41452244pfi.244.1560300953497;
        Tue, 11 Jun 2019 17:55:53 -0700 (PDT)
X-Received: by 2002:a62:e815:: with SMTP id c21mr41452203pfi.244.1560300952655;
        Tue, 11 Jun 2019 17:55:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560300952; cv=none;
        d=google.com; s=arc-20160816;
        b=AGF7nyqcrlG1C56P8wFmH/MgS+6YleMKqs/7QShf3xZrO4n/cDerEjqxMc5VECqhsZ
         qzq7qepmdi8Twlf1MUSxCFd4+VtcxAaUqRPVvW7ot+2r5SLHpbLV9L6T7tEj+Y861uGx
         xiFsMfDkCOx1UTjJA66W/5Kb6JxEt5ZX+9yl94fynFpc+RwIr7N21kD6OvLgH+A2EVlj
         m9Qkzs2IuTwPv9c45w0DDzIq+aXzviiwxdaOCFQBu8TFLEeBCZVmsJC5PYp06il6TkN2
         nXIn+dXd3H+D2rf6z+JRKpodji2L4Vr9TBLPeOyhFu2gNbdj4xKSdmywbBAMDP4fEMPW
         FHoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=JNCR25wKoUF8GmXR1+h5Qxc2sputayqDi9OAgx3GkdA=;
        b=PAkpoGJpMrau2RMblPaJ/831XhC8Ny4RKdLsnZHuvJMoZygRkeMrJmlMgbb4QdsicM
         scE4l70j3Yt2Ta5NDSrw3MiucmlPxBDbKWkRGBAG07SeipDGSWypjTsPEI2qfUJ4Q8ca
         WIS5bqRS6BovLjJZAkFOV+adeVGIQWaQ49vtiEXPJ9phFWjZurWVJrkNez1CWUVO6vqr
         RwkLEo+U+h5RAhqTTKyZ6xdzZslRejqYxLUxvTLCzvlRRzTMkSD22vIqYgcrZhQHNHpq
         AIc76RDdSiwVZ5dVAyfjBod6xF0gz3mZ0A51aqobt23iIV5wYuVmM4FCY3w5PLMjrsIC
         B2AA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NiAwzvuW;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q27sor1956687pgm.10.2019.06.11.17.55.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 17:55:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NiAwzvuW;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=JNCR25wKoUF8GmXR1+h5Qxc2sputayqDi9OAgx3GkdA=;
        b=NiAwzvuW1158vo7YqCqImrGi+gOspOS5ptLbXAIoG+Z9ze7uMdcN2eGWAsbNMH7+TG
         3ZkAe/orroen/eLz2qm7eGvkJnmLfn0Ao/sWgWXpra1h3e97Fbq8GTUU6tsqNa0XX05a
         hylXtqpcRAnnO0Mj6KHPmtmbR1ePDFiDX84pGRfqnwJNRN6N/PrW6Cr39MB8mYO7MJlz
         5R3W6R2v9YZy+6iSs2yC/ugh7qMnOvJh1iKbpPuLSnT/ouMOHYhMPkWq+xopLIjw9uu9
         yeTUr5c2xq1OasjqxvVRtr5VrtPFnBVEv4hsmatE9KIsBtR0qj+CcdswIM50TMbSCQvN
         o6Dw==
X-Google-Smtp-Source: APXvYqwFJLADjuhoiaHTsjm93GY2KEIrK+4logzMa1qKh7V/rBYbqMu9MhPfYO/mkPAOmVvGgW7CCQ==
X-Received: by 2002:a63:b07:: with SMTP id 7mr22723250pgl.21.1560300952204;
        Tue, 11 Jun 2019 17:55:52 -0700 (PDT)
Received: from localhost (242.60.168.202.static.comindico.com.au. [202.168.60.242])
        by smtp.gmail.com with ESMTPSA id u2sm3765259pjv.9.2019.06.11.17.55.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 17:55:51 -0700 (PDT)
Date: Wed, 12 Jun 2019 10:52:53 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 16/16] mm: pass get_user_pages_fast iterator arguments in
 a structure
To: Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, James Hogan <jhogan@kernel.org>, Paul Burton
	<paul.burton@mips.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Andrey Konovalov <andreyknvl@google.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Khalid Aziz <khalid.aziz@oracle.com>,
	linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-mm@kvack.org,
	linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, Michael Ellerman
	<mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
	sparclinux@vger.kernel.org, x86@kernel.org
References: <20190611144102.8848-1-hch@lst.de>
	<20190611144102.8848-17-hch@lst.de>
In-Reply-To: <20190611144102.8848-17-hch@lst.de>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1560300464.nijubslu3h.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig's on June 12, 2019 12:41 am:
> Instead of passing a set of always repeated arguments down the
> get_user_pages_fast iterators, create a struct gup_args to hold them and
> pass that by reference.  This leads to an over 100 byte .text size
> reduction for x86-64.

What does this do for performance? I've found this pattern can be
bad for store aliasing detection.

Thanks,
Nick
=

