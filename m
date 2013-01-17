Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 855BD6B0007
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 13:09:44 -0500 (EST)
Message-ID: <1358445589.14145.352.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 00/12] System device hot-plug framework
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 17 Jan 2013 10:59:49 -0700
In-Reply-To: <2389744.NKfBmfO9at@vostro.rjw.lan>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
	 <2389744.NKfBmfO9at@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Thu, 2013-01-17 at 01:50 +0100, Rafael J. Wysocki wrote:
> On Thursday, January 10, 2013 04:40:18 PM Toshi Kani wrote:
> > This patchset is a prototype of proposed system device hot-plug framework
> > for design review.  Unlike other hot-plug environments, such as USB and
> > PCI, there is no common framework for system device hot-plug [1].
> > Therefore, this patchset is designed to provide a common framework for
> > hot-plugging and online/offline operations of system devices, such as CPU,
> > Memory and Node.  While this patchset only supports ACPI-based hot-plug
> > operations, the framework itself is designed to be platform-neural and
> > can support other FW architectures as necessary.
 :
> At this point I'd like to clearly understand how the code is supposed to work.

Thanks for reviewing!

> From what I can say at the moment it all boils down to having two (ordered)
> lists of notifiers (shp_add_list, shp_del_list) that can be added to or removed
> from with shp_register_handler() and shp_unregister_handler(), respectively

Yes.

> (BTW, the abbreviation "hdr" makes me think about a "header" rather than a
> "handler", but maybe that's just me :-)), 

Well, it makes me think that way as well. :)  How about "hdlr"?

> and a workqueue for requests (why do
> we need a separate workqueue for that?).

This workqueue needs to be platform-neutral and max_active set to 1, and
preferably is dedicated for hotplug operations.  kacpi_hotplug_wq is
close, but is ACPI-specific.  So, I decided to create a new workqueue
for this framework.

> Whoever needs to carry out a hotplug operation is supposed to prepare a request
> and then put it into the workqueue with shp_submit_request().  The framework
> will then execute all of the notifier callbacks from the appropriate notifier
> list (depending on whether the operation is a hot-add or a hot-remove).  If any
> of those callbacks returns an error code and it is not too late (the order of
> the failing notifier is not too high), the already executed notifier callbacks
> will be run again with the "rollback" argument set to 1 (why not to use bool?)

Agreed.  I will change the rollback to bool.

> to indicate that they are supposed to bring things back to the initial state.
> Error codes returned in that stage only cause messages to be printed.
>
> Is the description above correct?

Yes.  It's very good summary!

> If so, it looks like subsystems are supposed to register notifiers (handlers)
> for hotplug/hot-remove operations of the devices they handle.  They are
> supposed to use predefined order values to indicate what kinds of devices
> those are.  Then, hopefully, if they do everything correctly, and the
> initiator of a hotplug/hot-remove operation prepares the request correctly,
> the callbacks will be executed in the right order, they will find their
> devices in the list attached to the request object and they will do what's
> necessary with them.
> 
> Am I still on the right track?

Yes.

> If that's the case, I have a few questions.

Well, there are more than a few :), but they all are excellent
questions!

> (1) Why is this limited to system devices?

It could be extended to other devices, but is specifically designed for
system devices as follows.  So, I think it is best to keep it in that
way.

a) Work with multiple subsystems without bus dependency.  Other hot-plug
frameworks are designed and implemented for a particular bus and a
subsystem.  Therefore, they work best for their targeted environment as
well.

b) Sequence with pre-defined order.  This allows hot-add operation and
the boot sequence to be consistent.  Other non-system devices are
initialized within a subsystem, and do not depend on the boot-up
sequence.

> (2) What's the guarantee that the ordering of hot-removal (for example) of CPU
>     cores with respect to memory and host bridges will always be the same?
>     What if the CPU cores themselves need to be hot-removed in a specific
>     order?

When devices are added in the order of A->B->C, their dependency model
is:
 - B may depend on A (but A may not depend on B)
 - C may depend on A and B (but A and B may not depend on C)

Therefore, they can be deleted in the order of C->B->A.

The boot sequence defines the order for add.  So, it is important to
make sure that we hot-add devices in the same order with the boot
sequence.  Of course, if there is an issue in the order, we need to fix
it.  But the point is that the add order should be consistent between
the boot sequence and hot-add.

In your example, the boot sequence adds them in the order of
memory->CPU->host bridge.  I think this makes sense because cpu may need
its local memory, and host bridge may need its local memory and local
cpu for interrupt.  So, hot-add needs to do the same for node hot-add,
and hot-delete should be able to delete them in the reversed order per
their dependency model.

> (3) What's the guarantee that the ordering of shp_add_list and shp_del_list
>     will be in agreement with the ordering of the device hierarchy?

Only the ACPI bus handlers (i.e. ACPI core) performs hierarchy based
initialization / deletion.  This is the case with the boot-up sequence
as well.

For hot-add, the ACPI core enumerates all devices based on the device
hierarchy and builds their device tree with "enabled" devices.  The
hierarchy defines the scope of devices to be added.  Then, all enabled
system devices are directly accessible without any restriction, so their
online initialization (cpu and mm handlers) does not have to be based on
their hierarchy.  It is done by the predefined order.

