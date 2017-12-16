Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF1C36B026E
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 21:15:44 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id d76so4844233oig.12
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 18:15:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 20sor3125187otd.69.2017.12.15.18.15.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 18:15:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hN6obiLuMGLpufL83E42fu=9ax_dU5YQ5dZjTE78c0Mg@mail.gmail.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <20171214021019.13579-2-ross.zwisler@linux.intel.com> <CAPcyv4gnZ3NJsEUugjBrsBHcs9-yqxkvs_G4V1HHGWF2JDi13g@mail.gmail.com>
 <1658696.rIK19Js0WO@aspire.rjw.lan> <CAPcyv4hN6obiLuMGLpufL83E42fu=9ax_dU5YQ5dZjTE78c0Mg@mail.gmail.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Sat, 16 Dec 2017 03:15:43 +0100
Message-ID: <CAJZ5v0j63w4xZ+82z3Y8TE_nmCqDvic3RNT8RK7W7FDvEredHw@mail.gmail.com>
Subject: Re: [PATCH v3 1/3] acpi: HMAT support in acpi_parse_entries_array()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linux ACPI <linux-acpi@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Sat, Dec 16, 2017 at 2:57 AM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Fri, Dec 15, 2017 at 5:53 PM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
>> On Friday, December 15, 2017 2:10:17 AM CET Dan Williams wrote:
>>> On Wed, Dec 13, 2017 at 6:10 PM, Ross Zwisler
>>> <ross.zwisler@linux.intel.com> wrote:
>>> > The current implementation of acpi_parse_entries_array() assumes that each
>>> > subtable has a standard ACPI subtable entry of type struct
>>> > acpi_subtable_header.  This standard subtable header has a one byte length
>>> > followed by a one byte type.
>>> >
>>> > The HMAT subtables have to allow for a longer length so they have subtable
>>> > headers of type struct acpi_hmat_structure which has a 2 byte type and a 4
>>> > byte length.
>>>
>>> Hmm, NFIT has a 2 byte type and a 2 byte length, so its one more
>>> permutation. I happened to reinvent sub-table parsing in the NFIT
>>> driver, but it might be nice in the future to refactor that to use the
>>> common parsing.
>>>
>>> >
>>> > Enhance the subtable parsing in acpi_parse_entries_array() so that it can
>>> > handle these new HMAT subtables.
>>> >
>>> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>>> > ---
>>> >  drivers/acpi/tables.c | 52 ++++++++++++++++++++++++++++++++++++++++-----------
>>> >  1 file changed, 41 insertions(+), 11 deletions(-)
>>> >
>>> > diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
>>> > index 80ce2a7d224b..f777b94c234a 100644
>>> > --- a/drivers/acpi/tables.c
>>> > +++ b/drivers/acpi/tables.c
>>> > @@ -218,6 +218,33 @@ void acpi_table_print_madt_entry(struct acpi_subtable_header *header)
>>> >         }
>>> >  }
>>> >
>>> > +static unsigned long __init
>>> > +acpi_get_entry_type(char *id, void *entry)
>>> > +{
>>> > +       if (strncmp(id, ACPI_SIG_HMAT, 4) == 0)
>>> > +               return ((struct acpi_hmat_structure *)entry)->type;
>>> > +       else
>>> > +               return ((struct acpi_subtable_header *)entry)->type;
>>> > +}
>>>
>>> It seems inefficient to make all checks keep asking "is HMAT?".
>>
>> Well, ideally, the signature should be checked once.  I guess that can be
>> arranged for here.
>>
>>> Especially if we want to extend this to other table types should we
>>> instead setup and pass a pair of function pointers to parse the
>>> sub-table format?
>>
>> Function pointers may be too much even. :-)
>
> True, how about an enum of acpi sub-table header types?

That works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
