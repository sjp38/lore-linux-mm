Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF526B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:58:01 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id r10-v6so8588212itc.2
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 02:58:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m23-v6si1160616jal.40.2018.07.20.02.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 02:58:00 -0700 (PDT)
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
 <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com>
 <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <9ab77cc7-2167-0659-a2ad-9cec3b9440e9@i-love.sakura.ne.jp>
Date: Fri, 20 Jul 2018 18:57:44 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/07/20 17:41, David Rientjes wrote:
> Absent oom_lock serialization, this is exactly working as intended.  You 
> could argue that once the thread has reached exit_mmap() and begins oom 
> reaping that it should be allowed to finish before the oom reaper declares 
> MMF_OOM_SKIP.  That could certainly be helpful, I simply haven't 
> encountered a usecase where it were needed.  Or, we could restart the oom 
> expiration when MMF_UNSTABLE is set and deem that progress is being made 
> so it give it some extra time.  In practice, again, we haven't seen this 
> needed.  But either of those are very easy to add in as well.  Which would 
> you prefer?

I don't think we need to introduce user-visible knob interface (even if it is in
debugfs), for I think that my approach can solve your problem. Please try OOM lockup
(CVE-2016-10723) mitigation patch ( https://marc.info/?l=linux-mm&m=153112243424285&w=4 )
and my cleanup patch ( [PATCH 1/2] at https://marc.info/?l=linux-mm&m=153119509215026&w=4 )
on top of linux.git . And please reply how was the result, for I'm currently asking
Roman whether we can apply these patches before applying the cgroup-aware OOM killer.
