Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF4896B704A
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 14:19:36 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id s140so11059273oih.4
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 11:19:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8sor8495671otp.142.2018.12.04.11.19.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 11:19:35 -0800 (PST)
MIME-Version: 1.0
References: <20181203233509.20671-1-jglisse@redhat.com> <20181203233509.20671-3-jglisse@redhat.com>
 <875zw98bm4.fsf@linux.intel.com> <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com> <20181204185725.GE2937@redhat.com>
In-Reply-To: <20181204185725.GE2937@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 4 Dec 2018 11:19:23 -0800
Message-ID: <CAPcyv4iddjvOvdRRRMrD5RtrVzLB13cPATbpE52ZcuPWWsyx-w@mail.gmail.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS) documentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Tue, Dec 4, 2018 at 10:58 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Tue, Dec 04, 2018 at 10:31:17AM -0800, Dan Williams wrote:
> > On Tue, Dec 4, 2018 at 10:24 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > >
> > > On Tue, Dec 04, 2018 at 09:06:59AM -0800, Andi Kleen wrote:
> > > > jglisse@redhat.com writes:
> > > >
> > > > > +
> > > > > +To help with forward compatibility each object as a version value and
> > > > > +it is mandatory for user space to only use target or initiator with
> > > > > +version supported by the user space. For instance if user space only
> > > > > +knows about what version 1 means and sees a target with version 2 then
> > > > > +the user space must ignore that target as if it does not exist.
> > > >
> > > > So once v2 is introduced all applications that only support v1 break.
> > > >
> > > > That seems very un-Linux and will break Linus' "do not break existing
> > > > applications" rule.
> > > >
> > > > The standard approach that if you add something incompatible is to
> > > > add new field, but keep the old ones.
> > >
> > > No that's not how it is suppose to work. So let says it is 2018 and you
> > > have v1 memory (like your regular main DDR memory for instance) then it
> > > will always be expose a v1 memory.
> > >
> > > Fast forward 2020 and you have this new type of memory that is not cache
> > > coherent and you want to expose this to userspace through HMS. What you
> > > do is a kernel patch that introduce the v2 type for target and define a
> > > set of new sysfs file to describe what v2 is. On this new computer you
> > > report your usual main memory as v1 and your new memory as v2.
> > >
> > > So the application that only knew about v1 will keep using any v1 memory
> > > on your new platform but it will not use any of the new memory v2 which
> > > is what you want to happen. You do not have to break existing application
> > > while allowing to add new type of memory.
> >
> > That sounds needlessly restrictive. Let the kernel arbitrate what
> > memory an application gets, don't design a system where applications
> > are hard coded to a memory type. Applications can hint, or optionally
> > specify an override and the kernel can react accordingly.
>
> You do not want to randomly use non cache coherent memory inside your
> application :)

The kernel arbitrates memory, it's a bug if it hands out something
that exotic to an unaware application.
