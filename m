Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 551F36B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 10:08:04 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so84279853wmu.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 07:08:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hm2si81650349wjb.167.2017.01.04.07.08.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 07:08:03 -0800 (PST)
Date: Wed, 4 Jan 2017 16:08:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: GFP_REPEAT usage in vhost_net_open resp. vhost_vsock_dev_open
Message-ID: <20170104150800.GO25453@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org

Hi Michael,
I am currently cleaning up opencoded kmalloc with vmalloc fallback users
[1] and my current kvmalloc_node helper doesn't support GFP_REPEAT
because there are no users which would need it. At least that's what I
thought until I've encountered vhost_vsock_dev_open resp.
vhost_vsock_dev_open which are trying to use GFP_REPEAT for kmalloc.
23cc5a991c7a ("vhost-net: extend device allocation to vmalloc") explains
the motivation as follows:
"
As vmalloc() adds overhead on a critical network path, add __GFP_REPEAT
to kzalloc() flags to do this fallback only when really needed.
"

I am wondering whether vmalloc adds more overhead than GFP_REPEAT which
can get pretty costly for order-4 allocation which will be used here as
struct vhost_net seems to be 36104 (at least in with my config). Have
you ever measured the difference?

So I am just trying to understand whether we should teach kvmalloc_node
to understand GFP_REPEAT or there is no strong reason to keep the repeat
flag.

[1] http://lkml.kernel.org/r/20170102133700.1734-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
