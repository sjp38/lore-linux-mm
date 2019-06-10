Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B854C31E74
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 14:28:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1A68207E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 14:28:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1A68207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42C7A6B0266; Mon, 10 Jun 2019 10:28:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DDEA6B0269; Mon, 10 Jun 2019 10:28:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CD1B6B026A; Mon, 10 Jun 2019 10:28:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D0BA26B0266
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:28:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so15674090ede.0
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 07:28:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZRcnd+4FFAqe8xm4XtIZs23v1ZxzreXxrMk5JFVduLs=;
        b=pE61iO036Wxxb0xOo0j3wJM+NjGu4PEUUm5TMOJXrBtQ/JbV5Yp1rsug8UwuEtyQns
         CSlGoTtLQ9ZzU8ROrek1Hw80vxaj84UcDeo1F9U0TmmWIaRnpO50c7GmaM3Mb1EW8Tl2
         NKQqJCXWVlNVk8Ja0XbiXy+LcgVzoYK/EIdQirDoHLAj4B0UqwP/ILmSoArcqFwW3Ys/
         7vXV7Lrpe+TJqR1a12/FIPcQsTXMZ9f1qZmFAA0hhkTcCAYQPCLJs/faL5wovF9OX5Sa
         HeRgeYLyvLhNraD6A7DYuGMJztkSD9b/8eIGyqxzdLxcnaIG1EURHA/fY63uMq6CzPPo
         P0hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXXsCubGTq/YTXzTaMkPy/kO/Sea0zBfh7g9y1wUJVLfukKEY9N
	ZVQlbT+nbTctHHW2EB/OGAFVJAdqWB8/yyiIhxZOgSOCLSEbBKYHem/ZCi+wy3fTQcN3r2W9LZq
	dr2+PMyKQ/ebb8Nyjpv4dB4rxtG/7k4NW43hpGyQFFXGiKHOnbamRUPVKYQM/tQMvbw==
X-Received: by 2002:a50:996e:: with SMTP id l43mr49203500edb.187.1560176917428;
        Mon, 10 Jun 2019 07:28:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0Hxt2RplzR2vaal1cxb1U2/6TMOboQfJdtfFrpECgbHZcW0/o7xSB+38M32w7BdZ0f7fG
X-Received: by 2002:a50:996e:: with SMTP id l43mr49203414edb.187.1560176916595;
        Mon, 10 Jun 2019 07:28:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560176916; cv=none;
        d=google.com; s=arc-20160816;
        b=qdeAw2HsNO78lxnoNHldiK2goMrmbshB3FjJ+cE3ixv1EV1Ffn+P//et8cgMPMAWWT
         OpnjnqtPbjCDs49ESGSwzv+ulL/p+XflBA11IpX1/IS1Q2aH7rPcJu0LA2/qKuP5gfFE
         cWQxF+iYhlPIwBgd5Bb+pkrK3uJdwEEYvCnAVPghJrbZ9IddahuDTYwmKBhAIkV9JpQa
         HvPhF13zyZ3YHSI+0iEn9CjbkfbtF6LVuTt7+CeqFUfZskI6jT2+ASr2v0CzKVq9Dc3b
         02fMDRZWu+OxDiCPpVtslKjwCaO25mQqXqlcifqE3BklgeWvV3b+TSNDJBf+/OQwqQ2i
         cK5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZRcnd+4FFAqe8xm4XtIZs23v1ZxzreXxrMk5JFVduLs=;
        b=lOS+cQABvFJRvQ3almcYSiOsoBQOPMr7t8LMA5tfN+YqQJKeOoeZmACBqoEhJ/61u6
         1DSeOO+arbWTBvR4kR0YJpG8qN7lfmUwTumGaULTrsqob9wxkPvieZDTj0iPXvPwtokz
         Pqf9Zf53L52BCe/7zX/yjetxEfiDWCX+x+B9kCR5B8XgB+Ghyhd9jz2RUFbqm2Z+Vw9U
         0Rvy+gGgCpRxg2RGQsWnKpLY0g/VbTKSYAxgBfFdOSSeVCvvf2c3p2pjB9yLVu9DDU3N
         ZQrIvNjRJqVyVk/23t9DW7pGbM4HJoWbTs21zKI79noOpACXmTSc4B0uZb8Nbl7MMw6G
         r/uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id u58si3826049edm.309.2019.06.10.07.28.36
        for <linux-mm@kvack.org>;
        Mon, 10 Jun 2019 07:28:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A6C8A344;
	Mon, 10 Jun 2019 07:28:35 -0700 (PDT)
Received: from c02tf0j2hf1t.cambridge.arm.com (c02tf0j2hf1t.cambridge.arm.com [10.1.32.192])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AF14A3F73C;
	Mon, 10 Jun 2019 07:28:27 -0700 (PDT)
Date: Mon, 10 Jun 2019 15:28:25 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 05/16] arm64: untag user pointers passed to memory
 syscalls
Message-ID: <20190610142824.GB10165@c02tf0j2hf1t.cambridge.arm.com>
References: <cover.1559580831.git.andreyknvl@google.com>
 <045a94326401693e015bf80c444a4d946a5c68ed.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <045a94326401693e015bf80c444a4d946a5c68ed.1559580831.git.andreyknvl@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:07PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> This patch allows tagged pointers to be passed to the following memory
> syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprotect,
> mremap, msync, munlock.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

I would add in the commit log (and possibly in the code with a comment)
that mremap() and mmap() do not currently accept tagged hint addresses.
Architectures may interpret the hint tag as a background colour for the
corresponding vma. With this:

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

-- 
Catalin

