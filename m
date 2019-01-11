Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 909AEC43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 15:32:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C16420836
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 15:32:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="blu6mQHM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C16420836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D09B38E0002; Fri, 11 Jan 2019 10:32:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB9378E0001; Fri, 11 Jan 2019 10:32:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B821F8E0002; Fri, 11 Jan 2019 10:32:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8577B8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:32:38 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id f203so6324347vsd.17
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:32:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VXZXG5epvEdViOnRFvQv5RkjlVMVW8QhHQzoX8VCrRo=;
        b=alMY2LKM1miFJosRt4qRkl6iHFtn4LNt1P65ElGe2qrvQMfVDO6ljWHBNAoC6jfNMT
         bumff6SnkU083qc+0uI+S5WgOJC1JVv8ex/3y5nsUvwCSl7DPJ7FFJtEnrg0GxvN9Jnr
         e1VAaCk2PW2iBz8IE8EcfruW527hrV/yDh7qFAdExY8+xANa4B99wLU9PzmsTy/t4go+
         x1jVzO0VzPDl0l9UBhVUbjn8a2tRfytTVDpoORb3vNyf+4DjXT74mP6qJQmkYNzqXc8C
         M65cJbe4UbJC1b09YLEz+pZVTzQXHzRQb5GemLL9tcdxfMCeC84hyybwxYK0nOH+oKQ1
         2Xdg==
X-Gm-Message-State: AJcUukfu1OMm1yek84HAUllZcG59ZgnRx/9VNSIiJqvyHkGcdpBiVEiq
	yndQebedJyRDnNUdUIrJnV6IIcvS+TcbumTRALygM3hIJuO6gWXuhGKW0nVhgphZawGKGD0GOLY
	bpU9M1YIEwHN8UCJ5oAK+lKjj2AIT8n9dJISrU/AUz4sejyHurnOINtYENHSpgNZk2X/UgfbeRS
	5oTJFrN1Z6l+faYxe9ccJ5k0gB91kqIARc4DFJNDVWYRpnJ8eomHOtPM2cCrX3ep0kp6iubQJ1W
	0hjINsj8GLHUlwwuC2Ms6MMevjsgv0pnWkzVGhJHoM2u//Hi7tPfrUckGmNBMd6EIXzFkMRaP1v
	KPvRNNlhDoUIqB3iARpSTzXNL3+Vp7DTWb+kgt5WsL8BNhzW3cQKdwWvmLVHOqDZnVJ1oKKrTLv
	B
X-Received: by 2002:a67:75c5:: with SMTP id q188mr6440794vsc.146.1547220758077;
        Fri, 11 Jan 2019 07:32:38 -0800 (PST)
