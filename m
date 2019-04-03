Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59568C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:50:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB01A206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:50:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB01A206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 882B16B000E; Wed,  3 Apr 2019 12:50:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 831EF6B0010; Wed,  3 Apr 2019 12:50:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FA3A6B0266; Wed,  3 Apr 2019 12:50:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA1A6B000E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 12:50:46 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z12so12646273pgs.4
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 09:50:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VtmjDkSXRPG0DHAbSkfLMIqT1ZnkluWpi4HuPbhukUw=;
        b=DvCxd+5DoQByM7BKtn87D8urp5epOhcP/iEai6K1VmYLlQEJKlxgDhYmfHzSxSUO3t
         KRqrfyoL/WVjQ/S8k1Utafu2yvLGESCMhTmUUSmyb+WYhMJwoWHjGLczVHuXw1YS4jrr
         65oLio5gYZ70HWCxltWObgpL50+wuXzRhdk25tFaGWeTA5Iz+Qjet4wxjmn5iJn0HuNn
         B4t8B/eAMMPS/MPIp2mDfzmdEBbwN8A7nGemJsDc98+Ypz4v7H8iH48GJ70FGpgHkRhG
         0KMxYaBSzNSP2bkNhxnv4kStlbVNBYkYOIwf8WDjqKoISs3tGqEa6d94FV0JYlWyBwIJ
         tdGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWN3XXhs5HlbDOG/KYeHeFuC+8uySAppH0U/OLCWYGEYIyKTDWv
	bf52zomID9H/Tp5KwF3943q2UrZJuRQ/xN42h9zmOL38hSN8j1yLfH7U6LJNLx4ixnDLYVKfFWX
	h7T8SM805zIwkVau00Qu5BkedtJL/oILC9oa0VQ1ZDCzjrm6v1eQ2LjbhJ59nWMt0Kw==
X-Received: by 2002:a63:fc0b:: with SMTP id j11mr746736pgi.74.1554310245675;
        Wed, 03 Apr 2019 09:50:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8QCy0m/Ov50wM6DWON1Rbc7K5NtZiIpD7vs+oS7ErznGYXaepKzrKtdke9G1Y7CLS3Zvq
X-Received: by 2002:a63:fc0b:: with SMTP id j11mr746672pgi.74.1554310244720;
        Wed, 03 Apr 2019 09:50:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554310244; cv=none;
        d=google.com; s=arc-20160816;
        b=aFRYewwWAIDvrtKL3EmXnzaFXam2UUBJ8nvFw+54vwDweD2+o3LcO5oFdG8UTZWMAg
         xjBGgmt5KqeTtXP6PK0xGwAk2/J/I+cDIKRmJ0UYe0+1k0m6IDTjIxY3Moomu+pzKpcy
         CzdRJHrKt8ndx6F+IIgFLybJAm8zK8clA++W+cProM8DX+JFApfxY+0qsOevlA0Kc5G1
         TlkugM4s21ukL6MBCeAKkTAPrTm5gkGjp2m6wGZzd6DEtiyzcTCSS+FPJNfzfC+ZADfA
         bah6z5T6954qR/fnBwwcaT31mInJ6x6tB6Hcj8gF2CVBy26aH3o+TiJrcKEZHx31z1Fk
         4Qng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VtmjDkSXRPG0DHAbSkfLMIqT1ZnkluWpi4HuPbhukUw=;
        b=j4dwjPVMY700SI9d55L9pa+CVMWT2VDDsGe97SqOKvLFMw1C0x2ieWgbF8wMLuWyII
         4mucHQBHgtTm51JUSam6FaSPWx14SVkR4U5Vxd0s10hziC6gRW/bOFibTvdfkcBAh2dO
         sTqLl6lDKnHSvaO74hIO0xlzX/t/o5R24S2Rd0m7WHpwSOp7iwHmC8sS6tcvDa7Kuh6d
         vRnZhM1OtUC2FRZL4zkyxNkNxQG+GNTIbhGzBqMcKcXelbyMfht5sjq38n741wXhr7j1
         EXi+QPO8BqVMfNnqktA4N0MTAia5SWjMpMMkrumOBwjiWmUD0F/hL+kb3VyBx4Rw5yry
         QLHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a36si14243825pgb.165.2019.04.03.09.50.44
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 09:50:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A04F880D;
	Wed,  3 Apr 2019 09:50:40 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 728023F68F;
	Wed,  3 Apr 2019 09:50:34 -0700 (PDT)
