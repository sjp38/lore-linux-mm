Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69D92C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:43:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1955B20700
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:43:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1955B20700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A9218E0002; Wed, 13 Feb 2019 12:43:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 657ED8E0001; Wed, 13 Feb 2019 12:43:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 521368E0002; Wed, 13 Feb 2019 12:43:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC3A98E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:43:29 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so1289939edt.23
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:43:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yMqE0SxU5CYG3T9tTFXhAtaDDtwlklgub+A0kqBD6fo=;
        b=JQxT2xs0oIDVMahLJ2D7oudLUqPtbNkc1CJBXNKCU6GQZjWPbVCbQfnT3vDSeLQOl3
         /P/l3F00g9Tqq8ub3vzvX4SS9gjr4DrKRAGzDnoy7OJavXJvMVMlyOhbLXi3Y6WoLi3J
         e1kUyhKwJy8dzu9/vYG3PMo7mkmqPCHeI31QOWOM5w+Wb/a11Hz9L9Vu8TDTORFRjfY2
         W+IwdM3rhwRUiFtiiz9NKxFA9sMy/c5YvYNWz3dYLpyLzFGv4Dj87siVTE77uVs78Z6j
         lg6o7HIY3Xom7svGycV0tWHCwb7KUlzfY7g3pVsjXVNo4VrtTx1kRbgdwwGupt3ltLT0
         BBFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: AHQUAubd51e/MuBvxwUZen3ypcq8zqmU0rVi6Mfin9W6Up5cda8vlG0M
	aRYB7n1SIgH6+q90KsTwPdkbDMuROYSH6eLR5s21uy0qN6qITV7BiRXtzCL6Gw3t/sZQNXj+mGA
	l3EdHBtFMDIQQjrrHZpv13jkvod6gvisIbuyRMkzyjy17S2D7fw3RoZCLFpCIw7pyVQ==
X-Received: by 2002:a17:906:180c:: with SMTP id v12mr1179392eje.45.1550079809444;
        Wed, 13 Feb 2019 09:43:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IavcJtTcSSQ35UvQ/s0SwPVhUv990BzdcDluKH4aH3QmYjKkc1Xj9uAJmjZuNs5EABW9LKw
X-Received: by 2002:a17:906:180c:: with SMTP id v12mr1179347eje.45.1550079808495;
        Wed, 13 Feb 2019 09:43:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550079808; cv=none;
        d=google.com; s=arc-20160816;
        b=VPFAfkIRTc6bxPcn0EV1tvWq4U6UzehewyYqcEfVMi/78nZOC+bZAq4+QzHWQf0w2t
         czWDBTEOK1jGNth/QxUvVH/s+QDgtcN0N/HkHaWFAeSyoGN7YF+RW8gC+R4jioeqPjO6
         hLPpYUOPhvk1ZRDxFbjTemcq/+K6AjDwExKo5ay6aGDNtOUA9YWkWPVkXO0PuTHIBl+A
         e+nPd1SjtR2qZrc8CSrBxVozAjUgrKSKYuP1oY4lP4zN9cRBT83oIsANUC3LF0EE0cjf
         DPJ/OdHVRdU5z6T6W6bmRnnYAbyyB5FEEdX5I4KZ/jlbIyF+Z12OPiIy9djkBjgYNaSV
         /O+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yMqE0SxU5CYG3T9tTFXhAtaDDtwlklgub+A0kqBD6fo=;
        b=qqAQITSISt60WqYeHYxiegy/GwmHXO3ayhi0btudaFBHLNhFvRX3Az7zGUtfkvBYLW
         h/C0lM3g/ULVeo9KyId0RNUIHCiFyZlJlIZWH4CdVYTJbJtAaaggB1bgBs89Mk/jx3/A
         SevGQaKSKD8IT6mJAonDf1EkF0bZ1qLinQXJ1KgHa3k05PPAKnJAlSN47N3pzBWRc8FI
         58/g5+fuE3Ye/95PN+QPKUKqxAwnzkDiI9nlYXmCo16I/GqrOSgw436MERtMzDMjkimv
         1xpat1so1wfLc6OCebsOqP654DAB2KRRvACYdRRnN1ARezwtEC0tmAxaGOD4AqxxHQGX
         gAmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f5si809991edw.285.2019.02.13.09.43.27
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 09:43:28 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 098A6A78;
	Wed, 13 Feb 2019 09:43:27 -0800 (PST)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2F30E3F675;
	Wed, 13 Feb 2019 09:43:22 -0800 (PST)
