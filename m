Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8EDDC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:06:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 667CE20838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:06:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 667CE20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0533A8E0018; Thu,  1 Aug 2019 10:06:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 003508E0001; Thu,  1 Aug 2019 10:06:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E34168E0018; Thu,  1 Aug 2019 10:06:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 932828E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 10:06:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l14so44943837edw.20
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 07:06:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DwjmtomE8I2hqDHJ9yMU5T/xNv8OrkpuhJgP+fexi8Q=;
        b=RHuwtGXhhXAsMeub0jmG2xGAI0XQycdbCKaWyZoZKus59KaObPMT7sGZ0/DnVLaN4q
         VyuJ9pM3N0ULtMXwyqvLO757CUuOME0CnNelzRxJO8aP0767DRqFtdwzs9+ty4q2GNaw
         Mbz1gdXN8hpiE0ql6KjxOlX9eBfTAVyvp84a/XTJbL0JkSh02a9FB4V8VXnkZaWRBHBY
         D2gnic/AddPWwXRL094exAz+zr27c5UlTFIDArnRHMCX5UXLFnjHiYVM0g9d1NgYyK4L
         eszWz/nWzoT8KBqP+d0qq+jcdq0JI0AT/10nkByCd+fl+ldq5EID6Gjh/hiN6iEFM7U8
         b9KQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVNMmj1f8h+i1Uj/NYJ79IfRP8s5RtLrkTgvEVfxoeEdXGjgCA4
	gKJKLCzUsGkJzkIKnNzvuuiYJ32zGFodzNZ++LeEmnMbxCB1XjUUTxENAzQo7RoOL58VZeJ+9dh
	S/r/SHkmEbIcSLD1vFIH4zw25eIIhGVr3WVHWrVYEiUSoGD7r6rxKSOZxfsjR5Cg=
X-Received: by 2002:aa7:cf8e:: with SMTP id z14mr113520096edx.40.1564668402136;
        Thu, 01 Aug 2019 07:06:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0lUsfyUNb/FoNoki3P2/kMvaW1YnizfxOwTgUfH9gzkfz3Or2g6bY9yXhziT/GplVDaQB
X-Received: by 2002:aa7:cf8e:: with SMTP id z14mr113519970edx.40.1564668401138;
        Thu, 01 Aug 2019 07:06:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564668401; cv=none;
        d=google.com; s=arc-20160816;
        b=A/HJAxj9CYfZHRTH/upnKvrZwIAQtv6yRP8QU5XUqVNdERn0bHom/Kyylb+4izFFwy
         BkPvjOTlKZtmAj4Byq8mgoUMgE9UbaAAXvkjL6hbkG0tNAMQPOVARv2mc9dL/U+dnQgu
         hDl3ehvufrwIEcd8bzX+6wayyTSf/o/6jd4ywtIr5ntuf5V3tym4lcfJ7+tslYV2eGO0
         2Rm+yaAyOZ/xaobWinZAZ/TzphAJMiW6ulPF5H97RDoXsbolIeBKeGC4r65dpr8J5hbI
         xTU9qd1vGE74/BakV35eEl8i5TVW1Mnxz7+2YTG2UkpgFtflL+UypFJHO7EA3XwWQ8I6
         0Spw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DwjmtomE8I2hqDHJ9yMU5T/xNv8OrkpuhJgP+fexi8Q=;
        b=VTnPMNk/cvgvsDtBegj1AhYdm6CK4/EiQt2FBEQKip+BUE3BtXYPtKRLeDkdDSaiN6
         Fot6a4RqrQSPKy4d4flsrddjKRVjte9/g6tt/KaxaQ3Yfi78arkzGHxLBR/QminFrJ4v
         op1aiLIvdv723Ac9YohRkWRLtS0A6Gvs8LLZ/6K2fNccSBEPTq/ytnM1K6cjcCehZGi7
         LaUhSMBJRl07EToHQX97l+f1/Ites8ba574wsW8cNDhtSEmTStWGq/RDyVBZUWYWjDse
         rRmkQCvZrLe5nJQ4/0h1IwzJK+vYfaQOiFJnLkYF/VX/LcIMpi2Qx96q1+aa5wAWdkYa
         c9IQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ha23si13209636ejb.56.2019.08.01.07.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 07:06:41 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 92EAAB6AB;
	Thu,  1 Aug 2019 14:06:40 +0000 (UTC)
