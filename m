Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id ED4A76B003D
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 06:14:05 -0400 (EDT)
Date: Thu, 14 Mar 2013 11:14:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Inactive memory keep growing and how to release it?
Message-ID: <20130314101403.GB11636@dhcp22.suse.cz>
References: <CAAO_Xo7sEH5W_9xoOjax8ynyjLCx7GBpse+EU0mF=9mEBFhrgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAO_Xo7sEH5W_9xoOjax8ynyjLCx7GBpse+EU0mF=9mEBFhrgw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lenky Gao <lenky.gao@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon 04-03-13 17:52:22, Lenky Gao wrote:
> Hi,
> 
> When i just run a test on Centos 6.2 as follows:
> 
> #!/bin/bash
> 
> while true
> do
> 
> 	file="/tmp/filetest"
> 
> 	echo $file
> 
> 	dd if=/dev/zero of=${file} bs=512 count=204800 &> /dev/null
> 
> 	sleep 5
> done
> 
> the inactive memory keep growing:
> 
> #cat /proc/meminfo | grep Inactive\(fi
> Inactive(file):   420144 kB
> ...
> #cat /proc/meminfo | grep Inactive\(fi
> Inactive(file):   911912 kB
> ...
> #cat /proc/meminfo | grep Inactive\(fi
> Inactive(file):  1547484 kB
> ...
> 
> and i cannot reclaim it:

How did you try to reclaim the memory? How much memory is still free?
Are you above watermaks (/proc/zoneinfo will tell you more)

> # cat /proc/meminfo | grep Inactive\(fi
> Inactive(file):  1557684 kB
> # echo 3 > /proc/sys/vm/drop_caches
> # cat /proc/meminfo | grep Inactive\(fi
> Inactive(file):  1520832 kB
> 
> I have tested on other version kernel, such as 2.6.30 and .6.11, the
> problom also exists.
> 
> When in the final situation, i cannot kmalloc a larger contiguous
> memory, especially in interrupt context.

This could be related to the memory fragmentation and your kernel seem
to be too large to have memory compaction which helps a lot in that
area.

> Can you give some tips to avoid this?

One way would be to increase /proc/sys/vm/min_free_kbytes which will
enlarge watermaks so the reclaim starts sooner.
 
> PS:
> # uname -a
> Linux localhost.localdomain 2.6.32-220.el6.x86_64 #1 SMP Tue Dec 6
> 19:48:22 GMT 2011 x86_64 x86_64 x86_64 GNU/Linux

This is really an old kernel and also a distribution one which might
contain a lot of patches on top of the core kernel. I would suggest to
contact Redhat or try to reproduce the issue with the vanilla and
up-to-date kernel and report here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
