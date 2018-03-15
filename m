Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE966B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:21:28 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n51so4541755qta.9
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:21:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o63si3485347qtd.423.2018.03.15.07.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 07:21:27 -0700 (PDT)
Date: Thu, 15 Mar 2018 15:21:20 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
Message-ID: <20180315142120.GA19218@redhat.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On 03/13, Ravi Bangoria wrote:
>
> @@ -1053,6 +1056,9 @@ int uprobe_mmap(struct vm_area_struct *vma)
>  	struct uprobe *uprobe, *u;
>  	struct inode *inode;
>
> +	if (uprobe_mmap_callback)
> +		uprobe_mmap_callback(vma);
> +
>  	if (no_uprobe_events() || !valid_vma(vma, true))
>  		return 0;

probe_event_enable() does

	uprobe_register();
	/* WINDOW */
	sdt_increment_ref_ctr();

what if uprobe_mmap() is called in between? The counter(s) in this vma
will be incremented twice, no?

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

I can't understand the logic... Lets ignore sdt_valid_vma() for now.
The caller has uprobe_map_info, why it can't simply do
vma = find_vma(uprobe_map_info->vaddr)? and then check sdt_valid_vma().

Oleg.
