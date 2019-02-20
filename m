Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0476C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:04:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 677EA214AF
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:04:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 677EA214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 053658E0036; Wed, 20 Feb 2019 17:04:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F42238E0002; Wed, 20 Feb 2019 17:04:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E31818E0036; Wed, 20 Feb 2019 17:04:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id B71498E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:04:31 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id e25so22234276otp.0
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:04:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=4yZxY3Y+S+KiVezA6TMkDyySmRqgAo0AmO1w1O/wAho=;
        b=ImnTNrCvR1yBzGDQUe3gKsSZcnipF2SVmI43XGcJ7si+aI8WxplKg2mZiebN2lMNtt
         vk6jrjS0kZ9+26ROYBBYUZJw9/4oEk4TWZUFrGrSSzlbnAA/9hrq0hiJdUDDm5TYLMmc
         QxJkMZy96took7TuFUuxIwW5e37+hfB0fWrumYRrHiYQUrwORRMo70z/DWYWYd3fYl0l
         xU8SD6HfLVZbov3fVHZPOfZ2/BJT6NZ6NFeWkCKFRPMhayjmnvh96AFd1TsLG5hhTVbk
         xQe5w+J6ELjZ7JGLojYnFtj0+h3nLNK4nps7A0r+HmNJZjS+BTdhWeteDaTUx/v9YABB
         gJSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYdE+hXjztWe5bX5b3lAbwNOslrYWag8jvERTZQ2ZI7LISqdl7o
	haavFSIp99SS7vJbcjrenCv2JJTFMOn0SNO+iVObgqG+4VeZWOYLi/xxXMdj31rBn+KCQJrvY0F
	M97OBrPJ2WL1eE/YzwcWAoLaDydikxef4yQ42e0x8QBlDbf+WEobEcxiZlAbwu5c+nayRm088Qw
	mIe2PRMkJv4dv5Wyv57A1XhHLSeYMLl/wnxk4cBB0L5yPuGKZb/Z5IteKJvCr9ljGjCVO2yQ5Wm
	mm3tBe5Vxr8jYQMYFRjXAzVzX2EI1ilDOSD/ErpVlYxpTANKowKxsj2MdPgEywkrRWmjR0V2X7Y
	Y1G3SpIWCBIDL4AAxdVhE5IjVDE/KFFhynniVaz+muwU/lnd64522jdm3SlUR20x4Sv8QcqJQA=
	=
X-Received: by 2002:a9d:480c:: with SMTP id c12mr19444634otf.290.1550700271520;
        Wed, 20 Feb 2019 14:04:31 -0800 (PST)
X-Received: by 2002:a9d:480c:: with SMTP id c12mr19444613otf.290.1550700270926;
        Wed, 20 Feb 2019 14:04:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550700270; cv=none;
        d=google.com; s=arc-20160816;
        b=a0oTE8uod8chczDLlYr2500sKGHN2U9tsjWa/zLykOQSUDT/s60hpWWBYnZrF5TrvL
         tA/A4y0gGIQ2OdekALI+XxBDqNZLUjsS0eLexuAji/fjWt2+LBbNCAj3rigNkjjU3tjt
         XhrvFuRSW10SybjkfniLh9B2raP4nHuODsTwzqmqOxj4EFPWpQt6d6UXtaYBKYDRezh7
         Qsi4vLOrAFbq+ZRZ+YtXf+d0fyZjGtSkUurtDUGXhL3CR3FSDu9hJdcFBZEGSi/mN1se
         vxs1mcBQ5UwyHiEdzcFa8qfXiMpuUKRcDWlX3aIAiPLEIBxlI2f5g0ApoXkeNntns5EC
         SQdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=4yZxY3Y+S+KiVezA6TMkDyySmRqgAo0AmO1w1O/wAho=;
        b=KdKUJte2j94UQ9YiutzYeReHz1uYxYQuwU55k9IH47GnoWmCAog+9U+F7TddE35wyt
         5pITrMraUETGG7GTFC71MG1ZMiJBqZHEqf3cV5LSjcXKXEUnOpeJIfqfRGPaSgnzJ3id
         Qa2xOSNCVsaxVMs3aiECAMKLDKvZDGPI7y6aigfsY4ewX7K5wX3xy/ZpwAyChcG1dV0S
         +A4HAnDx46p1iggr5r+WiISjle86QNE0kW4WlKwfFo0m4C3q3m2nprGiBdY+1eFB1OuQ
         zGax4mCu3NmvFuto0kEuGvyJpd+4XVKiyWiwvj3toc7BnsRsUHbVU1tnsPIB925FSYca
         p4Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p24sor10702671otl.112.2019.02.20.14.04.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 14:04:30 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IZ/5ZrH44I/xQLpQFBA1eX0LciDDyBHLZxZPOE/gs0KhKqDjYxda9HRw9mda9P291ig5HLaXDSGrqCQI+OfHK8=
X-Received: by 2002:a9d:5e8c:: with SMTP id f12mr23391011otl.343.1550700270606;
 Wed, 20 Feb 2019 14:04:30 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-9-keith.busch@intel.com>
In-Reply-To: <20190214171017.9362-9-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 20 Feb 2019 23:04:19 +0100
Message-ID: <CAJZ5v0giQ+Xbjem-FLsYGestzBq9BpmpaQk8Zsa7-ry+Z=1gWw@mail.gmail.com>
Subject: Re: [PATCHv6 08/10] acpi/hmat: Register performance attributes
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, 
	Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 6:10 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Save the best performance access attributes and register these with the
> memory's node if HMAT provides the locality table. While HMAT does make
> it possible to know performance for all possible initiator-target
> pairings, we export only the local pairings at this time.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  drivers/acpi/hmat/hmat.c | 17 ++++++++++++++++-
>  1 file changed, 16 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index b29f7160c7bb..6833c4897ff4 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -549,12 +549,27 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
>         }
>  }
>
> +static __init void hmat_register_target_perf(struct memory_target *target)
> +{
> +       unsigned mem_nid = pxm_to_node(target->memory_pxm);
> +
> +       if (!target->hmem_attrs.read_bandwidth &&
> +           !target->hmem_attrs.read_latency &&
> +           !target->hmem_attrs.write_bandwidth &&
> +           !target->hmem_attrs.write_latency)
> +               return;
> +
> +       node_set_perf_attrs(mem_nid, &target->hmem_attrs, 0);
> +}
> +
>  static __init void hmat_register_targets(void)
>  {
>         struct memory_target *target;
>
> -       list_for_each_entry(target, &targets, node)
> +       list_for_each_entry(target, &targets, node) {
>                 hmat_register_target_initiators(target);
> +               hmat_register_target_perf(target);
> +       }
>  }
>
>  static __init void hmat_free_structures(void)
> --
> 2.14.4
>

