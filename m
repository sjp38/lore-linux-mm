Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C26A6B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:44:55 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id k17so3485830pfj.10
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:44:55 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s2si3658602pgo.626.2018.03.15.09.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 09:44:54 -0700 (PDT)
Date: Thu, 15 Mar 2018 12:44:49 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/8] Uprobe: Rename map_info to uprobe_map_info
Message-ID: <20180315124449.7d92c06b@vmware.local.home>
In-Reply-To: <20180313125603.19819-4-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180313125603.19819-4-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On Tue, 13 Mar 2018 18:25:58 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
> -static inline struct map_info *free_map_info(struct map_info *info)
> +static inline struct uprobe_map_info *
> +uprobe_free_map_info(struct uprobe_map_info *info)
>  {
> -	struct map_info *next = info->next;
> +	struct uprobe_map_info *next = info->next;
>  	kfree(info);
>  	return next;
>  }
>  
> -static struct map_info *
> -build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
> +static struct uprobe_map_info *
> +uprobe_build_map_info(struct address_space *mapping, loff_t offset,

Also, as these functions have side effects (like you need to perform a
mmput(info->mm), you need to add kerneldoc type comments to these
functions, explaining how to use them.

When you upgrade a function from static to use cases outside the file,
it requires documenting that function for future users.

-- Steve


> +		      bool is_register)
>  {
>  	unsigned long pgoff = offset >> PAGE_SHIFT;
>  	struct vm_area_struct *vma;
> -	struct map_info *curr = NULL;
> -	struct map_info *prev = NULL;
> -	struct map_info *info;
> +	struct uprobe_map_info *curr = NULL;
> +	struct uprobe_map_info *prev = NULL;
> +	struct uprobe_map_info *info;
>  	int more = 0;
>  
>   again:
> @@ -729,7 +731,7 @@ static inline struct map_info *free_map_info(struct map_info *info)
>  			 * Needs GFP_NOWAIT to avoid i_mmap_rwsem recursion through
>  			 * reclaim. This is optimistic, no harm done if it fails.
>  			 */
> -			prev = kmalloc(sizeof(struct map_info),
> +			prev = kmalloc(sizeof(struct uprobe_map_info),
>  					GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);
>  			if (prev)
>  				prev->next = NULL;
> @@ -762,7 +764,7 @@ static inline struct map_info *free_map_info(struct map_info *info)
>  	}
>  
>  	do {
> -		info = kmalloc(sizeof(struct map_info), GFP_KERNEL);
> +		info = kmalloc(sizeof(struct uprobe_map_info), GFP_KERNEL);
>  		if (!info) {
>  			curr = ERR_PTR(-ENOMEM);
>  			goto out;
> @@ -774,7 +776,7 @@ static inline struct map_info *free_map_info(struct map_info *info)
>  	goto again;
>   out:
>  	while (prev)
> -		prev = free_map_info(prev);
> +		prev = uprobe_free_map_info(prev);
>  	return curr;
>  }
>  
> @@ -782,11 +784,11 @@ static inline struct map_info *free_map_info(struct map_info *info)
>  register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
>  {
>  	bool is_register = !!new;
> -	struct map_info *info;
> +	struct uprobe_map_info *info;
>  	int err = 0;
>  
>  	percpu_down_write(&dup_mmap_sem);
> -	info = build_map_info(uprobe->inode->i_mapping,
> +	info = uprobe_build_map_info(uprobe->inode->i_mapping,
>  					uprobe->offset, is_register);
>  	if (IS_ERR(info)) {
>  		err = PTR_ERR(info);
> @@ -825,7 +827,7 @@ static inline struct map_info *free_map_info(struct map_info *info)
>  		up_write(&mm->mmap_sem);
>   free:
>  		mmput(mm);
> -		info = free_map_info(info);
> +		info = uprobe_free_map_info(info);
>  	}
>   out:
>  	percpu_up_write(&dup_mmap_sem);
