Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF026B0005
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 18:06:51 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id jx14so78369189pad.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 15:06:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 68si11791159pfk.194.2015.12.21.15.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 15:06:50 -0800 (PST)
Date: Mon, 21 Dec 2015 15:06:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memory-hotplug: don't BUG() in
 register_memory_resource()
Message-Id: <20151221150649.f385889426082059bfc09495@linux-foundation.org>
In-Reply-To: <8737uwt8hw.fsf@vitty.brq.redhat.com>
References: <1450450224-18515-1-git-send-email-vkuznets@redhat.com>
	<20151218145022.eae1e368c82f090900582fcc@linux-foundation.org>
	<8737uwt8hw.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Sheng Yong <shengyong1@huawei.com>, David Rientjes <rientjes@google.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dan Williams <dan.j.williams@intel.com>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>

On Mon, 21 Dec 2015 11:13:15 +0100 Vitaly Kuznetsov <vkuznets@redhat.com> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Fri, 18 Dec 2015 15:50:24 +0100 Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
> >
> >> Out of memory condition is not a bug and while we can't add new memory in
> >> such case crashing the system seems wrong. Propagating the return value
> >> from register_memory_resource() requires interface change.
> >> 
> >> --- a/mm/memory_hotplug.c
> >> +++ b/mm/memory_hotplug.c
> >> +static int register_memory_resource(u64 start, u64 size,
> >> +				    struct resource **resource)
> >>  {
> >>  	struct resource *res;
> >>  	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
> >> -	BUG_ON(!res);
> >> +	if (!res)
> >> +		return -ENOMEM;
> >>  
> >>  	res->name = "System RAM";
> >>  	res->start = start;
> >> @@ -140,9 +142,10 @@ static struct resource *register_memory_resource(u64 start, u64 size)
> >>  	if (request_resource(&iomem_resource, res) < 0) {
> >>  		pr_debug("System RAM resource %pR cannot be added\n", res);
> >>  		kfree(res);
> >> -		res = NULL;
> >> +		return -EEXIST;
> >>  	}
> >> -	return res;
> >> +	*resource = res;
> >> +	return 0;
> >>  }
> >
> > Was there a reason for overwriting the request_resource() return
> > value?
> > Ordinarily it should be propagated back to callers.
> >
> > Please review.
> >
> 
> This is a nice-to-have addition but it will break at least ACPI
> memhotplug: request_resource() has the following:
> 
> conflict = request_resource_conflict(root, new);
> return conflict ? -EBUSY : 0;
> 
> so we'll end up returning -EBUSY from register_memory_resource() and
> add_memory(), at the same time acpi_memory_enable_device() counts on
> -EEXIST:
> 
> result = add_memory(node, info->start_addr, info->length);
> 
> /*
> * If the memory block has been used by the kernel, add_memory()
> * returns -EEXIST. If add_memory() returns the other error, it
> * means that this memory block is not used by the kernel.
> */
> if (result && result != -EEXIST)
> continue;
> 
> So I see 3 options here:
> 1) Keep the overwrite
> 2) Change the request_resource() return value to -EEXIST
> 3) Adapt all add_memory() call sites to -EBUSY.
> 
> Please let me know your preference.

urgh, what a mess.  We should standardize on EBUSY or EEXIST, I don't
see that it matter much which is chosen.  And for robustness the
callers should be checking for (err < 0) unless there's a very good
reason otherwise.

But it doesn't seem terribly important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
