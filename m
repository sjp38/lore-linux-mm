Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EAADC6B000D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 20:55:32 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j189-v6so2014433oih.11
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 17:55:32 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b1-v6si22134941oih.394.2018.07.16.17.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 17:55:31 -0700 (PDT)
Message-Id: <201807170055.w6H0tHn5075670@www262.sakura.ne.jp>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 17 Jul 2018 09:55:17 +0900
References: <0d018c7e-a3de-a23a-3996-bed8b28b1e4a@i-love.sakura.ne.jp> <20180716220918.GA3898@castle.DHCP.thefacebook.com>
In-Reply-To: <20180716220918.GA3898@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Roman Gushchin wrote:
> On Tue, Jul 17, 2018 at 06:13:47AM +0900, Tetsuo Handa wrote:
> > No response from Roman and David...
> > 
> > Andrew, will you once drop Roman's cgroup-aware OOM killer and David's patches?
> > Roman's series has a bug which I mentioned and which can be avoided by my patch.
> > David's patch is using MMF_UNSTABLE incorrectly such that it might start selecting
> > next OOM victim without trying to reclaim any memory.
> > 
> > Since they are not responding to my mail, I suggest once dropping from linux-next.
> 
> I was in cc, and didn't thought that you're expecting something from me.

Oops. I was waiting for your response. ;-)

  But Roman, my patch conflicts with your "mm, oom: cgroup-aware OOM killer" patch
  in linux-next. And it seems to me that your patch contains a bug which leads to
  premature memory allocation failure explained below.

  Can we apply my patch prior to your "mm, oom: cgroup-aware OOM killer" patch
  (which eliminates "delay" and "out:" from your patch) so that people can easily
  backport my patch? Or, do you want to apply a fix (which eliminates "delay" and
  "out:" from linux-next) prior to my patch?

> 
> I don't get, why it's necessary to drop the cgroup oom killer to merge your fix?
> I'm happy to help with rebasing and everything else.

Yes, I wish you rebase your series on top of OOM lockup (CVE-2016-10723) mitigation
patch ( https://marc.info/?l=linux-mm&m=153112243424285&w=4 ). It is a trivial change
and easy to cleanly backport (if applied before your series).

Also, I expect you to check whether my cleanup patch which removes "abort" path
( [PATCH 1/2] at https://marc.info/?l=linux-mm&m=153119509215026&w=4 ) helps
simplifying your series. I don't know detailed behavior of your series, but I
assume that your series do not kill threads which current thread should not wait
for MMF_OOM_SKIP.
