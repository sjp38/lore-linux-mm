Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EBF8C43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 21:01:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8FA7208E3
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 21:01:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qv4UO6Fp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8FA7208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 886358E0001; Thu, 10 Jan 2019 16:01:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 836648E0002; Thu, 10 Jan 2019 16:01:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7384E8E0001; Thu, 10 Jan 2019 16:01:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED438E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:01:41 -0500 (EST)
Received: by mail-vs1-f69.google.com with SMTP id f203so5171911vsd.17
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:01:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BwQUwoxWE9xddt/5B/7ivk+f8UFrG0jsvJWk4vuuwFQ=;
        b=aARpOXSTIsd2V2VJeltb5OlQni1g8j8jCxcx6XfXWNzPnbh3nbRoVbrc85+61HOT9K
         XgaR0ZcvTnhueZqCmIdtDHHL8fu0UIefeVxKV0Jj/VAS/zk3Zpu/IMHqmbCMFfPpN68Q
         xsgciPaQ6+2UayfK2Ej2mJ5P0ePDEt7PpGXmemUMsXwLP9a7pfXLQrEL7EWFCV7hUsvy
         ba3z17lsnVrrBZLNLlJ+cQ/M/nVUhpoFgw3XNfXDZ1HqaJEwnypM9QNuP8nrRWj+Enfb
         j7aBOZF8+5s6u3s/xuARr3S3ndcK/srPHVMlPS2R7dXRdXr74FdFG/dnX1Vb0EM8tyGc
         sNZg==
X-Gm-Message-State: AJcUukdRWMVA0QmlQoImdHbMbKRhmahF7GtfHuCGeWVNJnDQ/OZLzMrl
	RztA4aVlAxdO33PMl9T+ivIYou/zY1rez5Sv2arHr6K5/3uoOgvBs4FugQatL4pB0XyafM976H1
	+IgkpwidXqnyv3mS68NuFJ3ZjqBLG14k1rqHYcwfedviiK/5kWewZKCQwXwkcWcGpYNOagpUNwM
	+BjnvOk/f8JxxEPafuGngMcSm+uzko5Z/gTUh5FdXmWzBXHliw2JAwtbachUEM4K6Xc73oII6QJ
	R8S/IcqSK/0z269oawgQZSpeCxRFzNl/kmwqVwqWTiy1HdQdF9rLzoZKiiobKsAGm03pAepvRXa
	WG1chBQdfev2ZlCC5/BEQ9W0QqE50hioqmZa7uHfDULVUXSmViyEArTFJGchSg0bqK8wCiGqZLX
	w
X-Received: by 2002:a67:79d2:: with SMTP id u201mr4980548vsc.12.1547154100824;
        Thu, 10 Jan 2019 13:01:40 -0800 (PST)
