Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 076FD6B0008
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:35:35 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t66-v6so2858704oih.9
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:35:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k186-v6sor5602146oia.268.2018.04.16.11.35.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 11:35:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFqt6zZ9BJXjBxjJy06fOTZo8ybVYg3YOQjGbdaWK0NoAhzofg@mail.gmail.com>
References: <20180414155059.GA18015@jordon-HP-15-Notebook-PC>
 <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com>
 <20180416174740.GA12686@bombadil.infradead.org> <CAPcyv4hUsADs9ueDfLKvcqHvz3Z4ziW=a1V6rkcOtTvoJhw7xg@mail.gmail.com>
 <20180416182146.GC12686@bombadil.infradead.org> <CAFqt6zZ9BJXjBxjJy06fOTZo8ybVYg3YOQjGbdaWK0NoAhzofg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Apr 2018 11:35:33 -0700
Message-ID: <CAPcyv4hYDADk_-52XHAWBNXqrVuef7Q9Dz9q+x4Y++mP0bxp2A@mail.gmail.com>
Subject: Re: [PATCH] dax: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Mon, Apr 16, 2018 at 11:28 AM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> On Mon, Apr 16, 2018 at 11:51 PM, Matthew Wilcox <willy@infradead.org> wrote:
>> On Mon, Apr 16, 2018 at 11:00:26AM -0700, Dan Williams wrote:
>>> On Mon, Apr 16, 2018 at 10:47 AM, Matthew Wilcox <willy@infradead.org> wrote:
>>> > On Mon, Apr 16, 2018 at 09:14:48AM -0700, Dan Williams wrote:
>>> >> > -       rc = vm_insert_mixed(vmf->vma, vmf->address, pfn);
>>> >> > -
>>> >> > -       if (rc == -ENOMEM)
>>> >> > -               return VM_FAULT_OOM;
>>> >> > -       if (rc < 0 && rc != -EBUSY)
>>> >> > -               return VM_FAULT_SIGBUS;
>>> >> > -
>>> >> > -       return VM_FAULT_NOPAGE;
>>> >> > +       return vmf_insert_mixed(vmf->vma, vmf->address, pfn);
>>> >>
>>> >> Ugh, so this change to vmf_insert_mixed() went upstream without fixing
>>> >> the users? This changelog is now misleading as it does not mention
>>> >> that is now an urgent standalone fix. On first read I assumed this was
>>> >> part of a wider effort for 4.18.
>>> >
>>> > You read too quickly.  vmf_insert_mixed() is a *new* function which
>>> > *replaces* vm_insert_mixed() and
>>> > awful-mangling-of-return-values-done-per-driver.
>>> >
>>> > Eventually vm_insert_mixed() will be deleted.  But today is not that day.
>>>
>>> Ah, ok, thanks for the clarification. Then this patch should
>>> definitely be re-titled to "dax: convert to the new vmf_insert_mixed()
>>> helper". The vm_fault_t conversion is just a minor side-effect of that
>>> larger change. I assume this can wait for v4.18.
>
> The primary objective is to change the return type to
> vm_fault_t in all fault handlers and to support that
> we have replace vm_insert_mixed() with vmf_insert_
> mixed() within one fault handler function.
>
> Do I really need to change the patch title ?

At this point, yes, or at least mention the vm_insert_mixed -->
vmf_insert_mixed conversion in the changelog.
