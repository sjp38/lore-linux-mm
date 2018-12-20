Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0588E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 03:57:25 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id w24so517151otk.22
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 00:57:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v136sor2174472oia.95.2018.12.20.00.57.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 00:57:24 -0800 (PST)
MIME-Version: 1.0
References: <20181211010310.8551-1-keith.busch@intel.com> <20181211010310.8551-2-keith.busch@intel.com>
 <CAJZ5v0iqC2CwR2nM7eF6pDcJe2Me-_fFekX=s16-1TGZ6f6gcA@mail.gmail.com>
 <CF6A88132359CE47947DB4C6E1709ED53C557D62@ORSMSX122.amr.corp.intel.com>
 <CAPcyv4jmGH0FS8iBP9=A-nicNfgHAmU+nBHsGgxyS3RNZ9tV5Q@mail.gmail.com> <CF6A88132359CE47947DB4C6E1709ED53C557DAB@ORSMSX122.amr.corp.intel.com>
In-Reply-To: <CF6A88132359CE47947DB4C6E1709ED53C557DAB@ORSMSX122.amr.corp.intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 20 Dec 2018 09:57:11 +0100
Message-ID: <CAJZ5v0iMf15tC6xLwCC8G2DuDazvznPe-BGJ7F+_r384wBRCCA@mail.gmail.com>
Subject: Re: [PATCHv2 01/12] acpi: Create subtable parsing infrastructure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Schmauss, Erik" <erik.schmauss@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "Rafael J. Wysocki" <rafael@kernel.org>, Keith Busch <keith.busch@intel.com>, Robert Moore <robert.moore@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, Dec 20, 2018 at 2:15 AM Schmauss, Erik <erik.schmauss@intel.com> wrote:
>
>
>
> > -----Original Message-----
> > From: linux-acpi-owner@vger.kernel.org [mailto:linux-acpi-
> > owner@vger.kernel.org] On Behalf Of Dan Williams
> > Sent: Wednesday, December 19, 2018 4:00 PM
> > To: Schmauss, Erik <erik.schmauss@intel.com>
> > Cc: Rafael J. Wysocki <rafael@kernel.org>; Busch, Keith
> > <keith.busch@intel.com>; Moore, Robert <robert.moore@intel.com>;
> > Linux Kernel Mailing List <linux-kernel@vger.kernel.org>; ACPI Devel
> > Maling List <linux-acpi@vger.kernel.org>; Linux Memory Management
> > List <linux-mm@kvack.org>; Greg Kroah-Hartman
> > <gregkh@linuxfoundation.org>; Hansen, Dave
> > <dave.hansen@intel.com>
> > Subject: Re: [PATCHv2 01/12] acpi: Create subtable parsing
> > infrastructure
> >
> > On Wed, Dec 19, 2018 at 3:19 PM Schmauss, Erik
> > <erik.schmauss@intel.com> wrote:
> > >
> > >
> > >
> > > > -----Original Message-----
> > > > From: linux-acpi-owner@vger.kernel.org [mailto:linux-acpi-
> > > > owner@vger.kernel.org] On Behalf Of Rafael J. Wysocki
> > > > Sent: Tuesday, December 11, 2018 1:45 AM
> > > > To: Busch, Keith <keith.busch@intel.com>
> > > > Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>; ACPI
> > > > Devel Maling List <linux-acpi@vger.kernel.org>; Linux Memory
> > > > Management List <linux-mm@kvack.org>; Greg Kroah-Hartman
> > > > <gregkh@linuxfoundation.org>; Rafael J. Wysocki
> > <rafael@kernel.org>;
> > > > Hansen, Dave <dave.hansen@intel.com>; Williams, Dan J
> > > > <dan.j.williams@intel.com>
> > > > Subject: Re: [PATCHv2 01/12] acpi: Create subtable parsing
> > > > infrastructure
> > > >
> > > > On Tue, Dec 11, 2018 at 2:05 AM Keith Busch
> > <keith.busch@intel.com>
> > > > wrote:
> > > > >
> > >
> > > Hi Rafael and Bob,
> > >
> > > > > Parsing entries in an ACPI table had assumed a generic header
> > > > > structure that is most common. There is no standard ACPI
> > header,
> > > > > though, so less common types would need custom parsers if they
> > > > > want go through their sub-table entry list.
> > > >
> > > > It looks like the problem at hand is that acpi_hmat_structure is
> > > > incompatible with acpi_subtable_header because of the different
> > layout and field sizes.
> > >
> > > Just out of curiosity, why don't we use ACPICA code to parse static
> > > ACPI tables in Linux?
> > >
> > > We have a disassembler for static tables that parses all supported
> > > tables. This seems like a duplication of code/effort...
> >
> Hi Dan,
>
> > Oh, I thought acpi_table_parse_entries() was the common code.
> > What's the ACPICA duplicate?
>
> I was thinking AcpiDmDumpTable(). After looking at this ACPICA code,
> I realized that the this ACPICA doesn't actually build a parse tree or data structure.
> It loops over the data structure to format the input ACPI table to a file.
>
> To me, it seems like a good idea for Linux and ACPICA to share the same code when
> parsing and analyzing these structures. I know that Linux may emit warnings
> that are specific to Linux but there are structural analyses that should be the same (such as
> checking lengths of tables and subtables so that we don't have out of bounds access).

I agree.

I guess the reason why it has not been done this way was because
nobody thought about it. :-)

So a project to consolidate these things might be a good one.
