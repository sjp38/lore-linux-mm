Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6D7B6B02EE
	for <linux-mm@kvack.org>; Mon, 15 May 2017 14:09:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x73so23294922wma.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 11:09:23 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id c2si12637756wrb.192.2017.05.15.11.09.22
        for <linux-mm@kvack.org>;
        Mon, 15 May 2017 11:09:22 -0700 (PDT)
Date: Mon, 15 May 2017 20:09:13 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 14/32] efi: Add an EFI table address match function
Message-ID: <20170515180913.lhma7xw52irrdtvr@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211848.10190.65062.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170418211848.10190.65062.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Apr 18, 2017 at 04:18:48PM -0500, Tom Lendacky wrote:
> Add a function that will determine if a supplied physical address matches
> the address of an EFI table.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  drivers/firmware/efi/efi.c |   33 +++++++++++++++++++++++++++++++++
>  include/linux/efi.h        |    7 +++++++
>  2 files changed, 40 insertions(+)
> 
> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
> index b372aad..8f606a3 100644
> --- a/drivers/firmware/efi/efi.c
> +++ b/drivers/firmware/efi/efi.c
> @@ -55,6 +55,25 @@ struct efi __read_mostly efi = {
>  };
>  EXPORT_SYMBOL(efi);
>  
> +static unsigned long *efi_tables[] = {
> +	&efi.mps,
> +	&efi.acpi,
> +	&efi.acpi20,
> +	&efi.smbios,
> +	&efi.smbios3,
> +	&efi.sal_systab,
> +	&efi.boot_info,
> +	&efi.hcdp,
> +	&efi.uga,
> +	&efi.uv_systab,
> +	&efi.fw_vendor,
> +	&efi.runtime,
> +	&efi.config_table,
> +	&efi.esrt,
> +	&efi.properties_table,
> +	&efi.mem_attr_table,
> +};
> +
>  static bool disable_runtime;
>  static int __init setup_noefi(char *arg)
>  {
> @@ -854,6 +873,20 @@ int efi_status_to_err(efi_status_t status)
>  	return err;
>  }
>  
> +bool efi_table_address_match(unsigned long phys_addr)

efi_is_table_address() reads easier/better in the code.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
