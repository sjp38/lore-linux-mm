Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9E2B6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 19:45:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f11-v6so277038wmc.3
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 16:45:53 -0700 (PDT)
Received: from mail.nethype.de (mail.nethype.de. [5.9.56.24])
        by mx.google.com with ESMTPS id a88-v6si1768267wrc.109.2018.07.17.16.45.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Jul 2018 16:45:52 -0700 (PDT)
Date: Wed, 18 Jul 2018 01:45:49 +0200
From: Marc Lehmann <schmorp@schmorp.de>
Subject: Re: post linux 4.4 vm oom kill, lockup and thrashing woes
Message-ID: <20180717234549.4ng2expfkgaranuq@schmorp.de>
References: <20180710120755.3gmin4rogheqb3u5@schmorp.de>
 <20180710123222.GK14284@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180710123222.GK14284@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Tue, Jul 10, 2018 at 02:32:22PM +0200, Michal Hocko <mhocko@kernel.org> wrote:
> then we are out of luck. It is quite unfortunate that nvidia really
> insists on having order-3 allocation. Maybe it can use kvmalloc or use
> __GFP_RETRY_MAYFAIL in current kernels.

Please note that nvidia is really just one of many causes. For example,
right now, on one of our company servers with 25GB of available RAM and
no nvidia driver on linux 4.14.43, I couldn't start any kvm until I did a
manual cache flush:

   ~# vmctl start ...
   ioctl(KVM_CREATE_VM) failed: 12 Cannot allocate memory
   failed to initialize KVM: Cannot allocate memory
   ~# free
                 total        used        free      shared  buff/cache   available
   Mem:       32619348     6712028      989540       21652    24917780    25430736
   Swap:      33554428      249676    33304752
   ~# sync; echo 3 >/proc/sys/vm/drop_caches
   ~# vmctl start ...
   [successful]

reason was an order-6 allocation by kvm:

http://data.plan9.de/kvm_oom.txt

-- 
                The choice of a       Deliantra, the free code+content MORPG
      -----==-     _GNU_              http://www.deliantra.net
      ----==-- _       generation
      ---==---(_)__  __ ____  __      Marc Lehmann
      --==---/ / _ \/ // /\ \/ /      schmorp@schmorp.de
      -=====/_/_//_/\_,_/ /_/\_\
