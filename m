Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CF4D6B7C7F
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 16:51:22 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n45so1815114qta.5
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 13:51:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d128si982367qkb.270.2018.12.06.13.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 13:51:21 -0800 (PST)
Date: Thu, 6 Dec 2018 16:51:16 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 3/3] mm/mmu_notifier: contextual information for event
 triggering invalidation
Message-ID: <20181206215115.GF3544@redhat.com>
References: <20181203201817.10759-4-jglisse@redhat.com>
 <201812070514.QdWdUWIj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201812070514.QdWdUWIj%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org, dri-devel@lists.freedesktop.org

Should be all fixed in v2 i built with and without mmu notifier and
did not had any issue in v2.

On Fri, Dec 07, 2018 at 05:19:21AM +0800, kbuild test robot wrote:
> Hi J�r�me,
> 
> I love your patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.20-rc5]
> [cannot apply to next-20181206]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/jglisse-redhat-com/mmu-notifier-contextual-informations/20181207-031930
> config: x86_64-randconfig-x017-201848 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    fs///proc/task_mmu.c: In function 'clear_refs_write':
>    fs///proc/task_mmu.c:1099:29: error: storage size of 'range' isn't known
>       struct mmu_notifier_range range;
>                                 ^~~~~
> >> fs///proc/task_mmu.c:1147:18: error: 'MMU_NOTIFY_SOFT_DIRTY' undeclared (first use in this function); did you mean 'CLEAR_REFS_SOFT_DIRTY'?
>        range.event = MMU_NOTIFY_SOFT_DIRTY;
>                      ^~~~~~~~~~~~~~~~~~~~~
>                      CLEAR_REFS_SOFT_DIRTY
>    fs///proc/task_mmu.c:1147:18: note: each undeclared identifier is reported only once for each function it appears in
>    fs///proc/task_mmu.c:1099:29: warning: unused variable 'range' [-Wunused-variable]
>       struct mmu_notifier_range range;
>                                 ^~~~~
> 
> vim +1147 fs///proc/task_mmu.c
> 
>   1069	
>   1070	static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>   1071					size_t count, loff_t *ppos)
>   1072	{
>   1073		struct task_struct *task;
>   1074		char buffer[PROC_NUMBUF];
>   1075		struct mm_struct *mm;
>   1076		struct vm_area_struct *vma;
>   1077		enum clear_refs_types type;
>   1078		struct mmu_gather tlb;
>   1079		int itype;
>   1080		int rv;
>   1081	
>   1082		memset(buffer, 0, sizeof(buffer));
>   1083		if (count > sizeof(buffer) - 1)
>   1084			count = sizeof(buffer) - 1;
>   1085		if (copy_from_user(buffer, buf, count))
>   1086			return -EFAULT;
>   1087		rv = kstrtoint(strstrip(buffer), 10, &itype);
>   1088		if (rv < 0)
>   1089			return rv;
>   1090		type = (enum clear_refs_types)itype;
>   1091		if (type < CLEAR_REFS_ALL || type >= CLEAR_REFS_LAST)
>   1092			return -EINVAL;
>   1093	
>   1094		task = get_proc_task(file_inode(file));
>   1095		if (!task)
>   1096			return -ESRCH;
>   1097		mm = get_task_mm(task);
>   1098		if (mm) {
> > 1099			struct mmu_notifier_range range;
>   1100			struct clear_refs_private cp = {
>   1101				.type = type,
>   1102			};
>   1103			struct mm_walk clear_refs_walk = {
>   1104				.pmd_entry = clear_refs_pte_range,
>   1105				.test_walk = clear_refs_test_walk,
>   1106				.mm = mm,
>   1107				.private = &cp,
>   1108			};
>   1109	
>   1110			if (type == CLEAR_REFS_MM_HIWATER_RSS) {
>   1111				if (down_write_killable(&mm->mmap_sem)) {
>   1112					count = -EINTR;
>   1113					goto out_mm;
>   1114				}
>   1115	
>   1116				/*
>   1117				 * Writing 5 to /proc/pid/clear_refs resets the peak
>   1118				 * resident set size to this mm's current rss value.
>   1119				 */
>   1120				reset_mm_hiwater_rss(mm);
>   1121				up_write(&mm->mmap_sem);
>   1122				goto out_mm;
>   1123			}
>   1124	
>   1125			down_read(&mm->mmap_sem);
>   1126			tlb_gather_mmu(&tlb, mm, 0, -1);
>   1127			if (type == CLEAR_REFS_SOFT_DIRTY) {
>   1128				for (vma = mm->mmap; vma; vma = vma->vm_next) {
>   1129					if (!(vma->vm_flags & VM_SOFTDIRTY))
>   1130						continue;
>   1131					up_read(&mm->mmap_sem);
>   1132					if (down_write_killable(&mm->mmap_sem)) {
>   1133						count = -EINTR;
>   1134						goto out_mm;
>   1135					}
>   1136					for (vma = mm->mmap; vma; vma = vma->vm_next) {
>   1137						vma->vm_flags &= ~VM_SOFTDIRTY;
>   1138						vma_set_page_prot(vma);
>   1139					}
>   1140					downgrade_write(&mm->mmap_sem);
>   1141					break;
>   1142				}
>   1143	
>   1144				range.start = 0;
>   1145				range.end = -1UL;
>   1146				range.mm = mm;
> > 1147				range.event = MMU_NOTIFY_SOFT_DIRTY;
>   1148				mmu_notifier_invalidate_range_start(&range);
>   1149			}
>   1150			walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
>   1151			if (type == CLEAR_REFS_SOFT_DIRTY)
>   1152				mmu_notifier_invalidate_range_end(&range);
>   1153			tlb_finish_mmu(&tlb, 0, -1);
>   1154			up_read(&mm->mmap_sem);
>   1155	out_mm:
>   1156			mmput(mm);
>   1157		}
>   1158		put_task_struct(task);
>   1159	
>   1160		return count;
>   1161	}
>   1162	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
