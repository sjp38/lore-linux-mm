Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BF85C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 00:16:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFC8420811
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 00:16:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFC8420811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 238846B0003; Tue, 26 Mar 2019 20:16:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E67D6B0006; Tue, 26 Mar 2019 20:16:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B12B6B0007; Tue, 26 Mar 2019 20:16:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D21B86B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 20:16:22 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id i3so15295371qtc.7
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 17:16:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bqMUVcRV9eUYPPFSKYrO9HQjwlEDm3fJqcn80u5OoSE=;
        b=s6VPe8Dv2bYPYGzpwBslvLgAaZcs1WcShEjWewLnzqg9yr86x5fH5G+mzJPMJBEiXp
         EL6lIqDQzow56ohUkG3CfB+Wv8seqWiCOWsg9flFFImjqWgqHidAtmhjb3pkF8ft/tYt
         adcdJbPwKRFieMjqwJAnXbue2tMSayCt7l3jF93qvaAb9J9nlIZ2cNwXsXvc5kX4Gyd2
         XQeZJ1WSofXlmh+hiFzEba0z96rzIhPWPFtLnrCt8yOcSg7RbpWvxxYDiPv6jAGwvUFa
         r42/pHbMRTIBxhuks4f5fCFEmBuGwZlzmIRukkjxM97YYcx9iqnTGpHszJ8NKq8ODUlA
         1OXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWddB9wvo+5SfMLaySGUM3DrnLiBoH1+7FcCi2/dB6SlCU4mG83
	wmASUcmgptvnHo9aDuVI9rYYQPLHOY2P1kFDik4Q2Mq7wluoFd3iMFbVdZFAlMbyyrlDSVpo6sY
	x7KkDL+jCSA6iK2hcYpZxmnBQmOKKxZLphBIFH8mi0PmpeIU2IlvTA9+GjmqhMf4sjQ==
X-Received: by 2002:ac8:25b5:: with SMTP id e50mr29569663qte.186.1553645782543;
        Tue, 26 Mar 2019 17:16:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGn9+XCWJZSxC8vUGTlkSRwjzgjxeT4/xWnXXa/1HQ1jjrtvzhWyiO6GYEb6HDOQUwSyxA
X-Received: by 2002:ac8:25b5:: with SMTP id e50mr29569606qte.186.1553645781538;
        Tue, 26 Mar 2019 17:16:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553645781; cv=none;
        d=google.com; s=arc-20160816;
        b=xHP0rNOv96zJvPzJJfUyU20Zu33WwsobmSkgSVhRPUi7GtlpC12eJmATtrdQ1A0WeT
         WxHd7d3nTed3wktt7JacDupCSI0eRyUx9pgnGb5fflPZmqAMOwCC0YVu0QXWQUtaxLuV
         h7kxNshM6axUTGf0Rn6qHmbUWTgKpmhPxErih6as/GmGVDb/t3lL8LKJ8k8u8QoQUP7B
         uIxPzx96HyfSSpiArrCJDzF7YVHAiLzMa9i5OXyCgoL4gZJQk429HhW9hpqR8095uoTQ
         8k8u7JE4tSahLei52VjNs+nm2BM/dFIsSO/kLwG62L3P41by2uipuY+GfrI8QGV7GmZf
         c0xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bqMUVcRV9eUYPPFSKYrO9HQjwlEDm3fJqcn80u5OoSE=;
        b=jVTjtvwUDNB0gg8dXJbmGLVu4yO9fKMN2yrnNHX8cZYC5UJYHRNWp/suAqHmVSWEfX
         R+laRwEeeCUTL664FkgDfrwoFT0jQmj2g65UELIIscgYNd6QoS6z9A9RsLPvlTX40ExV
         9NNY3o7C8eRySO8sZMciHp6yvAcma0OYZDJNz86iHOXuahcvnvvslZm6jZZzmabInGmC
         KQ1glj4nnqyUsMlm5cE7l+eVmB6xpfyjW3jGDIFIgBiaVb2ZC5NKcQZuSqR8GljT3ubG
         o5tlqr3eyP5Iba1O/aOZJ0RUq/nhsdQInN0XD7kVgaaD/A+xfZ0HGR0sANPLGEfq+mP4
         VvCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 10si3082100qtv.118.2019.03.26.17.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 17:16:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5788358E42;
	Wed, 27 Mar 2019 00:16:20 +0000 (UTC)
