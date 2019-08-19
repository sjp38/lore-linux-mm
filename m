Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B119FC3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:47:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73C1D2070B
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:47:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hb156RXe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73C1D2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 173366B026F; Mon, 19 Aug 2019 11:47:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FD0A6B0270; Mon, 19 Aug 2019 11:47:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDF866B0271; Mon, 19 Aug 2019 11:47:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0098.hostedemail.com [216.40.44.98])
	by kanga.kvack.org (Postfix) with ESMTP id C639A6B026F
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:47:27 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 69508181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:47:27 +0000 (UTC)
X-FDA: 75839606934.14.food08_5e2154fd23c32
X-HE-Tag: food08_5e2154fd23c32
X-Filterd-Recvd-Size: 5644
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:47:26 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id d85so1400393pfd.2
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 08:47:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GVKhbnPbpjWbhz5xDYatb5Jf0xezOaFTSU5iPuDRTeo=;
        b=hb156RXeMFMq/ZFBxV79hUwsJ33TBPwNChB7tz9IM49HqYq3bFTECBQ0jWs93GlT2G
         SEOQohdK8Qpvg992CDM37AZOCtspic82CV7MxeJ16y4n+GAIARuDtkAqM0Vpcs5ugO59
         3sRkxC82ZNpPiJFiSjHCE8xFRcNyFvlrnKXcUERASk/OU7gh9oUuKntlcF8+9VOgRdQO
         XwzHDLp8GeaF9DmG79eL+xmRZIDuOI163umv7VF+AUJ3CNUJ8QSO3555UzdSqQRzm98/
         M6E4uyzHKgmn+l3ROAiDQuvOoBKPpaBx3AvAN7T4WwNWZXw8eHWQZ7MH/qOuEtyRVpnD
         8p+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=GVKhbnPbpjWbhz5xDYatb5Jf0xezOaFTSU5iPuDRTeo=;
        b=byo1P3E+lRQ/vUkUqAA5g1VX3NmmGln/n4mC7I5D3L+fBQhiycnYgDc2B8p2bvpDY7
         Q+yhu0yq6mpuneUQDSwi1kIvbXiOMT5QQd7qHZS3F0fLDniuOsqSg5i8MTaZHwvmH2sF
         7kubEKJ1kJZNygUeC+4mwr3Vxm53c25NkgEvEupEwjJ8UIby0mf2wHcSZcVlB1T6Qz5Z
         H/QKOIJCzQmlfGpbaFkfdpIqpr5OdJRZKOgy++N+1VfZM99MZNeELrXUHHncG4kHYeya
         S+qTB6EAEq61A8+tAhZ7wIcRiVCca8DpIGgaqluFHKnyb8gkof2gqxH/H6x3L+t1etKK
         6Sqg==
X-Gm-Message-State: APjAAAWnqpDE+dtKCHqfrWb59xIuaemQujzSR2vChTwZowCVchuCOxkr
	SoJ2TDOLTwZ3wh4BuEnIK5VYgU5FSnapV63QtVFMqg==
X-Google-Smtp-Source: APXvYqxLTHM5LEFPfn7KCCEc2GvHDBYCQbwS1b0CfA10FVE2b1wMY/bojyivxbvU4UFTnmGkD/DFGafc0BRQouvpbVg=
X-Received: by 2002:a17:90a:858c:: with SMTP id m12mr21540803pjn.129.1566229645488;
 Mon, 19 Aug 2019 08:47:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190815154403.16473-1-catalin.marinas@arm.com> <20190815154403.16473-4-catalin.marinas@arm.com>
In-Reply-To: <20190815154403.16473-4-catalin.marinas@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 19 Aug 2019 17:47:14 +0200
Message-ID: <CAAeHK+wSw6x8EpPc5-7tBnxEjKfYGfH6mUEh013YjKBCy40AZA@mail.gmail.com>
Subject: Re: [PATCH v8 3/5] arm64: Change the tagged_addr sysctl control
 semantics to only prevent the opt-in
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Szabolcs Nagy <szabolcs.nagy@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Dave P Martin <Dave.Martin@arm.com>, Dave Hansen <dave.hansen@intel.com>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 5:44 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> First rename the sysctl control to abi.tagged_addr_disabled and make it
> default off (zero). When abi.tagged_addr_disabled == 1, only block the
> enabling of the TBI ABI via prctl(PR_SET_TAGGED_ADDR_CTRL, PR_TAGGED_ADDR_ENABLE).
> Getting the status of the ABI or disabling it is still allowed.
>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Acked-by: Andrey Konovalov <andreyknvl@google.com>

> ---
>  arch/arm64/kernel/process.c | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
>
> diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> index 76b7c55026aa..03689c0beb34 100644
> --- a/arch/arm64/kernel/process.c
> +++ b/arch/arm64/kernel/process.c
> @@ -579,17 +579,22 @@ void arch_setup_new_exec(void)
>  /*
>   * Control the relaxed ABI allowing tagged user addresses into the kernel.
>   */
> -static unsigned int tagged_addr_prctl_allowed = 1;
> +static unsigned int tagged_addr_disabled;
>
>  long set_tagged_addr_ctrl(unsigned long arg)
>  {
> -       if (!tagged_addr_prctl_allowed)
> -               return -EINVAL;
>         if (is_compat_task())
>                 return -EINVAL;
>         if (arg & ~PR_TAGGED_ADDR_ENABLE)
>                 return -EINVAL;
>
> +       /*
> +        * Do not allow the enabling of the tagged address ABI if globally
> +        * disabled via sysctl abi.tagged_addr_disabled.
> +        */
> +       if (arg & PR_TAGGED_ADDR_ENABLE && tagged_addr_disabled)
> +               return -EINVAL;
> +
>         update_thread_flag(TIF_TAGGED_ADDR, arg & PR_TAGGED_ADDR_ENABLE);
>
>         return 0;
> @@ -597,8 +602,6 @@ long set_tagged_addr_ctrl(unsigned long arg)
>
>  long get_tagged_addr_ctrl(void)
>  {
> -       if (!tagged_addr_prctl_allowed)
> -               return -EINVAL;
>         if (is_compat_task())
>                 return -EINVAL;
>
> @@ -618,9 +621,9 @@ static int one = 1;
>
>  static struct ctl_table tagged_addr_sysctl_table[] = {
>         {
> -               .procname       = "tagged_addr",
> +               .procname       = "tagged_addr_disabled",
>                 .mode           = 0644,
> -               .data           = &tagged_addr_prctl_allowed,
> +               .data           = &tagged_addr_disabled,
>                 .maxlen         = sizeof(int),
>                 .proc_handler   = proc_dointvec_minmax,
>                 .extra1         = &zero,

