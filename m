Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 533D06B00CD
	for <linux-mm@kvack.org>; Tue,  7 May 2013 18:45:44 -0400 (EDT)
Message-ID: <1367966740.30363.26.camel@misato.fc.hp.com>
Subject: Re: [PATCH 2/2 v2, RFC] Driver core: Introduce offline/online
 callbacks for memory blocks
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 07 May 2013 16:45:40 -0600
In-Reply-To: <2150698.7rPOtiF0kp@vostro.rjw.lan>
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan>
	 <7132174.AKkXX1jln2@vostro.rjw.lan>
	 <1367960629.30363.21.camel@misato.fc.hp.com>
	 <2150698.7rPOtiF0kp@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org, wency@cn.fujitsu.com

On Wed, 2013-05-08 at 00:10 +0200, Rafael J. Wysocki wrote:
> On Tuesday, May 07, 2013 03:03:49 PM Toshi Kani wrote:
> > On Tue, 2013-05-07 at 14:11 +0200, Rafael J. Wysocki wrote:
> > > On Tuesday, May 07, 2013 12:59:45 PM Vasilis Liaskovitis wrote:
> > 
> >  :
> > 
> > > Updated patch is appended for completness.
> > 
> > Yes, this updated patch solved the locking issue.
> > 
> > > > > > A more general issue is that there are now two memory offlining efforts:
> > > > > > 
> > > > > > 1) from acpi_bus_offline_companions during device offline
> > > > > > 2) from mm: remove_memory during device detach (offline_memory_block_cb)
> > > > > > 
> > > > > > The 2nd is only called if the device offline operation was already succesful, so
> > > > > > it seems ineffective or redundant now, at least for x86_64/acpi_memhotplug machine
> > > > > > (unless the blocks were re-onlined in between).
> > > > > 
> > > > > Sure, and that should be OK for now.  Changing the detach behavior is not
> > > > > essential from the patch [2/2] perspective, we can do it later.
> > > > 
> > > > yes, ok.
> > > > 
> > > > > 
> > > > > > On the other hand, the 2nd effort has some more intelligence in offlining, as it
> > > > > > tries to offline twice in the precense of memcg, see commits df3e1b91 or
> > > > > > reworked 0baeab16. Maybe we need to consolidate the logic.
> > > > > 
> > > > > Hmm.  Perhaps it would make sense to implement that logic in
> > > > > memory_subsys_offline(), then?
> > > > 
> > > > the logic tries to offline the memory blocks of the device twice, because the
> > > > first memory block might be storing information for the subsequent memblocks.
> > > > 
> > > > memory_subsys_offline operates on one memory block at a time. Perhaps we can get
> > > > the same effect if we do an acpi_walk of acpi_bus_offline_companions twice in
> > > > acpi_scan_hot_remove but it's probably not a good idea, since that would
> > > > affect non-memory devices as well. 
> > > > 
> > > > I am not sure how important this intelligence is in practice (I am not using
> > > > mem cgroups in my guest kernel tests yet).  Maybe Wen (original author) has
> > > > more details on 2-pass offlining effectiveness.
> > > 
> > > OK
> > > 
> > > It may be added in a separate patch in any case.
> > 
> > I had the same comment as Vasilis.  And, I agree with you that we can
> > enhance it in separate patches.
> > 
> >  :
> > 
> > > +static int memory_subsys_offline(struct device *dev)
> > > +{
> > > +	struct memory_block *mem = container_of(dev, struct memory_block, dev);
> > > +	int ret;
> > > +
> > > +	mutex_lock(&mem->state_mutex);
> > > +	ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
> > 
> > This function needs to check mem->state just like
> > offline_memory_block().  That is:
> > 
> > 	int ret = 0;
> > 		:
> > 	if (mem->state != MEM_OFFLINE)
> > 		ret = __memory_block_change_state(...);
> > 
> > Otherwise, memory hot-delete to an off-lined memory fails in
> > __memory_block_change_state() since mem->state is already set to
> > MEM_OFFLINE.
> > 
> > With that change, for the series:
> > Reviewed-by: Toshi Kani <toshi.kani@hp.com>
> 
> OK, one more update, then (appended).
> 
> That said I thought that the check against dev->offline in device_offline()
> would be sufficient to guard agaist that.  Is there any "offline" code path
> I didn't take into account?

Oh, you are right about that.  The real problem is that dev->offline is
set to false (0) when a new memory is hot-added in off-line state.  So,
instead, dev->offline needs to be set properly.  

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
