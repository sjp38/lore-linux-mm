Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54D85C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:07:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17843208C0
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:07:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17843208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2A7D8E0004; Mon, 17 Jun 2019 14:07:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DA468E0001; Mon, 17 Jun 2019 14:07:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A41D8E0004; Mon, 17 Jun 2019 14:07:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5463B8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 14:07:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b10so8195527pgb.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:07:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=XlmQOAqcauA6JNOvPwo67Yo5PB0RliGVVT//2GdK+CA=;
        b=ojofArCDGgdkstvJ7r8acr9Jxl0idHX38A011nI+RsvnW0F54pZ1isql/i8KdUSYSx
         oMQlXw7A2EFBSQtAbTXvNru+CoCP5pBhqmOlMy5jiMyTe9JZkOX2fnDgQOAZypQEhzS1
         RoRDxxuEzwyQLF+5lIrBYrdvpQTUVX2XDnJ8qaN0q9q1GjEcBnDlNoZgffJeEgaZOS/0
         Ux3LleMJj0p/D4gwUUPJarLpjdiEhaS+B7otwrMjOn2xtsCmY9qA+69GvzvcAFy6stVd
         XAFVUCw8EL5EoKWT2jww8pTW/Nkesm9yEWlTySY+UGbZ0Df5ms0Osv0aFPe6NTLW4E5t
         PLUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXU6JEwPHNcU+cJ7FdOzqnSuXPtnvYpi8/UXxRBfBYS9TTrqE1h
	j/ZVGRI9e5St3PXEaHdody72VOfQQyD23VEucK2RdHg+dlfsAHvcV5UXgThF4zeCKIGiU2LOp+c
	I4mbn0d9R15n76SUFVNCipdf4LWBjCwYkzpH3bo7jQPhSVv0SC2mjyITM983U6vfWfw==
X-Received: by 2002:a17:90a:1706:: with SMTP id z6mr52304pjd.108.1560794866943;
        Mon, 17 Jun 2019 11:07:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOX2nr27KQJublF76E1DoZ+VRT4Da5mbTDNVpYydd4s4/Ph03RC51iv9NPW3YfGmxvclHU
X-Received: by 2002:a17:90a:1706:: with SMTP id z6mr52244pjd.108.1560794866310;
        Mon, 17 Jun 2019 11:07:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560794866; cv=none;
        d=google.com; s=arc-20160816;
        b=hLYj4r4r5+R3K602tPEo9rlzD+TPE7PwtB56reN3y9KGrisAXxtfG5oASanQNoVzKk
         dHIJ+MUMWDapReKgnGuLe+p76wmcYIyMXNro6ccJXZjDrg16pyMDa6mxR+8AGFFUQsxT
         LpWDaCunk8jJFWSYgLR0htZkS8xZLkcYWr9JsA7y7FC2nfUNBtHF4TrAMvY/Zx/tl8n3
         QAMRIZ2klkWZ4I0Y43hepQXL6yfFmuOQVIjpoqyGDA0PPYyzch4a7enLTzKVq/LEv4CL
         xMT9OmYCRWBwB8gBCyhiROZ7I1C8tgpodaFMqnKXyK/91JEwhwZvbmyTSLW0hK0mmYIr
         Ew/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=XlmQOAqcauA6JNOvPwo67Yo5PB0RliGVVT//2GdK+CA=;
        b=SK54pavT0lGWvnPGDNeJTbku8e8k8k7iNt/yXzgreCVht8MBtcff3+GGa23jLasSw0
         VnR1495bNxC6NcnemJsZ45YrAN6GOYntsi1vA9h2SBCTqEcdF0I+E1u0JMwfPgB+uqVZ
         kEpBFP22Z5mZnYdDymu5FiNE3wUjpn5iZhXawtekrpo/bEMvT8I78HCpK2b2g+80EA7Q
         Lm5dSGZW+AsfHXwheLldErvT8ekmVjfbXKG7mpsZQihFDpLdi3SNkVrhtUomj7KmMf7E
         gE0GcS7q3UJdrYZd2p1B34WgDhBbzMnOJhgtVVypMigNRQH64SMgXzfR1VH/bviEYCkz
         Wxdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id w18si5108pjn.74.2019.06.17.11.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 11:07:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 11:07:45 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga002.jf.intel.com with ESMTP; 17 Jun 2019 11:07:45 -0700
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
To: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>
Cc: Alexander Graf <graf@amazon.com>, Thomas Gleixner <tglx@linutronix.de>,
 Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>, Alexander Graf <graf@amazon.de>,
 David Woodhouse <dwmw@amazon.co.uk>,
 the arch/x86 maintainers <x86@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
 <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
 <58788f05-04c3-e71c-12c3-0123be55012c@amazon.com>
 <63b1b249-6bc7-ffd9-99db-d36dd3f1a962@intel.com>
 <CALCETrXph3Zg907kWTn6gAsZVsPbCB3A2XuNf0hy5Ez2jm2aNQ@mail.gmail.com>
 <698ca264-123d-46ae-c165-ed62ea149896@intel.com>
 <CALCETrVt=X+FB2cM5hMN9okvbcROFfT4_KMwaKaN2YVvc7UQTw@mail.gmail.com>
 <5AA8BF10-8987-4FCB-870C-667A5228D97B@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <f6f352ed-750e-d735-a1c9-7ff133ca8aea@intel.com>
Date: Mon, 17 Jun 2019 11:07:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <5AA8BF10-8987-4FCB-870C-667A5228D97B@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/17/19 9:53 AM, Nadav Amit wrote:
>>> For anyone following along at home, I'm going to go off into crazy
>>> per-cpu-pgds speculation mode now...  Feel free to stop reading now. :)
>>>
>>> But, I was thinking we could get away with not doing this on _every_
>>> context switch at least.  For instance, couldn't 'struct tlb_context'
>>> have PGD pointer (or two with PTI) in addition to the TLB info?  That
>>> way we only do the copying when we change the context.  Or does that tie
>>> the implementation up too much with PCIDs?
>> Hmm, that seems entirely reasonable.  I think the nasty bit would be
>> figuring out all the interactions with PV TLB flushing.  PV TLB
>> flushes already don't play so well with PCID tracking, and this will
>> make it worse.  We probably need to rewrite all that code regardless.
> How is PCID (as you implemented) related to TLB flushing of kernel (not
> user) PTEs? These kernel PTEs would be global, so they would be invalidated
> from all the address-spaces using INVLPG, I presume. No?

The idea is that you have a per-cpu address space.  Certain kernel
virtual addresses would map to different physical address based on where
you are running.  Each of the physical addresses would be "owned" by a
single CPU and would, by convention, never use a PGD that mapped an
address unless that CPU that "owned" it.

In that case, you never really invalidate those addresses.

