Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 0AF446B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 11:33:13 -0400 (EDT)
Message-ID: <1371655968.22206.35.camel@misato.fc.hp.com>
Subject: Re: [Part3 PATCH v2 0/4] Support hot-remove local pagetable pages.
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 19 Jun 2013 09:32:48 -0600
In-Reply-To: <51C11E56.2090903@jp.fujitsu.com>
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
	  <20130618170515.GC4553@dhcp-192-168-178-175.profitbricks.localdomain>
	 <1371599989.22206.6.camel@misato.fc.hp.com>
	 <51C11E56.2090903@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, Tang Chen <tangchen@cn.fujitsu.com>, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2013-06-19 at 11:58 +0900, Yasuaki Ishimatsu wrote:
> 2013/06/19 8:59, Toshi Kani wrote:
> > On Tue, 2013-06-18 at 19:05 +0200, Vasilis Liaskovitis wrote:
> >> Hi,
> >>
> >> On Thu, Jun 13, 2013 at 09:03:52PM +0800, Tang Chen wrote:
> >>> The following patch-set from Yinghai allocates pagetables to local nodes.
> >>> v1: https://lkml.org/lkml/2013/3/7/642
> >>> v2: https://lkml.org/lkml/2013/3/10/47
> >>> v3: https://lkml.org/lkml/2013/4/4/639
> >>> v4: https://lkml.org/lkml/2013/4/11/829
> >>>
> >>> Since pagetable pages are used by the kernel, they cannot be offlined.
> >>> As a result, they cannot be hot-remove.
> >>>
> >>> This patch fix this problem with the following solution:
> >>>
> >>>       1.   Introduce a new bootmem type LOCAL_NODE_DATAL, and register local
> >>>            pagetable pages as LOCAL_NODE_DATAL by setting page->lru.next to
> >>>            LOCAL_NODE_DATAL, just like we register SECTION_INFO pages.
> >>>
> >>>       2.   Skip LOCAL_NODE_DATAL pages in offline/online procedures. When the
> >>>            whole memory block they reside in is offlined, the kernel can
> >>>            still access the pagetables.
> >>>            (This changes the semantics of offline/online a little bit.)
> >>
> >> This could be a design problem of part3: if we allow local pagetable memory
> >> to not be offlined but allow the offlining to return successfully, then
> >> hot-remove is going to succeed. But the direct mapped pagetable pages are still
> >> mapped in the kernel. The hot-removed memblocks will suddenly disappear (think
> >> physical DIMMs getting disabled in real hardware, or in a VM case the
> >> corresponding guest memory getting freed from the emulator e.g. qemu/kvm). The
> >> system can crash as a result.
> >>
> >> I think these local pagetables do need to be unmapped from kernel, offlined and
> >> removed somehow - otherwise hot-remove should fail. Could they be migrated
> >> alternatively e.g. to node 0 memory?  But Iiuc direct mapped pages cannot be
> >> migrated, correct?
> >>
> >> What is the original reason for local node pagetable allocation with regards
> >> to memory hotplug? I assume we want to have hotplugged nodes use only their local
> >> memory, so that there are no inter-node memory dependencies for hot-add/remove.
> >> Are there other reasons that I am missing?
> >
> > I second Vasilis.  The part1/2/3 series could be much simpler & less
> > riskier if we focus on the SRAT changes first, and make the local node
> > pagetable changes as a separate item.  Is there particular reason why
> > they have to be done at a same time?
> 
> If my understanding is correct:
> Main purpose of Yinghai's work is to put pagetable on local node ram.
> For this, he needs to know SRAT information before setting pagetable.
> So part1 does them same time.

Thanks Yasuaki.  I like Tang Chen's new plan, and I think it is going to
be easier to proceed in that way.
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
