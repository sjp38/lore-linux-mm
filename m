Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63A04C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:05:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BD6621743
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:05:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="z2yxKPxy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BD6621743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB5396B0007; Tue,  6 Aug 2019 17:05:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA6EE6B0008; Tue,  6 Aug 2019 17:05:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 995836B000D; Tue,  6 Aug 2019 17:05:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3F06B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:05:39 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id d14so10962814otf.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:05:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bL9WIDO7sBDPuzb3CXk+Z4+KurUQJsfGVwyfuIglMnE=;
        b=TKPBYJqjFn4asdU4D2ZsoDVatxjyGBxxl4DIoBpFlUmx2aaR/KzZOlvsOm1W/jFgCK
         D8NU1WyEdRA+C83qCKqULUKT3WU7Yn/JsEljObL7YudteWu75JGTjyQiF3AY8XWR6j0D
         RNdjbjpqJhsLGc9a4Z/k/P+780Z3To3zwcjsVPOhI0m6ahYTaX+XTyXFo93tCFU2Q3m9
         e9Sqk4miFlAGDNUnRM2FavxT8KTv9VbM4mltEc389BVXmM/2xv1UzpokJiFg5c7ORINO
         jQsgndW1b9GSZ2943S6/vcLDYFOlMVLp8GZsq8C7FSFe+CVOMsNIPRHQJBGVewMElyUV
         7niw==
X-Gm-Message-State: APjAAAU5vPcY/XFjJIU1qLlqOUNeHpfy/PVP1kjUzKOH4M+wH7jW+yje
	hjsVpV8bmbGA9ygeelzFN8vDdUCb5ZCaK+46A2qJqNZnIISLUUrFPk9VkiBW1j18fEE20C86QXf
	+1yh+tQ0jzOqmPVbjGdOank/dfyKGSeIbcSHXUkWWwYqgpP7uUNZtB6SA3G0Aooy5Og==
X-Received: by 2002:a9d:30c3:: with SMTP id r3mr4500709otg.141.1565125539095;
        Tue, 06 Aug 2019 14:05:39 -0700 (PDT)
X-Received: by 2002:a9d:30c3:: with SMTP id r3mr4500654otg.141.1565125538109;
        Tue, 06 Aug 2019 14:05:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565125538; cv=none;
        d=google.com; s=arc-20160816;
        b=qekd3ypKLul5E90N7NFq7qTmUBxdJHAIQItCZ3+1LjvkI+01w9b9EQfhyeCCS+jRKI
         i2m/4OKtR65M8dPdLU/+nzc7JPD20gFYISqXrZ+uOT170C94OzPpu6+keZdnkOQ6Fvi5
         y2McprW9a6Tk1enCCPq12rU8pDh+v5erZttIHXxgjT416uM6tflqR3CmRdFcSn/mm3sk
         oED1rQ0dcRT8VHVAUNvmHMwviCZVwkijdzD6BYWV7+BcWaakBBIpohcyKYNKK2zcwsrw
         m4X5uMO7BLZT0+yNkMq0VbEWeyhWIuGxctgRYb/Zzui+sjWfZhshAU41YUg/Ldy3fom4
         kv+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bL9WIDO7sBDPuzb3CXk+Z4+KurUQJsfGVwyfuIglMnE=;
        b=tmG1oiRnLdfiVDU/dA7FC3Q/o8nWd94JOoPWErswUiZrOzUlbUnyw09hinwOfHwtZh
         rJeTkAz/SUM0GVcxyJiE0rLIS03S6hcJslklZgQdBlZfJx8ODm7o2w80bOi1wlUGT1pv
         j4cSGRBK3UTw/TUELdX8IuqBOVqwwaA0OG9NbMchoIp362GsAlEtQTgKVB65nijQvbQQ
         v70DvUcfqOm54k8Nm9RpaHOuZpFp1HDMnhgFEwzXVPmKU8vgn/0KF3Ah97MRvFRLBrmZ
         L8DovmgCBo5mZV1mCi2wDmrls10I2m6UpfuU6VnS/0e9WjVrG9fel/Yk81ir1S2Hd8WQ
         d5qA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=z2yxKPxy;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor45648749otf.164.2019.08.06.14.05.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 14:05:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=z2yxKPxy;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bL9WIDO7sBDPuzb3CXk+Z4+KurUQJsfGVwyfuIglMnE=;
        b=z2yxKPxyTcUc/O0JPDhYlubCTmWn88V/XHMgPAW10JVY9PDY328HIFjdo5D72jUH9f
         NgLzeLRf01N3eu0r1mdcfI7/BvjmTgkY/TwdpldwvbZ6CYEkwmp0eYXtVjobhRaRQuLv
         UKVBPLyKcHIhmZ3R5exIUzoaoQVCcIZsFwVAzTGEHH8mOBIpEeJV0N4FZvasdWo3/BMo
         KGuoLOtTZHjpAh9PykT0gDKxN/TsFkitTz6RF0I1c9hGrl8ZOrgqZWNkXh78fIJeqajS
         J0PWgZNpFBbIOgjBn3Sa58UezqTODB4r3nJN4DcwPF/L6QTs9YSzBz3/MuR4za3eFBwA
         +vLA==
