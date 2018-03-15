Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 110066B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:48:22 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t10-v6so3129926plr.12
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:48:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x190si3677873pgx.159.2018.03.15.09.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 09:48:21 -0700 (PDT)
Date: Thu, 15 Mar 2018 12:48:16 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
Message-ID: <20180315124816.6aa3d4e2@vmware.local.home>
In-Reply-To: <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On Tue, 13 Mar 2018 18:26:00 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:

> +static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
> +{
> +	struct uprobe_map_info *info;
> +	struct vm_area_struct *vma;
> +	unsigned long vaddr;
> +
> +	uprobe_start_dup_mmap();

Please add a comment here that this function ups the mm ref count for
each info returned. Otherwise it's hard to know what that mmput() below
matches.

-- Steve

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
