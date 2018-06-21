Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 188A16B000A
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 01:56:18 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id p83-v6so860986vkf.9
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 22:56:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n91-v6sor1681700uan.22.2018.06.20.22.56.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 22:56:17 -0700 (PDT)
MIME-Version: 1.0
References: <8fda53b0-9d86-943b-e8b4-fd9d6553f010@i-love.sakura.ne.jp>
 <20180621001509.GQ19934@dastard> <201806210547.w5L5l5Mh029257@www262.sakura.ne.jp>
In-Reply-To: <201806210547.w5L5l5Mh029257@www262.sakura.ne.jp>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 20 Jun 2018 22:56:04 -0700
Message-ID: <CAHH2K0YqWswbfKdi915PJToJUngAbdKqN_2cgtG9CzS1FJRHdg@mail.gmail.com>
Subject: Re: [PATCH] Makefile: Fix backtrace breakage
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: ak@linux.intel.com, Steven Rostedt <rostedt@goodmis.org>, Dave Chinner <david@fromorbit.com>, dchinner@redhat.com, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, osandov@fb.com

On Wed, Jun 20, 2018 at 10:47 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> From 7208bf13827fa7c7d6196ee20f7678eff0d29b36 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 21 Jun 2018 14:15:10 +0900
> Subject: [PATCH] Makefile: Fix backtrace breakage
>
> Dave Chinner noticed that backtrace part is missing in a lockdep report.
>
>   [   68.760085] the existing dependency chain (in reverse order) is:
>   [   69.258520]
>   [   69.258520] -> #1 (fs_reclaim){+.+.}:
>   [   69.623516]
>   [   69.623516] -> #0 (sb_internal){.+.+}:
>   [   70.152322]
>   [   70.152322] other info that might help us debug this:
>
> Since the kernel was using CONFIG_FTRACE_MCOUNT_RECORD=n &&
> CONFIG_FRAME_POINTER=n, objtool_args was not properly calculated
> due to incorrectly placed "endif" in commit 96f60dfa5819a065 ("trace:
> Use -mcount-record for dynamic ftrace").
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Steven Rostedt (VMware) <rostedt@goodmis.org>

This looks similar to https://lkml.org/lkml/2018/6/8/545

> ---
>  scripts/Makefile.build | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/scripts/Makefile.build b/scripts/Makefile.build
> index 34d9e9c..55f22f4 100644
> --- a/scripts/Makefile.build
> +++ b/scripts/Makefile.build
> @@ -239,6 +239,7 @@ cmd_record_mcount =                                         \
>              "$(CC_FLAGS_FTRACE)" ]; then                       \
>                 $(sub_cmd_record_mcount)                        \
>         fi;
> +endif
>  endif # CONFIG_FTRACE_MCOUNT_RECORD
>
>  ifdef CONFIG_STACK_VALIDATION
> @@ -263,7 +264,6 @@ ifneq ($(RETPOLINE_CFLAGS),)
>    objtool_args += --retpoline
>  endif
>  endif
> -endif
>
>
>  ifdef CONFIG_MODVERSIONS
> --
> 1.8.3.1
>