Date: Wed, 3 Apr 2019 17:50:31 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Kevin Brodsky <kevin.brodsky@arm.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Alexei Starovoitov <ast@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Branislav Rankov <Branislav.Rankov@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Dave Martin <Dave.Martin@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Graeme Barnes <Graeme.Barnes@arm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Shuah Khan <shuah@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 2/4] arm64: Define Documentation/arm64/elf_at_flags.txt
Message-ID: <20190403165031.GE34351@arrakis.emea.arm.com>
References: <cover.1552679409.git.andreyknvl@google.com>
 <20190318163533.26838-1-vincenzo.frascino@arm.com>
 <20190318163533.26838-3-vincenzo.frascino@arm.com>
 <859341c2-b352-e914-312a-d3de652495b6@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <859341c2-b352-e914-312a-d3de652495b6@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 03:52:49PM +0000, Kevin Brodsky wrote:
> On 18/03/2019 16:35, Vincenzo Frascino wrote:
> > +2. Features exposed via AT_FLAGS
> > +--------------------------------
> > +
> > +bit[0]: ARM64_AT_FLAGS_SYSCALL_TBI
> > +
> > +    On arm64 the TCR_EL1.TBI0 bit has been always enabled on the arm64
> > +    kernel, hence the userspace (EL0) is allowed to set a non-zero value
> > +    in the top byte but the resulting pointers are not allowed at the
> > +    user-kernel syscall ABI boundary.
> > +    When bit[0] is set to 1 the kernel is advertising to the userspace
> > +    that a relaxed ABI is supported hence this type of pointers are now
> > +    allowed to be passed to the syscalls, when these pointers are in
> > +    memory ranges privately owned by a process and obtained by the
> > +    process in accordance with the definition of "valid tagged pointer"
> > +    in paragraph 3.
> > +    In these cases the tag is preserved as the pointer goes through the
> > +    kernel. Only when the kernel needs to check if a pointer is coming
> > +    from userspace an untag operation is required.
> 
> I would leave this last sentence out, because:
> 1. It is an implementation detail that doesn't impact this user ABI.
> 2. It is not entirely accurate: untagging the pointer may be needed for
> various kinds of address lookup (like finding the corresponding VMA), at
> which point the kernel usually already knows it is a userspace pointer.

I fully agree, the above paragraph should not be part of the user ABI
document.

> > +3. ARM64_AT_FLAGS_SYSCALL_TBI
> > +-----------------------------
> > +
> > +From the kernel syscall interface prospective, we define, for the purposes
> > +of this document, a "valid tagged pointer" as a pointer that either it has
> > +a zero value set in the top byte or it has a non-zero value, it is in memory
> > +ranges privately owned by a userspace process and it is obtained in one of
> > +the following ways:
> > +  - mmap() done by the process itself, where either:
> > +    * flags = MAP_PRIVATE | MAP_ANONYMOUS
> > +    * flags = MAP_PRIVATE and the file descriptor refers to a regular
> > +      file or "/dev/zero"
> > +  - a mapping below sbrk(0) done by the process itself
> 
> I don't think that's very clear, this doesn't say how the mapping is
> obtained. Maybe "a mapping obtained by the process using brk() or sbrk()"?

I think what we mean here is anything in the "[heap]" section as per
/proc/*/maps (in the kernel this would be start_brk to brk).

> > +  - any memory mapped by the kernel in the process's address space during
> > +    creation and following the restrictions presented above (i.e. data, bss,
> > +    stack).
> 
> With the rules above, the code section is included as well. Replacing "i.e."
> with "e.g." would avoid having to list every single section (which is
> probably not a good idea anyway).

We could mention [stack] explicitly as that's documented in the
Documentation/filesystems/proc.txt and it's likely considered ABI
already.

The code section is MAP_PRIVATE, and can be done by the dynamic loader
(user process), so it falls under the mmap() rules listed above. I guess
we could simply drop "done by the process itself" here and allow
MAP_PRIVATE|MAP_ANONYMOUS or MAP_PRIVATE of regular file. This would
cover the [heap] and [stack] and we won't have to debate the brk() case
at all.

We probably mention somewhere (or we should in the tagged pointers doc)
that we don't support tagged PC.

-- 
Catalin

