Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F528C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:21:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A15B62133D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:21:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A15B62133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D07C66B0003; Thu, 13 Jun 2019 05:21:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C910C6B0005; Thu, 13 Jun 2019 05:21:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7EFA6B0006; Thu, 13 Jun 2019 05:21:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 655FD6B0003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:21:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so22728645eds.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:21:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UQSC32w3/XjYN3ZhLu8pmzjD2U/iz7P78futIHN2c4s=;
        b=SpaAMXFpN1t5C16rtnk7pVw2sGOsKOXt4CG/I5CPUmNLkyIsraRWiS2b6i/P2rg4OZ
         EKHy6K1+Wd1eogAkEH8RugU2ujMfTmBtMjPNyvrWrGjzQK73cdNfJpngK8vSIRy3+yO/
         RMYm0C6ZtVJdEsGmkuYCZJltywPRpw/icjpXnBOY0GjNIzr7JTSBVFNA3AHSu2q4Mezw
         z57ktTocPoswHoLoMlnO2lNulx/u3OpQnR2AMyQaUft6jjvVOL51C9x0eK8fJIHGyAJl
         BBqwHNofVf5+lw0gNgIxqiZFBbjE0Zs2j48GD+u9Br+jJmz2ZsRgqjXa7EUBpK6uqvOk
         zLMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUz6eF5BDifUvJlW2L30MI76aiOFQBSIZ1EkLnJyW0QvuLepiMl
	ux/uHN/KDDvZAm7IR2vNfz7l5XpYHZ8b8s1xqDZLkWI8oGs+Evf3ePXPXGg859OgKUUMkIaVEtp
	jH2ptmbOthutM5b2qKMhjk02NbaxAeXNyWIROZwU0uXvKsmjVruYpkvd/41oWHBEq8Q==
X-Received: by 2002:aa7:cdc6:: with SMTP id h6mr5817625edw.5.1560417668963;
        Thu, 13 Jun 2019 02:21:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwX4I3m2hfguDYf8Sz1dJBvbx0ve+tSVhTJJUPqCHPVZKDwK4EsApe/WQqbAylCFdQwC9vr
X-Received: by 2002:aa7:cdc6:: with SMTP id h6mr5817535edw.5.1560417667933;
        Thu, 13 Jun 2019 02:21:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560417667; cv=none;
        d=google.com; s=arc-20160816;
        b=K3Ie6gLNHNzUFJbSkKpVTmqUDKHMApUxlX65X/lqfPDY3e9dISOtWXtn9sSrmIvZfu
         VvtnVaCJBSpMzjrzSmg5UHqWu1BpywOSjCkwESiZrbN57E0tqFlYJiS+cLXIZApmC2u7
         FZcD1Nr1qw3Malx0z9yBhCEmgJvf9x0rh7Rl2XwgDEJY1zFRdX0oNo3gt5UtbpR0Vsw+
         kihFgjSRrR/+MDmkS18Yo5wBCvvuQYWbE1GsLAp9mFhkt5Mj1H+GXHQQIWQyRiMBqUTi
         tQb7kpcXE6tqMjOgZvO0TqzdmuowHWiBfxmx2c8CvkbSK5DsdVXUxmuUYvocdEb1NVV5
         TSaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UQSC32w3/XjYN3ZhLu8pmzjD2U/iz7P78futIHN2c4s=;
        b=KMrmgLMZq+CokQhofW3j7fXfCre1EbWQdeYePfcBsA7IWqy0hsvJEEee7KXlKTvyCB
         l/RwEvLUSUSDD7YKREXbwwzNlJiuBwDUNS1GfwboMG29KEWhV11oHDmVRDXKYb2lGMGw
         o7+6sQBX4UIfPQNJP7T0wczk+PCDw4qFDGVjvl9LMm8+oF0iYN6NPeaYtlyebJGvUC/l
         2Z9R2mA934YMNolc4/QM5/EpjV5V5In3JTBak5UPKPtzPgt9dD/Es0n7b6qrPONQHdTN
         F8OSNGLyqPgf/ytAEjbWwV5/qZN1MfULoadkEGvs3b+S2UB5kZ6XTMkDONMitH0fWRmr
         QpDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y4si1779484edh.240.2019.06.13.02.21.07
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 02:21:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4E080367;
	Thu, 13 Jun 2019 02:21:06 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 999743F694;
	Thu, 13 Jun 2019 02:21:02 -0700 (PDT)
