Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D355C7618F
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 21:11:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21D9A20665
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 21:11:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21D9A20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87A038E0003; Sun, 28 Jul 2019 17:11:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 829C78E0002; Sun, 28 Jul 2019 17:11:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 719ED8E0003; Sun, 28 Jul 2019 17:11:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 279548E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 17:11:56 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id b67so17723072wmd.0
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 14:11:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=Ic1l9sxV1aEYiIX34jdQZewqO3seyociygzb5FWKRSo=;
        b=V6944zNyPooDzFUUkhU8UlKcCcKUn7M+3zhecOOJMnrNTLdp64yj1xX9tlhgbpiuUc
         zyJOLPxi9huQtmtIVh7JRHKpdqUPeO15bm7STx1Gk4Jm7ccq1WQ+HFdqgR4Zi6d36a3w
         N/CRddLBCCnqgPZJ9rJAsVP4tb7V07zn6KLLQCgfkPyluIeQGLQyxnq2AlXAe6a79Bef
         b49OXF4mZh2zfchBGllsaQqzvzX5zq+aiuaI7fg6VHh4ZBoItVy6sTYKXcUiHsFwmPuq
         Jl6vYn9HwFvVfTt0duYevY7Swhbzw3UsvRh1NG6Qldbdl+28vSnb8GCqAjx+Nv29odyv
         NEPA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
X-Gm-Message-State: APjAAAWvuFwb/tW6vTwvdg2G7UzM0gZQfEq2vK+NpossQXLlLNF3rWhE
	wdCnNByDY0Mxm1CWmXpjr1cxpTmh4JhEGsKyYrlwgD3r/4kOCt+VKA4pH/K5vBu64eEjE0TANdu
	rA+6t63h/oIYlx2MrUiAfB4d0RDOGSAbAbCXbqA/IdABRmYa1A8hC88SIGvveoSc=
X-Received: by 2002:a5d:67cd:: with SMTP id n13mr41600856wrw.138.1564348315665;
        Sun, 28 Jul 2019 14:11:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1SL9lWpLb3s0ROuLvSNZfJbx9pWoR0z2+ken6qNqnNPVSaJ18/pJlQXEnF23uC15W3yH/
X-Received: by 2002:a5d:67cd:: with SMTP id n13mr41600827wrw.138.1564348314631;
        Sun, 28 Jul 2019 14:11:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564348314; cv=none;
        d=google.com; s=arc-20160816;
        b=NoxpT0NK0gAc5Zv/KO7kEuCjMjnVCFyFo90FUC6OgM93Lt8lFA0ZW8jXiSQJ0hsGt6
         cB0e4P5sDyH716I3UUvzTKAUHGJq+d9SHouQf2gMLJRnKP2zIJo3C14SM/hCbZuLnIEw
         RM+CLvzInAWHcE8vrk7di1BzMKLzZ7tseZ/tPZ5+dFrfXs9Rw3V9vEK4KQzbDsGM70M/
         L6/Fgv+0cuVmHIG9t0HaxLS1k9KUQ9s2fuN9gHsrxwO6IgEM6lqiNuCW3Jdc1PJ6aQCe
         /i7ApLtqXafQmvh51QgzyfKrIISf6+PIVpe09az2JeiKFd77L1CULY1ppBazps7Ilewc
         Ng/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=Ic1l9sxV1aEYiIX34jdQZewqO3seyociygzb5FWKRSo=;
        b=IbPk9p7HC+dRqruyhNfZ/XpzESsyD0V9eNVFKlp8TsLh0LL7hpgst+sfGNQFqZrqYT
         Zb8QfNGvcy5mRyVPc0E7281NjrIVNDdol1YqmZctUMGQuYkOYG+6mBZMPSJ4va+pDgx6
         8CEh/5Y09Pj+F5qUDA8tqBSb0kTibczay7kH71n500E0igdgBaclIELxVwPzxTjApLOk
         rnopZ/OmXLTzu7a9KMvqP5lIBCZmbvc3khbJJUlwr9H2l/Ny/7ts0NySQ/31UGR099EZ
         lvbm68RQ0lE9NOyO0tzwDnX+2AxeKEEd0I1SEhI32IpZycwbEfNWCIHsYB7apRogW7NX
         I3Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id q5si51274106wrj.333.2019.07.28.14.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Jul 2019 14:11:54 -0700 (PDT)
Received-SPF: neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) client-ip=178.250.10.56;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: (qmail 1443 invoked from network); 28 Jul 2019 23:11:54 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.242.2.6]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Sun, 28 Jul 2019 23:11:54 +0200
Subject: Re: No memory reclaim while reaching MemoryHigh
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
To: Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>, p.kramme@profihost.ag
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
 <20190725140117.GC3582@dhcp22.suse.cz>
 <028ff462-b547-b9a5-bdb0-e0de3a884afd@profihost.ag>
 <20190726074557.GF6142@dhcp22.suse.cz>
 <d205c7a1-30c4-e26c-7e9c-debc431b5ada@profihost.ag>
