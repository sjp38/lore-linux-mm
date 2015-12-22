Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id BD3AB82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 17:26:06 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id cy9so40967412pac.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:26:06 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id e21si14429768pfb.51.2015.12.22.14.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 14:26:06 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id q63so6570227pfb.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:26:06 -0800 (PST)
Date: Tue, 22 Dec 2015 14:26:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] memory-hotplug: add automatic onlining policy for
 the newly added memory
In-Reply-To: <20151222135520.1bcb2d18382f1e414864992c@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1512221422480.5172@chino.kir.corp.google.com>
References: <1450801950-7744-1-git-send-email-vkuznets@redhat.com> <20151222135520.1bcb2d18382f1e414864992c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Tue, 22 Dec 2015, Andrew Morton wrote:

> On Tue, 22 Dec 2015 17:32:30 +0100 Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
> 
> > Currently, all newly added memory blocks remain in 'offline' state unless
> > someone onlines them, some linux distributions carry special udev rules
> > like:
> > 
> > SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"
> > 
> > to make this happen automatically. This is not a great solution for virtual
> > machines where memory hotplug is being used to address high memory pressure
> > situations as such onlining is slow and a userspace process doing this
> > (udev) has a chance of being killed by the OOM killer as it will probably
> > require to allocate some memory.
> > 
> > Introduce default policy for the newly added memory blocks in
> > /sys/devices/system/memory/hotplug_autoonline file with two possible
> > values: "offline" which preserves the current behavior and "online" which
> > causes all newly added memory blocks to go online as soon as they're added.
> > The default is "online" when MEMORY_HOTPLUG_AUTOONLINE kernel config option
> > is selected.
> 
> I think the default should be "offline" so vendors can ship kernels
> which have CONFIG_MEMORY_HOTPLUG_AUTOONLINE=y while being
> back-compatible with previous kernels.
> 

But isn't the premise of the changelog that this is currently being 
handled by the distribution?  Perhaps I don't understand why this patch 
can't end up just introducing a sysfs tunable that is always present and 
can be set by initscripts of that distribution.

I'd also suggest that hotplug_autoonline be renamed to auto_online_block.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
