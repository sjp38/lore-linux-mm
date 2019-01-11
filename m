Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8577B8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:32:38 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id f203so6324347vsd.17
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:32:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor51150629vsk.36.2019.01.11.07.32.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 07:32:37 -0800 (PST)
MIME-Version: 1.0
References: <20181203180613.228133-1-james.morse@arm.com> <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic> <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com> <20190111120322.GD4729@zn.tnic>
In-Reply-To: <20190111120322.GD4729@zn.tnic>
From: Tyler Baicar <baicar.tyler@gmail.com>
Date: Fri, 11 Jan 2019 10:32:23 -0500
Message-ID: <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: James Morse <james.morse@arm.com>, Linux ACPI <linux-acpi@vger.kernel.org>, kvmarm@lists.cs.columbia.edu, arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

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
