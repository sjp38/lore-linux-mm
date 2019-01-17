Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-10-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-10-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 16:21:16 +0100
Message-ID: <CAJZ5v0hFFZjMNr+_iRRvTE7XMsw1+2hOQDPuT6PD6UnAjjxoZw@mail.gmail.com>
Subject: Re: [PATCHv4 09/13] acpi/hmat: Register performance attributes
Content-Type: text/plain; charset="UTF-8"
Sender: linux-kernel-owner@vger.kernel.org
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Save the best performace access attributes and register these with the
> memory's node if HMAT provides the locality table. While HMAT does make
> it possible to know performance for all possible initiator-target
> pairings, we export only the best pairings at this time.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/hmat/Kconfig |  1 +
>  drivers/acpi/hmat/hmat.c  | 34 ++++++++++++++++++++++++++++++++++
>  2 files changed, 35 insertions(+)
>
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> index a4034d37a311..20a0e96ba58a 100644
> --- a/drivers/acpi/hmat/Kconfig
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -2,6 +2,7 @@
>  config ACPI_HMAT
>         bool "ACPI Heterogeneous Memory Attribute Table Support"
>         depends on ACPI_NUMA
> +       select HMEM_REPORTING

If you want HMEM_REPORTING to be only set when ACPI_HMAT is set, then
don't make HMEM_REPORTING user-selectable.

>         help
>          Parses representation of the ACPI Heterogeneous Memory Attributes
>          Table (HMAT) and set the memory node relationships and access
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index efb33c74d1a3..45e20dc677f9 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -23,6 +23,8 @@ struct memory_target {
>         struct list_head node;
>         unsigned int memory_pxm;
>         unsigned long p_nodes[BITS_TO_LONGS(MAX_NUMNODES)];
> +       bool hmem_valid;
> +       struct node_hmem_attrs hmem;
>  };
>
>  static __init struct memory_target *find_mem_target(unsigned int m)
> @@ -108,6 +110,34 @@ static __init void hmat_update_access(u8 type, u32 value, u32 *best)
>         }
>  }
>
> +static __init void hmat_update_target(struct memory_target *t, u8 type,
> +                                     u32 value)
> +{
> +       switch (type) {
> +       case ACPI_HMAT_ACCESS_LATENCY:
> +               t->hmem.read_latency = value;
> +               t->hmem.write_latency = value;
> +               break;
> +       case ACPI_HMAT_READ_LATENCY:
> +               t->hmem.read_latency = value;
> +               break;
> +       case ACPI_HMAT_WRITE_LATENCY:
> +               t->hmem.write_latency = value;
> +               break;
> +       case ACPI_HMAT_ACCESS_BANDWIDTH:
> +               t->hmem.read_bandwidth = value;
> +               t->hmem.write_bandwidth = value;
> +               break;
> +       case ACPI_HMAT_READ_BANDWIDTH:
> +               t->hmem.read_bandwidth = value;
> +               break;
> +       case ACPI_HMAT_WRITE_BANDWIDTH:
> +               t->hmem.write_bandwidth = value;
> +               break;
> +       }
> +       t->hmem_valid = true;

What if 'type' is none of the above?  After all these values come from
the firmware and that need not be correct.

Do you still want to set hmem_valid in that case?

> +}
> +
>  static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>                                       const unsigned long end)
>  {
> @@ -166,6 +196,8 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>                                         set_bit(p_node, t->p_nodes);
>                         }
>                 }
> +               if (t && best)
> +                       hmat_update_target(t, type, best);
>         }
>         return 0;
>  }
> @@ -267,6 +299,8 @@ static __init void hmat_register_targets(void)
>                 m = pxm_to_node(t->memory_pxm);
>                 for_each_set_bit(p, t->p_nodes, MAX_NUMNODES)
>                         register_memory_node_under_compute_node(m, p, 0);
> +               if (t->hmem_valid)
> +                       node_set_perf_attrs(m, &t->hmem, 0);
>                 kfree(t);
>         }
>  }
> --
