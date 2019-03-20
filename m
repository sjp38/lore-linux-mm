Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1652C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:25:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A9712175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:25:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A9712175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F27966B0003; Wed, 20 Mar 2019 07:25:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED7C36B0006; Wed, 20 Mar 2019 07:25:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC77D6B0007; Wed, 20 Mar 2019 07:25:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 893996B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:25:58 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id k3so846242wmi.7
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:25:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pY3E9J/FvgCYJx2iTDGip3j13VeoD2WhW5RpiF5tyZQ=;
        b=E+IlJQupZMePQ/4XMOFrKDnQll10f4VKHu2F010VrT3LownC61ugk/asm4oyG9kAIp
         hQLIt1lmZIcCO+Bn9G5YZelsPPhXecJSFUZXMdFIPHZnCoXcwOBj4xZcQnUaGK1zI4vI
         v345yDc6wOj1iz5YsFWrVILsoNewPn1ezFT5WZr2e8Fl8HiSEPgbJNPcql9LPUfHB1oF
         s76xl9oSs3XhDpcjx8k6WvFdhsKCch1eK9PG6exduPofx5wyzCaNXaJIPwjrBBH64PQY
         5LPzk+ELM47YL0GT1NvMrAF3B8ldl5hFBg3BOqCiy22RzA5WKdBey2rGPn+QgvdU04id
         NMtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWbwHqBCtqlYQnJi91D393iC/gTq4D0VQLE7YP+g6U6+jxasP5Z
	uXynKPSr38RhPMZxhy7VMUZCiSRIjo+XjGvzf3bcaHcdPFhL9GDtN6qLuluNISAFdRck23Zk9HS
	I+HYI8G+4mdqLJtDLfbrWNMg2MwNu9l2F1j/QnVsYMDMOrH3etCM2YHhVKChkuKSRzQ==
X-Received: by 2002:a1c:3842:: with SMTP id f63mr7857073wma.25.1553081158040;
        Wed, 20 Mar 2019 04:25:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxynujv/12nG3MCr7Ar1L9baHyXluPuL9YWSPPK9CfVW7/6SqpMlPLrWxIy0CYxCsmw3wGU
X-Received: by 2002:a1c:3842:: with SMTP id f63mr7857006wma.25.1553081157091;
        Wed, 20 Mar 2019 04:25:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553081157; cv=none;
        d=google.com; s=arc-20160816;
        b=ZGlCsxBfi25hAGDusBxoe9blBoKnyB1exR0nR8Tn+xd8d40zBXv2cKtaueOFAkiZfQ
         O21G9cedSWZRfy3aaMO/BH/O+4k/y7BLnGk84547HlAY5k2Rln5lLvD7hRX/UgGZs6Zu
         Ni6C8jaZLQsYhhU8WCtwzfrC53rUyeCgJhxiJ6t5i9N/13Kty3iWQydLc/onQbi8nEQh
         P7K1gl9xq7fmcPzQCJMyXVqRwUtYlBmIUYD/teAh4BJq6JkW77OB2wqA8kQixbuoRr6c
         YQfur6sewWj5johTD/cSzW4FlupvbH5NH9LN5ulPjdh6PFUD47BcHLV2BQhrmxeqMfTD
         m6vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pY3E9J/FvgCYJx2iTDGip3j13VeoD2WhW5RpiF5tyZQ=;
        b=08hnS/2gEHdUqC3Wn1IarZ51PZTHQ8us3+GWN1EU87hoon5cZGuaUbl5rp1HM2484B
         aQYwp5VleV82oua3RrzlHNffg8uShTdzWbvOjZsSFFw3+85ULRlPUi9ROSB6UzX9nlDZ
         qcV74cT6JoIR816KNlhBzPh6kkau+WtS5A5wKnsLzuX8BOfcXXGGwGYqPVBi7eTpEbJM
         +vSxCx7M2cSqAAWxrYPU61VxLKNmkkcQMUl0l2kxFPZQQXrfrwk5B5sYtJjuFecOSimK
         XgEdzXAhc4ZolmQoZ7DQI36KolVhCtHRTALOZS/ng5SpKcnSRK94kPPoDf/Gc3jsqiCN
         Aqtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j14si1087082wrx.413.2019.03.20.04.25.56
        for <linux-mm@kvack.org>;
        Wed, 20 Mar 2019 04:25:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C199A1650;
	Wed, 20 Mar 2019 04:25:55 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7C08D3F575;
	Wed, 20 Mar 2019 04:25:49 -0700 (PDT)
Date: Wed, 20 Mar 2019 11:25:46 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	netdev@vger.kernel.org, bpf@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, khalid.aziz@oracle.com
Subject: Re: [PATCH v12 00/13] arm64: untag user pointers passed to the kernel
Message-ID: <20190320112545.GB25040@arrakis.emea.arm.com>
References: <cover.1552929301.git.andreyknvl@google.com>
 <20190319113212.ca1d56301112454dfb5a39ba@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319113212.ca1d56301112454dfb5a39ba@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 11:32:12AM -0700, Andrew Morton wrote:
> On Mon, 18 Mar 2019 18:17:32 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:
> > === Notes
> > 
> > This patchset is meant to be merged together with "arm64 relaxed ABI" [3].
> 
> What does this mean, precisely?  That neither series is useful without
> the other?  That either patchset will break things without the other?

This series does the work of relaxing the ABI w.r.t. pointer syscall
arguments for arm64 (while preserving backwards compatibility, we can't
break this). Vincenzo's patches [1] document the ABI relaxation and
introduce an AT_FLAG bit by which user space can check for the presence
of such support. So I'd say [1] goes on top of this series.

Once we agreed on the ABI definition, they should be posted as a single
series.

> Only a small fraction of these patches carry evidence of having been
> reviewed.  Fixable?

That's fixable, though the discussions go back to last summer mostly at
a higher level: are we sure these are the only places that need
patching? The outcome of such discussions was a document clarifying
which pointers user can tag and pass to the kernel based on the origins
of the memory range (e.g. anonymous mmap()).

I'd very much like to get input from the SPARC ADI guys on these series
(cc'ing Khalid). While currently for arm64 that's just a software
feature (the hardware one, MTE - memory tagging extensions, is coming
later), the ADI has similar requirements regarding the user ABI. AFAICT
from the SPARC example code, the user is not allowed to pass a tagged
pointers (non-zero top byte) into the kernel. Feedback from the Google
hwasan guys is that such approach is not practical for a generic
deployment of this feature (e.g. automatic tagging of heap allocations).

> Which maintainer tree would be appropriate for carrying these patches?

Given that the arm64 changes are fairly minimal, the -mm tree works for
me (once I reviewed/acked the patches and, ideally, get the SPARC people
onboard with such approach).

[1] https://lkml.org/lkml/2019/3/18/819

-- 
Catalin

