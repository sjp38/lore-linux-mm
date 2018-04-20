Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D68246B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 01:57:18 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j6so2463266pgn.7
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 22:57:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i127sor1264629pgc.70.2018.04.19.22.57.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 22:57:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180420053329.GA37680@big-sky.local>
References: <20180419172451.104700-1-dvyukov@google.com> <CAGXu5jK0fWnyQUYP3H5e8hP-6QbtmeC102a-2Mab4CSqj4bpgg@mail.gmail.com>
 <20180420053329.GA37680@big-sky.local>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 20 Apr 2018 07:56:56 +0200
Message-ID: <CACT4Y+ZZZvHDbiCXXWNVzACU25QZT0j-TbpMpSetuUQFb8Km=Q@mail.gmail.com>
Subject: Re: [PATCH v2] KASAN: prohibit KASAN+STRUCTLEAK combination
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: Kees Cook <keescook@google.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Fengguang Wu <fengguang.wu@intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Fri, Apr 20, 2018 at 7:33 AM, Dennis Zhou <dennisszhou@gmail.com> wrote:
> Hi,
>
> On Thu, Apr 19, 2018 at 01:43:11PM -0700, Kees Cook wrote:
>> On Thu, Apr 19, 2018 at 10:24 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> > Currently STRUCTLEAK inserts initialization out of live scope of
>> > variables from KASAN point of view. This leads to KASAN false
>> > positive reports. Prohibit this combination for now.
>> >
>
> I remember looking at this false positive in November. Please bear with
> me as this is my first time digging through into gcc. It seems address
> sanitizing is a process that starts adding instructions in the ompexp
> pass, with I presume additional passes later doing other things.
>
> It seems the structleak plugin isn't respecting the ASAN markings as it
> also runs after ASAN starts adding instructions and before inlining.
> Thus, the use-after-scope bugs from [1] and [2] get triggered by
> subsequent iterations when looping over an inlined building block.
>
> Would it be possible to run the structleak plugin say before
> "*all_optimizations" instead of "early_optimizations"? Doing so has the
> plugin run after inlining has been done placing initialization code in
> an earlier block that is not a part of the loop. This seems to resolve
> the issue for the latest one from [1] and the November repro case I had
> in [2].


In general, we either need to move the structleak pass or make it
insert instructions at proper locations. I don't know what is the
right way. Moving the pass looks easier.

As a sanity check, I would count number of zeroing inserted by the
plugin it both cases and ensure that now it does not insert order of
magnitude more/less. It's easy with function calls (count them in
objdump output), not sure what's the easiest way to do it for inline
instrumentation. We could insert printf into the pass itself, but it
if runs before inlining and other optimization, it's not the final
number.

Also note that asan pass is at different locations in the pipeline
depending on optimization level:
https://gcc.gnu.org/viewcvs/gcc/trunk/gcc/passes.def?view=markup


> [1] https://lkml.org/lkml/2018/4/18/825
> [2] https://lkml.org/lkml/2017/11/29/868
>
> Thanks,
> Dennis
>
> --------
> diff --git a/scripts/gcc-plugins/structleak_plugin.c b/scripts/gcc-plugins/structleak_plugin.c
> index 10292f7..0061040 100644
> --- a/scripts/gcc-plugins/structleak_plugin.c
> +++ b/scripts/gcc-plugins/structleak_plugin.c
> @@ -211,7 +211,7 @@ __visible int plugin_init(struct plugin_name_args *plugin_info, struct plugin_gc
>         const struct plugin_argument * const argv = plugin_info->argv;
>         bool enable = true;
>
> -       PASS_INFO(structleak, "early_optimizations", 1, PASS_POS_INSERT_BEFORE);
> +       PASS_INFO(structleak, "*all_optimizations", 1, PASS_POS_INSERT_BEFORE);
>
>         if (!plugin_default_version_check(version, &gcc_version)) {
>                 error(G_("incompatible gcc/plugin versions"));
