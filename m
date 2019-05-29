Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FA92C46460
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 00:23:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BE9F216FD
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 00:23:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BE9F216FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D2A26B0275; Tue, 28 May 2019 20:23:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 983AB6B0276; Tue, 28 May 2019 20:23:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 898C56B027F; Tue, 28 May 2019 20:23:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3D66B0275
	for <linux-mm@kvack.org>; Tue, 28 May 2019 20:23:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y22so536199eds.14
        for <linux-mm@kvack.org>; Tue, 28 May 2019 17:23:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zWbqLuxc9T3i4OwitMVE7R7dtbwb5y/QPhxQ8ywqOxg=;
        b=sqQvPPPGsYV00dwKMkCfNW0oa5djLZF2tTByDhBvtqm14546bcGLOY7VOcn2R4wkio
         dNvup/UzOgVvdZ6RRXUZS+JXQMCEevIxeKCy/DLL/TujGI7+A9z+WGq8nYf0FZ3YyDe3
         Sm3dNGDUhGSr7gRmAlGRypg7FkL6Mcr+sWRCKCJ1LPOmZf+28wrR9Lb0NdeiAV1xkx43
         ZFleBvJ36HREBYealArL5fg7Ujjeezen8eUQUHNBK6T8xXto03sbcHXfDvtYq8lbd7RO
         J+1xitPx/Xx4+uHAI+obb1ZXK8cr3+x8iecSu/1/y9G0nRtLwBlMdzRdbZ1NHl4/yxz/
         6zIA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAVIq8UehPIrUcVd9jon5QdC4FWH9ec0tVbnIbzKJScXe35qEd1u
	YqA9pAFz61upZ1iz37USBXC7E7YvYTJ4tNhApc/ByV2xzBJYzaBTzM+pbsLmjoJVofEnwYn0Foy
	/JSX+gp7odQ9iENw7YhPB4xhzVsUimf7h7S6slbBm5/yhrU72S/gtGywngpK9QqY=
X-Received: by 2002:a17:906:d212:: with SMTP id w18mr37077149ejz.289.1559089411905;
        Tue, 28 May 2019 17:23:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6FX4AWd4fzpfapcV9a8Otco3jZw0P46zsDK/oKYYRtz3HVtwHwcZ544KquwZtzRbI7yde
X-Received: by 2002:a17:906:d212:: with SMTP id w18mr37077091ejz.289.1559089410669;
        Tue, 28 May 2019 17:23:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559089410; cv=none;
        d=google.com; s=arc-20160816;
        b=TvXDa+5EMzq1aqBpYzL6ELw7nE4S65kQNoeY7V90MhFFFpwgg5539pcv+GF4lwub5u
         r61p12XkR976fEviIP7V11MLZlKaYzThN9UVPL87dsOsiqQkdyFy2901UA7Ov7b5tl69
         yWwPrtbeeV/DI6n0z8W0o0OnDqByUDmqYEd8Qf9k3DSD04920tUHTqAXoq3/9/+ihp1r
         nQ+uuOPDIjCS0GHxVq2wbkYzE5/BsYdU6KxC38pA1BMs+ebkCunCddBdjvzAlTO7JZf8
         CO0OrDyaGeBJWsVGaMCZOwsVzG++jXFBF6D0Sh/CXOc/FQlSinCFAhG77GDC86dwgBLW
         jCqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=zWbqLuxc9T3i4OwitMVE7R7dtbwb5y/QPhxQ8ywqOxg=;
        b=gJ70eskN7jVQvLpTMzLKMSiTAqjrtFxyhcyJS21Zl6L5mu6e67h+3eE8u1dxMIHq+T
         PRWI9Yi08P/dV6fGhibVbwxXVGnJpyYa7LfxGU/r/5BxOeKH90OOYPtg5UFdMUxskzix
         CCkbtjRnR8TfEmj/n8AXx5JU74LBjHNG4CZKq5bfbpvblwHS36I3VxM+/nmyZbpla/D7
         uygwY/+YEWDEaYrJ5cWdfmT76BVaGSIUgQmOUQXvjYQogG2DjsF+5dge2csQ/K+J9ZAz
         kNcDRF5dbuI9er0+zluFgz42+4CxjD0/OJ2U6f6Bv3tWmSiNaqHyJQf80U1SSdUHiGSr
         FxWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id w4si9606440ejz.118.2019.05.28.17.23.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 17:23:30 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::3d8])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3319E1400E0D1;
	Tue, 28 May 2019 17:23:28 -0700 (PDT)
Date: Tue, 28 May 2019 17:23:27 -0700 (PDT)
Message-Id: <20190528.172327.2113097810388476996.davem@davemloft.net>
To: rick.p.edgecombe@intel.com
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org,
 luto@kernel.org, dave.hansen@intel.com, namit@vmware.com
Subject: Re: [PATCH v5 0/2] Fix issues with vmalloc flush flag
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190527211058.2729-1-rick.p.edgecombe@intel.com>
References: <20190527211058.2729-1-rick.p.edgecombe@intel.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Tue, 28 May 2019 17:23:28 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Date: Mon, 27 May 2019 14:10:56 -0700

> These two patches address issues with the recently added
> VM_FLUSH_RESET_PERMS vmalloc flag.
> 
> Patch 1 addresses an issue that could cause a crash after other
> architectures besides x86 rely on this path.
> 
> Patch 2 addresses an issue where in a rare case strange arguments
> could be provided to flush_tlb_kernel_range(). 

It just occurred to me another situation that would cause trouble on
sparc64, and that's if someone the address range of the main kernel
image ended up being passed to flush_tlb_kernel_range().

That would flush the locked kernel mapping and crash the kernel
instantly in a completely non-recoverable way.

