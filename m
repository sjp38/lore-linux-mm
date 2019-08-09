Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65FA6C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:12:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31DD92171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:12:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31DD92171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C05F66B0007; Fri,  9 Aug 2019 10:12:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB6FD6B0008; Fri,  9 Aug 2019 10:12:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACBC26B000A; Fri,  9 Aug 2019 10:12:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4206B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 10:12:03 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 28so9314236pgm.12
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 07:12:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=c+3bCqxJo39DpqIWFRjrtINk477xyXEJPFLQQV7GifQ=;
        b=Zhl9jStL6xNeblYIvcF58wDtzGkuLfZHZdiJFtBIOlppXTWUfj0oZ7pgt9X5EpExBM
         8xvN5PZL3KkGtFH2xwhP1v3xyk5YqA9xNt1SGUeMfqKaj5aAMQ1WTdkl2xybTJlJMTqJ
         LOswQZaG0oMNeByo+/LhDoLaD2KvFtzgu+9bVrhPEAEMdpTCXiT4hMhdZdSW0Mbm1c+X
         n1+VHsKI+3o5Q1NGyANnmJWjh1ktD1mIfTgGe6pGz1EVJ6P7F0kQgpU1A5mf75Ev9Mb7
         n5cRrgrXua6sldQY88SWFhQnfoIHjL5HSGsXBMzqME08mWwjfc17uPyJv7U7daNpYT/m
         +hIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAUvuxQn6E7gA3zCmbMSRLUT5Rv7wmGwpz/KfW3VRZQSUl5ZCvWQ
	W5IaJ7BlwtHuP4SvVkMSeILVP7fs/wfqmW9ljze6PmZKJ6SPpgRCtPczeXrp24XS8GkBZl9RzK3
	ui5vt8bz6qYL4SEaBiU0x2FoqUzHuPOHBHkfljbiw8aNKumrg1TGApho3yzHOGuKp0Q==
X-Received: by 2002:a65:64c4:: with SMTP id t4mr16468756pgv.298.1565359923061;
        Fri, 09 Aug 2019 07:12:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxU4wc1p7kvQvgX+/DufU+kg/58WQfetthoi37pVMc4UnVBQM6MXh0PHubi1EBXOj9dc0gq
X-Received: by 2002:a65:64c4:: with SMTP id t4mr16468701pgv.298.1565359922343;
        Fri, 09 Aug 2019 07:12:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565359922; cv=none;
        d=google.com; s=arc-20160816;
        b=X8X0FE0K6DuhBcGtbBuAPiFeMIV4TGazXrf+zqFIEL+TzFBCcwIRPD0UN3mCU9oF3U
         GkJ08sk7dJKpF/b9HdySI7LxEpy11OgMbKJHvQsjbhhNa6GrdzEnt1jP3uWbGkiP2Pp1
         s17kc298oxXp1bSWbCqhQIogE+Twj5dVlbBrwP8s6NToJYi1bZAHHJpTiLqJS59hA+qX
         Edlbkrl4267uXnz7C6eTVAEeb5Bh2VvqJrrdeHqD0OPg3jaDfXReamdSGmsuymbtqi33
         Lnsw9mtwLvmDKcOYLQIXAAzPZd7MnPh46wdt6kcgKPZccaH2z07mIhrg4GvAInhwxMYp
         0BLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=c+3bCqxJo39DpqIWFRjrtINk477xyXEJPFLQQV7GifQ=;
        b=zRi8XQ2sCcJSTxqS9p9XOjtICdZmBnz92ZLpFFFF5ZI2SSyRJhEBRRB9UKiLQ0O70C
         GhsKB12fK3BI3rRp3UY/taSKNIjqIuG+Vtb26OJNLi9ug4MpgtPn8KsMO58qOsvJ9A2T
         hTzPLX3buupDFB++9+XJu61vdftctz8MPw0Q/f5PKUjWgsG5fmyigapmuRAA0ucJXHLb
         SVakDb+yCDabLl7lYuIkopIEbq1lC/76AhGOVKM0rG1rpRgBye1EmMtvUbAYGhXvVaGb
         6JmmM2jxrAeFtX+Fp0PR8F2pt9ZDR+gSJDer1Y0/lWFNL8+8dAZ/r7MghYQIe97DhsB7
         cr/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTP id r16si6509120pgh.385.2019.08.09.07.12.01
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 07:12:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: 725620696fd34fab965989687eb53529-20190809
X-UUID: 725620696fd34fab965989687eb53529-20190809
Received: from mtkexhb01.mediatek.inc [(172.21.101.102)] by mailgw02.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 735304464; Fri, 09 Aug 2019 22:11:58 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Fri, 9 Aug 2019 22:11:58 +0800
Received: from [172.21.77.33] (172.21.77.33) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Fri, 9 Aug 2019 22:11:58 +0800
Message-ID: <1565359918.12824.20.camel@mtkswgap22>
Subject: Re: [RFC PATCH v2] mm: slub: print kernel addresses in slub debug
 messages
From: Miles Chen <miles.chen@mediatek.com>
To: Matthew Wilcox <willy@infradead.org>
CC: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew
 Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <linux-mediatek@lists.infradead.org>,
	<wsd_upstream@mediatek.com>, "Tobin C . Harding" <me@tobin.cc>, Kees Cook
	<keescook@chromium.org>
Date: Fri, 9 Aug 2019 22:11:58 +0800
In-Reply-To: <20190809024644.GL5482@bombadil.infradead.org>
References: <20190809010837.24166-1-miles.chen@mediatek.com>
	 <20190809024644.GL5482@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001192, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-08-08 at 19:46 -0700, Matthew Wilcox wrote:
> On Fri, Aug 09, 2019 at 09:08:37AM +0800, miles.chen@mediatek.com wrote:
> > Possible approaches are:
> > 1. stop printing kernel addresses
> > 2. print with %pK,
> > 3. print with %px.
> 
> No.  The point of obscuring kernel addresses is that if the attacker manages to find a way to get the kernel to spit out some debug messages that we shouldn't
> leak all this extra information.

got it.
> 
> > 4. do nothing
> 
> 5. Find something more useful to print.

agree
> 
> > INFO: Slab 0x(____ptrval____) objects=25 used=10 fp=0x(____ptrval____)
> 
> ... you don't have any randomness on your platform?

We have randomized base on our platforms.

> But if you have randomness, at least some of these "pointers" are valuable
> because you can compare them against "pointers" printed by other parts
> of the kernel.

Understood. Keep current %p, do not leak kernel addresses.

I'll collect more cases and see if we really need some extra
information. (maybe the @offset in current message is enough)


thanks for your comments!



