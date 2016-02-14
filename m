Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 16DA26B0009
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 09:27:47 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id xk3so180640321obc.2
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 06:27:47 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0058.outbound.protection.outlook.com. [157.55.234.58])
        by mx.google.com with ESMTPS id g137si12419992oic.115.2016.02.14.06.27.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 14 Feb 2016 06:27:46 -0800 (PST)
Subject: Re: [RFC 0/7] Peer-direct memory
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
 <20160211191838.GA23675@obsidianresearch.com>
From: Haggai Eran <haggaie@mellanox.com>
Message-ID: <56C08EC8.10207@mellanox.com>
Date: Sun, 14 Feb 2016 16:27:20 +0200
MIME-Version: 1.0
In-Reply-To: <20160211191838.GA23675@obsidianresearch.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Kovalyov Artemy <artemyko@mellanox.com>
Cc: "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "leon@leon.ro" <leon@leon.ro>, Sagi Grimberg <sagig@mellanox.com>

[apologies: sending again because linux-mm address was wrong]

On 11/02/2016 21:18, Jason Gunthorpe wrote:
> Resubmit those parts under the mm subsystem, or another more
> appropriate place.

We want the feedback from linux-mm, and they are now Cced.

> If you want to make some incremental progress then implement the
> existing ZONE_DEVICE API for the IB core and add the invalidate stuff
> later, once you've negotiated a common API for that with linux-mm.

So there are couple of issues we currently have with ZONE_DEVICE. 
Perhaps they can be solved and then we could use it directly.

First, I'm not sure it is intended to be used for our purpose. 
memremap() has this comment [1]:
> memremap() is "ioremap" for cases where it is known that the resource
> being mapped does not have i/o side effects and the __iomem
> annotation is not applicable. 

Does this apply also to devm_memremap_pages()? Because the HCA BAR 
clearly doesn't fall under this definition.

Second, there's a requirement that ZONE_DEVICE ranges are aligned to 
section-boundary, right? We have devices that have 8MB or 32MB BARs, 
so they won't work with 128MB sections on x86_64.

Third, I understand there was a desire to place ZONE_DEVICE page structs 
in the device itself. This can work for pmem, but obviously won't work 
for an I/O device BAR like an HCA.

Regards,
Haggai

[1] http://lxr.free-electrons.com/source/kernel/memremap.c?v=4.4#L38

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
