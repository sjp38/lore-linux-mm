Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1A196B0010
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 09:48:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g66so1620740pfj.11
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 06:48:18 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m1si1876103pgq.399.2018.03.14.06.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 06:48:17 -0700 (PDT)
Date: Wed, 14 Mar 2018 22:48:09 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
Message-Id: <20180314224809.5ee4c8834bb366faa398e342@kernel.org>
In-Reply-To: <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

Hi Ravi,

On Tue, 13 Mar 2018 18:26:00 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:

> Userspace Statically Defined Tracepoints[1] are dtrace style markers
> inside userspace applications. These markers are added by developer at
> important places in the code. Each marker source expands to a single
> nop instruction in the compiled code but there may be additional
> overhead for computing the marker arguments which expands to couple of
> instructions. In case the overhead is more, execution of it can be
> ommited by runtime if() condition when no one is tracing on the marker:
> 
>     if (reference_counter > 0) {
>         Execute marker instructions;
>     }
> 
> Default value of reference counter is 0. Tracer has to increment the
> reference counter before tracing on a marker and decrement it when
> done with the tracing.
> 
> Implement the reference counter logic in trace_uprobe, leaving core
> uprobe infrastructure as is, except one new callback from uprobe_mmap()
> to trace_uprobe.
> 
> trace_uprobe definition with reference counter will now be:
> 
>   <path>:<offset>[(ref_ctr_offset)]

Would you mean 
<path>:<offset>(<ref_ctr_offset>)
?

or use "[]" for delimiter?

Since,

> @@ -454,6 +458,26 @@ static int create_trace_uprobe(int argc, char **argv)
>  		goto fail_address_parse;
>  	}
>  
> +	/* Parse reference counter offset if specified. */
> +	rctr = strchr(arg, '(');

This seems you choose "()" for delimiter.

