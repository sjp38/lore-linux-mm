Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3C72C6B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 20:37:19 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so257207pab.32
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 17:37:18 -0700 (PDT)
Message-ID: <524B6AB0.6030009@jp.fujitsu.com>
Date: Tue, 01 Oct 2013 20:37:04 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 2/2] mm: add a field to store names for private anonymous
 memory
References: <1380658901-11666-1-git-send-email-ccross@android.com> <1380658901-11666-2-git-send-email-ccross@android.com>
In-Reply-To: <1380658901-11666-2-git-send-email-ccross@android.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ccross@android.com
Cc: linux-kernel@vger.kernel.org, penberg@kernel.org, dave.hansen@intel.com, peterz@infradead.org, mingo@kernel.org, oleg@redhat.com, ebiederm@xmission.com, jan.glauber@gmail.com, rob@landley.net, akpm@linux-foundation.org, gorcunov@openvz.org, rientjes@google.com, dave@gnu.org, keescook@chromium.org, xemul@parallels.com, liwanp@linux.vnet.ibm.com, walken@google.com, mgorman@suse.de, riel@redhat.com, jiang.liu@huawei.com, khlebnikov@openvz.org, paulmck@linux.vnet.ibm.com, dhowells@redhat.com, arnd@arndb.de, davej@redhat.com, holt@sgi.com, rafael.j.wysocki@intel.com, shli@fusionio.com, sasha.levin@oracle.com, kosaki.motohiro@jp.fujitsu.com, hughd@google.com, hannes@cmpxchg.org, a.p.zijlstra@chello.nl, linux-doc@vger.kernel.org, linux-mm@kvack.org

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

You can't show the name if the name is placed in end of page.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
