Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 69FB16B0036
	for <linux-mm@kvack.org>; Mon, 13 May 2013 11:00:50 -0400 (EDT)
Date: Mon, 13 May 2013 17:00:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH -V2] mm/THP: Use pmd_populate to update the pmd with
 pgtable_t pointer
Message-ID: <20130513150037.GM27980@redhat.com>
References: <1368457000-20874-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368457000-20874-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Mon, May 13, 2013 at 08:26:40PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We should not use set_pmd_at to update pmd_t with pgtable_t pointer. set_pmd_at
> is used to set pmd with huge pte entries and architectures like ppc64, clear
> few flags from the pte when saving a new entry. Without this change we observe
> bad pte errors like below on ppc64 with THP enabled.
> 
> BUG: Bad page map in process ld mm=0xc000001ee39f4780 pte:7fc3f37848000001 pmd:c000001ec0000000
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/huge_memory.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 03a89a2..362c329 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2325,7 +2325,12 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		pte_unmap(pte);
>  		spin_lock(&mm->page_table_lock);
>  		BUG_ON(!pmd_none(*pmd));
> -		set_pmd_at(mm, address, pmd, _pmd);
> +		/*
> +		 * We can only use set_pmd_at when establishing
> +		 * hugepmds and never for establishing regular pmds that
> +		 * points to regular pagetables. Use pmd_populate for that
> +		 */
> +		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
>  		spin_unlock(&mm->page_table_lock);
>  		anon_vma_unlock_write(vma->anon_vma);
>  		goto out;

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
