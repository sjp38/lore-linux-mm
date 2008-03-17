Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m2H22BRF005204
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 02:02:11 GMT
Received: from py-out-1112.google.com (pybu52.prod.google.com [10.34.97.52])
	by zps76.corp.google.com with ESMTP id m2H22Ae6015744
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 19:02:10 -0700
Received: by py-out-1112.google.com with SMTP id u52so5126099pyb.1
        for <linux-mm@kvack.org>; Sun, 16 Mar 2008 19:02:09 -0700 (PDT)
Message-ID: <6599ad830803161902r8f9a274t246a25b3d337fee8@mail.gmail.com>
Date: Mon, 17 Mar 2008 10:02:09 +0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][2/3] Account and control virtual address space allocations
In-Reply-To: <20080316173005.8812.88290.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
	 <20080316173005.8812.88290.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 1:30 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>   /*
>  + * Check if the current cgroup exceeds its address space limit.
>  + * Returns 0 on success and 1 on failure.
>  + */
>  +int mem_cgroup_update_as(struct mm_struct *mm, long nr_pages)
>  +{
>  +       int ret = 0;
>  +       struct mem_cgroup *mem;
>  +       if (mem_cgroup_subsys.disabled)
>  +               return ret;
>  +
>  +       rcu_read_lock();
>  +       mem = rcu_dereference(mm->mem_cgroup);
>  +       css_get(&mem->css);
>  +       rcu_read_unlock();
>  +

How about if this function avoided charging the root cgroup? You'd
save 4 atomic operations on a global data structure on every
mmap/munmap when the virtual address limit cgroup wasn't in use, which
could be significant on a large system. And I don't see situations
where you really need to limit the address space of the root cgroup.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
