Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9916B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 13:06:28 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id d17so50845215wjx.5
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 10:06:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f19si3070339wmf.101.2017.01.04.10.06.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 10:06:27 -0800 (PST)
Date: Wed, 4 Jan 2017 19:06:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: GFP_REPEAT usage in vhost_net_open resp. vhost_vsock_dev_open
Message-ID: <20170104180624.GA10183@dhcp22.suse.cz>
References: <20170104150800.GO25453@dhcp22.suse.cz>
 <20170104195521-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104195521-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On Wed 04-01-17 19:56:42, Michael S. Tsirkin wrote:
> On Wed, Jan 04, 2017 at 04:08:00PM +0100, Michal Hocko wrote:
> > Hi Michael,
> > I am currently cleaning up opencoded kmalloc with vmalloc fallback users
> > [1] and my current kvmalloc_node helper doesn't support GFP_REPEAT
> > because there are no users which would need it. At least that's what I
> > thought until I've encountered vhost_vsock_dev_open resp.
> > vhost_vsock_dev_open which are trying to use GFP_REPEAT for kmalloc.
> > 23cc5a991c7a ("vhost-net: extend device allocation to vmalloc") explains
> > the motivation as follows:
> > "
> > As vmalloc() adds overhead on a critical network path, add __GFP_REPEAT
> > to kzalloc() flags to do this fallback only when really needed.
> > "
> > 
> > I am wondering whether vmalloc adds more overhead than GFP_REPEAT
> 
> Yes but the GFP_REPEAT overhead is during allocation time.
> Using vmalloc means all accesses are slowed down.
> Allocation is not on data path, accesses are.

OK, that wasn't clear to me. Thanks for the clarification. If the access
path can compensate the allocation cost then I agree that GFP_REPEAT
makes a lot of sense. I will cook up a patch to allow GFP_REPEAT in the
current kvmalloc_node and convert vhost users to it.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
