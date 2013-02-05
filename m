Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id EADCC6B00B9
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 19:56:08 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug framework
Date: Tue, 05 Feb 2013 02:02:23 +0100
Message-ID: <1477324.WRerxpPAK8@vostro.rjw.lan>
In-Reply-To: <20130205000447.GA21782@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com> <7003418.onqVlaaHJS@vostro.rjw.lan> <20130205000447.GA21782@kroah.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Monday, February 04, 2013 04:04:47 PM Greg KH wrote:
> On Tue, Feb 05, 2013 at 12:52:30AM +0100, Rafael J. Wysocki wrote:
> > You'd probably never try to hot-remove a disk before unmounting filesystems
> > mounted from it or failing it as a RAID component and nobody sane wants the
> > kernel to do things like that automatically when the user presses the eject
> > button.  In my opinion we should treat memory eject, or CPU package eject, or
> > PCI host bridge eject in exactly the same way: Don't eject if it is not
> > prepared for ejecting in the first place.
> 
> Bad example, we have disks hot-removed all the time without any
> filesystems being unmounted, and have supported this since the 2.2 days
> (although we didn't get it "right" until 2.6.)

Well, that wasn't my point.

My point was that we have tools for unmounting filesystems from disks that
the user wants to hot-remove and the user is supposed to use those tools
before hot-removing the disks.  At least I wouldn't recommend anyone to
do otherwise. :-)

Now, for memory hot-removal we don't have anything like that, as far as I
can say, so my point was why don't we add memory "offline" that can be
done and tested separately from hot-removal and use that before we go and
hot-remove stuff?  And analogously for PCI host bridges etc.?

[Now, there's a question if an "eject" button on the system case, if there is
one, should *always* cause the eject to happen even though things are not
"offline".  My opinion is that not necessarily, because users may not be aware
that they are doing something wrong.

Quite analogously, does the power button always cause the system to shut down?
No.  So why the heck should an eject button always cause an eject to happen?
I see no reason.

That said, the most straightforward approach may be simply to let user space
disable eject events for specific devices when it wants and only enable them
when it knows that the given devices are ready for removal.

But I'm digressing.]

> PCI Host bridge eject is the same as PCI eject today, the user asks us
> to do it, and we can not fail it from happening.  We also can have them
> removed without us being told about it in the first place, and can
> properly clean up from it all.

Well, are you sure we'll always clean up?  I kind of have my doubts. :-)

> > And if you think about it, that makes things *massively* simpler, because now
> > the kernel doesn't heed to worry about all of those "synchronous removal"
> > scenarions that very well may involve every single device in the system and
> > the whole problem is nicely split into several separate "implement
> > offline/online" problems that are subsystem-specific and a single
> > "eject if everything relevant is offline" problem which is kind of trivial.
> > Plus the one of exposing information to user space, which is separate too.
> > 
> > Now, each of them can be worked on separately, *tested* separately and
> > debugged separately if need be and it is much easier to isolate failures
> > and so on.
> 
> So you are agreeing with me in that we can not fail hot removing any
> device, nice :)

That depends on how you define hot-removing.  If you regard the "offline"
as a separate operation that can be carried out independently and hot-remove
as the last step causing the device to actually go away, then I agree that
it can't fail.  The "offline" itself, however, is a different matter (pretty
much like unmounting a file system).

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
