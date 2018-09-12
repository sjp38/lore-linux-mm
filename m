Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2A1C8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 12:36:50 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k204-v6so15078296ite.1
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:36:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6-v6sor1179900itz.0.2018.09.12.09.36.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 09:36:49 -0700 (PDT)
MIME-Version: 1.0
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
 <20180910234341.4068.26882.stgit@localhost.localdomain> <20180912141053.GL10951@dhcp22.suse.cz>
 <CAKgT0UdvhV7U5Zniq=KskXz2QsRP8C7ctr5=ZtJwYAVpBT-RHw@mail.gmail.com> <841e8101-40db-9ff2-f688-5f175d91fc31@intel.com>
In-Reply-To: <841e8101-40db-9ff2-f688-5f175d91fc31@intel.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 12 Sep 2018 09:36:37 -0700
Message-ID: <CAKgT0UeKnaY4XebOmtGozbjEJN4k3cwyhdBLPPJLc677-QU+Sw@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: Provide kernel parameter to allow disabling page
 init poisoning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, mhocko@kernel.org, pavel.tatashin@microsoft.com, dan.j.williams@intel.com
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm@lists.01.org, dave.jiang@intel.com, Ingo Molnar <mingo@kernel.org>, jglisse@redhat.com, Andrew Morton <akpm@linux-foundation.org>, logang@deltatee.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Sep 12, 2018 at 8:25 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 09/12/2018 07:49 AM, Alexander Duyck wrote:
> >>> +     page_init_poison=       [KNL] Boot-time parameter changing the
> >>> +                     state of poisoning of page structures during early
> >>> +                     boot. Used to verify page metadata is not accessed
> >>> +                     prior to initialization. Available with
> >>> +                     CONFIG_DEBUG_VM=y.
> >>> +                     off: turn off poisoning
> >>> +                     on: turn on poisoning (default)
> >>> +
> >> what about the following wording or something along those lines
> >>
> >> Boot-time parameter to control struct page poisoning which is a
> >> debugging feature to catch unitialized struct page access. This option
> >> is available only for CONFIG_DEBUG_VM=y and it affects boot time
> >> (especially on large systems). If there are no poisoning bugs reported
> >> on the particular system and workload it should be safe to disable it to
> >> speed up the boot time.
> > That works for me. I will update it for the next release.
>
> FWIW, I rather liked Dan's idea of wrapping this under
> vm_debug=<something>.  We've got a zoo of boot options and it's really
> hard to _remember_ what does what.  For this case, we're creating one
> that's only available under a specific debug option and I think it makes
> total sense to name the boot option accordingly.
>
> For now, I think it makes total sense to do vm_debug=all/off.  If, in
> the future, we get more options, we can do things like slab does and do
> vm_debug=P (for Page poison) for this feature specifically.
>
>         vm_debug =      [KNL] Available with CONFIG_DEBUG_VM=y.
>                         May slow down boot speed, especially on larger-
>                         memory systems when enabled.
>                         off: turn off all runtime VM debug features
>                         all: turn on all debug features (default)

This would introduce a significant amount of code change if we do it
as a parameter that has control over everything.

I would be open to something like "vm_debug_disables=" where we could
then pass individual values like 'P' for disabling page poisoning.
However doing this as a generic interface that could disable
everything now would be messy. I could then also update the print
message so that it lists what is disabled, and what was left enabled.
Then as we need to disable things in the future we could add
additional letters for individual features. I just don't want us
preemptively adding control flags for features that may never need to
be toggled.

I would want to hear from Michal on this before I get too deep into it
as he seemed to be of the opinion that we were already doing too much
code for this and it seems like this is starting to veer off in that
direction.

- Alex
