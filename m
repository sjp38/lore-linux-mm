Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 150C76B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 02:50:59 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id m2-v6so18987435plt.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 23:50:59 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id m193-v6si25188763pfc.312.2018.07.12.23.50.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 23:50:57 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v5 06/11] mm, memory_failure: Collect mapping size in
 collect_procs()
Date: Fri, 13 Jul 2018 06:49:16 +0000
Message-ID: <20180713064916.GB10034@hori1.linux.bs1.fc.nec.co.jp>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153074045526.27838.11460088022513024933.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153074045526.27838.11460088022513024933.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <91675B8EB5C02F4A93C6F4133359C60B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "hch@lst.de" <hch@lst.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jack@suse.cz" <jack@suse.cz>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>

On Wed, Jul 04, 2018 at 02:40:55PM -0700, Dan Williams wrote:
> In preparation for supporting memory_failure() for dax mappings, teach
> collect_procs() to also determine the mapping size. Unlike typical
> mappings the dax mapping size is determined by walking page-table
> entries rather than using the compound-page accounting for THP pages.
>=20
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Looks good to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c |   81 +++++++++++++++++++++++++--------------------=
------
>  1 file changed, 40 insertions(+), 41 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 9d142b9b86dc..4d70753af59c 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -174,22 +174,51 @@ int hwpoison_filter(struct page *p)
>  EXPORT_SYMBOL_GPL(hwpoison_filter);
> =20
>  /*
> + * Kill all processes that have a poisoned page mapped and then isolate
> + * the page.
> + *
> + * General strategy:
> + * Find all processes having the page mapped and kill them.
> + * But we keep a page reference around so that the page is not
> + * actually freed yet.
> + * Then stash the page away
> + *
> + * There's no convenient way to get back to mapped processes
> + * from the VMAs. So do a brute-force search over all
> + * running processes.
> + *
> + * Remember that machine checks are not common (or rather
> + * if they are common you have other problems), so this shouldn't
> + * be a performance issue.
> + *
> + * Also there are some races possible while we get from the
> + * error detection to actually handle it.
> + */
> +
> +struct to_kill {
> +	struct list_head nd;
> +	struct task_struct *tsk;
> +	unsigned long addr;
> +	short size_shift;
> +	char addr_valid;
> +};
> +
> +/*
>   * Send all the processes who have the page mapped a signal.
>   * ``action optional'' if they are not immediately affected by the error
>   * ``action required'' if error happened in current execution context
>   */
> -static int kill_proc(struct task_struct *t, unsigned long addr,
> -			unsigned long pfn, struct page *page, int flags)
> +static int kill_proc(struct to_kill *tk, unsigned long pfn, int flags)
>  {
> -	short addr_lsb;
> +	struct task_struct *t =3D tk->tsk;
> +	short addr_lsb =3D tk->size_shift;
>  	int ret;
> =20
>  	pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory corr=
uption\n",
>  		pfn, t->comm, t->pid);
> -	addr_lsb =3D compound_order(compound_head(page)) + PAGE_SHIFT;
> =20
>  	if ((flags & MF_ACTION_REQUIRED) && t->mm =3D=3D current->mm) {
> -		ret =3D force_sig_mceerr(BUS_MCEERR_AR, (void __user *)addr,
> +		ret =3D force_sig_mceerr(BUS_MCEERR_AR, (void __user *)tk->addr,
>  				       addr_lsb, current);
>  	} else {
>  		/*
> @@ -198,7 +227,7 @@ static int kill_proc(struct task_struct *t, unsigned =
long addr,
>  		 * This could cause a loop when the user sets SIGBUS
>  		 * to SIG_IGN, but hopefully no one will do that?
>  		 */
> -		ret =3D send_sig_mceerr(BUS_MCEERR_AO, (void __user *)addr,
> +		ret =3D send_sig_mceerr(BUS_MCEERR_AO, (void __user *)tk->addr,
>  				      addr_lsb, t);  /* synchronous? */
>  	}
>  	if (ret < 0)
> @@ -235,35 +264,6 @@ void shake_page(struct page *p, int access)
>  EXPORT_SYMBOL_GPL(shake_page);
> =20
>  /*
> - * Kill all processes that have a poisoned page mapped and then isolate
> - * the page.
> - *
> - * General strategy:
> - * Find all processes having the page mapped and kill them.
> - * But we keep a page reference around so that the page is not
> - * actually freed yet.
> - * Then stash the page away
> - *
> - * There's no convenient way to get back to mapped processes
> - * from the VMAs. So do a brute-force search over all
> - * running processes.
> - *
> - * Remember that machine checks are not common (or rather
> - * if they are common you have other problems), so this shouldn't
> - * be a performance issue.
> - *
> - * Also there are some races possible while we get from the
> - * error detection to actually handle it.
> - */
> -
> -struct to_kill {
> -	struct list_head nd;
> -	struct task_struct *tsk;
> -	unsigned long addr;
> -	char addr_valid;
> -};
> -
> -/*
>   * Failure handling: if we can't find or can't kill a process there's
>   * not much we can do.	We just print a message and ignore otherwise.
>   */
> @@ -292,6 +292,7 @@ static void add_to_kill(struct task_struct *tsk, stru=
ct page *p,
>  	}
>  	tk->addr =3D page_address_in_vma(p, vma);
>  	tk->addr_valid =3D 1;
> +	tk->size_shift =3D compound_order(compound_head(p)) + PAGE_SHIFT;
> =20
>  	/*
>  	 * In theory we don't have to kill when the page was
> @@ -317,9 +318,8 @@ static void add_to_kill(struct task_struct *tsk, stru=
ct page *p,
>   * Also when FAIL is set do a force kill because something went
>   * wrong earlier.
>   */
> -static void kill_procs(struct list_head *to_kill, int forcekill,
> -			  bool fail, struct page *page, unsigned long pfn,
> -			  int flags)
> +static void kill_procs(struct list_head *to_kill, int forcekill, bool fa=
il,
> +		unsigned long pfn, int flags)
>  {
>  	struct to_kill *tk, *next;
> =20
> @@ -342,8 +342,7 @@ static void kill_procs(struct list_head *to_kill, int=
 forcekill,
>  			 * check for that, but we need to tell the
>  			 * process anyways.
>  			 */
> -			else if (kill_proc(tk->tsk, tk->addr,
> -					      pfn, page, flags) < 0)
> +			else if (kill_proc(tk, pfn, flags) < 0)
>  				pr_err("Memory failure: %#lx: Cannot send advisory machine check sig=
nal to %s:%d\n",
>  				       pfn, tk->tsk->comm, tk->tsk->pid);
>  		}
> @@ -1012,7 +1011,7 @@ static bool hwpoison_user_mappings(struct page *p, =
unsigned long pfn,
>  	 * any accesses to the poisoned memory.
>  	 */
>  	forcekill =3D PageDirty(hpage) || (flags & MF_MUST_KILL);
> -	kill_procs(&tokill, forcekill, !unmap_success, p, pfn, flags);
> +	kill_procs(&tokill, forcekill, !unmap_success, pfn, flags);
> =20
>  	return unmap_success;
>  }
>=20
> =
