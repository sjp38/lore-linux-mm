Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 014AE6B000A
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:00:29 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id e21-v6so10671128otf.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:00:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i3-v6sor4502686oib.127.2018.04.16.11.00.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 11:00:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416174740.GA12686@bombadil.infradead.org>
References: <20180414155059.GA18015@jordon-HP-15-Notebook-PC>
 <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com> <20180416174740.GA12686@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Apr 2018 11:00:26 -0700
Message-ID: <CAPcyv4hUsADs9ueDfLKvcqHvz3Z4ziW=a1V6rkcOtTvoJhw7xg@mail.gmail.com>
Subject: Re: [PATCH] dax: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Mon, Apr 16, 2018 at 10:47 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Mon, Apr 16, 2018 at 09:14:48AM -0700, Dan Williams wrote:
>> > -       rc = vm_insert_mixed(vmf->vma, vmf->address, pfn);
>> > -
>> > -       if (rc == -ENOMEM)
>> > -               return VM_FAULT_OOM;
>> > -       if (rc < 0 && rc != -EBUSY)
>> > -               return VM_FAULT_SIGBUS;
>> > -
>> > -       return VM_FAULT_NOPAGE;
>> > +       return vmf_insert_mixed(vmf->vma, vmf->address, pfn);
>>
>> Ugh, so this change to vmf_insert_mixed() went upstream without fixing
>> the users? This changelog is now misleading as it does not mention
>> that is now an urgent standalone fix. On first read I assumed this was
>> part of a wider effort for 4.18.
>
> You read too quickly.  vmf_insert_mixed() is a *new* function which
> *replaces* vm_insert_mixed() and
> awful-mangling-of-return-values-done-per-driver.
>
> Eventually vm_insert_mixed() will be deleted.  But today is not that day.

Ah, ok, thanks for the clarification. Then this patch should
definitely be re-titled to "dax: convert to the new vmf_insert_mixed()
helper". The vm_fault_t conversion is just a minor side-effect of that
larger change. I assume this can wait for v4.18.
