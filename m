Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id B05DC8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 18:24:30 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id a82so2327976vsd.19
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 15:24:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 79sor33612423vkv.73.2019.01.08.15.24.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 15:24:26 -0800 (PST)
Received: from mail-vk1-f179.google.com (mail-vk1-f179.google.com. [209.85.221.179])
        by smtp.gmail.com with ESMTPSA id x132sm23037330vsc.34.2019.01.08.15.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 15:24:23 -0800 (PST)
Received: by mail-vk1-f179.google.com with SMTP id h128so1263857vkg.11
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 15:24:23 -0800 (PST)
MIME-Version: 1.0
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327057.676627.18166704439241470885.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGXu5jLGkfHax86C-M9ya05ojPwwKrpDL90k3gfAqxKc_emKpA@mail.gmail.com> <CAPcyv4h-Qce3-+Ragh5+0hzDvhCbV5YhNhzsnT0+dqnxR0bSzQ@mail.gmail.com>
In-Reply-To: <CAPcyv4h-Qce3-+Ragh5+0hzDvhCbV5YhNhzsnT0+dqnxR0bSzQ@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 8 Jan 2019 15:24:11 -0800
Message-ID: <CAGXu5jLVB6EKETqnKAwjtDYYXj9kjccb6HbFcghmxt8E1Qxq=g@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

On Mon, Jan 7, 2019 at 5:48 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Mon, Jan 7, 2019 at 4:19 PM Kees Cook <keescook@chromium.org> wrote:
> > Why does this need ACPI_NUMA? (e.g. why can't I use this on a non-ACPI
> > arm64 system?)
>
> I was thinking this would be expanded for each platform-type that will
> implement the auto-detect capability. However, there really is no
> direct dependency and if you wanted to just use the command line
> switch that should be allowed on any platform.
>
> I'll delete this dependency for v8, but I'll hold off on that posting
> awaiting feedback from mm folks.

Okay, cool. I'm glad there wasn't a real dep. :)

> > > +static bool shuffle_param;
> > > +extern int shuffle_show(char *buffer, const struct kernel_param *kp)
> > > +{
> > > +       return sprintf(buffer, "%c\n", test_bit(SHUFFLE_ENABLE, &shuffle_state)
> > > +                       ? 'Y' : 'N');
> > > +}
> > > +static int shuffle_store(const char *val, const struct kernel_param *kp)
> > > +{
> > > +       int rc = param_set_bool(val, kp);
> > > +
> > > +       if (rc < 0)
> > > +               return rc;
> > > +       if (shuffle_param)
> > > +               page_alloc_shuffle(SHUFFLE_ENABLE);
> > > +       else
> > > +               page_alloc_shuffle(SHUFFLE_FORCE_DISABLE);
> > > +       return 0;
> > > +}
> > > +module_param_call(shuffle, shuffle_store, shuffle_show, &shuffle_param, 0400);
> >
> > If this is 0400, you don't intend it to be changed after boot. If it's
> > supposed to be immutable, why not make these __init calls?
>
> It's not changeable after boot, but it's still readable after boot.
> This is there to allow interrogation of whether shuffling is in-effect
> at runtime.

In that case, can you make all the runtime-immutable things __ro_after_init?

> > > +                               ALIGN_DOWN(get_random_long() % z->spanned_pages,
> > > +                                               order_pages);
> >
> > How late in the boot process does this happen, btw?
>
> This happens early at mem_init() before the software rng is initialized.
>
> > Do we get warnings
> > from the RNG about early usage?
>
> Yes, it would trigger on some platforms. It does not on my test system
> because I'm running on an arch_get_random_long() enabled system.

Okay, cool. :)

-- 
Kees Cook