X-Received: by 2002:a67:79d2:: with SMTP id u201mr4980524vsc.12.1547154099853;
        Thu, 10 Jan 2019 13:01:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547154099; cv=none;
        d=google.com; s=arc-20160816;
        b=OYBk2KhF76wPqtYXxZBjG/TD6c+n1DHr7pTcqp/K0540Jfd4N2b9LQ+PrxwgGoHDcT
         mE1cjxGK2vt1Eg9HmUQZKHHWLyHiOuY5Z7zqou/gXlx99/Kj/rvHhj7ASCbxCl/YEag8
         eknkXCg9hM7UUdtNJGdOZkgdKEBnmdzRfZbZwhCuI63fmgfWUs6CTQYUXL+xYpi4NN0/
         EzlJwGC9i11dhyclWd6bVilEJqjjKFSSZ4Fy5W1wW6A2Z/vsdegaA4MRwpKkdCI02ch3
         +aNDcANK3iowfTpXmiHFyFEfbBOB0QZUSQ7o4c7twci917QqoANA4m+bokZZ9C3fNAt4
         JaNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BwQUwoxWE9xddt/5B/7ivk+f8UFrG0jsvJWk4vuuwFQ=;
        b=hlWIKsGEN3YyJLiDb9XLLPFwS3B6PXlMS+hHy4AkDFul+D5dGwSN5wagQAcs+qyoXq
         IRtDB2h29q6ovjgKXb51bNMoC3WF9E65bVz1wp/0NYlU6Hgm19gMS9byLWNs/oEaz3XZ
         W/9o8vsu6uGFlCW8annZ6ISw+XTwzIOmLdVyOCk+ydk/o8f2LCyy1XPlBbstzFGSbzeY
         EzFnvUZ9rCN25LIou1p50ffaBzUt0doiozvR1OOEz7+KXstCLDL1fQKMyNWRcX0QWwXk
         5fuLCNw1lCGpw/9GBeqFqv3fR4D+kCqRwEd1yrtJyP1qHX0p7ymaTRgoIaZ9QKayBUK5
         bE1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qv4UO6Fp;
       spf=pass (google.com: domain of baicar.tyler@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=baicar.tyler@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor49768125vsk.36.2019.01.10.13.01.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 13:01:39 -0800 (PST)
Received-SPF: pass (google.com: domain of baicar.tyler@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qv4UO6Fp;
       spf=pass (google.com: domain of baicar.tyler@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=baicar.tyler@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BwQUwoxWE9xddt/5B/7ivk+f8UFrG0jsvJWk4vuuwFQ=;
        b=qv4UO6FpqbcXjESpEyv6dMMa0ZVDKl3AXXY3Z6ghoqkOyRPJSb2wxDdd9jY9/MQqDz
         ZNxeGNGg13e5BuSafswztXuyY+nVAD+KTFUyapwOv6M4lK2tX6RZ2GVZPk4tFBp4X9Kp
         GhFvUnmyfOcEd+ZzfLzkXNw8lZepJZ3YANpPesKc9HztZhEUJvva5RQvpZmygFBctHlb
         iY2vT1hiRBdDIxQ53VEInE9XoL77Yd6Kcx+UTYCnO0vXHkopySwwJqzoxNTmUnWlOr5U
         qNyCfYclsQZLlURpkiOT1QeuJ1/thy9dmNNnV9/15lfHi786u+TmLJGuITP05OsWOKJ5
         nkRg==
X-Google-Smtp-Source: ALg8bN7/euEd7hrNjX8CZxbHBxPuqP9dEQzhslf1LrRY1c4u3M0PvYOPaAqoVJxODXBanGQcn9ihKfe8zsRMn3xd7qk=
X-Received: by 2002:a67:6b07:: with SMTP id g7mr4545930vsc.150.1547154099333;
 Thu, 10 Jan 2019 13:01:39 -0800 (PST)
MIME-Version: 1.0
References: <20181203180613.228133-1-james.morse@arm.com> <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic> <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
In-Reply-To: <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
From: Tyler Baicar <baicar.tyler@gmail.com>
Date: Thu, 10 Jan 2019 16:01:27 -0500
Message-ID:
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com>
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
To: James Morse <james.morse@arm.com>
Cc: Borislav Petkov <bp@alien8.de>, Linux ACPI <linux-acpi@vger.kernel.org>, 
	kvmarm@lists.cs.columbia.edu, 
	arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, 
	Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, 
	Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, 
	Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, 
	Fan Wu <wufan@codeaurora.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110210127.u7ruOxmkR_sxI1Au_tBcHdSDpzkY-ejdDHg_Kq3MsVI@z>

On Thu, Jan 10, 2019 at 1:23 PM James Morse <james.morse@arm.com> wrote:
> >>
> >> +    if (is_hest_type_generic_v2(ghes) && ghes_ack_error(ghes->generic_v2))
> >
> > Since ghes_ack_error() is always prepended with this check, you could
> > push it down into the function:
> >
> > ghes_ack_error(ghes)
> > ...
> >
> >       if (!is_hest_type_generic_v2(ghes))
> >               return 0;
> >
> > and simplify the two callsites :)
>
> Great idea! ...
>
> .. huh. Turns out for ghes_proc() we discard any errors other than ENOENT from
> ghes_read_estatus() if is_hest_type_generic_v2(). This masks EIO.
>
> Most of the error sources discard the result, the worst thing I can find is
> ghes_irq_func() will return IRQ_HANDLED, instead of IRQ_NONE when we didn't
> really handle the IRQ. They're registered as SHARED, but I don't have an example
> of what goes wrong next.
>
> I think this will also stop the spurious handling code kicking in to shut it up
> if its broken and screaming. Unlikely, but not impossible.
>
> Fixed in a prior patch, with Boris' suggestion, ghes_proc()s tail ends up look
> like this:
> ----------------------%<----------------------
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index 0321d9420b1e..8d1f9930b159 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -700,18 +708,11 @@ static int ghes_proc(struct ghes *ghes)
>
>  out:
>         ghes_clear_estatus(ghes, buf_paddr);
> +       if (rc != -ENOENT)
> +               rc_ack = ghes_ack_error(ghes);
>
> -       if (rc == -ENOENT)
> -               return rc;
> -
> -       /*
> -        * GHESv2 type HEST entries introduce support for error acknowledgment,
> -        * so only acknowledge the error if this support is present.
> -        */
> -       if (is_hest_type_generic_v2(ghes))
> -               return ghes_ack_error(ghes->generic_v2);
> -
> -       return rc;
> +       /* If rc and rc_ack failed, return the first one */
> +       return rc ? rc : rc_ack;
>  }
> ----------------------%<----------------------
>

Looks good to me, I guess there's no harm in acking invalid error status blocks.

T

