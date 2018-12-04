Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F54A6B7057
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 14:33:02 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id f22so17546914qkm.11
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 11:33:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i127si636375qkd.79.2018.12.04.11.33.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 11:33:01 -0800 (PST)
Date: Tue, 4 Dec 2018 14:32:56 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181204193256.GH2937@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com>
 <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
 <CAPcyv4iddjvOvdRRRMrD5RtrVzLB13cPATbpE52ZcuPWWsyx-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4iddjvOvdRRRMrD5RtrVzLB13cPATbpE52ZcuPWWsyx-w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Tue, Dec 04, 2018 at 11:19:23AM -0800, Dan Williams wrote:
> On Tue, Dec 4, 2018 at 10:58 AM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Dec 04, 2018 at 10:31:17AM -0800, Dan Williams wrote:
> > > On Tue, Dec 4, 2018 at 10:24 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > >
> > > > On Tue, Dec 04, 2018 at 09:06:59AM -0800, Andi Kleen wrote:
> > > > > jglisse@redhat.com writes:
> > > > >
> > > > > > +
> > > > > > +To help with forward compatibility each object as a version value and
> > > > > > +it is mandatory for user space to only use target or initiator with
> > > > > > +version supported by the user space. For instance if user space only
> > > > > > +knows about what version 1 means and sees a target with version 2 then
> > > > > > +the user space must ignore that target as if it does not exist.
> > > > >
> > > > > So once v2 is introduced all applications that only support v1 break.
> > > > >
> > > > > That seems very un-Linux and will break Linus' "do not break existing
> > > > > applications" rule.
> > > > >
> > > > > The standard approach that if you add something incompatible is to
> > > > > add new field, but keep the old ones.
> > > >
> > > > No that's not how it is suppose to work. So let says it is 2018 and you
> > > > have v1 memory (like your regular main DDR memory for instance) then it
> > > > will always be expose a v1 memory.
> > > >
> > > > Fast forward 2020 and you have this new type of memory that is not cache
> > > > coherent and you want to expose this to userspace through HMS. What you
> > > > do is a kernel patch that introduce the v2 type for target and define a
> > > > set of new sysfs file to describe what v2 is. On this new computer you
> > > > report your usual main memory as v1 and your new memory as v2.
> > > >
> > > > So the application that only knew about v1 will keep using any v1 memory
> > > > on your new platform but it will not use any of the new memory v2 which
> > > > is what you want to happen. You do not have to break existing application
> > > > while allowing to add new type of memory.
> > >
> > > That sounds needlessly restrictive. Let the kernel arbitrate what
> > > memory an application gets, don't design a system where applications
> > > are hard coded to a memory type. Applications can hint, or optionally
> > > specify an override and the kernel can react accordingly.
> >
> > You do not want to randomly use non cache coherent memory inside your
> > application :)
> 
> The kernel arbitrates memory, it's a bug if it hands out something
> that exotic to an unaware application.

In some case and for some period of time some application would like
to use exotic memory for performance reasons. This does exist today.
Graphics API routinely expose uncache memory to application and it has
been doing so for many years.

Some compute folks would like to have some of the benefit of that
sometime. The idea is that you malloc() some memory in your application
do stuff on the CPU, business as usual, then you gonna use that memory
on some exotic device and for that device it would be best if you
migrated that memory to uncache/uncoherent memory. If application
knows its safe to do so then it can decide to pick such memory with
HMS and migrate its malloced stuff there.

This is not only happening in application, it can happen inside a
library that the application use and the application might be totaly
unaware of the library doing so. This is very common today in AI/ML
workload where all the various library in your AI/ML stacks do thing
to the memory you handed them over. It is all part of the library
API contract.

So they are legitimate use case for this hence why i would like to
be able to expose exotic memory to userspace so that it can migrate
regular allocation there when that make sense.

Cheers,
J�r�me
