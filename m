Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 221626B026D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 03:36:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z11-v6so805372wma.4
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 00:36:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16-v6sor4259539wrr.24.2018.07.24.00.36.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 00:36:44 -0700 (PDT)
Date: Tue, 24 Jul 2018 09:36:41 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v6 11/13] x86/mm/pat: Prepare {reserve, free}_memtype()
 for "decoy" addresses
Message-ID: <20180724073641.GA15984@gmail.com>
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153154382700.34503.10197588570935341739.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153154382700.34503.10197588570935341739.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, linux-edac@vger.kernel.org, x86@kernel.org, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Dan Williams <dan.j.williams@intel.com> wrote:

> In preparation for using set_memory_uc() instead set_memory_np() for
> isolating poison from speculation, teach the memtype code to sanitize
> physical addresses vs __PHYSICAL_MASK.
> 
> The motivation for using set_memory_uc() for this case is to allow
> ongoing access to persistent memory pages via the pmem-driver +
> memcpy_mcsafe() until the poison is repaired.
> 
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: <linux-edac@vger.kernel.org>
> Cc: <x86@kernel.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/x86/mm/pat.c |   16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> index 1555bd7d3449..6788ffa990f8 100644
> --- a/arch/x86/mm/pat.c
> +++ b/arch/x86/mm/pat.c
> @@ -512,6 +512,17 @@ static int free_ram_pages_type(u64 start, u64 end)
>  	return 0;
>  }
>  
> +static u64 sanitize_phys(u64 address)
> +{
> +	/*
> +	 * When changing the memtype for pages containing poison allow
> +	 * for a "decoy" virtual address (bit 63 clear) passed to
> +	 * set_memory_X(). __pa() on a "decoy" address results in a
> +	 * physical address with it 63 set.
> +	 */
> +	return address & __PHYSICAL_MASK;

s/it/bit

Thanks,

	Ingo
