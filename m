Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 876E56B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:16:25 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c9so6905559qth.16
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:16:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g88si6390860qkh.342.2018.03.16.09.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 09:16:24 -0700 (PDT)
Date: Fri, 16 Mar 2018 17:16:17 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
Message-ID: <20180316161616.GA28249@redhat.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
 <20180315124816.6aa3d4e2@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180315124816.6aa3d4e2@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>, mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On 03/15, Steven Rostedt wrote:
>
> On Tue, 13 Mar 2018 18:26:00 +0530
> Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
>
> > +static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
> > +{
> > +	struct uprobe_map_info *info;
> > +	struct vm_area_struct *vma;
> > +	unsigned long vaddr;
> > +
> > +	uprobe_start_dup_mmap();
>
> Please add a comment here that this function ups the mm ref count for
> each info returned. Otherwise it's hard to know what that mmput() below
> matches.

You meant uprobe_build_map_info(), not uprobe_start_dup_mmap().

Yes, and if it gets more callers perhaps we should move this mmput() into
uprobe_free_map_info()...

Oleg.


--- x/kernel/events/uprobes.c
+++ x/kernel/events/uprobes.c
@@ -714,6 +714,7 @@ struct map_info {
 static inline struct map_info *free_map_info(struct map_info *info)
 {
 	struct map_info *next = info->next;
+	mmput(info->mm);
 	kfree(info);
 	return next;
 }
@@ -783,8 +784,11 @@ build_map_info(struct address_space *map
 
 	goto again;
  out:
-	while (prev)
-		prev = free_map_info(prev);
+	while (prev) {
+		info = prev;
+		prev = prev->next;
+		kfree(info);
+	}
 	return curr;
 }
 
@@ -834,7 +838,6 @@ register_for_each_vma(struct uprobe *upr
  unlock:
 		up_write(&mm->mmap_sem);
  free:
-		mmput(mm);
 		info = free_map_info(info);
 	}
  out:
