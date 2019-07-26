Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA1CBC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:46:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88857217D4
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:46:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88857217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DD9E6B0003; Fri, 26 Jul 2019 03:46:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38D706B0006; Fri, 26 Jul 2019 03:46:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A4428E0002; Fri, 26 Jul 2019 03:46:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D28016B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:45:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20so33625248edr.15
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 00:45:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=00mjn142mbtfOlG1behugmBK394IadtZdo+QjJ10HIQ=;
        b=QGZuYsgeDhBLnnQk1c6eX5nPVoXw5x2D+3Vo4a1ykgMIi9jUQWib0yMBTPNGdH0enP
         msm2m+vEIsfuwNT5+oUbB+3irlfFWBuoBiHDR4msBKOYRpdBqLXBM6l0dVB4L5LsVLY1
         Ke/CVoi3uhHVOD6+qzcUECmJ7gljVS9E5GjRku1ww2V/g/QEQQko902IiJxuDxSYbwys
         VKlVRv2gghJUamHiibuXRJ9PaRhBtY+VUOxOIduISuVEwJdpMJWYw8bFoAE2nTh+k5gn
         eqRcwAXq9117SmdpahXozjLEj2xUrZYGY++2eUUmgcEqLOBpTL/H1JYtbNWVdqsQhzLD
         i1mw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW4FKBCh0C8YxJ1XwLBoRcimoQVRWbppCxDJOCsPx+Ar5apEvcg
	PWVXHQpdDsXf8xMBBphH3rcqMAQCvfwELfSbZFV7W+BdOVxdCL1PrcOO56BuSrNA6d24Hzjv67F
	L3uK071br5mNIpyn4NXfcPTkpJrALxxT8QCEP1ttT8gW/EOUO+rUXZ00fwh0pdKk=
X-Received: by 2002:a50:acc6:: with SMTP id x64mr83003721edc.100.1564127159416;
        Fri, 26 Jul 2019 00:45:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyw6x1SrYUfKIZYka2dpEapvCNrImIirVI21lxgnhGIJXjzzdSIF6wLXP+iPNY/WfNc5EM
X-Received: by 2002:a50:acc6:: with SMTP id x64mr83003687edc.100.1564127158746;
        Fri, 26 Jul 2019 00:45:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564127158; cv=none;
        d=google.com; s=arc-20160816;
        b=rIqaVZrQ1kVr/2PwB/qIdNYxtFA1SBHccdiac7rQDqaNCMfgs0sTr7M/qwG/juK3ht
         rQnCXBZ+fBE0MFJIL5Dz9EOnUOnhre+HubqFVcw6uUIjnEX+cqo6zUfcafQraSAij1bs
         wWGeUPAJLDon/wLuslGdr4Y+je/3D0VXZzmv1zv3DsF7/fY/j0TwUy6J2EPXkz9Jvmg3
         JfVcYc4p+nBwJCPEQrjgciWB6C6kivr6qrdAccUzuHuZBUjjjAHcsy/dt2oaHWetMQs8
         aTjzFyU5nkvns1a8YcMlHE05wITyPamHnRxue/JZ5U4eukWVuePmuZODWeiAIjn1mjmn
         kbnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=00mjn142mbtfOlG1behugmBK394IadtZdo+QjJ10HIQ=;
        b=EyJzAWAXJNQUqsMTUMjzzqVueH+dKcFC7+V9iJQ7AudcTHpEUUz7dvIXISysr6v0Lu
         cIgy3LkjCYxkVPDzRVcn+QiRFq/Z0XcS3bv5GDDk+eTyDpH2MOUnBKaW8aiOVQC8OQ05
         J0z6Ve0+UNzx00TRdc+GqE49Fyulrtm15DLNXEtSebSOIcy4jdxkGGC9ldQZKL82mO5w
         hAdS8Hg0eURHO94q9RVg5VJ2oLvYo62gsBOixVxVY3s4bDzdONy4rEzKRnr7upHYZ131
         hCPvojr0aJNBnMkdjBp9usIARrbtxQLLBzAQAGL/ry/yQkYD0nNNCr1EVtWJ2zBOHs6I
         TwOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rv6si11283056ejb.320.2019.07.26.00.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 00:45:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DD504AD18;
	Fri, 26 Jul 2019 07:45:57 +0000 (UTC)
Date: Fri, 26 Jul 2019 09:45:57 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
	Daniel Aberger - Profihost AG <d.aberger@profihost.ag>,
	p.kramme@profihost.ag
Subject: Re: No memory reclaim while reaching MemoryHigh
Message-ID: <20190726074557.GF6142@dhcp22.suse.cz>
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
 <20190725140117.GC3582@dhcp22.suse.cz>
 <028ff462-b547-b9a5-bdb0-e0de3a884afd@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <028ff462-b547-b9a5-bdb0-e0de3a884afd@profihost.ag>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-07-19 23:37:14, Stefan Priebe - Profihost AG wrote:
> Hi Michal,
> 
> Am 25.07.19 um 16:01 schrieb Michal Hocko:
> > On Thu 25-07-19 15:17:17, Stefan Priebe - Profihost AG wrote:
> >> Hello all,
> >>
> >> i hope i added the right list and people - if i missed someone i would
> >> be happy to know.
> >>
> >> While using kernel 4.19.55 and cgroupv2 i set a MemoryHigh value for a
> >> varnish service.
> >>
> >> It happens that the varnish.service cgroup reaches it's MemoryHigh value
> >> and stops working due to throttling.
> > 
> > What do you mean by "stops working"? Does it mean that the process is
> > stuck in the kernel doing the reclaim? /proc/<pid>/stack would tell you
> > what the kernel executing for the process.
> 
> The service no longer responses to HTTP requests.
> 
> stack switches in this case between:
> [<0>] io_schedule+0x12/0x40
> [<0>] __lock_page_or_retry+0x1e7/0x4e0
> [<0>] filemap_fault+0x42f/0x830
> [<0>] __xfs_filemap_fault.constprop.11+0x49/0x120
> [<0>] __do_fault+0x57/0x108
> [<0>] __handle_mm_fault+0x949/0xef0
> [<0>] handle_mm_fault+0xfc/0x1f0
> [<0>] __do_page_fault+0x24a/0x450
> [<0>] do_page_fault+0x32/0x110
> [<0>] async_page_fault+0x1e/0x30
> [<0>] 0xffffffffffffffff
> 
> and
> 
> [<0>] poll_schedule_timeout.constprop.13+0x42/0x70
> [<0>] do_sys_poll+0x51e/0x5f0
> [<0>] __x64_sys_poll+0xe7/0x130
> [<0>] do_syscall_64+0x5b/0x170
> [<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [<0>] 0xffffffffffffffff

Neither of the two seem to be memcg related. Have you tried to get
several snapshots and see if the backtrace is stable? strace would also
tell you whether your application is stuck in a single syscall or they
are just progressing very slowly (-ttt parameter should give you timing)
-- 
Michal Hocko
SUSE Labs

