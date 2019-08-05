Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF0AAC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 11:24:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BABCB20679
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 11:24:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BABCB20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34C726B0006; Mon,  5 Aug 2019 07:24:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FCA86B0007; Mon,  5 Aug 2019 07:24:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C4E16B0008; Mon,  5 Aug 2019 07:24:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3D186B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 07:24:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so51317242edr.13
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 04:24:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OtRlU6oGzI1Dyqj93vHy7t7z5z6E+BkGBNAfpScvUjE=;
        b=mMLFg0kE5jgaxwyc3C86ZHm7i/yQuMb1FHqRUey7gp/Btwwnk+b63kStvz468XFwKD
         Bp8Zmv44UM/b+2/P0A3uYAq10TiAjhP4wD40EdhUzjjtE942WR35TMerFCIeaLqvMmig
         m6Wf3PGH3v31MnBwXX/c/L7EYETuvuYvs/AESG/sRxLL2ZW3DSix1sB9pemvLNy7wSSk
         +gMIh0kVHT3l/zeL2blipV4YxPkz43Iy0gVv02AkEEf/URKkDQvIz7Z7Vf9OZsbOHq8Y
         YTEWW4C/27RKI7mzL/e1o/lKggvy6s9uJa1p7hfSk7DwEpLvOJwfnXj3Jl/Shlo3ASQ9
         x1Og==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUy5ghDTatj+n5RF/diSLM/fphz+kcZlIx6bsLqIWlACMKhTfaW
	Weho3bsmolPggUkU+cnftZGfNT/RIIRpmIRT8KCWr/nNbva/YNzJ0n1w7OeGWGFnei4ij3+3xAN
	GAEXz6RipNXFAESDm+JmN6H7qEPEz0FYQwM/6jAeWF5P9hD/E51T7eroNt9U4cuk=
X-Received: by 2002:a17:906:154f:: with SMTP id c15mr116080785ejd.268.1565004280248;
        Mon, 05 Aug 2019 04:24:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhXdpGEjA8WJ3vM08rbhKvitxDkqH9qTcWSOcO8UiK95wsz+gzjIRQGzzrOC0P9cdB9u0U
X-Received: by 2002:a17:906:154f:: with SMTP id c15mr116080739ejd.268.1565004279475;
        Mon, 05 Aug 2019 04:24:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565004279; cv=none;
        d=google.com; s=arc-20160816;
        b=m6kXvALAQmCEQ/KrnxoThwh+1GdVU/oAx734vzdl7NOpvuxR/PfBvsyXiPX6/fOjXo
         NVoeUugQq6vJsGh4dAUlyyolevLMxGQ1AlwIjmGUCeHODoyj5uMWR1j+peywQoEMyH0o
         KqoeNxJ7n5zEpAqBp/EFD+bHYwTcj5/SlxvYGsYDDTkJkCyqM+TtrWkLd/sN2mKifKgt
         iCZvuA5a/E91XTTWafHB8Ah9ZjqaKaf768RKbYIKSGa3x6/U07ouDJmXDjJkoshuGLws
         85/Qm441ckbmzO8doXGTAUhAtsqpiEjoHxsCb2tv09wVM197bGkiYASyLiJAkKrJ/bF7
         WwuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OtRlU6oGzI1Dyqj93vHy7t7z5z6E+BkGBNAfpScvUjE=;
        b=uZVKR93ST9bJPRxLuP1h54BhD0VNdAM4YlXuj2ZSGrjIFTtqD7CG43PYFFvJlfvSIt
         3jRIAxWwN6bVJY5dUwlYif6O7YYex2cihFCMO5ohsmZ3TpiKV01oJX5V1oMs0/r6wxBp
         i43BBW47JFOq1+bTTB1qvMlawYVoHXI6D10xNfICzNQjg/T+XyMSXgR5w4Pfm/4+PFjh
         +cz5Ctt9XCsZ62NfZUhiynh7UrMyol2OLK5jZezc2a3KQvc2N4uy8ceQNw3f9qqaZECO
         dTAmVeugglQAJ8m27QrQExL9UMydLgWlUIhtgX5E6eb07DGt+DnlljPvkQUsJEt0Osq2
         oscQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h13si27486955eda.63.2019.08.05.04.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 04:24:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A560EAEFD;
	Mon,  5 Aug 2019 11:24:38 +0000 (UTC)
