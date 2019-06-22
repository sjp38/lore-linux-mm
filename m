Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6184AC48BE8
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 17:51:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F217E206B7
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 17:51:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F217E206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C0A76B0003; Sat, 22 Jun 2019 13:51:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 549CC8E0002; Sat, 22 Jun 2019 13:51:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EA258E0001; Sat, 22 Jun 2019 13:51:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1783D6B0003
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 13:51:46 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c207so11416088qkb.11
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 10:51:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qbdH2leCYSMBj19HSMYtTt5L6S0BqeLKhvEfqvbE79s=;
        b=FZ79BvrmdcuNpYKu/jC8int4OMJrADCBezvyAFayllItdppsjtvcmgwT4q0KQmp0JP
         fooS5WxM4FiX/d2xzz996GizQ1jF3QewW7xxQ2WtqwEBeA66oFeGhz4Elvjg2I/szXiY
         aWCGTf3m/RtN0J+h6mWeplCtk/FNJmNGT74F0NFYSXy7uLhgEEIsZxLiuKp8ZZRjG071
         JXym5jlhP888ZpQhQb+lFqGdul4V36OUpP6SGG8rPBVI+MDGWeXpCXqgbO3zOzmhE9F0
         n+oMD3fe9tpxBcGQ5qsM3/Q9suSyTxkeS1MBcqn+Ik/9vGYZuAUFXeeQPrcBSrYHLwHz
         V0tA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWdE0hIZnzuiTokf0E/LvodjhZcilDz7pyVEKFhtzNVwlz2CuS9
	lGqGEiKmZUXSF3LRZ5prCuTpqU+r/uB41C51UmRNP60s/uAahYX/xQkJ6cBSF4/Pov3yo8EuyT7
	s1jtx9E0NOMNYKgbIiACb0tcYt9HEDSLsP6LFIXFNMP1LVrDFc91TCH0Zs+KqQ60Kag==
X-Received: by 2002:a05:620a:15c9:: with SMTP id o9mr73986398qkm.195.1561225905767;
        Sat, 22 Jun 2019 10:51:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvE7Rtr07IvvSxAPnZFkWRS7cAPTwRx+ZDCveBx8amVGuIPXlTMCuAiSwCCfY55vDMbd6h
X-Received: by 2002:a05:620a:15c9:: with SMTP id o9mr73986359qkm.195.1561225904810;
        Sat, 22 Jun 2019 10:51:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561225904; cv=none;
        d=google.com; s=arc-20160816;
        b=FRqcAHsAzu9yz9ypd3igKwBfBuAVtiGN4mtirFo618PQhxQxYvKTowFauGSAeirB7g
         CPDzu5So8d8qfgnlMXYLj74lo4iTa3wYsnan6EnI4DY2m9oL+WHQ1AXd2U6aY2BHi0Ez
         fZ+z91r1nkMCmQ/r4pg9JTbvpFcL4HpCS0REH8s/9yx5jne4NxcmFQVRkG6YEaLf2uZN
         lJefG1DNRiFY9jDO5GzK4y72ljtILYAJRPrF+I/DXyYl0Re7uHSf0gSnXUhD7X11tCL/
         wRWVQRBgjJDXLJxRL114JKttk7S/qyK02tMYnMGi80oCTopNCN4OvSqK37YDmKwNQupB
         RR1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qbdH2leCYSMBj19HSMYtTt5L6S0BqeLKhvEfqvbE79s=;
        b=ZJLDCtnc3f6TBfuv0uWKsST7n11OXRB2DCddNapof7pJCErX5jj7cP8dFN70AZf+Zp
         Qx5sGjO6kas0nYyDPigWqfQg3vvNDRQRewDlUOiLwKR8tMZQSTeM7vlFNMZ1jl96+OIj
         vKvNrWt4awkpb5o/BAO4iPbUB0RJGo24YgdYYaNXmCI9WUk1sE7JfrlbDJH6+gJPfmjh
         seHPpxol91euptYqpL5Z/mYSva4iYT5yfcmqLqaB3vsvqwEGL0KmjJNkld2H8cVkr8Y2
         OeLtkT9JvclkW5FIhqQChE0V6jkgx88TXGXnG1fEAOFeXY9Ggj2rOmU9mNmaI/uMZR9y
         WnEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e38si4138764qtc.192.2019.06.22.10.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 10:51:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BF1B981F0F;
	Sat, 22 Jun 2019 17:51:43 +0000 (UTC)
Received: from ultra.random (ovpn-125-188.rdu2.redhat.com [10.10.125.188])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 42033601A0;
	Sat, 22 Jun 2019 17:51:43 +0000 (UTC)
Date: Sat, 22 Jun 2019 13:51:42 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Borislav Petkov <bp@suse.de>,
	"Dr. David Alan Gilbert" <dgilbert@redhat.com>, kvm@vger.kernel.org
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
Message-ID: <20190622175142.GA32455@redhat.com>
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
 <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org>
 <20190522203828.GC18865@rapoport-lnx>
 <20190522141803.c6714f96f57612caaac5d19b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522141803.c6714f96f57612caaac5d19b@linux-foundation.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Sat, 22 Jun 2019 17:51:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello everyone,

On Wed, May 22, 2019 at 02:18:03PM -0700, Andrew Morton wrote:
> > arch/x86/kernel/fpu/signal.c:198:8-31:  -> gup with !pages

This simply had not to return -EFAULT if ret < nr_pages.. but ret >= 0.

Instead it did:

               if (ret == nr_pages)
                       goto retry;
               return -EFAULT;

