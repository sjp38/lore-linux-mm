Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3C1EC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:37:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7586D21721
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:37:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7586D21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B89D6B026F; Thu, 13 Jun 2019 07:37:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 042506B0271; Thu, 13 Jun 2019 07:37:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFE446B0272; Thu, 13 Jun 2019 07:37:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C37F6B026F
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:37:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l53so30478918edc.7
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:37:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Nk9N49wBZm/+VbpF7F1oQJN2/uaoffAm2FHk4WXmGdc=;
        b=hPDe+XYFOsR5ErzUMO9cWgSm3u0pjlii1YBSAjaVi2jeVOl5K9h9LmM84KNMM7vMar
         q0FvB7gBJnlPrChmH/juQY7xQ9sAAw8NCUmgCL5+6W5NeU2r4Vd3+QCsTemveHCbxYY4
         ZHJyYXMT5eTkvwFcfDgnKwf3g7r61+VRMXeBNQHawpVC+61bECgRaqkaLv41e88BsD0j
         4jjDEZoAaq+d/5RNtlDvcsVwEs/SbAHHG1fiAN465yK9VcGjx7WqPDbBQw8qOyvot9ed
         uGapvhwTXLyaCU8SofX0zSE9TFVfbMcHl+n/56A3lXnnf0Xj2UOAYrvltyi3A3jKqJC3
         BpdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAWgM22GqULdBXldYtQiUQoUDxtT01d35WEIxHmeeMqu5EAHrxZ3
	ifUZttIaIRk/IHXxPd4/ywzd1JkeVXtSZ3d/x8BeBseHaZmdr2oQzI5FGgT8WOdJxbY2GhS05Lf
	mUQVrwgT/RI0Gx5Ub5I7WVSbTL1Lc4RIQSCaBsxJg6ADGw0rBJUL0YqustjY9uQ6O5g==
X-Received: by 2002:a17:906:fc6:: with SMTP id c6mr75443264ejk.218.1560425857979;
        Thu, 13 Jun 2019 04:37:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhjdikI65SXrmeK9bAOxU09Yp5g8oYEGfnxmJE8G5nTl+/ZvbLGYQrR3CyB9zUAW7T/nZU
X-Received: by 2002:a17:906:fc6:: with SMTP id c6mr75443205ejk.218.1560425857023;
        Thu, 13 Jun 2019 04:37:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560425857; cv=none;
        d=google.com; s=arc-20160816;
        b=Erz5Xp7YPIamgGDQ3S7c4UnwrKmYGtnWbvmz8Ccvoe3jhdI4M8tZdqTraQ4LLl3Qod
         1ZQIfIK3FXaf3BFcki9ptk5Z9kCJQfOJftpYwKSH6u/DUyCKfkf4LF+nQSFQK5ZxmB01
         9FzT6ow0r2OP7ZrmJvU4ALbjNS8CONxjCwT8PH0bXianKoSox1bfzQNqyu078lGOvm5z
         UAKFJDINfpd/LDLGSHG9wmq+1YAbH9uP5679BcCI/9rUnUselPt2ekJpRBQxCvLptZWk
         oIvsybaeloIgq4VYvUcFuzKuIlEbTxwE+ByqMMxa22I+iL5BKu0yvRHwnfc9IOG8X+0D
         BP7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Nk9N49wBZm/+VbpF7F1oQJN2/uaoffAm2FHk4WXmGdc=;
        b=WhFDbhA/bKQlPCyEbnrPYpHIKTTqefe5wqErAlfNX9M6mbLo8jxgKNEzfoh9uabD5k
         kk51doBbE51RDsF7Pl0HJe28ME7uOn/bqGTSmNhq7D66Dl0KP/rK4xCXVXFNo0a3RRJX
         uQzU7jKGyAwEzOjHIrJXk/f65G0CYKjmlYhADFPaKqUmeZDr5i3DHjWoosp/gTDABEHV
         SeH4wyGEw7wC/5QD03L8rBsxGLPam6Y+1H70lfgpLPdJ98aI4TCznL/8XoRREMSrCug7
         F7vYdBQHjyaBY9PypCVfpiHvQOEHDIBOrFjK36QFvR4G2vhkX2Wi6hm37gwcYvimYTRl
         cpmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h27si1879724ejs.90.2019.06.13.04.37.36
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 04:37:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EC6DC367;
	Thu, 13 Jun 2019 04:37:35 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B2D923F694;
	Thu, 13 Jun 2019 04:39:17 -0700 (PDT)
