Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7FD56B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:50:06 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y17so4534202qth.11
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:50:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g73si2825951qka.136.2018.03.15.07.50.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 07:50:05 -0700 (PDT)
Date: Thu, 15 Mar 2018 15:49:59 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 6/8] trace_uprobe/sdt: Fix multiple update of same
 reference counter
Message-ID: <20180315144959.GB19643@redhat.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-7-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313125603.19819-7-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On 03/13, Ravi Bangoria wrote:
>
> For tiny binaries/libraries, different mmap regions points to the
> same file portion. In such cases, we may increment reference counter
> multiple times.

Yes,

> But while de-registration, reference counter will get
> decremented only by once

could you explain why this happens? sdt_increment_ref_ctr() and
sdt_decrement_ref_ctr() look symmetrical, _decrement_ should see
the same mappings?

Ether way, this patch doesn't look right at first glance... Just
for example,

> +static bool sdt_check_mm_list(struct trace_uprobe *tu, struct mm_struct *mm)
> +{
> +	struct sdt_mm_list *tmp = tu->sml;
> +
> +	if (!tu->sml || !mm)
> +		return false;
> +
> +	while (tmp) {
> +		if (tmp->mm == mm)
> +			return true;
> +		tmp = tmp->next;
> +	}
> +
> +	return false;

...

> +}
> +
> +static void sdt_add_mm_list(struct trace_uprobe *tu, struct mm_struct *mm)
> +{
> +	struct sdt_mm_list *tmp;
> +
> +	tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
> +	if (!tmp)
> +		return;
> +
> +	tmp->mm = mm;
> +	tmp->next = tu->sml;
> +	tu->sml = tmp;
> +}
> +

...

> @@ -1020,8 +1104,16 @@ void trace_uprobe_mmap_callback(struct vm_area_struct *vma)
>  		    !trace_probe_is_enabled(&tu->tp))
>  			continue;
>
> +		down_write(&tu->sml_rw_sem);
> +		if (sdt_check_mm_list(tu, vma->vm_mm))
> +			goto cont;
> +
>  		vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
> -		sdt_update_ref_ctr(vma->vm_mm, vaddr, 1);
> +		if (!sdt_update_ref_ctr(vma->vm_mm, vaddr, 1))
> +			sdt_add_mm_list(tu, vma->vm_mm);
> +
> +cont:
> +		up_write(&tu->sml_rw_sem);

To simplify, suppose that tu->sml is empty.

Some process calls this function, increments the counter and adds its ->mm into
the list.

Then it exits, ->mm is freed.

The next fork/exec allocates the same memory for the new ->mm, the new process
calls trace_uprobe_mmap_callback() and sdt_check_mm_list() returns T?

Oleg.
