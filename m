Date: Sat, 31 May 2003 10:46:18 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Always passing mm and vma down (was: [RFC][PATCH] Convert do_no_page() to a hook to avoid DFS race)
Message-ID: <20030531104617.J672@nightmaster.csn.tu-chemnitz.de>
References: <20030530164150.A26766@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030530164150.A26766@us.ibm.com>; from paulmck@us.ibm.com on Fri, May 30, 2003 at 04:41:50PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@digeo.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Hi there,

On Fri, May 30, 2003 at 04:41:50PM -0700, Paul E. McKenney wrote:
> -struct page *
> -ia32_install_shared_page (struct vm_area_struct *vma, unsigned long address, int no_share)
> +int
> +ia32_install_shared_page (struct mm_struct *mm, struct vm_area_struct *vma, unsigned long address, int write_access, pmd_t *pmd)
>  {
>  	struct page *pg = ia32_shared_page[(address - vma->vm_start)/PAGE_SIZE];
>  
>  	get_page(pg);
> -	return pg;
> +	return install_new_page(mm, vma, address, write_access, pmd, pg);
>  }

Why do we always pass mm and vma down, even if vma->vm_mm
contains the mm, where the vma belongs to? Is the connection
between a vma and its mm also protected by the mmap_sem?

Is this really necessary or an oversight and we waste a lot of
stack in a lot of places?

If we just need it for accounting: We need current->mm, if we
need it to locate the next vma relatively to this vma, vma->vm_mm
is the one.

Puzzled

Ingo Oeser
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
