Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 42B566B000C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 04:38:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c2-v6so1622628edi.20
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 01:38:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r26-v6si2416570edm.42.2018.07.18.01.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 01:38:09 -0700 (PDT)
Date: Wed, 18 Jul 2018 10:38:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: post linux 4.4 vm oom kill, lockup and thrashing woes
Message-ID: <20180718083808.GR7193@dhcp22.suse.cz>
References: <20180710120755.3gmin4rogheqb3u5@schmorp.de>
 <20180710123222.GK14284@dhcp22.suse.cz>
 <20180717234549.4ng2expfkgaranuq@schmorp.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717234549.4ng2expfkgaranuq@schmorp.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Lehmann <schmorp@schmorp.de>
Cc: linux-mm@kvack.org

On Wed 18-07-18 01:45:49, Marc Lehmann wrote:
> On Tue, Jul 10, 2018 at 02:32:22PM +0200, Michal Hocko <mhocko@kernel.org> wrote:
> > then we are out of luck. It is quite unfortunate that nvidia really
> > insists on having order-3 allocation. Maybe it can use kvmalloc or use
> > __GFP_RETRY_MAYFAIL in current kernels.
> 
> Please note that nvidia is really just one of many causes. For example,
> right now, on one of our company servers with 25GB of available RAM and
> no nvidia driver on linux 4.14.43, I couldn't start any kvm until I did a
> manual cache flush:
> 
>    ~# vmctl start ...
>    ioctl(KVM_CREATE_VM) failed: 12 Cannot allocate memory
>    failed to initialize KVM: Cannot allocate memory
>    ~# free
>                  total        used        free      shared  buff/cache   available
>    Mem:       32619348     6712028      989540       21652    24917780    25430736
>    Swap:      33554428      249676    33304752
>    ~# sync; echo 3 >/proc/sys/vm/drop_caches
>    ~# vmctl start ...
>    [successful]
> 
> reason was an order-6 allocation by kvm:
> 
> http://data.plan9.de/kvm_oom.txt

That is something to bring up with kvm guys. Order-6 pages are
considered costly and success of the allocation is by no means
guaranteed. Unike for orders smaller than 4 they do not trigger the oom
killer though.

If kvm doesn't really require the physically contiguous memory then
vmalloc fallback would be a good alternative. Unfortunatelly I am not
able to find which allocation is that. What does faddr2line kvm_dev_ioctl_create_vm+0x40
say?
-- 
Michal Hocko
SUSE Labs