Date: Thu, 1 Aug 2019 16:06:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jan Hadrava <had@kam.mff.cuni.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	wizards@kam.mff.cuni.cz, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Shakeel Butt <shakeelb@google.com>
Subject: Re: [BUG]: mm/vmscan.c: shrink_slab does not work correctly with
 memcg disabled via commandline
Message-ID: <20190801140610.GM11627@dhcp22.suse.cz>
References: <20190801134250.scbfnjewahbt5zui@kam.mff.cuni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801134250.scbfnjewahbt5zui@kam.mff.cuni.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Cc few more people

On Thu 01-08-19 15:42:50, Jan Hadrava wrote:
> There seems to be a bug in mm/vmscan.c shrink_slab function when kernel is
> compilled with CONFIG_MEMCG=y and it is then disabled at boot with commandline
> parameter cgroup_disable=memory. SLABs are then not getting shrinked if the
> system memory is consumed by userspace.

This looks similar to http://lkml.kernel.org/r/1563385526-20805-1-git-send-email-yang.shi@linux.alibaba.com
although the culprit commit has been identified to be different. Could
you try it out please? Maybe we need more fixes.

keeping the rest of the email for the reference

> This issue is present in linux-stable 4.19 and all newer lines.
>     (tested on git tags v5.3-rc2 v5.2.5 v5.1.21 v4.19.63)
> And it is no not present in 4.14.135 (v4.14.135).
> 
> Git bisect is pointing to commit:
> 	b0dedc49a2daa0f44ddc51fbf686b2ef012fccbf
> 
> Particulary the last hunk seems to be causing it:
> 
> @@ -585,13 +657,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>                         .memcg = memcg,
>                 };
> 
> -               /*
> -                * If kernel memory accounting is disabled, we ignore
> -                * SHRINKER_MEMCG_AWARE flag and call all shrinkers
> -                * passing NULL for memcg.
> -                */
> -               if (memcg_kmem_enabled() &&
> -                   !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> +               if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
>                         continue;
> 
>                 if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
> 
> Following commit aeed1d325d429ac9699c4bf62d17156d60905519
> deletes conditional continue (and so it fixes the problem). But it is creating
> similar issue few lines earlier:
> 
> @@ -644,7 +642,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>         struct shrinker *shrinker;
>         unsigned long freed = 0;
> 
> -       if (memcg && !mem_cgroup_is_root(memcg))
> +       if (!mem_cgroup_is_root(memcg))
>                 return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
> 
>         if (!down_read_trylock(&shrinker_rwsem))
> @@ -657,9 +655,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>                         .memcg = memcg,
>                 };
> 
> -               if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> -                       continue;
> -
>                 if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>                         sc.nid = 0;
> 
> 
> How was the bisection done:
> 
>  - Compile kernel with x86_64_defconfig + CONFIG_MEMCG=y
>  - Boot VM with cgroup_disable=memory and filesystem with 500k Inodes and run
>    simple script on it:
>    - Observe number of active objects of ext4_inode_cache
>      --> around 400, but anything under 1000 was accepted by the bisect script
> 
>    - Call `find / > /dev/null`
>    - Again observe number of active objects of ext4_inode_cache
>      --> around 7000, but anything over 6000 was accepted by the script
> 
>    - Consume whole memory by simple program `while(1){ malloc(1); }` until it
>      gets killed by oom-killer.
>    - Again observe number of active objects of ext4_inode_cache
>      --> around 7000, script threshold: >= 6000 --> bug is there
>      --> around 100, script threshold <= 1000 --> bug not present
> 
> Real-world appearance:
> 
> We encountered this issue after upgrading kernel from 4.9 to 4.19 on our backup
> server. (Debian Stretch userspace, upgrade to Debian Buster distribution kernel
> or custom build 4.19.60.) The server has around 12 M of used inodes and only
> 4 GB of RAM. Whenever we run the backup, memory gets quickly consumed by kernel
> SLABs (mainly ext4_inode_cache). Userspace starts receiving a lot of hits by
> oom-killer after that so the server is completly unusable until reboot.
> 
> We just removed the cgroup_disable=memory parameter on our server. Memory
> footprint of memcg is significantly smaller then it used to be in the time we
> started using this parameter. But i still think that mentioned behaviour is a
> bug and should be fixed.
> 
> By the way, it seems like the raspberrypi kernel was fighting this issue as well:
> 	https://github.com/raspberrypi/linux/issues/2829
> If I'm reading correctly: they disabled memcg via commandline due to some
> memory leaks. Month later: they hit this issue and reenabled memcg.
> 
> 
> Thanks,
> Jan

-- 
Michal Hocko
SUSE Labs