Date: Mon, 5 Aug 2019 13:24:37 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pankaj.suryawanshi@einfochips.com
Subject: Re: oom-killer
Message-ID: <20190805112437.GF7597@dhcp22.suse.cz>
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 03-08-19 18:53:50, Pankaj Suryawanshi wrote:
> Hello,
> 
> Below are the logs from oom-kller. I am not able to interpret/decode the
> logs as well as not able to find root cause of oom-killer.
> 
> Note: CPU Arch: Arm 32-bit , Kernel - 4.14.65

Fixed up line wrapping and trimmed to the bare minimum

> [  727.941258] kworker/u8:2 invoked oom-killer: gfp_mask=0x15080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO), nodemask=(null),  order=1, oom_score_adj=0

This tells us that this is order 1 (two physically contiguous pages)
request restricted to GFP_KERNEL (GFP_KERNEL_ACCOUNT is GFP_KERNEL |
__GFP_ACCOUNT) and that means that the request can be satisfied only
from the low memory zone. This is important because you are running 32b
system and that means that only low 1G is directly addressable by the
kernel. The rest is in highmem.

> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P           O  4.14.65 #606
[...]
> [  728.029390] [<c034a094>] (oom_kill_process) from [<c034af24>] (out_of_memory+0x140/0x368)
> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121e680 r6:c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
> [  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>]  (__alloc_pages_nodemask+0x1178/0x124c)
> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155
> [  728.062460] [<c0350834>] (__alloc_pages_nodemask) from [<c021e9d4>] (copy_process.part.5+0x114/0x1a28)
> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08 r6:c1216588 r5:00808111
> [  728.079587]  r4:d1063c00
> [  728.082119] [<c021e8c0>] (copy_process.part.5) from [<c0220470>] (_do_fork+0xd0/0x464)
> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:00000000 r6:c1216588 r5:d2d58ac0
> [  728.097857]  r4:00808111

The call trace tells that this is a fork (of a usermodhlper but that is
not all that important.
[...]
> [  728.260031] DMA free:17960kB min:16384kB low:25664kB high:29760kB active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file:28kB unevictable:0kB writepending:0kB present:458752kB managed:422896kB mlocked:0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB local_pcp:0kB free_cma:0kB
> [  728.287402] lowmem_reserve[]: 0 0 579 579

So this is the only usable zone and you are close to the min watermark
which means that your system is under a serious memory pressure but not
yet under OOM for order-0 request. The situation is not great though
because there is close to no reclaimable memory (look at *_anon, *_file)
counters and it is quite likely that compaction will stubmle over
unmovable pages very often as well.

> [  728.326634] DMA: 71*4kB (EH) 113*8kB (UH) 207*16kB (UMH) 103*32kB (UMH) 70*64kB (UMH) 27*128kB (UMH) 5*256kB (UMH) 1*512kB (H) 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB = 17524kB

This is more interesting because there seem to be order-1+ blocks to
be used for this allocation. H stands for High atomic reserve, U for
unmovable blocks and GFP_KERNEL belong to such an allocation and M is
for movable pageblock (see show_migration_types for all migration
types). From the above it would mean that the allocation should pass
through but note that the information is dumped after the last watermark
check so the situation might have changed.

In any case your system seems to be tight on the lowmem and I would
expect it could get to OOM in peak memory demand on top of the current
state.

-- 
Michal Hocko
SUSE Labs