Received: from sky.random (ovpn-120-118.rdu2.redhat.com [10.10.120.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8A23F6085B;
	Wed, 27 Mar 2019 00:16:17 +0000 (UTC)
Date: Tue, 26 Mar 2019 20:16:16 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	zhong jiang <zhongjiang@huawei.com>,
	syzkaller-bugs@googlegroups.com,
	syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Peter Xu <peterx@redhat.com>, Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH 1/2] userfaultfd: use RCU to free the task struct when
 fork fails
Message-ID: <20190327001616.GB15679@redhat.com>
References: <20190325225636.11635-1-aarcange@redhat.com>
 <20190325225636.11635-2-aarcange@redhat.com>
 <20190326085643.GG28406@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326085643.GG28406@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 27 Mar 2019 00:16:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 09:56:43AM +0100, Michal Hocko wrote:
> On Mon 25-03-19 18:56:35, Andrea Arcangeli wrote:
> > MEMCG depends on the task structure not to be freed under
> > rcu_read_lock() in get_mem_cgroup_from_mm() after it dereferences
> > mm->owner.
> 
> Please state the actual problem. Your cover letter mentiones a race
> condition. Please make it explicit in the changelog.

The actual problem is the task structure is freed while
get_mem_cgroup_from_mm() holds rcu_read_lock() and dereferences
mm->owner.

I thought the breakage of RCU is pretty clear, but we could add a
description of the race like I did in the original thread:

https://lkml.kernel.org/r/000000000000601367057a095de4@google.com
https://lkml.kernel.org/r/20190316194222.GA29767@redhat.com

> > An alternate possible fix would be to defer the delivery of the
> > userfaultfd contexts to the monitor until after fork() is guaranteed
> > to succeed. Such a change would require more changes because it would
> > create a strict ordering dependency where the uffd methods would need
> > to be called beyond the last potentially failing branch in order to be
> > safe.
> 
> How much more changes are we talking about? Because ...

I haven't implemented but I can theorize. It should require a new
hooking point and information being accumulated in RAM and passed from
the current hooking point to the new hooking point and to hold off the
delivery of such information to the uffd monitor (the fd reader),
until the new hooking point is invoked. The new hooking point would
need to be invoked after fork cannot fail anymore.

We already accumulate some information in RAM there, but the first
delivery happens at a point where fork can still fail.

> > This solution as opposed only adds the dependency to common code
> > to set mm->owner to NULL and to free the task struct that was pointed
> > by mm->owner with RCU, if fork ends up failing. The userfaultfd
> > methods can still be called anywhere during the fork runtime and the
> > monitor will keep discarding orphaned "mm" coming from failed forks in
> > userland.
> 
> ... this is adding a subtle hack that might break in the future because
> copy_process error paths are far from trivial and quite error prone
> IMHO. I am not opposed to the patch in principle but I would really like
> to see what kind of solutions we are comparing here.

The rule of clearing mm->owner and then freeing the mm->owner memory
with call_rcu is already followed everywhere else. See for example
mm_update_next_owner() that sets mm->owner to NULL and only then
invokes put_task_struct which frees the memory pointed by the old
value of mm->owner using RCU.

The "subtle hack" already happens at every exit when MEMCG=y. All the
patch does is to extend the "subtle hack" to the fork failure path too
which it didn't follow the rule and it didn't clear mm->owner and it
just freed the task struct without waiting for a RCU grace period. In
fact like pointed out by Kirill Tkhai we could reuse
delayed_put_task_struct method that is already used by exit, except it
does more than freeing the task structure and it relies on refcounters
to be initialized so I thought the free_task -> call_rcu( free_task)
conversion was simpler and more obviously safe. Sharing the other
method only looked a complication that requires syncing up the
refcounts.

I think the only conceptual simplification possible would be again to
add a new hooking point and more buildup of information until fork
cannot fail, but in implementation terms I doubt the fix will become
smaller or simpler that way.

> > This race condition couldn't trigger if CONFIG_MEMCG was set =n at
> > build time.
> 
> All the CONFIG_MEMCG is just ugly as hell. Can we reduce that please?
> E.g. use if (IS_ENABLED(CONFIG_MEMCG)) where appropriate?

There's just one place where I could use that instead of #ifdef.

> > +static __always_inline void mm_clear_owner(struct mm_struct *mm,
> > +					   struct task_struct *p)
> > +{
> > +#ifdef CONFIG_MEMCG
> > +	if (mm->owner == p)
> > +		WRITE_ONCE(mm->owner, NULL);
> > +#endif
> 
> How can we ever hit this warning and what does that mean?

Which warning?

