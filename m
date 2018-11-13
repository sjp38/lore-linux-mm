Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D8EE66B0005
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 06:06:06 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id y40-v6so12254472wrd.21
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:06:06 -0800 (PST)
Received: from vulcan.natalenko.name (vulcan.natalenko.name. [2001:19f0:6c00:8846:5400:ff:fe0c:dfa0])
        by mx.google.com with ESMTPS id o16-v6si15794051wrs.141.2018.11.13.03.06.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Nov 2018 03:06:04 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Nov 2018 12:06:03 +0100
From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
In-Reply-To: <<20181112231344.7161-1-timofey.titovets@synesis.ru>>
Message-ID: <b4c41073d763dc5798562233de8eaa6d@natalenko.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: timofey.titovets@synesis.ru
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nefelim4ag@gmail.com, willy@infradead.org

Hi.

> ksm by default working only on memory that added by
> madvise().
> 
> And only way get that work on other applications:
>   * Use LD_PRELOAD and libraries
>   * Patch kernel
> 
> Lets use kernel task list and add logic to import VMAs from tasks.
> 
> That behaviour controlled by new attributes:
>   * mode:
>     I try mimic hugepages attribute, so mode have two states:
>       * madvise      - old default behaviour
>       * always [new] - allow ksm to get tasks vma and
>                        try working on that.
>   * seeker_sleep_millisecs:
>     Add pauses between imports tasks VMA
> 
> For rate limiting proporses and tasklist locking time,
> ksm seeker thread only import VMAs from one task per loop.
> 
> Some numbers from different not madvised workloads.
> Formulas:
>   Percentage ratio = (pages_sharing - pages_shared)/pages_unshared
>   Memory saved = (pages_sharing - pages_shared)*4/1024 MiB
>   Memory used = free -h
> 
>   * Name: My working laptop
>     Description: Many different chrome/electron apps + KDE
>     Ratio: 5%
>     Saved: ~100  MiB
>     Used:  ~2000 MiB
> 
>   * Name: K8s test VM
>     Description: Some small random running docker images
>     Ratio: 40%
>     Saved: ~160 MiB
>     Used:  ~920 MiB
> 
>   * Name: Ceph test VM
>     Description: Ceph Mon/OSD, some containers
>     Ratio: 20%
>     Saved: ~60 MiB
>     Used:  ~600 MiB
> 
>   * Name: BareMetal K8s backend server
>     Description: Different server apps in containers C, Java, GO & etc
>     Ratio: 72%
>     Saved: ~5800 MiB
>     Used:  ~35.7 GiB
> 
>   * Name: BareMetal K8s processing server
>     Description: Many instance of one CPU intensive application
>     Ratio: 55%
>     Saved: ~2600 MiB
>     Used:  ~28.0 GiB
> 
>   * Name: BareMetal Ceph node
>     Description: Only OSD storage daemons running
>     Raio: 2%
>     Saved: ~190 MiB
>     Used:  ~11.7 GiB

Out of curiosity, have you compared these results with UKSM [1]?

Thanks.

-- 
   Oleksandr Natalenko (post-factum)

[1] https://github.com/dolohow/uksm
