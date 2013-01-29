Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 5A6BE6B00A4
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 13:41:17 -0500 (EST)
Message-ID: <510817AA.4070800@zytor.com>
Date: Tue, 29 Jan 2013 10:40:42 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] acpi, memory-hotplug: Support getting hotplug info
 from SRAT.
References: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com> <1359106929-3034-4-git-send-email-tangchen@cn.fujitsu.com> <20130125171230.34c5a273.akpm@linux-foundation.org> <51033186.3000706@zytor.com> <5105DD4B.9020901@cn.fujitsu.com> <3908561D78D1C84285E8C5FCA982C28F1C98F9CB@ORSMSX108.amr.corp.intel.com> <51076FAC.9060605@cn.fujitsu.com> <3908561D78D1C84285E8C5FCA982C28F1C9909DD@ORSMSX108.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C9909DD@ORSMSX108.amr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/29/2013 10:38 AM, Luck, Tony wrote:
>>> Node 0 (or more specifically the node that contains memory<4GB) will be
>>> full of BIOS reserved holes in the memory map.
> 
>> One thing I'm not sure, is memory<4GB always on node 0 ?
>> On my box, it is on node 0.
> 
> I think in practice the <4GB memory will be on node 0 ... but it all depends
> on how Linux decides to number the nodes ... which in turn depends on the
> order of entries in various BIOS tables.  So it is theoretically possible that
> we'd end up with some system on which the low memory is on some other
> node. But it might require stranger than usual BIOS.
> 
> Summary: coding "node == 0" is almost 100% certain to be right - except
> on some pathological systems.  So code for node==0 and if we ever see
> a pathological machine - we can either point and laugh at the BIOS people
> that set that up - or possibly fix our code.
> 

We also probably need to weld down the memory that the kernel static
areas occupy and where we have allocated memory during boot time.  In
particular, memory that you want to be movable MUST NOT have boot-time
kernel allocations, and it becomes critical to enforce that, lest you
pull memory that you thought was safe and crash the system.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
