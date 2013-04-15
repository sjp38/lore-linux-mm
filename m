Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 729E96B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 20:08:08 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id q11so2192379pdj.25
        for <linux-mm@kvack.org>; Sun, 14 Apr 2013 17:08:07 -0700 (PDT)
Date: Sun, 14 Apr 2013 17:08:04 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: ramster: add how-to for ramster
Message-ID: <20130415000804.GA15244@kroah.com>
References: <1365983816-30204-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365983816-30204-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

On Mon, Apr 15, 2013 at 07:56:56AM +0800, Wanpeng Li wrote:
> +This is a how-to document for RAMster.  It applies to the March 9, 2013
> +version of RAMster, re-merged with the new zcache codebase, built and tested
> +on the 3.9 tree and submitted for the staging tree for 3.9.

This is not needed at all, given that it should just reflect the state
of the code in the kernel that this file is present in.  Please remove
it.

> +Note that this document was created from notes taken earlier.  I would
> +appreciate any feedback from anyone who follows the process as described
> +to confirm that it works and to clarify any possible misunderstandings,
> +or to report problems.

Is this needed?

> +A. PRELIMINARY
> +
> +1) Install two or more Linux systems that are known to work when upgraded
> +   to a recent upstream Linux kernel version (e.g. v3.9).  I used Oracle
> +   Linux 6 ("OL6") on two Dell Optiplex 790s.  Note that it should be possible
> +   to use ocfs2 as a filesystem on your systems but this hasn't been
> +   tested thoroughly, so if you do use ocfs2 and run into problems, please
> +   report them.  Up to eight nodes should work, but not much testing has
> +   been done with more than three nodes.
> +
> +On each system:
> +
> +2) Configure, build and install then boot Linux (e.g. 3.9), just to ensure it
> +   can be done with an unmodified upstream kernel.  Confirm you booted
> +   the upstream kernel with "uname -a".
> +
> +3) Install ramster-tools.  The src.rpm and an OL6 rpm are available
> +   in this directory.  I'm not very good at userspace stuff and
> +   would welcome any help in turning ramster-tools into more
> +   distributable rpms/debs for a wider range of distros.

This isn't true, the rpms are not here.

> +B. BUILDING RAMSTER INTO THE KERNEL
> +
> +Do the following on each system:
> +
> +1) Ensure you have the new codebase for drivers/staging/zcache in your source.
> +
> +2) Change your .config to have:
> +
> +	CONFIG_CLEANCACHE=y
> +	CONFIG_FRONTSWAP=y
> +	CONFIG_STAGING=y
> +	CONFIG_ZCACHE=y
> +	CONFIG_RAMSTER=y
> +
> +   You may have to reconfigure your kernel multiple times to ensure
> +   all of these are set properly.  I use:
> +
> +	# yes "" | make oldconfig
> +
> +   and then manually check the .config file to ensure my selections
> +   have "taken".

This last bit isn't needed at all.  Just stick to the "these are the
settings you need enabled."

> +   Do not bother to build the kernel until you are certain all of
> +   the above config selections will stick for the build.
> +
> +3) Build this kernel and "make install" so that you have a new kernel
> +   in /etc/grub.conf

Don't assume 'make install' works for all distros, nor that
/etc/grub.conf is a grub config file (hint, it usually isn't, and what
about all the people not even using grub for their bootloader?)

> +4) Add "ramster" to the kernel boot line in /etc/grub.conf.

Again, drop grub.conf reference

> +5) Reboot and check dmesg to ensure there are some messages from ramster
> +   and that "ramster_enabled=1" appears.
> +
> +	# dmesg | grep ramster

Are you sure ramster still spits out messages?  If so, provide an
example of what it should look like.

> +   You should also see a lot of files in:
> +
> +	# ls /sys/kernel/debug/zcache
> +	# ls /sys/kernel/debug/ramster

You forgot to mention that debugfs needs to be mounted.

> +   and a few files in:
> +
> +	# ls /sys/kernel/mm/ramster
> +
> +   RAMster now will act as a single-system zcache but doesn't yet
> +   know anything about the cluster so can't do anything remotely.
> +
> +C. BUILDING THE RAMSTER CLUSTER
> +
> +This is the error prone part unless you are a clustering expert.  We need
> +to describe the cluster in /etc/ramster.conf file and the init scripts
> +that parse it are extremely picky about the syntax.
> +
> +1) Create the /etc/ramster.conf file and ensure it is identical
> +   on both systems.  There is a good amount of similar documentation
> +   for ocfs2 /etc/cluster.conf that can be googled for this, but I use:
> +
> +	cluster:
> +		name = ramster
> +		node_count = 2
> +	node:
> +		name = system1
> +		cluster = ramster
> +		number = 0
> +		ip_address = my.ip.ad.r1
> +		ip_port = 7777
> +	node:
> +		name = system2
> +		cluster = ramster
> +		number = 0
> +		ip_address = my.ip.ad.r2
> +		ip_port = 7777
> +
> +   You must ensure that the "name" field in the file exactly matches
> +   the output of "hostname" on each system.  The following assumes
> +   you use "ramster" as the name of your cluster.
> +
> +2) Enable the ramster service and configure it:
> +
> +	# chkconfig --add ramster
> +	# service ramster configure

That's a huge assumption as to how your system config/startup scripts
work, right?  Not all the world is using old-style system V init
anymore, what about systemd?  openrc?

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