X-Received: by 2002:a67:75c5:: with SMTP id q188mr6440776vsc.146.1547220757245;
        Fri, 11 Jan 2019 07:32:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547220757; cv=none;
        d=google.com; s=arc-20160816;
        b=g4BhVEbvniMKJMUquPM/tJN4TPxgj3+IvJP1NKcsvwOoNHXXlR6topyBjCpjiqGigl
         TttHHGcKpI6vc+VnZBhrmMk8l7wdknOj+utzA8EGKd+o+t24SmM7Xm5XVYDKxU+k0OrU
         OrJUuXqqMqaS96+p1FmjnUMn7uC8Ax+0qHpDSzZa0fOwKxe2iJ7B/q5kH5AdtwLYhG6A
         pVOUAbYqNuDOOuCxzrfhrvC3ieVKSiNzUP/PvSAKLARZFzTc49i8TbBlgvIjE5YDTtfg
         NppLJUwaHGr2UPBAXeRmHzM0hvp5xDHhDhLE+vx07DBph5Ae+VwhHPR3J7dThb1DGXui
         60sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VXZXG5epvEdViOnRFvQv5RkjlVMVW8QhHQzoX8VCrRo=;
        b=ZwZI+gNYQyBN2A1vcKxb+oBiAAViD3IMv+JpItYSETOYmUQ95FkBEy7hiiiHx0Glce
         zSfycALjSv+SPwTghDoSOVJOGSiuMSuKWgUMrm+kOpcjyUCmrtVvZORSVgkxCTj/oA3p
         3yJp2Kdc+UkIUSakQSBP0sD2JosT7d0OmFxC60CS6SEiGBliH3SrBg+1qg4GfgD0HE+I
         pgSivoI//YhNZUtExLqMplUsgiEXRMivRe4iYt8nejNhIBrfcFa7xAIlC3bIcAZ7LtCV
         JpO4/ZZZIg4aOwsXkuIeU/PEFPa7+gGzu+h6Q+qfrOAjJvYWXoVm50WcV72QycZabNtp
         8lvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=blu6mQHM;
       spf=pass (google.com: domain of baicar.tyler@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=baicar.tyler@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor51150629vsk.36.2019.01.11.07.32.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 07:32:37 -0800 (PST)
Received-SPF: pass (google.com: domain of baicar.tyler@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=blu6mQHM;
       spf=pass (google.com: domain of baicar.tyler@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=baicar.tyler@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VXZXG5epvEdViOnRFvQv5RkjlVMVW8QhHQzoX8VCrRo=;
        b=blu6mQHMsW8yznkTp7FqEbWnU6zzoK+iUF2DbDCj+QZitYIMD5yLZSjMQ7JSWa5I6B
         ppZ0vzw5GdqlMw9TD0SsLsNRafznAqs0RUcecMzJtgTRDtA3G7uaTdCjIVL/NmHMFt74
         fAhdCmHKXlqd01FK7LmYEGZl3XXl6bScR5pFw7zwwbZbOi8TmH/I2wbLUSKKfPe3eIub
         lX3VxhxrvksOuBXgnjRKiIcYyExycdHVFUGE1h9OSW46vfu7jTji+VZvgVv5noYs3xzh
         3e3n2TTZF/aerwtvoUIIi8E/aWZ2fD+P4xfHcUgQ/WXJnvQFQYqZhyvpW8mDmrOLiPtk
         7qCQ==
X-Google-Smtp-Source: ALg8bN4rCz7VRS32EHMBUAq+aYoqhbFKkFrMoBEIUkOibyOeuko4rwAIUyq/krWK8kRRfQyZzDZCDZg3kG5ujK7HfYg=
X-Received: by 2002:a67:6b07:: with SMTP id g7mr5713996vsc.150.1547220756660;
 Fri, 11 Jan 2019 07:32:36 -0800 (PST)
MIME-Version: 1.0
References: <20181203180613.228133-1-james.morse@arm.com> <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic> <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com> <20190111120322.GD4729@zn.tnic>
In-Reply-To: <20190111120322.GD4729@zn.tnic>
From: Tyler Baicar <baicar.tyler@gmail.com>
Date: Fri, 11 Jan 2019 10:32:23 -0500
Message-ID:
 <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
To: Borislav Petkov <bp@alien8.de>
Cc: James Morse <james.morse@arm.com>, Linux ACPI <linux-acpi@vger.kernel.org>, 
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
Message-ID: <20190111153223.8OPTNRhVPRVqAcQ5uwPD_32g_QD6P70hrq8jQIlo0h0@z>

On Fri, Jan 11, 2019 at 7:03 AM Borislav Petkov <bp@alien8.de> wrote:
> On Thu, Jan 10, 2019 at 04:01:27PM -0500, Tyler Baicar wrote:
> > On Thu, Jan 10, 2019 at 1:23 PM James Morse <james.morse@arm.com> wrote:
> > > >>
> > > >> +    if (is_hest_type_generic_v2(ghes) && ghes_ack_error(ghes->generic_v2))
> > > >
> > > > Since ghes_ack_error() is always prepended with this check, you could
> > > > push it down into the function:
> > > >
> > > > ghes_ack_error(ghes)
> > > > ...
> > > >
> > > >       if (!is_hest_type_generic_v2(ghes))
> > > >               return 0;
> > > >
> > > > and simplify the two callsites :)
> > >
> > > Great idea! ...
> > >
> > > .. huh. Turns out for ghes_proc() we discard any errors other than ENOENT from
> > > ghes_read_estatus() if is_hest_type_generic_v2(). This masks EIO.
> > >
> > > Most of the error sources discard the result, the worst thing I can find is
> > > ghes_irq_func() will return IRQ_HANDLED, instead of IRQ_NONE when we didn't
> > > really handle the IRQ. They're registered as SHARED, but I don't have an example
> > > of what goes wrong next.
> > >
> > > I think this will also stop the spurious handling code kicking in to shut it up
> > > if its broken and screaming. Unlikely, but not impossible.
> > >
> > > Fixed in a prior patch, with Boris' suggestion, ghes_proc()s tail ends up look
> > > like this:
> > > ----------------------%<----------------------
> > > diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> > > index 0321d9420b1e..8d1f9930b159 100644
> > > --- a/drivers/acpi/apei/ghes.c
> > > +++ b/drivers/acpi/apei/ghes.c
> > > @@ -700,18 +708,11 @@ static int ghes_proc(struct ghes *ghes)
> > >
> > >  out:
> > >         ghes_clear_estatus(ghes, buf_paddr);
> > > +       if (rc != -ENOENT)
> > > +               rc_ack = ghes_ack_error(ghes);
> > >
> > > -       if (rc == -ENOENT)
> > > -               return rc;
> > > -
> > > -       /*
> > > -        * GHESv2 type HEST entries introduce support for error acknowledgment,
> > > -        * so only acknowledge the error if this support is present.
> > > -        */
> > > -       if (is_hest_type_generic_v2(ghes))
> > > -               return ghes_ack_error(ghes->generic_v2);
> > > -
> > > -       return rc;
> > > +       /* If rc and rc_ack failed, return the first one */
> > > +       return rc ? rc : rc_ack;
> > >  }
> > > ----------------------%<----------------------
> > >
> >
> > Looks good to me, I guess there's no harm in acking invalid error status blocks.
>
> Err, why?

If ghes_read_estatus() fails, then either there was no error populated or the
error status block was invalid. If the error status block is invalid, then the
kernel doesn't know what happened in hardware.

I originally thought this was changing what's acked, but it's just changing the
return value of ghes_proc() when ghes_read_estatus() returns -EIO.

> I don't know what the firmware glue does on ARM but if I'd have to
> remain logical - which is hard to do with firmware - the proper thing to
> do would be this:
>
>         rc = ghes_read_estatus(ghes, &buf_paddr);
>         if (rc) {
>                 ghes_reset_hardware();

The kernel would have no way of knowing what to do here.

>         }
>
>         /* clear estatus and bla bla */
>
>         /* Now, I'm in the success case: */
>          ghes_ack_error();
>
>
> This way, you have the error path clear of something unexpected happened
> when reading the hardware, obvious and separated. ghes_reset_hardware()
> clears the registers and does the necessary steps to put the hardware in
> good state again so that it can report the next error.
>
> And the success path simply acks the error and does possibly the same
> thing. The naming of the functions is important though, to denote what
> gets called when.
>
> This way you handle all the cases just fine. No looking at the error
> type and blabla.
>
> Right?