Date: Wed, 13 Feb 2019 17:43:19 +0000
From: Dave Martin <Dave.Martin@arm.com>
To: Kevin Brodsky <kevin.brodsky@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	Will Deacon <will.deacon@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgenii Stepanov <eugenis@google.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Branislav Rankov <Branislav.Rankov@arm.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
Message-ID: <20190213174318.GM3567@e103592.cambridge.arm.com>
References: <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com>
 <20181219125249.GB22067@e103592.cambridge.arm.com>
 <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
 <CAFKCwrhH5R3e5ntX0t-gxcE6zzbCNm06pzeFfYEN2K13c5WLTg@mail.gmail.com>
 <20190212180223.GD199333@arrakis.emea.arm.com>
 <20190213145834.GJ3567@e103592.cambridge.arm.com>
 <90c54249-00dd-f8dd-6873-6bb8615c2c8a@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <90c54249-00dd-f8dd-6873-6bb8615c2c8a@arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 04:42:11PM +0000, Kevin Brodsky wrote:
> (+Cc other people with MTE experience: Branislav, Ruben)

[...]

> >I'm wondering whether we can piggy-back on existing concepts.
> >
> >We could say that recolouring memory is safe when and only when
> >unmapping of the page or removing permissions on the page (via
> >munmap/mremap/mprotect) would be safe.  Otherwise, the resulting
> >behaviour of the process is undefined.
> 
> Is that a sufficient requirement? I don't think that anything prevents you
> from using mprotect() on say [vvar], but we don't necessarily want to map
> [vvar] as tagged. I'm not sure it's easy to define what "safe" would mean
> here.

I think the origin rules have to apply too: [vvar] is not a regular,
private page but a weird, shared thing mapped for you by the kernel.

Presumably userspace _cannot_ do mprotect(PROT_WRITE) on it.

I'm also assuming that userspace cannot recolour memory in read-only
pages.  That sounds bad if there's no way to prevent it.

[...]

> >It might be reasonable to do the check in access_ok() and skip it in
> >__put_user() etc.
> >
> >(I seem to remember some separate discussion about abolishing
> >__put_user() and friends though, due to the accident risk they pose.)
> 
> Keep in mind that with MTE, there is no need to do any explicit check when
> accessing user memory via a user-provided pointer. The tagged user pointer
> is directly passed to copy_*_user() or put_user(). If the load/store causes
> a tag fault, then it is handled just like a page fault (i.e. invoking the
> fixup handler). As far as I can tell, there's no need to do anything special
> in access_ok() in that case.
> 
> [The above applies to precise mode. In imprecise mode, some more work will
> be needed after the load/store to check whether a tag fault happened.]

Fair enough, I'm a bit hazy on the details as of right now..

[...]

> There are many possible ways to deploy MTE, and debugging is just one of
> them. For instance, you may want to turn on heap colouring for some
> processes in the system, including in production.

To implement enforceable protection, or as a diagnostic tool for when
something goes wrong?

In the latter case it's still OK for the kernel's tag checking not to be
exhaustive.

> Regarding those cases where it is impossible to check tags at the point of
> accessing user memory, it is indeed possible to check the memory tags at the
> point of stripping the tag from the user pointer. Given that some MTE
> use-cases favour performance over tag check coverage, the ideal approach
> would be to make these checks configurable (e.g. check one granule, check
> all of them, or check none). I don't know how feasible this is in practice.

Check all granules of a massive DMA buffer?

That doesn't sounds feasible without explicit support in the hardware to
have the DMA check tags itself as the memory is accessed.  MTE by itself
doesn't provide for this IIUC (at least, it would require support in the
platform, not just the CPU).

We do not want to bake any assumptions into the ABI about whether a
given data transfer may or may not be offloaded to DMA.  That feels
like a slippery slope.

Providing we get the checks for free in put_user/get_user/
copy_{to,from}_user(), those will cover a lot of cases though, for
non-bulk-IO cases.


My assumption has been that at this point in time we are mainly aiming
to support the debug/diagnostic use cases today.

At least, those are the low(ish)-hanging fruit.

Others are better placed than me to comment on the goals here.

Cheers
---Dave