Similarly, for hot-delete, the ACPI core trims all devices based on the
device hierarchy after all devices are off-lined with predefined order.

> (4) Why do you think that the ordering of hot-plug operations needs to be
>     independent of the device herarchy ordering?

The ordering of the boot sequence and hot-add need to be consistent, and
the boot sequence may not be ordered by the hierarchy.  Furthermore, the
hierarchy does not necessarily dictate the proper order of device
initialization.  For instance, memory devices and processor devices may
be described as siblings under a same parent (ex. node, socket), but
there is no guarantee that memory devices are listed before processor
devices in order to initialize memory before cpu (or in order to delete
cpu before memory).

> (5) Why do you think it's a good idea to require every callback routine to
>     browse the entire list of devices attached to the request object?  Wouldn't
>     it be more convenient if they were called only for the types of devices
>     they have declared to handle?  [That would reduce some code duplication,
>     for example.]

This version is aimed for simplicity and yes, there is a room for
optimization.  One way to do so is to have a separate device list for
each type in shp_request.  This way, for instance, the cpu handlers only
check for the cpu list, and do nothing for memory hot-plug since the cpu
list is empty.  I will make this change if it makes sense.

struct shp_request {
        /* common info */
		:

        /* device resource info */
        struct list_head        cpu_dev_list;   /* cpu device list */
        struct list_head        mem_dev_list;   /* memory device list */
		:
};

> (6) Why is it convenient to use order values (priorities) of notifiers to
>     indicate both the ordering with respect to the other notifiers and the
>     "level" (e.g. whether or not rollback is possible) at the same time?  Those
>     things appear to be conceptually distinct.

It allows a single set of add (shp_add_list_head) and delete (
shp_del_list_head) lists to list all levels of the handlers.  Otherwise,
it will need to have a separate list for validate, execute and commit.
This makes shp_start_req() simpler as it can call all handlers from a
single list.

Note that this list handling is abstracted within sys_hotplug.c, and is
not visible from the handlers.  struct shp_handler, order base values
(ex. SHP_EXECUTE_ORDER_BASE), and the lists are all locally defined in
sys_hotplug.c.  Therefore, the list handling can be updated without
impacting the handlers.

> (7) Why callbacks used for "add" operations still need to check if the
>     operation type is "add" (cpu_add_execute() does that for example)?

Such check should not be needed.  Are you referring the check with
shp_is_online_op() in cpu_add_execute()?  shp_is_online_op() returns
true for online/offline operations, and false for hot-add/delete
operations.  This check is a workaround for an inherited issue from the
original code.  KOBJ_ONLINE needs to be sent to a cpu dev
under /sys/devices/system/cpu.  However, in case of hot-add/delete
operations, we only have a device for an ACPI cpu dev (LNXCPU)
under /sys/bus/acpi/devices.  Hence, we cannot send KOBJ_ONLINE to the
cpu dev.  Similarly, acpi_processor_handle_eject() in the original code
cannot send KOBJ_OFFLINE to its cpu dev when it calls cpu_down().

>From what I see in udev's behavior, though, this issue does not seem to
cause any issue.  For hot-add/delete, it still sends
KOBJ_ADD/KOBJ_REMOVE to a cpu dev, and udev reacts from this event.

> (8) What problems *exactly* this is supposed to address?  Can you give a few
>     examples, please?

Here are a few examples of the problems that this framework will
address.

1. Race conditions.  The current locking scheme is fine grained.  While
it protects some critical sections, it does not protect from multiple
operations running simultaneously and competing each other.  For
instance, the following case can happen.
 1) A node hot-delete operation runs, and offlined all CPUs in the node.
 2) A separate cpu online operation comes in, and onlined a CPU in the
node.
 3) The node hot-plug operation ejects the node, and the system gets
crashed since one of the CPU is online.

The framework provides end-to-end protection to an operation, and
prevents such case to happen.  We may also remove the current fine
grained locking for simpler and better code maintainability.

2. ACPI .add/.remove overload.  Currently, ACPI drivers use .add/.remove
to online/offline a device during hot-plug operations.  The .add/.remove
ops are defined as attach/detach of the driver to a device, not
online/offline of the device.  Therefore, .add/.remove may not fail.
This has caused a major issue in memory hot-delete that it still ejects
a target memory even if its memory offlining failed.

The framework allows .add/.remove opts to do as they defined, and handle
failure cases properly.

3. Inconsistency with the boot path.  In the boot-up sequence, system
devices are initialized in pre-defined order, and ACPI bus walk is done
as one of the last steps after most system devices are actually
initialized.  The current hotplug scheme requires all system device
initialization to proceed in ACPI bus walk, which requires an
inconsistent role model for hotplug operations compared with the boot-up
sequence.  Furthermore, it may not properly order system device
initialization among multiple device types (i.e. Memory -> CPU) for node
hotplug, unlike the boot-up sequence.

The framework keeps the role model consistent with the boot sequence as
well as the ordering of the initialization.

> I guess I'll have more questions going forward.

Great!

Thanks a lot!
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
