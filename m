Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8216B0005
	for <linux-mm@kvack.org>; Sat, 11 Jun 2016 16:39:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so169007207pfa.2
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 13:39:23 -0700 (PDT)
Received: from sender163-mail.zoho.com (sender163-mail.zoho.com. [74.201.84.163])
        by mx.google.com with ESMTPS id gm10si6739933pac.65.2016.06.11.13.39.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 11 Jun 2016 13:39:22 -0700 (PDT)
From: "James Johnston" <johnstonj.public@codenest.com>
Subject: Placing swap partition on a loop device hangs the system
Date: Sat, 11 Jun 2016 20:39:03 -0000
Message-ID: <0f0a01d1c421$4bab08c0$e3011a40$@codenest.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, linux-mm@kvack.org

 Hi,

It's well-known that btrfs doesn't directly support swap files.  =
However, a
common workaround I read is to make a loop device from a file on the =
btrfs file
system, and then put a swap partition on the loop device.  See for =
example:

    =
https://btrfs.wiki.kernel.org/index.php/FAQ#Does_btrfs_support_swap_files=
.3F
    "A workaround ... is to mount a swap file via a loop device."

The Arch Linux wiki page on btrfs makes similar recommendations, and in =
fact
provides a package to automate the process:

    =
https://github.com/Nefelim4ag/systemd-swap/blob/a36efac996b70e95156c43307=
038b4f4ff2bc0ac/systemd-swap.sh#L78

However, I have not been successful in getting this to work on Ubuntu =
Linux.  In
fact, I cannot get swap on a loop device to work on ext4 either, so I =
think it
is not strictly a btrfs problem.  Maybe a bug with the loop driver, or =
swap?
However I'm mailing btrfs in addition to linux-mm because some btrfs =
users use
this technique, and I'd be interested to know how they got it working =
and what
their configuration & kernel versions are.  (Also, loop device has no =
maintainer
or list.)

    # Userspace is Ubuntu 16.04, all up-to-date:
    # Tested on kernel built from mainline v4.7-rc2 (i.e. not distro =
kernel):
    uname -r    # Prints: 4.7.0-rc2-af8c34ce
    # Following commands are run on a VM with 1 GB RAM
    fallocate --length 3000MiB /swaploop
    losetup --show -f /swaploop
    mkswap /dev/loop0
    swapon /dev/loop0
    # Check for swap presence:
    free -m

    # Following will make 8 workers that allocate 256 MB RAM each (i.e. =
2 GB).
    # Since there is only 1 GB RAM, this is guaranteed to use swap.
    apt-get install stress
    stress --vm-keep -m 8

At this point, the system almost completely hangs, and it never comes =
back.
The hypervisor says one CPU in the dual-CPU VM is maxed out, and the =
other one
is idle.  Disk I/O is absent.

[  240.391459] INFO: task kswapd0:38 blocked for more than 120 seconds.
[  240.394980]       Not tainted 4.7.0-rc2-af8c34ce #1
[  240.397361] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" =
disables this message.
[  240.400412] INFO: task jbd2/sda2-8:479 blocked for more than 120 =
seconds.
[  240.402877]       Not tainted 4.7.0-rc2-af8c34ce #1
[  240.405127] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" =
disables this message.
[  240.408233] INFO: task systemd-udevd:594 blocked for more than 120 =
seconds.
[  240.412323]       Not tainted 4.7.0-rc2-af8c34ce #1
[  240.414109] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" =
disables this message.
[  240.417490] INFO: task gmain:1177 blocked for more than 120 seconds.
[  240.420323]       Not tainted 4.7.0-rc2-af8c34ce #1
[  240.421999] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" =
disables this message.
[  240.425073] INFO: task cron:1158 blocked for more than 120 seconds.
[  240.427170]       Not tainted 4.7.0-rc2-af8c34ce #1
[  240.428815] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" =
disables this message.
[  240.431385] INFO: task vmtoolsd:1160 blocked for more than 120 =
seconds.
[  240.435214]       Not tainted 4.7.0-rc2-af8c34ce #1
[  240.437132] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" =
disables this message.
[  240.440538] INFO: task loop0:1561 blocked for more than 120 seconds.
[  240.443889]       Not tainted 4.7.0-rc2-af8c34ce #1
[  240.446787] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" =
disables this message.
[  240.451323] INFO: task stress:1575 blocked for more than 120 seconds.
[  240.453545]       Not tainted 4.7.0-rc2-af8c34ce #1
[  240.455214] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" =
disables this message.
[  240.458051] INFO: task stress:1576 blocked for more than 120 seconds.
[  240.460344]       Not tainted 4.7.0-rc2-af8c34ce #1
[  240.466992] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" =
disables this message.
[  240.479494] INFO: task stress:1577 blocked for more than 120 seconds.
[  240.481504]       Not tainted 4.7.0-rc2-af8c34ce #1
[  240.483145] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" =
disables this message.

Since apparently this worked in the past (???), I'm guessing this is =
some kind
of regression.  If anyone has a working configuration that passes the =
above
stress test, I'd be willing to try bisecting (e.g. known-good =
distribution
version & kernel version).  Maybe there is some regression, or a =
configuration
difference between the distributions?  (When building 4.7-rc2, I reused =
config
from Ubuntu 4.4 kernel.)

Or if anyone already knows what the problem might be, I'm all ears. :)

Best regards,

James Johnston


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
