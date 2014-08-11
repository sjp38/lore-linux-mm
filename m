Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DDD7A6B0035
	for <linux-mm@kvack.org>; Sun, 10 Aug 2014 21:27:16 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so10195610pab.14
        for <linux-mm@kvack.org>; Sun, 10 Aug 2014 18:27:16 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id lw9si12119923pab.30.2014.08.10.18.27.15
        for <linux-mm@kvack.org>;
        Sun, 10 Aug 2014 18:27:15 -0700 (PDT)
From: "Sha, Ruibin" <ruibin.sha@intel.com>
Subject: RE: [PATCH]  export the function kmap_flush_unused.
Date: Mon, 11 Aug 2014 01:26:45 +0000
Message-ID: <3C85A229999D6B4A89FA64D4680BA6142CAFF3@SHSMSX101.ccr.corp.intel.com>
References: <3C85A229999D6B4A89FA64D4680BA6142C7DFA@SHSMSX101.ccr.corp.intel.com>
 <53E4D312.5000601@codeaurora.org>
In-Reply-To: <53E4D312.5000601@codeaurora.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "mgorman@suse.de" <mgorman@suse.de>, "mingo@redhat.com" <mingo@redhat.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "He, Bo" <bo.he@intel.com>

Hi Chintan,
Thank you very much for your timely and kindly response and comments.

Here is more detail about our Scenario:

    We have a big driver on Android product. The driver allocates lots of
    DDR pages. When applications mmap a file exported from the driver,
    driver would mmap the pages to the application space, usually with
    uncachable prot.
    On ia32/x86_64 arch, we have to avoid page cache alias issue. When
    driver allocates the pages, it would change page original mapping in
    page table with uncachable prot. Sometimes, the allocated page was
    used by kmap/kunmap. After kunmap, the page is still mapped in KMAP
    space. The entries in KMAP page table are not cleaned up until a
    kernel thread flushes the freed KMAP pages(usually it is woken up by ku=
nmap).
    It means the driver need  force to flush the KMAP page table entries be=
fore mapping pages to
    application space to be used. Otherwise, there is a race to create
    cache alias.

    To resolve this issue, we need export function kmap_flush_unused as
    the driver is compiled as module. Then, the driver calls
    kmap_flush_unused if the allocated pages are in HIGHMEM and being
    used by kmap.

Thanks again!

Best Regards
---------------------------------------------------------------
Sha, Rui bin ( Robin )
+86 13817890945
Android System Integration Shanghai

-----Original Message-----
From: Chintan Pandya [mailto:cpandya@codeaurora.org]=20
Sent: Friday, August 8, 2014 9:40 PM
To: Sha, Ruibin
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; mel@csn.ul.ie; a.p.zi=
jlstra@chello.nl; mgorman@suse.de; mingo@redhat.com; Zhang, Yanmin; He, Bo
Subject: Re: [PATCH] export the function kmap_flush_unused.

On 08/08/2014 02:46 PM, Sha, Ruibin wrote:
> export the function kmap_flush_unused.
>
> Scenario: When graphic driver need high memory spece, we use=20
> alloc_pages() to allocate. But if the allocated page has just been=20
> mapped in the KMAP space(like first kmap then kunmap) and no flush=20
> page happened on PKMAP, the page virtual address is not NULL.Then when=20
> we get that page and set page attribute like set_memory_uc and=20
> set_memory_wc, we hit error.

Could you explain your scenario with more details ? set_memory_* should be =
applied on mapped address. And in attempt to map your page (which was just =
kmap and kunmap'ed), it will overwrite the previous mappings.

Moreover, in my view, kmap_flush_unused is just helping us in keeping the c=
ache clean for kmap virtual addresses if they are unmapped. Is it serving a=
ny more purpose here ?

>
> fix: For that scenario,when we get the allocated page and its virtual
> address is not NULL, we would like first flush that page.
> So need export that function kmap_flush_unused.
>
> Signed-off-by: sha, ruibin <ruibin.sha@intel.com>
>
> ---
> mm/highmem.c | 1 +
> 1 file changed, 1 insertion(+)
>
> diff --git a/mm/highmem.c b/mm/highmem.c
> index b32b70c..511299b 100644
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -156,6 +156,7 @@ void kmap_flush_unused(void)
> flush_all_zero_pkmaps();
> unlock_kmap();
> }
> +EXPORT_SYMBOL(kmap_flush_unused);
This symbol is already extern'ed. Is it not sufficient for your case ?
>
> static inline unsigned long map_new_virtual(struct page *page)
> {
> --
> 1.7.9.5
>
> Best Regards
>
> ---------------------------------------------------------------
>
> Sha, Rui bin ( Robin )
>
> +86 13817890945
>
> Android System Integration Shanghai
>


--=20
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
