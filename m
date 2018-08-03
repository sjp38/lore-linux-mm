Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 736956B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 11:59:22 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id h11-v6so2767379uao.22
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 08:59:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 6-v6sor2106662uas.151.2018.08.03.08.59.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Aug 2018 08:59:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
 <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com> <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Fri, 3 Aug 2018 18:59:20 +0300
Message-ID: <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Fri, Aug 3, 2018 at 6:17 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
> On 08/03/2018 09:41 AM, Tony Battersby wrote:
>> On 08/03/2018 04:56 AM, Andy Shevchenko wrote:
>>> On Thu, Aug 2, 2018 at 10:57 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
>>>> Remove code duplication in error messages.  It is now safe to pas a NULL
>>>> dev to dev_err(), so the checks to avoid doing so are no longer
>>>> necessary.
>>>>
>>>> Example:
>>>>
>>>> Error message with dev != NULL:
>>>>   mpt3sas 0000:02:00.0: dma_pool_destroy chain pool, (____ptrval____) busy
>>>>
>>>> Same error message with dev == NULL before patch:
>>>>   dma_pool_destroy chain pool, (____ptrval____) busy
>>>>
>>>> Same error message with dev == NULL after patch:
>>>>   (NULL device *): dma_pool_destroy chain pool, (____ptrval____) busy
>>> Have you checked a history of this?
>>>
>>> I'm pretty sure this was created in an order to avoid bad looking (and
>>> in some cases frightening) "NULL device *" part.
>>>
>>> If it it's the case, I would rather leave it as is, and even not the
>>> case, I'm slightly more bent to the current state.
>>>
>> I did.  "drivers/base/dmapool.c", later moved to "mm/dmapool.c", was
>> added in linux-2.6.3, for which dev_err() did not work will a NULL dev,
>> so the check was necessary back then.  I agree that the (NULL device *):
>> bit is ugly, but these messages should be printed only after a kernel
>> bug, so it is not like they will be making a regular appearance in
>> dmesg.  Considering that, I think that it is better to keep it simple.
>>
>
> My original unsubmitted patch used the following:
>
> +#define pool_err(pool, fmt, args...) \
> +       do { \
> +               if ((pool)->dev) \
> +                       dev_err((pool)->dev, fmt, args); \
> +               else \
> +                       pr_err(fmt, args); \
> +       } while (0)
>
> But then I decided to simplify it to just use dev_err().  I still have
> the old version.  When I submit v3 of the patchset, which would you prefer?

JFYI: git log --no-merges --grep 'NULL device \*'

P.S. I already shared my opinion on this anyway.

-- 
With Best Regards,
Andy Shevchenko
