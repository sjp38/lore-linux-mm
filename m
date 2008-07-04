Message-ID: <486DBF66.6020701@cn.fujitsu.com>
Date: Fri, 04 Jul 2008 14:12:54 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [-mm] BUG: sleeping function called from invalid context at include/linux/pagemap.h:290
References: <486C9FBD.9000800@cn.fujitsu.com> <Pine.LNX.4.64.0807031747470.14783@blonde.site> <20080704091349.BAA2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080704091349.BAA2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik Van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> Li-san, Could you try to below patch on your environment?
> 

I've tested it, so UNEVICTABLE_LRU is disabled and the bug disapeared.

> 
> ----------------------
> pagewalk use pte_offset_map().
> pte_offset_map() use kmap_atomic().
> __munlock_pte_handler() use lock_page().
> 
> So, in CONFIG_HIGHPTE=y, following error happend.
> 
> 
> BUG: sleeping function called from invalid context at include/linux/pagemap.h:290
> in_atomic():1, irqs_disabled():0
> no locks held by gpg-agent/2134.
> Pid: 2134, comm: gpg-agent Not tainted 2.6.26-rc8-mm1 #11
>  [<c0421d38>] __might_sleep+0xbe/0xc5
>  [<c04770a2>] __munlock_pte_handler+0x3c/0x9e
>  [<c047c11f>] walk_page_range+0x15b/0x1b4
>  [<c0477048>] __munlock_vma_pages_range+0x4e/0x5b
>  [<c0476f0c>] ? __munlock_pmd_handler+0x0/0x10
>  [<c0477066>] ? __munlock_pte_handler+0x0/0x9e
>  [<c0477064>] munlock_vma_pages_range+0xf/0x11
>  [<c0477dcb>] exit_mmap+0x32/0xf2
>  [<c042ac12>] ? exit_mm+0xc7/0xda
>  [<c042732a>] mmput+0x3a/0x8b
>  [<c042ac20>] exit_mm+0xd5/0xda
>  [<c042bf6a>] do_exit+0x1fb/0x5d5
>  [<c045c4df>] ? audit_syscall_exit+0x2aa/0x2c5
>  [<c042c3a3>] do_group_exit+0x5f/0x88
>  [<c042c3db>] sys_exit_group+0xf/0x11
>  [<c0403956>] syscall_call+0x7/0xb
> 
> then, this feature should be disabled on 32BIT until fixed above problem.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> ---
>  mm/Kconfig |    1 +
>  1 file changed, 1 insertion(+)
> 
> Index: b/mm/Kconfig
> ===================================================================
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -216,6 +216,7 @@ config PAGE_WALKER
>  config UNEVICTABLE_LRU
>  	bool "Add LRU list to track non-evictable pages"
>  	default y
> +	depends on 64BIT
>  	select PAGE_WALKER
>  	help
>  	  Keeps unevictable pages off of the active and inactive pageout
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