Message-ID: <9eb7d70a-40b1-b452-a0cf-24418fa6254c@profihost.ag>
Date: Sun, 28 Jul 2019 23:11:53 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <d205c7a1-30c4-e26c-7e9c-debc431b5ada@profihost.ag>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

here is a memory.stat output of the cgroup:
# cat /sys/fs/cgroup/system.slice/varnish.service/memory.stat
anon 8113229824
file 39735296
kernel_stack 26345472
slab 24985600
sock 339968
shmem 0
file_mapped 38793216
file_dirty 946176
file_writeback 0
inactive_anon 0
active_anon 8113119232
inactive_file 40198144
active_file 102400
unevictable 0
slab_reclaimable 2859008
slab_unreclaimable 22126592
pgfault 178231449
pgmajfault 22011
pgrefill 393038
pgscan 4218254
pgsteal 430005
pgactivate 295416
pgdeactivate 351487
pglazyfree 0
pglazyfreed 0
workingset_refault 401874
workingset_activate 62535
workingset_nodereclaim 0

Greets,
Stefan

Am 26.07.19 um 20:30 schrieb Stefan Priebe - Profihost AG:
> Am 26.07.19 um 09:45 schrieb Michal Hocko:
>> On Thu 25-07-19 23:37:14, Stefan Priebe - Profihost AG wrote:
>>> Hi Michal,
>>>
>>> Am 25.07.19 um 16:01 schrieb Michal Hocko:
>>>> On Thu 25-07-19 15:17:17, Stefan Priebe - Profihost AG wrote:
>>>>> Hello all,
>>>>>
>>>>> i hope i added the right list and people - if i missed someone i would
>>>>> be happy to know.
>>>>>
>>>>> While using kernel 4.19.55 and cgroupv2 i set a MemoryHigh value for a
>>>>> varnish service.
>>>>>
>>>>> It happens that the varnish.service cgroup reaches it's MemoryHigh value
>>>>> and stops working due to throttling.
>>>>
>>>> What do you mean by "stops working"? Does it mean that the process is
>>>> stuck in the kernel doing the reclaim? /proc/<pid>/stack would tell you
>>>> what the kernel executing for the process.
>>>
>>> The service no longer responses to HTTP requests.
>>>
>>> stack switches in this case between:
>>> [<0>] io_schedule+0x12/0x40
>>> [<0>] __lock_page_or_retry+0x1e7/0x4e0
>>> [<0>] filemap_fault+0x42f/0x830
>>> [<0>] __xfs_filemap_fault.constprop.11+0x49/0x120
>>> [<0>] __do_fault+0x57/0x108
>>> [<0>] __handle_mm_fault+0x949/0xef0
>>> [<0>] handle_mm_fault+0xfc/0x1f0
>>> [<0>] __do_page_fault+0x24a/0x450
>>> [<0>] do_page_fault+0x32/0x110
>>> [<0>] async_page_fault+0x1e/0x30
>>> [<0>] 0xffffffffffffffff
>>>
>>> and
>>>
>>> [<0>] poll_schedule_timeout.constprop.13+0x42/0x70
>>> [<0>] do_sys_poll+0x51e/0x5f0
>>> [<0>] __x64_sys_poll+0xe7/0x130
>>> [<0>] do_syscall_64+0x5b/0x170
>>> [<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
>>> [<0>] 0xffffffffffffffff
>>
>> Neither of the two seem to be memcg related.
> 
> Yes but at least the xfs one is a page fault - isn't this related?
> 
>> Have you tried to get
>> several snapshots and see if the backtrace is stable?
> No it's not it switches most of the time between these both. But as long
> as the xfs one with the page fault is seen it does not serve requests
> and that one is seen for at least 1-5s than the poill one is visible and
> than the xfs one again for 1-5s.
> 
> This happens if i do:
> systemctl set-property --runtime varnish.service MemoryHigh=6.5G
> 
> if i set:
> systemctl set-property --runtime varnish.service MemoryHigh=14G
> 
> i never get the xfs handle_mm fault one. This is reproducable.
> 
>> tell you whether your application is stuck in a single syscall or they
>> are just progressing very slowly (-ttt parameter should give you timing)
> 
> Yes it's still going forward but really really slow due to memory
> pressure. memory.pressure of varnish cgroup shows high values above 100
> or 200.
> 
> I can reproduce the same with rsync or other tasks using memory for
> inodes and dentries. What i don't unterstand is that the kernel does not
> reclaim memory for the userspace process and drops the cache. I can't
> believe those entries are hot - as they must be at least some days old
> as a fresh process running a day only consumes about 200MB of indoe /
> dentries / page cache.
> 
> Greets,
> Stefan
> 

