Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9D796B0024
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 16:53:23 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f59-v6so6122232plb.7
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 13:53:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x4si5016005pgq.11.2018.03.22.13.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 13:53:18 -0700 (PDT)
Date: Thu, 22 Mar 2018 13:53:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH v2 1/2] Randomization of address chosen by mmap.
Message-Id: <20180322135314.61efce938293e051e118fa46@linux-foundation.org>
In-Reply-To: <1521736598-12812-2-git-send-email-blackzert@gmail.com>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
	<1521736598-12812-2-git-send-email-blackzert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@synopsys.com, linux@armlinux.org.uk, tony.luck@intel.com, fenghua.yu@intel.com, jhogan@kernel.org, ralf@linux-mips.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, nyc@holomorphy.com, viro@zeniv.linux.org.uk, arnd@arndb.de, gregkh@linuxfoundation.org, deepa.kernel@gmail.com, mhocko@suse.com, hughd@google.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, steve.capper@arm.com, punit.agrawal@arm.com, paul.burton@mips.com, aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com, keescook@chromium.org, bhsharma@redhat.com, riel@redhat.com, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, jglisse@redhat.com, willy@infradead.org, aarcange@redhat.com, oleg@redhat.com, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

On Thu, 22 Mar 2018 19:36:37 +0300 Ilya Smith <blackzert@gmail.com> wrote:

>  include/linux/mm.h |  16 ++++--
>  mm/mmap.c          | 164 +++++++++++++++++++++++++++++++++++++++++++++++++++++

You'll be wanting to update the documentation. 
Documentation/sysctl/kernel.txt and
Documentation/admin-guide/kernel-parameters.txt.

> ...
>
> @@ -2268,6 +2276,9 @@ extern unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info);
>  static inline unsigned long
>  vm_unmapped_area(struct vm_unmapped_area_info *info)
>  {
> +	/* How about 32 bit process?? */
> +	if ((current->flags & PF_RANDOMIZE) && randomize_va_space > 3)
> +		return unmapped_area_random(info);

The handling of randomize_va_space is peculiar.  Rather than being a
bitfield which independently selects different modes, it is treated as
a scalar: the larger the value, the more stuff we randomize.

I can see the sense in that (and I wonder what randomize_va_space=5
will do).  But it is...  odd.

Why did you select randomize_va_space=4 for this?  Is there a mode 3
already and we forgot to document it?  Or did you leave a gap for
something?  If the former, please feel free to fix the documentation
(in a separate, preceding patch) while you're in there ;)

>  	if (info->flags & VM_UNMAPPED_AREA_TOPDOWN)
>  		return unmapped_area_topdown(info);
>  	else
> @@ -2529,11 +2540,6 @@ int drop_caches_sysctl_handler(struct ctl_table *, int,
>  void drop_slab(void);
>  void drop_slab_node(int nid);
>  
>
> ...
>
> @@ -1780,6 +1781,169 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  	return error;
>  }
>  
> +unsigned long unmapped_area_random(struct vm_unmapped_area_info *info)
> +{

This function is just dead code if CONFIG_MMU=n, yes?  Let's add the
ifdefs to make it go away in that case.

> +	struct mm_struct *mm = current->mm;
> +	struct vm_area_struct *vma = NULL;
> +	struct vm_area_struct *visited_vma = NULL;
> +	unsigned long entropy[2];
> +	unsigned long length, low_limit, high_limit, gap_start, gap_end;
> +	unsigned long addr = 0;
> +
> +	/* get entropy with prng */
> +	prandom_bytes(&entropy, sizeof(entropy));
> +	/* small hack to prevent EPERM result */
> +	info->low_limit = max(info->low_limit, mmap_min_addr);
> +
>
> ...
>
> +found:
> +	/* We found a suitable gap. Clip it with the original high_limit. */
> +	if (gap_end > info->high_limit)
> +		gap_end = info->high_limit;
> +	gap_end -= info->length;
> +	gap_end -= (gap_end - info->align_offset) & info->align_mask;
> +	/* only one suitable page */
> +	if (gap_end ==  gap_start)
> +		return gap_start;
> +	addr = entropy[1] % (min((gap_end - gap_start) >> PAGE_SHIFT,
> +							 0x10000UL));

What does the magic 10000 mean?  Isn't a comment needed explaining this?

> +	addr = gap_end - (addr << PAGE_SHIFT);
> +	addr += (info->align_offset - addr) & info->align_mask;
> +	return addr;
> +}
>
> ...
>
