Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B2A546B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 13:34:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id h12-v6so5989921wrq.2
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 10:34:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t12-v6sor6611352wrs.18.2018.06.07.10.34.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 10:34:54 -0700 (PDT)
MIME-Version: 1.0
References: <20180607145720.22590-1-willy@infradead.org> <20180607145720.22590-7-willy@infradead.org>
 <03d9addb-9c68-c6e5-d7db-57468fc3950c@nvidia.com>
In-Reply-To: <03d9addb-9c68-c6e5-d7db-57468fc3950c@nvidia.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 7 Jun 2018 10:34:41 -0700
Message-ID: <CALvZod6SCZ8mqW4RDkBA0xYqBkF=qbzMDtUaP7q0SBHTbGxmOg@mail.gmail.com>
Subject: Re: [PATCH 6/6] Convert intel uncore to struct_size
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rcampbell@nvidia.com
Cc: Matthew Wilcox <willy@infradead.org>, keescook@chromium.org, Matthew Wilcox <mawilcox@microsoft.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com

On Thu, Jun 7, 2018 at 10:30 AM Ralph Campbell <rcampbell@nvidia.com> wrote:
>
>
>
> On 06/07/2018 07:57 AM, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> >
> > Need to do a bit of rearranging to make this work.
> >
> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > ---
> >   arch/x86/events/intel/uncore.c | 19 ++++++++++---------
> >   1 file changed, 10 insertions(+), 9 deletions(-)
> >
> > diff --git a/arch/x86/events/intel/uncore.c b/arch/x86/events/intel/uncore.c
> > index 15b07379e72d..e15cfad4f89b 100644
> > --- a/arch/x86/events/intel/uncore.c
> > +++ b/arch/x86/events/intel/uncore.c
> > @@ -865,8 +865,6 @@ static void uncore_types_exit(struct intel_uncore_type **types)
> >   static int __init uncore_type_init(struct intel_uncore_type *type, bool setid)
> >   {
> >       struct intel_uncore_pmu *pmus;
> > -     struct attribute_group *attr_group;
> > -     struct attribute **attrs;
> >       size_t size;
> >       int i, j;
> >
> > @@ -891,21 +889,24 @@ static int __init uncore_type_init(struct intel_uncore_type *type, bool setid)
> >                               0, type->num_counters, 0, 0);
> >
> >       if (type->event_descs) {
> > +             struct {
> > +                     struct attribute_group group;
> > +                     struct attribute *attrs[];
> > +             } *attr_group;
> >               for (i = 0; type->event_descs[i].attr.attr.name; i++);
>
> What does this for loop do?
> Looks like nothing given the semicolon at the end.
>

Finding the first index 'i' where type->event_descs[i].attr.attr.name
is NULL with the assumption that one such entry definitely exists.