Date: Thu, 13 Jun 2019 12:37:32 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-kselftest@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH v4 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
Message-ID: <20190613113731.GY28398@e103592.cambridge.arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-2-vincenzo.frascino@arm.com>
 <20190612153538.GL28951@C02TF0J2HF1T.local>
 <141c740a-94c2-2243-b6d1-b44ffee43791@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <141c740a-94c2-2243-b6d1-b44ffee43791@arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:15:34AM +0100, Vincenzo Frascino wrote:
> Hi Catalin,
> 
> On 12/06/2019 16:35, Catalin Marinas wrote:
> > Hi Vincenzo,
> > 
> > Some minor comments below but it looks fine to me overall. Cc'ing
> > Szabolcs as well since I'd like a view from the libc people.
> > 
> 
> Thanks for this, I saw Szabolcs comments.
> 
> > On Wed, Jun 12, 2019 at 03:21:10PM +0100, Vincenzo Frascino wrote:
> >> diff --git a/Documentation/arm64/tagged-address-abi.txt b/Documentation/arm64/tagged-address-abi.txt
> >> new file mode 100644
> >> index 000000000000..96e149e2c55c
> >> --- /dev/null
> >> +++ b/Documentation/arm64/tagged-address-abi.txt

[...]

> >> +Since it is not desirable to relax the ABI to allow tagged user addresses
> >> +into the kernel indiscriminately, arm64 provides a new sysctl interface
> >> +(/proc/sys/abi/tagged_addr) that is used to prevent the applications from
> >> +enabling the relaxed ABI and a new prctl() interface that can be used to
> >> +enable or disable the relaxed ABI.
> >> +
> >> +The sysctl is meant also for testing purposes in order to provide a simple
> >> +way for the userspace to verify the return error checking of the prctl()
> >> +command without having to reconfigure the kernel.
> >> +
> >> +The ABI properties are inherited by threads of the same application and
> >> +fork()'ed children but cleared when a new process is spawn (execve()).
> > 
> > "spawned".

I'd just say "cleared by execve()."

"Spawn" suggests (v)fork+exec to me (at least, what's what "spawn" means on
certain other OSes).

> > 
> > I guess you could drop these three paragraphs here and mention the
> > inheritance properties when introducing the prctl() below. You can also
> > mention the global sysctl switch after the prctl() was introduced.
> > 
> 
> I will move the last two (rewording them) to the _section_ 2, but I would still
> prefer the Introduction to give an overview of the solution as well.
> 
> >> +
> >> +2. ARM64 Tagged Address ABI
> >> +---------------------------
> >> +
> >> +From the kernel syscall interface prospective, we define, for the purposes
> >> +of this document, a "valid tagged pointer" as a pointer that either it has
> > 
> > "either has" (no 'it') sounds slightly better but I'm not a native
> > English speaker either.
> > 
> >> +a zero value set in the top byte or it has a non-zero value, it is in memory
> >> +ranges privately owned by a userspace process and it is obtained in one of
> >> +the following ways:
> >> +  - mmap() done by the process itself, where either:
> >> +    * flags = MAP_PRIVATE | MAP_ANONYMOUS
> >> +    * flags = MAP_PRIVATE and the file descriptor refers to a regular
> >> +      file or "/dev/zero"
> >> +  - a mapping below sbrk(0) done by the process itself
> >> +  - any memory mapped by the kernel in the process's address space during
> >> +    creation and following the restrictions presented above (i.e. data, bss,
> >> +    stack).
> >> +
> >> +The ARM64 Tagged Address ABI is an opt-in feature, and an application can
> >> +control it using the following prctl()s:
> >> +  - PR_SET_TAGGED_ADDR_CTRL: can be used to enable the Tagged Address ABI.
> > 
> > enable or disable (not sure we need the latter but it doesn't heart).
> > 
> > I'd add the arg2 description here as well.
> > 
> 
> Good point I missed this.
> 
> >> +  - PR_GET_TAGGED_ADDR_CTRL: can be used to check the status of the Tagged
> >> +                             Address ABI.

For both prctls, you should also document the zeroed arguments up to
arg5 (unless we get rid of the enforcement and just ignore them).


Is there a canonical way to detect whether this whole API/ABI is
available?  (i.e., try to call this prctl / check for an HWCAP bit,
etc.)

[...]

Cheers
---Dave