Date: Thu, 13 Jun 2019 10:20:59 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Cc: Vincenzo Frascino <Vincenzo.Frascino@arm.com>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	nd <nd@arm.com>, Will Deacon <Will.Deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v4 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
Message-ID: <20190613092054.GO28951@C02TF0J2HF1T.local>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-2-vincenzo.frascino@arm.com>
 <a90da586-8ff6-4bed-d940-9306d517a18c@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a90da586-8ff6-4bed-d940-9306d517a18c@arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Szabolcs,

On Wed, Jun 12, 2019 at 05:30:34PM +0100, Szabolcs Nagy wrote:
> On 12/06/2019 15:21, Vincenzo Frascino wrote:
> > +2. ARM64 Tagged Address ABI
> > +---------------------------
> > +
> > +From the kernel syscall interface prospective, we define, for the purposes
>                                      ^^^^^^^^^^^
> perspective
> 
> > +of this document, a "valid tagged pointer" as a pointer that either it has
> > +a zero value set in the top byte or it has a non-zero value, it is in memory
> > +ranges privately owned by a userspace process and it is obtained in one of
> > +the following ways:
> > +  - mmap() done by the process itself, where either:
> > +    * flags = MAP_PRIVATE | MAP_ANONYMOUS
> > +    * flags = MAP_PRIVATE and the file descriptor refers to a regular
> > +      file or "/dev/zero"
> 
> this does not make it clear if MAP_FIXED or other flags are valid
> (there are many map flags i don't know, but at least fixed should work
> and stack/growsdown. i'd expect anything that's not incompatible with
> private|anon to work).

Just to clarify, this document tries to define the memory ranges from
where tagged addresses can be passed into the kernel in the context
of TBI only (not MTE); that is for hwasan support. FIXED or GROWSDOWN
should not affect this.

> > +  - a mapping below sbrk(0) done by the process itself
> 
> doesn't the mmap rule cover this?

IIUC it doesn't cover it as that's memory mapped by the kernel
automatically on access vs a pointer returned by mmap(). The statement
above talks about how the address is obtained by the user.

> > +  - any memory mapped by the kernel in the process's address space during
> > +    creation and following the restrictions presented above (i.e. data, bss,
> > +    stack).
> 
> OK.
> 
> Can a null pointer have a tag?
> (in case NULL is valid to pass to a syscall)

Good point. I don't think it can. We may change this for MTE where we
give a hint tag but no hint address, however, this document only covers
TBI for now.

> > +The ARM64 Tagged Address ABI is an opt-in feature, and an application can
> > +control it using the following prctl()s:
> > +  - PR_SET_TAGGED_ADDR_CTRL: can be used to enable the Tagged Address ABI.
> > +  - PR_GET_TAGGED_ADDR_CTRL: can be used to check the status of the Tagged
> > +                             Address ABI.
> > +
> > +As a consequence of invoking PR_SET_TAGGED_ADDR_CTRL prctl() by an applications,
> > +the ABI guarantees the following behaviours:
> > +
> > +  - Every current or newly introduced syscall can accept any valid tagged
> > +    pointers.
> > +
> > +  - If a non valid tagged pointer is passed to a syscall then the behaviour
> > +    is undefined.
> > +
> > +  - Every valid tagged pointer is expected to work as an untagged one.
> > +
> > +  - The kernel preserves any valid tagged pointers and returns them to the
> > +    userspace unchanged in all the cases except the ones documented in the
> > +    "Preserving tags" paragraph of tagged-pointers.txt.
> 
> OK.
> 
> i guess pointers of another process are not "valid tagged pointers"
> for the current one, so e.g. in ptrace the ptracer has to clear the
> tags before PEEK etc.

Another good point. Are there any pros/cons here or use-cases? When we
add MTE support, should we handle this differently?

> > +A definition of the meaning of tagged pointers on arm64 can be found in:
> > +Documentation/arm64/tagged-pointers.txt.
> > +
> > +3. ARM64 Tagged Address ABI Exceptions
> > +--------------------------------------
> > +
> > +The behaviours described in paragraph 2, with particular reference to the
> > +acceptance by the syscalls of any valid tagged pointer are not applicable
> > +to the following cases:
> > +  - mmap() addr parameter.
> > +  - mremap() new_address parameter.
> > +  - prctl_set_mm() struct prctl_map fields.
> > +  - prctl_set_mm_map() struct prctl_map fields.
> 
> i don't understand the exception: does it mean that passing a tagged
> address to these syscalls is undefined?

I'd say it's as undefined as it is right now without these patches. We
may be able to explain this better in the document.

-- 
Catalin

