Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76971C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:26:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E5B720B1F
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:26:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="sQw0Lu9C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E5B720B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEAE16B02E0; Thu,  6 Jun 2019 16:26:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9BAD6B02E2; Thu,  6 Jun 2019 16:26:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A63AF6B02E3; Thu,  6 Jun 2019 16:26:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAAC6B02E0
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:26:48 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a125so2618336pfa.13
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:26:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8bmaTLUYmWyy33EIwh6XtvatyhxxpHqVpTk9Zded5gQ=;
        b=gW2FqMm1+yau5PIhn6hWDZg3WMfj4agxEUGB4d+y91lUoTujcfDoS/WdWkybDrFZZF
         inHREUtAtsK8MqcqL3BDWZS9cE/RqyKFWlriwEyr7wK3+JDiSM6MvYHkDZ+3vVVsKZbR
         ef92mdCXbeV3eDnCXvQdD4NdlvlSj9z5QpZCupiMai52ICSBByzoU9S4/U4/zV6zUDw9
         vm55M/8lFTCNAFWWd2HZCNtVQ70Edlb7MmTq2H3qUy5Rw0PEFcIhYNBEpDqyh/yZhpr1
         LxdUi6yL2cSkNpmfckBRF7qdigvGRSzuYZw7EoPOetvC/zawQ5HkV211o3nzUWcxDDhZ
         tF1g==
X-Gm-Message-State: APjAAAUey6U/EIJU8ukQ9WVQ083QpEWXJEOrXI+E0lCw9KkOxSpk2eNk
	ZIF09sHU4TpqUjOQbpeUrWitY1CiS9B3+GB/U3t2l2Ziv+M7y6kkA+ckueGY1jBofaIgVUsbJCU
	bnZlDKm1huQiFjaiJEklIJ0lZM5RBhIrGmqyZdBQkqgtf2tb/Q9sRFTAjxy0LP+Atiw==
X-Received: by 2002:a65:60d9:: with SMTP id r25mr353956pgv.228.1559852808058;
        Thu, 06 Jun 2019 13:26:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxo7GgbcXDubL4DgmMPXdWSqIiWNm0oOj3Cj2tC50ASf2lOrkLb0ag3yxs1i6sCXFeIEHv
X-Received: by 2002:a65:60d9:: with SMTP id r25mr353914pgv.228.1559852807414;
        Thu, 06 Jun 2019 13:26:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852807; cv=none;
        d=google.com; s=arc-20160816;
        b=HadgEfDT/Ocmk3RLbUeVDIHkIo5RNmZJeiwGUpOjRlLjloGu8cQLpV5Xz/MLsrSV8/
         N+N7ySX4/0OpFYtFoAHPDBw7s2KqP+IK9ucHFEsY0IYpBs9U5j1pZbgvI3+9EhB4nWJK
         BMWk39CgU6dA1eMYo32hNh8b1CF0yFIN5Cnc4qKxHQJZB+MxVUDJVjP6qvBmQBRKlTJg
         86dks7lpef6jlP75nGx0EWI7pcHFnihA9ceScjWQH0g8TEWEttuN5fvHZgwt6GufMN6j
         W6LVmYfBWkTZF9edfMrjxVTOCG6SeKZ0qdIWxddvn8qW4MkdIOhneB5x+DvUAxM5Ff6n
         PXag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8bmaTLUYmWyy33EIwh6XtvatyhxxpHqVpTk9Zded5gQ=;
        b=ENOqn6J8zkyW/hsK2wCtmZwRyAt7S2wYK4SQFepK2j537jhIBVwSwEiZQBshrLnVc4
         xGJFXXNDshR30UdeVzbR3t5WneK6pbrlcRqGiSQEMHlI5+P5NMR47tITMxw1GGZOretG
         OwKITC8j412Gj1PXBHbwQd4hl4l5gHSAgSIDonukl9CTekg0D+T6noQuLveRo+EdXVAL
         HmnW/DY4FObxfTATjZ+q13mML4G7JWRJgQxcXk8wrJaDSyZxumpxZfhTSqYETOLo5eVe
         F3PBXcO8fnh7hKmBix8RV3cJrkOf01TJjfkYY/SnKyEbEWvrmv8Igvs3UOl2BfEdrkmX
         IV4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=sQw0Lu9C;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y7si73672pgj.252.2019.06.06.13.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:26:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=sQw0Lu9C;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D86DD215EA
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 20:26:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559852807;
	bh=KPzI+YwSmOs28yM0mu03w5J/5AGDUhBeJx6OEeWoVX4=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=sQw0Lu9CAjfPFLxj0f4izZgbct9wON3UkoluMWtqqvnVZi7LX6+PqbRKcUNtGFPRC
	 VwSx/IwIvxNRl/Eh2ce4stDlwhsMthuxOUrJ/gpf6YOh6guy7TBeQP/aoPkMh3L+/v
	 d2/JTlzLlzvCzvUELTMuYV1T3nAUPyJwHIqwc0MM=
Received: by mail-wm1-f51.google.com with SMTP id z23so1213468wma.4
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:26:46 -0700 (PDT)
X-Received: by 2002:a1c:6242:: with SMTP id w63mr1265538wmb.161.1559852805470;
 Thu, 06 Jun 2019 13:26:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-10-yu-cheng.yu@intel.com>
In-Reply-To: <20190606200926.4029-10-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 6 Jun 2019 13:26:34 -0700
X-Gmail-Original-Message-ID: <CALCETrVhw4U939E2RorUMorxx8VqLyg2Zm8qEMUSM5pX+cc2FQ@mail.gmail.com>
Message-ID: <CALCETrVhw4U939E2RorUMorxx8VqLyg2Zm8qEMUSM5pX+cc2FQ@mail.gmail.com>
Subject: Re: [PATCH v7 09/14] x86/vdso: Insert endbr32/endbr64 to vDSO
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, 
	Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, 
	Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin <Dave.Martin@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 6, 2019 at 1:17 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> From: "H.J. Lu" <hjl.tools@gmail.com>
>
> When Intel indirect branch tracking is enabled, functions in vDSO which
> may be called indirectly must have endbr32 or endbr64 as the first
> instruction.  Compiler must support -fcf-protection=branch so that it
> can be used to compile vDSO.

Acked-by: Andy Lutomirski <luto@kernel.org>

>
> Signed-off-by: H.J. Lu <hjl.tools@gmail.com>

You're still missing your Signed-off-by.

