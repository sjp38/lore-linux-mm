Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C20B6B0253
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 05:50:18 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p41so7581504lfi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 02:50:18 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id p185si19513762wmb.26.2016.07.12.02.50.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 02:50:16 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id o80so18091523wme.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 02:50:15 -0700 (PDT)
Date: Tue, 12 Jul 2016 11:50:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Page Allocation Failures/OOM with dm-crypt on software RAID10
 (Intel Rapid Storage)
Message-ID: <20160712095013.GA14591@dhcp22.suse.cz>
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

On Tue 12-07-16 10:27:37, Matthias Dahl wrote:
> Hello,
> 
> I posted this issue already on linux-mm, linux-kernel and dm-devel a
> few days ago and after further investigation it seems like that this
> issue is somehow related to the fact that I am using an Intel Rapid
> Storage RAID10, so I am summarizing everything again in this mail
> and include linux-raid in my post. Sorry for the noise... :(
> 
> I am currently setting up a new machine (since my old one broke down)
> and I ran into a lot of " Unable to allocate memory on node -1" warnings
> while using dm-crypt. I have attached as much of the full log as I could
> recover.
> 
> The encrypted device is sitting on a RAID10 (software raid, Intel Rapid
> Storage). I am currently limited to testing via Linux live images since
> the machine is not yet properly setup but I did my tests across several
> of those.
> 
> Steps to reproduce are:
> 
> 1)
> cryptsetup -s 512 -d /dev/urandom -c aes-xts-plain64 open --type plain
> /dev/md126p5 test-device
> 
> 2)
> dd if=/dev/zero of=/dev/mapper/test-device status=progress bs=512K
> 
> While running and monitoring the memory usage with free, it can be seen
> that the used memory increases rapidly and after just a few seconds, the
> system is out of memory and page allocation failures start to be issued
> as well as the OOM killer gets involved.

Here are two instances of the oom killer Mem-Info:

[18907.592206] Mem-Info:
[18907.592209] active_anon:110314 inactive_anon:295 isolated_anon:0
                active_file:27534 inactive_file:819673 isolated_file:160
                unevictable:13001 dirty:167859 writeback:651864 unstable:0
                slab_reclaimable:177477 slab_unreclaimable:1817501
                mapped:934 shmem:588 pagetables:7109 bounce:0
                free:49928 free_pcp:45 free_cma:0

[18908.976349] Mem-Info:
[18908.976352] active_anon:109647 inactive_anon:295 isolated_anon:0
                active_file:27535 inactive_file:819602 isolated_file:128
                unevictable:13001 dirty:167672 writeback:652038 unstable:0
                slab_reclaimable:177477 slab_unreclaimable:1817828
                mapped:934 shmem:588 pagetables:7109 bounce:0
                free:50252 free_pcp:91 free_cma:0

This smells like file pages are stuck in the writeback somewhere and the
anon memory is not reclaimable because you do not have any swap device.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
