Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E02A6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 12:56:44 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id m67so314743006qkf.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 09:56:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x6si36010559qkd.310.2017.01.04.09.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 09:56:43 -0800 (PST)
Date: Wed, 4 Jan 2017 19:56:42 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: GFP_REPEAT usage in vhost_net_open resp. vhost_vsock_dev_open
Message-ID: <20170104195521-mutt-send-email-mst@kernel.org>
References: <20170104150800.GO25453@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104150800.GO25453@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On Wed, Jan 04, 2017 at 04:08:00PM +0100, Michal Hocko wrote:
> Hi Michael,
> I am currently cleaning up opencoded kmalloc with vmalloc fallback users
> [1] and my current kvmalloc_node helper doesn't support GFP_REPEAT
> because there are no users which would need it. At least that's what I
> thought until I've encountered vhost_vsock_dev_open resp.
> vhost_vsock_dev_open which are trying to use GFP_REPEAT for kmalloc.
> 23cc5a991c7a ("vhost-net: extend device allocation to vmalloc") explains
> the motivation as follows:
> "
> As vmalloc() adds overhead on a critical network path, add __GFP_REPEAT
> to kzalloc() flags to do this fallback only when really needed.
> "
> 
> I am wondering whether vmalloc adds more overhead than GFP_REPEAT

Yes but the GFP_REPEAT overhead is during allocation time.
Using vmalloc means all accesses are slowed down.
Allocation is not on data path, accesses are.

> which
> can get pretty costly for order-4 allocation which will be used here as
> struct vhost_net seems to be 36104 (at least in with my config). Have
> you ever measured the difference?

I think it was measureable.

> So I am just trying to understand whether we should teach kvmalloc_node
> to understand GFP_REPEAT or there is no strong reason to keep the repeat
> flag.
> 
> [1] http://lkml.kernel.org/r/20170102133700.1734-1-mhocko@kernel.org
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
