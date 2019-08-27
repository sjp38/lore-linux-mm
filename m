Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 882F0C3A5A4
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 23:25:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E44720856
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 23:25:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GWIVi50/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E44720856
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B86866B0006; Tue, 27 Aug 2019 19:25:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B375F6B0008; Tue, 27 Aug 2019 19:25:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4D7C6B000A; Tue, 27 Aug 2019 19:25:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0027.hostedemail.com [216.40.44.27])
	by kanga.kvack.org (Postfix) with ESMTP id 86BFD6B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 19:25:30 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 294C58243765
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 23:25:30 +0000 (UTC)
X-FDA: 75869791620.21.eye10_2ff822a0ad00f
X-HE-Tag: eye10_2ff822a0ad00f
X-Filterd-Recvd-Size: 5763
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 23:25:29 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id d85so395631pfd.2
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 16:25:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=C3Lh+/0FHXGNq2XvS9+HzZnHDnerotizKClAN2CZjKM=;
        b=GWIVi50/b9qoWMgc0w6dan6EeuXkiS/wa2OU8GCVtmDmpXZF2gbr8cQzkvqZrRpECo
         LMFbVstbTesHK2HmDy6GIzY0YyHeK4Q25QKY11usxlEnGqxiV1mijHsBqS2YhwFISzWY
         aZIhkUZYCiMTyWARDlYeSRSpUyDHN4cpcDxevC+9TkfugR6++6o7phn73bJjWpNSzHm2
         zXjusNoBhczPgvGq/i0fBeFta9ZJqw3rlCdx63i6EDPIUwDO5hNXyBZjc5Dfqa+16Fjq
         P8KiHZR8g3IoDsBOWsOJUvGx58zEHy8QdcSpYC3LnjKteI1M43/13Yeailat0OlTZmT9
         b5/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=C3Lh+/0FHXGNq2XvS9+HzZnHDnerotizKClAN2CZjKM=;
        b=Ly8dvjiiQ1gbu1XnBuRgdduKVEPtER1M4++tcWFHelo8NtJWUi6hxJ3YhJd8ZoVm+b
         wu6ckCorQvGxVXMb4W+8SlCpCQjxuzJ96hJY0wKs2GzKYyJEZjadQ26WLLfq1NmdMx9A
         s8uGBXJ/rntHEpvcSAkTqXO0bYOyg7/eIcTPqvDoHfI/LWG62VRsviIs4cOaxu4QCv9u
         U5BYTquf1eVeWXajAsDtfV7+ctQepcyON+fzp9yo+8j89xewsA+I6gCPZiBZpV3QYVN6
         zfqD7JtPw/bWiqPkgnhtdy8jeljO5+OG+A2SQ09cgJNVCpHd5wXpC86w/Xuw0DDDIz6G
         ahjw==
X-Gm-Message-State: APjAAAWonTIqxYlHjkkoZ9Z0Tn3IaidbzPmcwAAugfVI4mJxczGnxive
	sxbA7AVc2Mx/n5M/SxoFU2alI8JXKDxF55dAb6leLQ==
X-Google-Smtp-Source: APXvYqyNcjG5Dunca/fY3J5WjjGlFBlaU8uhKfiPQcptmXaOhOOJjgTB+dbJfrHZkMgVq2JBfoQN/wVpCALRvZhCJqA=
X-Received: by 2002:aa7:984a:: with SMTP id n10mr1197241pfq.3.1566948328083;
 Tue, 27 Aug 2019 16:25:28 -0700 (PDT)
MIME-Version: 1.0
References: <1566920867-27453-1-git-send-email-cai@lca.pw>
In-Reply-To: <1566920867-27453-1-git-send-email-cai@lca.pw>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Tue, 27 Aug 2019 16:25:16 -0700
Message-ID: <CAKwvOdmEZ6ADQyquRYmr+uNFXyZ0wpBZxNCrQnn8qaRZADzjRw@mail.gmail.com>
Subject: Re: [PATCH] mm: silence -Woverride-init/initializer-overrides
To: Qian Cai <cai@lca.pw>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	clang-built-linux <clang-built-linux@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Mark Rutland <mark.rutland@arm.com>, Arnd Bergmann <arnd@arndb.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 8:49 AM Qian Cai <cai@lca.pw> wrote:
>
> When compiling a kernel with W=1, there are several of those warnings
> due to arm64 override a field by purpose. Just disable those warnings
> for both GCC and Clang of this file, so it will help dig "gems" hidden
> in the W=1 warnings by reducing some noises.
>
> mm/init-mm.c:39:2: warning: initializer overrides prior initialization
> of this subobject [-Winitializer-overrides]
>         INIT_MM_CONTEXT(init_mm)
>         ^~~~~~~~~~~~~~~~~~~~~~~~
> ./arch/arm64/include/asm/mmu.h:133:9: note: expanded from macro
> 'INIT_MM_CONTEXT'
>         .pgd = init_pg_dir,
>                ^~~~~~~~~~~
> mm/init-mm.c:30:10: note: previous initialization is here
>         .pgd            = swapper_pg_dir,
>                           ^~~~~~~~~~~~~~
>
> Note: there is a side project trying to support explicitly allowing
> specific initializer overrides in Clang, but there is no guarantee it
> will happen or not.
>
> https://github.com/ClangBuiltLinux/linux/issues/639
>
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/Makefile | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/Makefile b/mm/Makefile
> index d0b295c3b764..5a30b8ecdc55 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile

Hi Qian, thanks for the patch.
Rather than disable the warning outright, and bury the disabling in a
directory specific Makefile, why not move it to W=2 in
scripts/Makefile.extrawarn?


I think even better would be to use pragma's to disable the warning in
mm/init.c.  Looks like __diag support was never ported for clang yet
from include/linux/compiler-gcc.h to include/linux/compiler-clang.h.

Then you could do:

 28 struct mm_struct init_mm = {
 29   .mm_rb    = RB_ROOT,
 30   .pgd    = swapper_pg_dir,
 31   .mm_users = ATOMIC_INIT(2),
 32   .mm_count = ATOMIC_INIT(1),
 33   .mmap_sem = __RWSEM_INITIALIZER(init_mm.mmap_sem),
 34   .page_table_lock =
__SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 35   .arg_lock =  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
 36   .mmlist   = LIST_HEAD_INIT(init_mm.mmlist),
 37   .user_ns  = &init_user_ns,
 38   .cpu_bitmap = { [BITS_TO_LONGS(NR_CPUS)] = 0},
__diag_push();
__diag_ignore(CLANG, 4, "-Winitializer-overrides")
 39   INIT_MM_CONTEXT(init_mm)
__diag_pop();
 40 };


I mean, the arm64 case is not a bug, but I worry about turning this
warning off.  I'd expect it to only warn once during an arm64 build,
so does the warning really detract from "W=1 gem finding?"

> @@ -21,6 +21,9 @@ KCOV_INSTRUMENT_memcontrol.o := n
>  KCOV_INSTRUMENT_mmzone.o := n
>  KCOV_INSTRUMENT_vmstat.o := n
>
> +CFLAGS_init-mm.o += $(call cc-disable-warning, override-init)

-Woverride-init isn't mentioned in the commit message, so not sure if
it's meant to ride along?

> +CFLAGS_init-mm.o += $(call cc-disable-warning, initializer-overrides)
> +

-- 
Thanks,
~Nick Desaulniers

