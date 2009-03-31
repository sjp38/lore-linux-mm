Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 136726B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:25:17 -0400 (EDT)
Date: Tue, 31 Mar 2009 16:25:33 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-ID: <20090331142533.GR9137@random.random>
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com> <1238457560-7613-2-git-send-email-ieidus@redhat.com> <1238457560-7613-3-git-send-email-ieidus@redhat.com> <1238457560-7613-4-git-send-email-ieidus@redhat.com> <1238457560-7613-5-git-send-email-ieidus@redhat.com> <49D17C04.9070307@codemonkey.ws> <49D20B63.8020709@redhat.com> <49D21B33.4070406@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49D21B33.4070406@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 31, 2009 at 08:31:31AM -0500, Anthony Liguori wrote:
> You could drop KSM_START_STOP_KTHREAD and KSM_GET_INFO_KTHREAD altogether, 
> and introduce a sysfs hierarchy:
>
> /sysfs/<some/path>/ksm/{enable,pages_to_scan,sleep_time}

Introducing a sysfs hierarchy sounds a bit of overkill.

> the ability to disable KSM.  That seems like a security concern to me since 
> registering a memory region ought to be an unprivileged action whereas 
> enabling/disabling KSM ought to be a privileged action.

sysfs files would then only be writeable by admin, so if we want to
allow only admin to start/stop/tune ksm it'd be enough to plug an
admin capability check in the ioctl to provide equivalent permissions.

I could imagine converting the enable/pages_to_scan/sleep_time to
module params and tweaking them through /sys/module/ksm/parameters,
but for "enable" to work that way, we'd need to intercept the write so
we can at least weakup the kksmd daemon, which doesn't seem possible
with /sys/module/ksm/parameters, so in the end if we stick to the
ioctl for registering regions, it seems simpler to use it for
start/stop/tune too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
