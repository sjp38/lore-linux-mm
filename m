Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id DCD826B0062
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 15:07:00 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so2517889oag.14
        for <linux-mm@kvack.org>; Fri, 05 Oct 2012 12:07:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506E43E0.70507@jp.fujitsu.com>
References: <506E43E0.70507@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 15:06:35 -0400
Message-ID: <CAHGf_=qCZvL7xcOkea80Y995sZWkOMQLLVnuvLUto4W+qpUbWA@mail.gmail.com>
Subject: Re: [PATCH 0/10] memory-hotplug: hot-remove physical memory
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, wency@cn.fujitsu.com

> Known problems:
> 1. memory can't be offlined when CONFIG_MEMCG is selected.
>    For example: there is a memory device on node 1. The address range
>    is [1G, 1.5G). You will find 4 new directories memory8, memory9, memory10,
>    and memory11 under the directory /sys/devices/system/memory/.
>    If CONFIG_MEMCG is selected, we will allocate memory to store page cgroup
>    when we online pages. When we online memory8, the memory stored page cgroup
>    is not provided by this memory device. But when we online memory9, the memory
>    stored page cgroup may be provided by memory8. So we can't offline memory8
>    now. We should offline the memory in the reversed order.
>    When the memory device is hotremoved, we will auto offline memory provided
>    by this memory device. But we don't know which memory is onlined first, so
>    offlining memory may fail. In such case, you should offline the memory by
>    hand before hotremoving the memory device.

Just iterate twice. 1st iterate: offline every non primary memory
block. 2nd iterate:
offline primary (i.e. first added) memory block. It may work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