> +	if (rctr) {
> +		rctr_end = strchr(arg, ')');

		rctr_end = strchr(rctr, ')');

? since we are sure rctr != NULL.

> +		if (rctr > rctr_end || *(rctr_end + 1) != 0) {
> +			ret = -EINVAL;
> +			pr_info("Invalid reference counter offset.\n");
> +			goto fail_address_parse;
> +		}


Also

> +
> +		*rctr++ = 0;
> +		*rctr_end = 0;

Please consider to use '\0' for nul;

Thanks,



> +		ret = kstrtoul(rctr, 0, &ref_ctr_offset);
> +		if (ret) {
> +			pr_info("Invalid reference counter offset.\n");
> +			goto fail_address_parse;
> +		}
> +	}
> +
> +	/* Parse uprobe offset. */
>  	ret = kstrtoul(arg, 0, &offset);
>  	if (ret)
>  		goto fail_address_parse;
> @@ -488,6 +512,7 @@ static int create_trace_uprobe(int argc, char **argv)
>  		goto fail_address_parse;
>  	}
>  	tu->offset = offset;
> +	tu->ref_ctr_offset = ref_ctr_offset;
>  	tu->inode = inode;
>  	tu->filename = kstrdup(filename, GFP_KERNEL);
>  
> @@ -620,6 +645,8 @@ static int probes_seq_show(struct seq_file *m, void *v)
>  			break;
>  		}
>  	}
> +	if (tu->ref_ctr_offset)
> +		seq_printf(m, "(0x%lx)", tu->ref_ctr_offset);
>  
>  	for (i = 0; i < tu->tp.nr_args; i++)
>  		seq_printf(m, " %s=%s", tu->tp.args[i].name, tu->tp.args[i].comm);
> @@ -894,6 +921,139 @@ static void uretprobe_trace_func(struct trace_uprobe *tu, unsigned long func,
>  	return trace_handle_return(s);
>  }
>  
> +static bool sdt_valid_vma(struct trace_uprobe *tu, struct vm_area_struct *vma)
> +{
> +	unsigned long vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
> +
> +	return tu->ref_ctr_offset &&
> +		vma->vm_file &&
> +		file_inode(vma->vm_file) == tu->inode &&
> +		vma->vm_flags & VM_WRITE &&
> +		vma->vm_start <= vaddr &&
> +		vma->vm_end > vaddr;
> +}
> +
> +static struct vm_area_struct *
> +sdt_find_vma(struct mm_struct *mm, struct trace_uprobe *tu)
> +{
> +	struct vm_area_struct *tmp;
> +
> +	for (tmp = mm->mmap; tmp != NULL; tmp = tmp->vm_next)
> +		if (sdt_valid_vma(tu, tmp))
> +			return tmp;
> +
> +	return NULL;
> +}
> +
> +/*
> + * Reference count gate the invocation of probe. If present,
> + * by default reference count is 0. One needs to increment
> + * it before tracing the probe and decrement it when done.
> + */
> +static int
> +sdt_update_ref_ctr(struct mm_struct *mm, unsigned long vaddr, short d)
> +{
> +	void *kaddr;
> +	struct page *page;
> +	struct vm_area_struct *vma;
> +	int ret = 0;
> +	unsigned short orig = 0;
> +
> +	if (vaddr == 0)
> +		return -EINVAL;
> +
> +	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
> +		FOLL_FORCE | FOLL_WRITE, &page, &vma, NULL);
> +	if (ret <= 0)
> +		return ret;
> +
> +	kaddr = kmap_atomic(page);
> +	memcpy(&orig, kaddr + (vaddr & ~PAGE_MASK), sizeof(orig));
> +	orig += d;
> +	memcpy(kaddr + (vaddr & ~PAGE_MASK), &orig, sizeof(orig));
> +	kunmap_atomic(kaddr);
> +
> +	put_page(page);
> +	return 0;
> +}
> +
> +static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
> +{
> +	struct uprobe_map_info *info;
> +	struct vm_area_struct *vma;
> +	unsigned long vaddr;
> +
> +	uprobe_start_dup_mmap();
> +	info = uprobe_build_map_info(tu->inode->i_mapping,
> +				tu->ref_ctr_offset, false);
> +	if (IS_ERR(info))
> +		goto out;
> +
> +	while (info) {
> +		down_write(&info->mm->mmap_sem);
> +
> +		vma = sdt_find_vma(info->mm, tu);
> +		vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
> +		sdt_update_ref_ctr(info->mm, vaddr, 1);
> +
> +		up_write(&info->mm->mmap_sem);
> +		mmput(info->mm);
> +		info = uprobe_free_map_info(info);
> +	}
> +
> +out:
> +	uprobe_end_dup_mmap();
> +}
> +
> +/* Called with down_write(&vma->vm_mm->mmap_sem) */
> +void trace_uprobe_mmap_callback(struct vm_area_struct *vma)
> +{
> +	struct trace_uprobe *tu;
> +	unsigned long vaddr;
> +
> +	if (!(vma->vm_flags & VM_WRITE))
> +		return;
> +
> +	mutex_lock(&uprobe_lock);
> +	list_for_each_entry(tu, &uprobe_list, list) {
> +		if (!sdt_valid_vma(tu, vma) ||
> +		    !trace_probe_is_enabled(&tu->tp))
> +			continue;
> +
> +		vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
> +		sdt_update_ref_ctr(vma->vm_mm, vaddr, 1);
> +	}
> +	mutex_unlock(&uprobe_lock);
> +}
> +
> +static void sdt_decrement_ref_ctr(struct trace_uprobe *tu)
> +{
> +	struct vm_area_struct *vma;
> +	unsigned long vaddr;
> +	struct uprobe_map_info *info;
> +
> +	uprobe_start_dup_mmap();
> +	info = uprobe_build_map_info(tu->inode->i_mapping,
> +				tu->ref_ctr_offset, false);
> +	if (IS_ERR(info))
> +		goto out;
> +
> +	while (info) {
> +		down_write(&info->mm->mmap_sem);
> +
> +		vma = sdt_find_vma(info->mm, tu);
> +		vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
> +		sdt_update_ref_ctr(info->mm, vaddr, -1);
> +
> +		up_write(&info->mm->mmap_sem);
> +		mmput(info->mm);
> +		info = uprobe_free_map_info(info);
> +	}
> +
> +out:
> +	uprobe_end_dup_mmap();
> +}
> +
>  typedef bool (*filter_func_t)(struct uprobe_consumer *self,
>  				enum uprobe_filter_ctx ctx,
>  				struct mm_struct *mm);
> @@ -939,6 +1099,9 @@ typedef bool (*filter_func_t)(struct uprobe_consumer *self,
>  	if (ret)
>  		goto err_buffer;
>  
> +	if (tu->ref_ctr_offset)
> +		sdt_increment_ref_ctr(tu);
> +
>  	return 0;
>  
>   err_buffer:
> @@ -979,6 +1142,9 @@ typedef bool (*filter_func_t)(struct uprobe_consumer *self,
>  
>  	WARN_ON(!uprobe_filter_is_empty(&tu->filter));
>  
> +	if (tu->ref_ctr_offset)
> +		sdt_decrement_ref_ctr(tu);
> +
>  	uprobe_unregister(tu->inode, tu->offset, &tu->consumer);
>  	tu->tp.flags &= file ? ~TP_FLAG_TRACE : ~TP_FLAG_PROFILE;
>  
> @@ -1423,6 +1589,8 @@ static __init int init_uprobe_trace(void)
>  	/* Profile interface */
>  	trace_create_file("uprobe_profile", 0444, d_tracer,
>  				    NULL, &uprobe_profile_ops);
> +
> +	uprobe_mmap_callback = trace_uprobe_mmap_callback;
>  	return 0;
>  }
>  
> -- 
> 1.8.3.1
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
