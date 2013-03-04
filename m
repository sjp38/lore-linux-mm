Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 259BC6B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 05:41:59 -0500 (EST)
Date: Mon, 04 Mar 2013 11:41:50 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <CAAO_Xo7sEH5W_9xoOjax8ynyjLCx7GBpse+EU0mF=9mEBFhrgw@mail.gmail.com>
In-Reply-To: <CAAO_Xo7sEH5W_9xoOjax8ynyjLCx7GBpse+EU0mF=9mEBFhrgw@mail.gmail.com>
Message-ID: <51347A6E.8010608@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: Inactive memory keep growing and how to release it?
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lenky Gao <lenky.gao@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04.03.2013 10:52, Lenky Gao wrote:
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
>
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
> Can you give some tips to avoid this?
>

The drop_caches mechanism doesn't free dirty page cache pages. And your 
bash script is creating a lot of dirty pages. Run it like this and see 
if it helps your case:

sync; echo 3 > /proc/sys/vm/drop_caches

Regards,
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
