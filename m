Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA8A56B0279
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 18:22:03 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 13so16025806pgg.8
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 15:22:03 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id k64si850655pge.371.2017.07.06.15.22.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 15:22:02 -0700 (PDT)
Date: Thu, 6 Jul 2017 16:22:00 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [RFC v2 2/5] acpi: HMAT support in acpi_parse_entries_array()
Message-ID: <20170706222200.GA31795@linux.intel.com>
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
 <20170706215233.11329-3-ross.zwisler@linux.intel.com>
 <CAJZ5v0gUA4d+NFqEdsXPVktXf+2AX9MurEQAiCFGxU_eaoYE5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0gUA4d+NFqEdsXPVktXf+2AX9MurEQAiCFGxU_eaoYE5A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jerome Glisse <jglisse@redhat.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, "devel@acpica.org" <devel@acpica.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Fri, Jul 07, 2017 at 12:13:54AM +0200, Rafael J. Wysocki wrote:
> On Thu, Jul 6, 2017 at 11:52 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > The current implementation of acpi_parse_entries_array() assumes that each
> > subtable has a standard ACPI subtable entry of type struct
> > acpi_sutbable_header.  This standard subtable header has a one byte length
> > followed by a one byte type.
> >
> > The HMAT subtables have to allow for a longer length so they have subtable
> > headers of type struct acpi_hmat_structure which has a 2 byte type and a 4
> > byte length.
> >
> > Enhance the subtable parsing in acpi_parse_entries_array() so that it can
> > handle these new HMAT subtables.
> >
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  drivers/acpi/numa.c   |  2 +-
> >  drivers/acpi/tables.c | 52 ++++++++++++++++++++++++++++++++++++++++-----------
> >  2 files changed, 42 insertions(+), 12 deletions(-)
> >
> > diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> > index edb0c79..917f1cc 100644
> > --- a/drivers/acpi/numa.c
> > +++ b/drivers/acpi/numa.c
> > @@ -443,7 +443,7 @@ int __init acpi_numa_init(void)
> >          * So go over all cpu entries in SRAT to get apicid to node mapping.
> >          */
> >
> > -       /* SRAT: Static Resource Affinity Table */
> > +       /* SRAT: System Resource Affinity Table */
> >         if (!acpi_table_parse(ACPI_SIG_SRAT, acpi_parse_srat)) {
> >                 struct acpi_subtable_proc srat_proc[3];
> >
> 
> This change is unrelated to the rest of the patch.
> 
> Maybe send it separately?

Sure, will do.

> > diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
> > index ff42539..7979171 100644
> > --- a/drivers/acpi/tables.c
> > +++ b/drivers/acpi/tables.c
> > @@ -218,6 +218,33 @@ void acpi_table_print_madt_entry(struct acpi_subtable_header *header)
> >         }
> >  }
> >
> > +static unsigned long __init
> > +acpi_get_entry_type(char *id, void *entry)
> > +{
> > +       if (!strncmp(id, ACPI_SIG_HMAT, 4))
> > +               return ((struct acpi_hmat_structure *)entry)->type;
> > +       else
> > +               return ((struct acpi_subtable_header *)entry)->type;
> > +}
> 
> I slightly prefer to use ? : in similar situations.

Hmm..that becomes rather long, and seems complex for the already hard to read
?: operator?  Let's see, this:

	if (!strncmp(id, ACPI_SIG_HMAT, 4))
		return ((struct acpi_hmat_structure *)entry)->type;
	else
		return ((struct acpi_subtable_header *)entry)->type;

becomes

	return strncmp(id, ACPI_SIG_HMAT, 4)) ?
		((struct acpi_subtable_header *)entry)->type :
		((struct acpi_hmat_structure *)entry)->type;

Hmm...we only save one line, and I personally find that a lot harder to read,
but that being said if you feel strongly about it I'll make the change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
