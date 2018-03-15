Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58A9E6B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:33:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 139so3470657pfw.7
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:33:01 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g21si781537pgv.388.2018.03.15.09.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 09:33:00 -0700 (PDT)
Date: Thu, 15 Mar 2018 12:32:55 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 4/8] Uprobe: Export uprobe_map_info along with
 uprobe_{build/free}_map_info()
Message-ID: <20180315123255.17a8d997@vmware.local.home>
In-Reply-To: <20180313125603.19819-5-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180313125603.19819-5-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On Tue, 13 Mar 2018 18:25:59 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:

> These exported data structure and functions will be used by other
> files in later patches.

I'm reluctantly OK with the above.

> 
> No functionality changes.

Please remove this line. There are functionality changes. Turning a
static inline into an exported function *is* a functionality change.

-- Steve

> 
> Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
> ---
>  include/linux/uprobes.h |  9 +++++++++
>  kernel/events/uprobes.c | 14 +++-----------
>  2 files changed, 12 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
> index 0a294e9..7bd2760 100644
> --- a/include/linux/uprobes.h
> +++ b/include/linux/uprobes.h
> @@ -109,12 +109,19 @@ enum rp_check {
>  	RP_CHECK_RET,
>  };
>  
> +struct address_space;
>  struct xol_area;
>  
>  struct uprobes_state {
>  	struct xol_area		*xol_area;
>  };
>  
> +struct uprobe_map_info {
> +	struct uprobe_map_info *next;
> +	struct mm_struct *mm;
> +	unsigned long vaddr;
> +};
> +
>  extern int set_swbp(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
>  extern int set_orig_insn(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
>  extern bool is_swbp_insn(uprobe_opcode_t *insn);
> @@ -149,6 +156,8 @@ struct uprobes_state {
>  extern bool arch_uprobe_ignore(struct arch_uprobe *aup, struct pt_regs *regs);
>  extern void arch_uprobe_copy_ixol(struct page *page, unsigned long vaddr,
>  					 void *src, unsigned long len);
> +extern struct uprobe_map_info *uprobe_free_map_info(struct uprobe_map_info *info);
> +extern struct uprobe_map_info *uprobe_build_map_info(struct address_space *mapping, loff_t offset, bool is_register);
>  #else /* !CONFIG_UPROBES */
>  struct uprobes_state {
>  };
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index 081b88c1..e7830b8 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -695,23 +695,15 @@ static void delete_uprobe(struct uprobe *uprobe)
>  	put_uprobe(uprobe);
>  }
>  
> -struct uprobe_map_info {
> -	struct uprobe_map_info *next;
> -	struct mm_struct *mm;
> -	unsigned long vaddr;
> -};
> -
> -static inline struct uprobe_map_info *
> -uprobe_free_map_info(struct uprobe_map_info *info)
> +struct uprobe_map_info *uprobe_free_map_info(struct uprobe_map_info *info)
>  {
>  	struct uprobe_map_info *next = info->next;
>  	kfree(info);
>  	return next;
>  }
>  
> -static struct uprobe_map_info *
> -uprobe_build_map_info(struct address_space *mapping, loff_t offset,
> -		      bool is_register)
> +struct uprobe_map_info *uprobe_build_map_info(struct address_space *mapping,
> +					      loff_t offset, bool is_register)
>  {
>  	unsigned long pgoff = offset >> PAGE_SHIFT;
>  	struct vm_area_struct *vma;
