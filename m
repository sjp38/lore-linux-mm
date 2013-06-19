Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id ECBC66B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 06:00:47 -0400 (EDT)
Received: by mail-bk0-f54.google.com with SMTP id it16so2213827bkc.41
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 03:00:46 -0700 (PDT)
Date: Wed, 19 Jun 2013 12:00:42 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [Part3 PATCH v2 0/4] Support hot-remove local pagetable pages.
Message-ID: <20130619100042.GA4545@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130618170515.GC4553@dhcp-192-168-178-175.profitbricks.localdomain>
 <51C15DC2.3030501@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51C15DC2.3030501@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: yinghai@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Tang,
On Wed, Jun 19, 2013 at 03:29:06PM +0800, Tang Chen wrote:
> Hi Vasilis, Yinghai,
> 
> On 06/19/2013 01:05 AM, Vasilis Liaskovitis wrote:
> ......
> >
> >This could be a design problem of part3: if we allow local pagetable memory
> >to not be offlined but allow the offlining to return successfully, then
> >hot-remove is going to succeed. But the direct mapped pagetable pages are still
> >mapped in the kernel. The hot-removed memblocks will suddenly disappear (think
> >physical DIMMs getting disabled in real hardware, or in a VM case the
> >corresponding guest memory getting freed from the emulator e.g. qemu/kvm). The
> >system can crash as a result.
> >
> 
> Yes. Since the pagetable pages is only allocated to local node, a node may
> have more than one device, hot-remove only one memory device could be
> problematic.
> 
> But I think it will work if we hot-remove a whole node. I should have
> mentioned it. And sorry for the not fully test.

ok, the crash I saw was also for the partial node removal.

> I think allocating pagetable pages to local device will resolve this
> problem.

ok. Yes, you mentioned this approach before I think.

> And need to restructure this patch-set.
> 
> >I think these local pagetables do need to be unmapped from kernel, offlined and
> >removed somehow - otherwise hot-remove should fail. Could they be migrated
> >alternatively e.g. to node 0 memory?  But Iiuc direct mapped pages cannot be
> >migrated, correct?
> 
> I think we have unmapped the local pagetables. in functions
> free_pud/pmd/pte_table(), we cleared pud, pmd, and pte. We just didn't
> free the pagetable pages to buddy.

ok, thanks for explaining.

> 
> But when we are not hot-removing the whole node, it is still problematic.
> This is true, and it is my design problem.
> 
> >
> >What is the original reason for local node pagetable allocation with regards
> >to memory hotplug? I assume we want to have hotplugged nodes use only their local
> >memory, so that there are no inter-node memory dependencies for hot-add/remove.
> >Are there other reasons that I am missing?
> 
> I think the original reason to do local node pagetable is to improve
> performance.
> Using local pagetable, vmemmap and so on will be faster.
> 
> But actually I think there is no particular reason to implement
> memory hot-remove
> and local node pagetable at the same time. And before this
> patch-set, I also
> suggested once that implement memory hot-remove first, and then
> improve it to
> local pagetable. But Yinghai has done the local pagetable work in
> has patches (part1).
> And my work is based on his patches. So I just did it.
> 
> But obviously it is more complicated than I thought.
> 
> And now, it seems tj has some more thinking on part1.
> 
> So how about the following plan:
> 1. Implement arranging hotpluggable memory with SRAT first, without
> local pagetable.
>    (The main work in part2. And of course, need some patches in part1.)

agreed (and yes, several patches from part1 will be needed to do the early srat
parsing here)

> 2. Do the local device pagetable work, not local node.
> 3. Improve memory hotplug to support local device pagetable.

ok, I 'll think about these as well, and help out.

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
