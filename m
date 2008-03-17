Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HGtF1o000505
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 12:55:15 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HGrDLB221084
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 12:53:13 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HGrD42030901
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 12:53:13 -0400
Subject: Re: [RFC][2/3] Account and control virtual address space
	allocations
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20080316173005.8812.88290.sendpatchset@localhost.localdomain>
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
	 <20080316173005.8812.88290.sendpatchset@localhost.localdomain>
Content-Type: text/plain
Date: Mon, 17 Mar 2008 09:53:10 -0700
Message-Id: <1205772790.18916.17.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2008-03-16 at 23:00 +0530, Balbir Singh wrote:
> @@ -787,6 +788,8 @@ static int ptrace_bts_realloc(struct tas
>         current->mm->total_vm  -= old_size;
>         current->mm->locked_vm -= old_size;
>  
> +       mem_cgroup_update_as(current->mm, -old_size);
> +
>         if (size == 0)
>                 goto out;

I think splattering these things all over is probably a bad idea.

If you're going to do this, I think you need a couple of phases.  

1. update the vm_(un)acct_memory() functions to take an mm
2. start using them (or some other abstracted functions in place)
3. update the new functions for cgroups

It's a bit non-obvious why you do the mem_cgroup_update_as() calls in
the places that you do from context.

Having some other vm-abstracted functions will also keep you from
splattering mem_cgroup_update_as() across the tree.  That's a pretty bad
name. :)  ...update_mapped() or ...update_vm() might be a wee bit
better. 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
