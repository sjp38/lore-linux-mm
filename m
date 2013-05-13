Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id B31236B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 10:13:59 -0400 (EDT)
Date: Mon, 13 May 2013 16:13:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/THP: Use pmd_populate to update the pmd with
 pgtable_t pointer
Message-ID: <20130513141357.GL27980@redhat.com>
References: <1368347715-24597-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <871u9b56t2.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871u9b56t2.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

Hi Aneesh,

On Mon, May 13, 2013 at 07:18:57PM +0530, Aneesh Kumar K.V wrote:
> 
> updated one fixing a compile warning.
> 
> From f721c77eb0d6aaf75758e8e93991a05207680ac8 Mon Sep 17 00:00:00 2001
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Date: Sun, 12 May 2013 01:59:00 +0530
> Subject: [PATCH] mm/THP: Use pmd_populate to update the pmd with pgtable_t
>  pointer
> 
> We should not use set_pmd_at to update pmd_t with pgtable_t pointer. set_pmd_at
> is used to set pmd with huge pte entries and architectures like ppc64, clear
> few flags from the pte when saving a new entry. Without this change we observe
> bad pte errors like below on ppc64 with THP enabled.
> 
> BUG: Bad page map in process ld mm=0xc000001ee39f4780 pte:7fc3f37848000001 pmd:c000001ec0000000
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/huge_memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 03a89a2..f0bad1f 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2325,7 +2325,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		pte_unmap(pte);
>  		spin_lock(&mm->page_table_lock);
>  		BUG_ON(!pmd_none(*pmd));
> -		set_pmd_at(mm, address, pmd, _pmd);
> +		pmd_populate(mm, pmd, (pgtable_t)_pmd);
>  		spin_unlock(&mm->page_table_lock);
>  		anon_vma_unlock_write(vma->anon_vma);
>  		goto out;

Great, looks like you found the ppc problem with gcc builds and that
explains also why it cannot happen on x86.

But about the fix, did you test it? The above should be:
pmd_populate(mm, pmd, pmd_pgtable(_pmd)) instead.

_pmd is not a pointer to a page struct and the cast seems to be hiding
a bug. _pmd if something is a physical address potentially with some
high bit set not making it a good physical address either.

So you can only use set_pmd_at when establishing hugepmds, and never
for establishing regular pmds that points to regular pagetables. I
guess a comment would be good to add too.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
