Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EF1DC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 12:11:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E34220838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 12:11:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E34220838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E64C98E000E; Thu,  1 Aug 2019 08:11:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEE918E0001; Thu,  1 Aug 2019 08:11:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB6A38E000E; Thu,  1 Aug 2019 08:11:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 799788E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 08:11:50 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so44728011ede.0
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 05:11:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=BsJn7+VtwgYufjLm85ANil3F49Dku0T16TA8sA6u0Io=;
        b=qKK/a8qLTR+jXOWEoKvqv8lVTH9NxSq1oT/7PElyyaIFbjAnHPFi5T0hJ8HKNhv1IU
         jIQG1wrORK4s8Pf4MP7vFzwyiGnbLFAQtutzxHm1+76p90DAmfCWPj2WR+uqSXuhCqMC
         lmS+trvyTYVuYd04Ql8psD8mkU9BJ/Vge1D+ztaOUa8QKIg8jTsSgEGltGtfpJBsZASF
         hOjANlKewVnMI3+oHpihWNWX4ZgDLEKqhafSvtDT+43T03FwxjNGq6eDdlH3wWy7xjl8
         ezKzhQvCwh7vrzTQYSSLzNEPknLRFK148osUvsUllP1vnP5rlHrimOAjLUyA4HAOoAwl
         M62w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAUu5+hwQbAkI0Wmm7FAXgMz0AxSlxerGg1hsmyByq9UtiqQbyDS
	EKaeY5wdNHCDAT3rukRJqN80XABkdYHylQWtvohFsUdlS8MhlvSEiNsuvJ+HY0IQaZFAezJun3b
	puvQ76Iw9y6Le6XxRPzNUthxT7eTTNECbsB8nh3zea3qFYftoe104+a04xUebMdygGA==
X-Received: by 2002:a50:976d:: with SMTP id d42mr112525939edb.77.1564661509940;
        Thu, 01 Aug 2019 05:11:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiB0YEHOkDyo52fYouUxVLsw6XRXHvWMr0+pMzW514E/jFfqJRoE5tcCm8qBhlwaZUHCZo
X-Received: by 2002:a50:976d:: with SMTP id d42mr112525831edb.77.1564661508801;
        Thu, 01 Aug 2019 05:11:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564661508; cv=none;
        d=google.com; s=arc-20160816;
        b=uI762uZiKDlHu1jJ7mbR+ob9RLkXuDaDCF4UT9oeP/MTIhowIKrPYMN/e/oqZMnABq
         glK07lRGssRiPHGcdZ7oyoySJltY/HH8PkZh9hBb/KHihFKExd1WE23scwg+smf+O0ke
         9k5vxziiz3b8UL/W3Hxee7gQXoM2fyhLi8mDU4z9djWRMFj4ngREH1oIbBx053Q85a8H
         7N2XYF37gzDvxS9ZF8WzBVA32lWZCKY2FoGdTiPYYdzlehxcZMpbP3r9U3Jb+bI1h6ZW
         HRVtGeXOKKOtZdGYuZkc8m6ikGu2Z8cL5cr1eJBKMBTfivXyxFSsxfVfefOfgAXGYwvI
         ZMhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BsJn7+VtwgYufjLm85ANil3F49Dku0T16TA8sA6u0Io=;
        b=bnS6OOqbcnhmRSOJ6kH6IT72UeuWb3HDVT88cPFTJ+Lq7r1Qspom+kx54itk7xM7YC
         o8ggM/HOn3ihSXa+RBTaLlSRn64w4nBcWEr/UQi71Hier6iwpYjlKK+gZAgOJeg3WYWY
         HuPtzJqG5l+aCVUtcapfEM+1Xx0+ufFQQChj6J8493VrGcdz85E9fC5+WUzjpN9v4O2u
         rIjTD1vZ86Elu1DregteQVyiC7azMtBJbij3Iac9W4CiRPrXouOpDbY8UDAEr+onxDS/
         i9ZagysFFbWT0DnxJFjM14XOPFmQtg5BZ7+iwzaKFIrdQiT81oeU0zttLo5zQjsvPMY7
         stNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h20si19770609ejx.253.2019.08.01.05.11.48
        for <linux-mm@kvack.org>;
        Thu, 01 Aug 2019 05:11:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B3A191570;
	Thu,  1 Aug 2019 05:11:47 -0700 (PDT)
Received: from [10.1.194.48] (e123572-lin.cambridge.arm.com [10.1.194.48])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3A4393F575;
	Thu,  1 Aug 2019 05:11:42 -0700 (PDT)
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
To: Dave Hansen <dave.hansen@intel.com>,
 Andrey Konovalov <andreyknvl@google.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
 linux-media@vger.kernel.org, kvm@vger.kernel.org,
 linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
 Vincenzo Frascino <vincenzo.frascino@arm.com>,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 Alexander Deucher <Alexander.Deucher@amd.com>,
 Christian Koenig <Christian.Koenig@amd.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>,
 Jens Wiklander <jens.wiklander@linaro.org>,
 Alex Williamson <alex.williamson@redhat.com>,
 Leon Romanovsky <leon@kernel.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>,
 enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>,
 Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <8c618cc9-ae68-9769-c5bb-67f1295abc4e@intel.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <13b4cf53-3ecb-f7e7-b504-d77af15d77aa@arm.com>
Date: Thu, 1 Aug 2019 13:11:40 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <8c618cc9-ae68-9769-c5bb-67f1295abc4e@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31/07/2019 17:50, Dave Hansen wrote:
> On 7/23/19 10:58 AM, Andrey Konovalov wrote:
>> The mmap and mremap (only new_addr) syscalls do not currently accept
>> tagged addresses. Architectures may interpret the tag as a background
>> colour for the corresponding vma.
> What the heck is a "background colour"? :)

Good point, this is some jargon that we started using for MTE, the idea being that 
the kernel could set a tag value (specified during mmap()) as "background colour" for 
anonymous pages allocated in that range.

Anyway, this patch series is not about MTE. Andrey, for v20 (if any), I think it's 
best to drop this last sentence to avoid any confusion.

Kevin

