Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id DF5BE6B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 17:13:13 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so7796974pdi.19
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 14:13:13 -0700 (PDT)
Message-ID: <524B3AC2.1090904@intel.com>
Date: Tue, 01 Oct 2013 14:12:34 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 2/2] mm: add a field to store names for private anonymous
 memory
References: <1380658901-11666-1-git-send-email-ccross@android.com> <1380658901-11666-2-git-send-email-ccross@android.com>
In-Reply-To: <1380658901-11666-2-git-send-email-ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jan Glauber <jan.glauber@gmail.com>
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Pavel Emelyanov <xemul@parallels.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, Robin Holt <holt@sgi.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, open@kvack.org, list@kvack.org, DOCUMENTATION <linux-doc@vger.kernel.org>open@kvack.orglist@kvack.org, MEMORY MANAGEMENT <linux-mm@kvack.org>

On 10/01/2013 01:21 PM, Colin Cross wrote:
> +static void seq_print_vma_name(struct seq_file *m, struct vm_area_struct *vma)
> +{
> +	const char __user *name = vma_get_anon_name(vma);
> +	struct mm_struct *mm = vma->vm_mm;
> +
> +	unsigned long page_start_vaddr;
> +	unsigned long page_offset;
> +	unsigned long num_pages;
> +	unsigned long max_len = NAME_MAX;
> +	int i;
> +
> +	page_start_vaddr = (unsigned long)name & PAGE_MASK;
> +	page_offset = (unsigned long)name - page_start_vaddr;
> +	num_pages = DIV_ROUND_UP(page_offset + max_len, PAGE_SIZE);
> +
> +	seq_puts(m, "[anon:");
> +
> +	for (i = 0; i < num_pages; i++) {
> +		int len;
> +		int write_len;
> +		const char *kaddr;
> +		long pages_pinned;
> +		struct page *page;
> +
> +		pages_pinned = get_user_pages(current, mm, page_start_vaddr,
> +				1, 0, 0, &page, NULL);
> +		if (pages_pinned < 1) {
> +			seq_puts(m, "<fault>]");
> +			return;
> +		}
> +
> +		kaddr = (const char *)kmap(page);
> +		len = min(max_len, PAGE_SIZE - page_offset);
> +		write_len = strnlen(kaddr + page_offset, len);
> +		seq_write(m, kaddr + page_offset, write_len);
> +		kunmap(page);
> +		put_page(page);
> +
> +		/* if strnlen hit a null terminator then we're done */
> +		if (write_len != len)
> +			break;
> +
> +		max_len -= len;
> +		page_offset = 0;
> +		page_start_vaddr += PAGE_SIZE;
> +	}
> +
> +	seq_putc(m, ']');
> +}

Is there a reason you can't use access_process_vm(), or share some code
with proc_pid_cmdline()?  It seems to be doing a bunch of the same stuff
that you are.  Also, considering that this roll-your-own code, and it's
digging around in user-supplied addresses, it seems like the kind of
thing that's prone to introducing security problems.  Could you share
some of your logic around how misuse of this mechanism is prevented?

If the range this is going after spans two pages, and the second is
bogus, you'll end up with :

	[anon: foo<fault>]

I guess that's OK, but I find it a wee bit funky.


>  #ifdef CONFIG_NUMA
>  /*
>   * These functions are for numa_maps but called in generic **maps seq_file
> @@ -336,6 +386,12 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
>  				pad_len_spaces(m, len);
>  				seq_printf(m, "[stack:%d]", tid);
>  			}
> +			goto done;
> +		}
> +
> +		if (vma_get_anon_name(vma)) {
> +			pad_len_spaces(m, len);
> +			seq_print_vma_name(m, vma);
>  		}
>  	}
>  
> @@ -635,6 +691,12 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  
>  	show_smap_vma_flags(m, vma);
>  
> +	if (vma_get_anon_name(vma)) {
> +		seq_puts(m, "Name:           ");
> +		seq_print_vma_name(m, vma);
> +		seq_putc(m, '\n');
> +	}

FWIW, I'm not a fan of using "get" in function names unless it's taking
some kind of reference.  I'd probably call it "vma_user_anon_ptr()" or
something.

I dug through the implementation a bit, and don't see any showstoppers,
but it does churn around the VMA merging code enough to make me a bit
nervous.  I hope you tested it well. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
