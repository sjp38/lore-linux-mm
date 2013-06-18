Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id D050A6B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 01:44:18 -0400 (EDT)
Message-ID: <51BFF464.809@cn.fujitsu.com>
Date: Tue, 18 Jun 2013 13:47:16 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com> <20130618020357.GZ32663@mtj.dyndns.org>
In-Reply-To: <20130618020357.GZ32663@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi tj,

On 06/18/2013 10:03 AM, Tejun Heo wrote:
......
>
> So, can you please explain why you're doing the above?  What are you
> trying to achieve in the end and why is this the best approach?  This
> is all for memory hotplug, right?

Yes, this is all for memory hotplug.

[why]
At early boot time (before parsing SRAT), memblock will allocate memory
for kernel to use. But the memory could be hotpluggable memory because
at such an early time, we don't know which memory is hotpluggable. This
will cause hotpluggable memory un-hotpluggable. What we are trying to
do is to prevent memblock from allocating hotpluggable memory.

[approach]
Parse SRAT earlier before memblock starts to work, because there is a
bit in SRAT specifying which memory is hotpluggable.

I'm not saying this is the best approach. I can also see that this
patch-set touches a lot of boot code. But i think parsing SRAT earlier
is reasonable because this is the only way for now to know which memory
is hotpluggable from firmware.

>
> I can understand the part where you're move NUMA discovery before
> initializations which will get allocated permanent addresses in the
> wrong nodes, but trying to do the same with memblock itself is making
> the code extremely fragile.  It's nasty because there's nothing
> apparent which seems to necessitate such ordering.  The ordering looks
> rather arbitrary but changing the orders will subtly break memory
> hotplug support, which is a really bad way to structure the code.
>
> Can't you just move memblock arrays after NUMA init is complete?
> That'd be a lot simpler and way more robust than the proposed changes,
> no?

Sorry, I don't quite understand the approach you are suggesting. If we
move memblock arrays, we need to update all the pointers pointing to
the moved memory. How can we do this ?

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
