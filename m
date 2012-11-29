Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 8A1946B0068
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 06:36:42 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so7240382bkc.14
        for <linux-mm@kvack.org>; Thu, 29 Nov 2012 03:36:40 -0800 (PST)
Date: Thu, 29 Nov 2012 12:36:35 +0100
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device
 operation
Message-ID: <20121129113635.GC639@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
 <50B5EFE9.3040206@huawei.com>
 <1354128096.26955.276.camel@misato.fc.hp.com>
 <75241306.UQIr1RW8Qh@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <75241306.UQIr1RW8Qh@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-acpi@vger.kernel.org, Toshi Kani <toshi.kani@hp.com>, Hanjun Guo <guohanjun@huawei.com>, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>

On Thu, Nov 29, 2012 at 11:15:31AM +0100, Rafael J. Wysocki wrote:
> On Wednesday, November 28, 2012 11:41:36 AM Toshi Kani wrote:
> > On Wed, 2012-11-28 at 19:05 +0800, Hanjun Guo wrote:
> > > We met the same problem when we doing computer node hotplug, It is a good idea
> > > to introduce prepare_remove before actual device removal.
> > > 
> > > I think we could do more in prepare_remove, such as rollback. In most cases, we can
> > > offline most of memory sections except kernel used pages now, should we rollback
> > > and online the memory sections when prepare_remove failed ?
> > 
> > I think hot-plug operation should have all-or-nothing semantics.  That
> > is, an operation should either complete successfully, or rollback to the
> > original state.
> 
> That's correct.
> 
> > > As you may know, the ACPI based hotplug framework we are working on already addressed
> > > this problem, and the way we slove this problem is a bit like yours.
> > > 
> > > We introduce hp_ops in struct acpi_device_ops:
> > > struct acpi_device_ops {
> > > 	acpi_op_add add;
> > > 	acpi_op_remove remove;
> > > 	acpi_op_start start;
> > > 	acpi_op_bind bind;
> > > 	acpi_op_unbind unbind;
> > > 	acpi_op_notify notify;
> > > #ifdef	CONFIG_ACPI_HOTPLUG
> > > 	struct acpihp_dev_ops *hp_ops;
> > > #endif	/* CONFIG_ACPI_HOTPLUG */
> > > };
> > > 
> > > in hp_ops, we divide the prepare_remove into six small steps, that is:
> > > 1) pre_release(): optional step to mark device going to be removed/busy
> > > 2) release(): reclaim device from running system
> > > 3) post_release(): rollback if cancelled by user or error happened
> > > 4) pre_unconfigure(): optional step to solve possible dependency issue
> > > 5) unconfigure(): remove devices from running system
> > > 6) post_unconfigure(): free resources used by devices
> > > 
> > > In this way, we can easily rollback if error happens.
> > > How do you think of this solution, any suggestion ? I think we can achieve
> > > a better way for sharing ideas. :)
> > 
> > Yes, sharing idea is good. :)  I do not know if we need all 6 steps (I
> > have not looked at all your changes yet..), but in my mind, a hot-plug
> > operation should be composed with the following 3 phases.
> > 
> > 1. Validate phase - Verify if the request is a supported operation.  All
> > known restrictions are verified at this phase.  For instance, if a
> > hot-remove request involves kernel memory, it is failed in this phase.
> > Since this phase makes no change, no rollback is necessary to fail.  
> 
> Actually, we can't do it this way, because the conditions may change between
> the check and the execution.  So the first phase needs to involve execution
> to some extent, although only as far as it remains reversible.
> 
> > 2. Execute phase - Perform hot-add / hot-remove operation that can be
> > rolled-back in case of error or cancel.
> 
> I would just merge 1 and 2.

I agree steps 1 and 2 can be merged, at least for the current ACPI framework.
E.g. for memory hotplug, the mm function we call for memory removal
(remove_memory) handles both these steps.

The new ACPI framework could perhaps expand the operations as Hanjun described,
if it makes sense.

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