X-Google-Smtp-Source: APXvYqz/Ak9jnetJg9GXee4VtqrfI/7ybe9DtdbHdF+C7k/OSWwPkzRw1cnJyGFIKt8iguhq8EC0LfgFQg7v9HFSu0g=
X-Received: by 2002:a9d:470d:: with SMTP id a13mr4639053otf.126.1565125537390;
 Tue, 06 Aug 2019 14:05:37 -0700 (PDT)
MIME-Version: 1.0
References: <1565112345-28754-1-git-send-email-jane.chu@oracle.com> <1565112345-28754-2-git-send-email-jane.chu@oracle.com>
In-Reply-To: <1565112345-28754-2-git-send-email-jane.chu@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 6 Aug 2019 14:05:25 -0700
Message-ID: <CAPcyv4jv1Dr=mDkYZ62B=nZux=bFWxYFu3u_N+8Pr0i0jyM2Lg@mail.gmail.com>
Subject: Re: [PATCH v4 1/2] mm/memory-failure.c clean up around tk pre-allocation
To: Jane Chu <jane.chu@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jane, looks good. Checkpatch prompts me to point out a couple more fixups:

This patch is titled:

    "mm/memory-failure.c clean up..."

...to match the second patch it should be:

    "mm/memory-failure: clean up..."

On Tue, Aug 6, 2019 at 10:26 AM Jane Chu <jane.chu@oracle.com> wrote:
>
> add_to_kill() expects the first 'tk' to be pre-allocated, it makes
> subsequent allocations on need basis, this makes the code a bit
> difficult to read. Move all the allocation internal to add_to_kill()
> and drop the **tk argument.
>
> Signed-off-by: Jane Chu <jane.chu@oracle.com>
> ---
>  mm/memory-failure.c | 40 +++++++++++++---------------------------
>  1 file changed, 13 insertions(+), 27 deletions(-)
>
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index d9cc660..51d5b20 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -304,25 +304,19 @@ static unsigned long dev_pagemap_mapping_shift(struct page *page,
>  /*
>   * Schedule a process for later kill.
>   * Uses GFP_ATOMIC allocations to avoid potential recursions in the VM.
> - * TBD would GFP_NOIO be enough?
>   */
>  static void add_to_kill(struct task_struct *tsk, struct page *p,
>                        struct vm_area_struct *vma,
> -                      struct list_head *to_kill,
> -                      struct to_kill **tkc)
> +                      struct list_head *to_kill)
>  {
>         struct to_kill *tk;
>
> -       if (*tkc) {
> -               tk = *tkc;
> -               *tkc = NULL;
> -       } else {
> -               tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
> -               if (!tk) {
> -                       pr_err("Memory failure: Out of memory while machine check handling\n");
> -                       return;
> -               }
> +       tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
> +       if (!tk) {
> +               pr_err("Memory failure: Out of memory while machine check handling\n");
> +               return;
>         }

checkpatch points out that this error message can be deleted.
According to the commit that added this check (ebfdc40969f2
"checkpatch: attempt to find unnecessary 'out of memory' messages")
the kernel already prints a message and a backtrace on these events,
so seems like a decent additional cleanup to fold.

With those fixups you can add:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

...along with Naoya's ack.

I would Cc: Andrew Morton on the v5 posting of these as he's the
upstream path for changes to this file.

