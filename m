Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DF3FC04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:03:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2949520848
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:03:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2949520848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7B676B0005; Thu, 16 May 2019 09:03:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B03FD6B0006; Thu, 16 May 2019 09:03:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97CC26B0007; Thu, 16 May 2019 09:03:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 32F8A6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 09:03:03 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id o1so670535lfl.8
        for <linux-mm@kvack.org>; Thu, 16 May 2019 06:03:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WNdy61vJT/6/APtY5tF6cpzhh5oF2Ja2UZFn9VPKnbI=;
        b=VaBTXEgPfZG/S2wPOl0KWonNZ0YNtrAg9N6WEEe7mRgqbhdFhJZbsHC+m5pXZD0Dmi
         XLnPYwMJ/uqFUIxDP5bZg3KlImqlaBIq/XSvrznS9zU6hkPUGP4QVDM/VHPVgiCjz7bH
         foCQm3EG4m7V9cbct1Ywob1e0041cgFnziVtevYecgMMBEesHEWs7mx1L4O5bAnkRIR6
         GeQRIIzb1aOuaMWoClKEnwo7qzUDxq0QWdloMGbL0rlKbYq8g0QXJ7mIjCvIIsEP9SNT
         rRMqmuIdqSpyN9xM+TJtQrtETpF3xO14e7PhE+7atx8Cfm/wS0jom7v+99deDIoxkXq/
         kQ8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVN99KbmqZtOLNpgE6hwMF0xdf0Or9bSVJ05/+79uAW7PSs+bFP
	cuGYcN+Ta+Kt4xZZfPxO0qGkLObpuZ0ayb02kemC0paGG8HFUAc6vUvwtbDY/olfadqVOLouBgM
	DxdFiJiM+06najRkaK9J605HJBKRPUinrtDcQQkmHkl7rtHeaGmbiqJh6H3X9miy4Iw==
X-Received: by 2002:a2e:5301:: with SMTP id h1mr17000691ljb.196.1558011782188;
        Thu, 16 May 2019 06:03:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5mnkKUde/UL+yVJolfvHZp/CLMGos6Hk+H+kKAT3akXtVpsOHCJpg0l3HxShy2u6Bigyv
X-Received: by 2002:a2e:5301:: with SMTP id h1mr17000602ljb.196.1558011780720;
        Thu, 16 May 2019 06:03:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558011780; cv=none;
        d=google.com; s=arc-20160816;
        b=B0QM2a8XNTDMxqjyk6dqAa1GgQiIGrg1ArNGDnebc54QLQ56chAxFAOqXR80kn1Zbq
         IeToIjpY65InP7dt9K+UGPGF5DrC5CzBXPlxIJG1+IZAj1TA4Rz3YYot80IY1uPxcuyg
         lGFmPi9NT/iVFJ/QMFzgi6EUzJIqnSlt7nuR4CcWgJLIWBogkFgvvq0R14owFaDIjjx8
         XTXuF++i5ry54SBusfu5TqfZPOq5bbLemVZgH9Uv3KziywS7h6U0PEtMhqBTSjLfc0lQ
         089ug4tbXc4CAjTgn24wJwNLn1rltECIbgtkgsw33hM+cOeEm4pE3xhsa8KF8Jvz0zme
         wl/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WNdy61vJT/6/APtY5tF6cpzhh5oF2Ja2UZFn9VPKnbI=;
        b=xWQGD3l8pXgoVPK7Y9r+HFAz410ymvgNKzi59Qqe1rBufhUk7CR1L1eFV3Vx6YlqbV
         +gZa4xsSDm925sIVTmuR8+QPAQR00KRfbaxDwrtnaLFeX19P4iItBIX4557EdRjg/Xxo
         zkcIderf8W4lxBXwvucYtiKVjY1KgX7P6w9WJZdXWuuJQo70ifVbM1ll6undI/CUY1nc
         ILxQpqxqML0BojZ04P7YTqyidKyPfUnu6tfj7MhF5f8HGVUDt5pUXv+9AwObSfvTphxo
         nnWYNZg1Ckyil3J047K44s2MdJdEGZ1DDWFtn2wl3nsgneMVuJGeZ4D+ZtdoBI57DCVz
         gKGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id y7si4600696lfh.9.2019.05.16.06.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 06:03:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hRG2D-0006j8-2v; Thu, 16 May 2019 16:02:57 +0300
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>,
 keith.busch@intel.com, "Kirill A . Shutemov"
 <kirill.shutemov@linux.intel.com>, pasha.tatashin@oracle.com,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>, ira.weiny@intel.com,
 Andrey Konovalov <andreyknvl@google.com>, arunks@codeaurora.org,
 Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>,
 Rik van Riel <riel@surriel.com>, Kees Cook <keescook@chromium.org>,
 hannes@cmpxchg.org, npiggin@gmail.com,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, shakeelb@google.com,
 Roman Gushchin <guro@fb.com>, Andrea Arcangeli <aarcange@redhat.com>,
 Hugh Dickins <hughd@google.com>, Jerome Glisse <jglisse@redhat.com>,
 Mel Gorman <mgorman@techsingularity.net>, daniel.m.jordan@oracle.com,
 kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
 <CAG48ez20Nu76Q8Tye9Hd3HGCmvfUYH+Ubp2EWbnhLp+J6wqRvw@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <456c7367-0656-933b-986d-febdcc5ab98e@virtuozzo.com>
Date: Thu, 16 May 2019 16:02:55 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAG48ez20Nu76Q8Tye9Hd3HGCmvfUYH+Ubp2EWbnhLp+J6wqRvw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Jann,

On 15.05.2019 21:46, Jann Horn wrote:
> On Wed, May 15, 2019 at 5:11 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>> This patchset adds a new syscall, which makes possible
>> to clone a mapping from a process to another process.
>> The syscall supplements the functionality provided
>> by process_vm_writev() and process_vm_readv() syscalls,
>> and it may be useful in many situation.
>>
>> For example, it allows to make a zero copy of data,
>> when process_vm_writev() was previously used:
> [...]
>> This syscall may be used for page servers like in example
>> above, for migration (I assume, even virtual machines may
>> want something like this), for zero-copy desiring users
>> of process_vm_writev() and process_vm_readv(), for debug
>> purposes, etc. It requires the same permittions like
>> existing proc_vm_xxx() syscalls have.
> 
> Have you considered using userfaultfd instead? userfaultfd has
> interfaces (UFFDIO_COPY and UFFDIO_ZERO) for directly shoving pages
> into the VMAs of other processes. This works without the churn of
> creating and merging VMAs all the time. userfaultfd is the interface
> that was written to support virtual machine migration (and it supports
> live migration, too).

I know about userfaultfd, but it does solve the discussed problem.
It allocates new pages to make UFFDIO_COPY (see mcopy_atomic_pte()),
and it accumulates all the disadvantages, the example from [0/5]
message has.

Kirill