That was the bug and the correct code would have been:

    	    ret = get_user_pages_unlocked(pages=NULL)
	    if (ret < 0)
	       return -EFAULT;
	    goto retry;

This eventually should have worked fine but it was less efficient
because it's still acting in a full prefault mode and it just tells
GUP that pages = NULL and so all it is trying to do is to issue the
blocking I/O after the mmap_sem has been released already.

Overall the solution applied in commit
b81ff1013eb8eef2934ca7e8cf53d553c1029e84 looks nicer.

Alternatively it could have used down_read(); get_user_pages(); which
prevents get_user_pages to drop the mmap_sem and break the loop if
some blocking I/O had to be executed outside mmap_sem. But that would
have the side effect of breaking userfaultfd (uffd requires
gup_locked/unlocked and FAULT_FLAG_ALLOW_RETRY to be set in the fault
flags).

Eventually we need to allow VM_FAULT_RETRY to be returned even if
FOLL_TRIED is set, so in theory get_user_pages_unlocked(pages=NULL) in
a loop must eventually stop returning VM_FAULT_RETRY. FOLL_TRIED could
still disambiguate if VM_FAULT_RETRY should or should not be returned
so that it is only returned only if it cannnot be avoided
(i.e. userfaultfd case).

With gup_unlocked(pages=NULL) however all we are interested about is
to execute the blocking I/O and we don't care to map anything in the
pagetables. A later page fault has to happen anyway for sure because
pages was == NULL, it just needs to be a fast one.

> > arch/x86/mm/mpx.c:423:11-25:  -> gup with !pages

Note that get_user_pages is never affected by whatever change after
the below, !locked check in gup_locked:

		if (!locked)
			/* VM_FAULT_RETRY couldn't trigger, bypass */
			return ret;

The bypass means when locked is NULL, there is a 1:1 bypass from
__get_user_pages<->get_user_pages and the VM_FAULT_RETRY dance never
runs.

get_user_pages in fact can't support userfaultfd, which makes ptrace
and core dump and the hwpoison non blocking in VM_FAULT_RETRY.

All places that must support userfaultfd must use
get_user_pages_unlocked/locked or somehow end up with
FAULT_FLAG_ALLOW_RETRY set in the fault flags.

> > virt/kvm/async_pf.c:90:1-22:  -> gup with !pages

Didn't this get slowed down with the commit
df17277b2a85c00f5710e33ce238ba4114687a28?

I mean it was a feature not a bug to skip that additional
__get_user_pages(FOLL_TRIED).

> > virt/kvm/kvm_main.c:1437:6-20:  -> gup with !pages

Like for mpx.c get_user_pages is agnostic to all these gup_locked
changes because it sets locked = NULL, it couldn't break the loop
early because it couldn't return VM_FAULT_RETRY.

> 
> OK.

Commit df17277b2a85c00f5710e33ce238ba4114687a28 is now applied.

So I think the effect it has is to make async_pf.c slower and we
didn't solve anything.

There are two __get_user_pages:

1)		ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
				       vmas, locked);


		if (called by get_user_pages)
		    return ret; /* bypass the whole VM_FAULT_RETRY logic */


		*locked = 1;
		lock_dropped = true;
		down_read(&mm->mmap_sem);
2)		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
				       pages, NULL, NULL);


The problem introduced is that 2) is getting executed with pages==NULL
but there's no point to ever run 2) with pages = NULL.

async_pf especially uses nr_pages == 1, so it couldn't get any more
optimal than it already was.

Before df17277b2a85c00f5710e33ce238ba4114687a28 we broke the loop as
soon as the first __get_user_pages returned VM_FAULT_RETRY.

We can argue if we shouldn't have broken the loop and we should have
kept executing only the first __get_user_pages (marked "1)" above) for
the whole range, but nr_pages == 1 is common and in such case there's
no difference between the two behaviors.

The prefetch callers with nr_pages == 1, didn't even check the retval
at all:

	down_read(&mm->mmap_sem);
	get_user_pages_remote(NULL, mm, addr, 1, FOLL_WRITE, NULL, NULL,
			&locked);                            ^^^^ pages NULL

	// retval ignored

It should probably check for retval < 0... but the fault will be
retried for good later still with get_user_pages_unlocked() but with
pages != NULL, so it'll find out later if it's a segfault.

Now if we change the code to skip the second __get_user_pages it's not
clear if we can return nr_pages because we may still not have faulted
in the whole range in the pagetables. I guess we could still return
nr_pages even if we scanned the whole range with only the first of the
two __get_user_pages. However if you had mmu notifier registered in
the range nr_pages would have stronger semantics if you would execute
2) too, but then without pages array not-NULL such stronger semantics
cannot be taken advantage of anyway, because you don't know where
those pages are and you can't map them in a secondary MMU even if you
execute the line 2).

I personally preferred the older code which should at least in theory
run faster, it just required documentation that if "pages == NULL"
we'll break the loop early because it has to be a "prefetch" attempt
and it must be retried until nr_pages == ret.

Either that or add a "continue" to skip the second __get_user_pages in
line 2) above and then returning nr_pages to indicate VM_FAULT_RETRY
may very well have been returned on all page offsets in the virtual
range. That will behave the same for async_pf.c because nr_pages == 1.

When VM_FAULT_RETRY is returned all I/O should be complete (no matter
if network or disk with userfaultfd or just pagecache readpage on
filebacked kernel faults) and only a minor fault is required to obtain
the page. But it is better to defer that second minor fault to the
point where "pages" already become != NULL, so we end up calling
__get_user_pages 2 times instead of 3 times.

Thanks,
Andrea

