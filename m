Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 896E6C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 10:47:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 304C92177B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 10:47:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 304C92177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F94B6B0003; Tue, 23 Apr 2019 06:47:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 883A26B0006; Tue, 23 Apr 2019 06:47:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74E116B0007; Tue, 23 Apr 2019 06:47:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 232776B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 06:47:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id j3so7739421edb.14
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 03:47:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I7wK+U4okHW9rsvcyKmYk5H6L/Mmu/w6eyeKgP3ZLYU=;
        b=LmyN785aqdd8fiQZ4QhkR6yUh+SbFrhrBrn1kNUCH5soDNBjtLaZfAfyOOWhHjHxEw
         KnMNNzREXvMmc/7HWWHIE3+QJSq5FzcOdA4rnSem/YR+z+5YSWOBsuj1sqT9T53uKhw8
         oNkZO7kC9Rq7b029CMEUXaUE5DGXnUfgf6mVoyEpU8E93Ksba6861chSQel6DHocMsEj
         JmIOmnf7Sh7XogCwhVK3R2YoTOJ77Stt7/0VYt8TdBClr4wXWr3XvfyzgeDaRGFdZqoV
         Mpxr/Ir741nQqgUnKfyb51RCnRL8Z/KDdg+r9ti4HlAuNg8QS8W9kYwi4JNLSUqNTNrs
         2Ncw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW3Rgky+mf3ij3xMLiltj59PSnTqIYySgWIqRNTxfF3BSyntNAE
	tLtiGy2gW07hvIRoYmoW6nFSXsy5xWhkJHyNaB5freFvvyZJUSn7FPJWMB/efkzboyogGHhHHsd
	hxkbdMugRlBSKBvRMIksQ3SMMJyyVzNoCu5EOQgAdD2ZCsYATWLeNq+lNHMSGgow=
X-Received: by 2002:a50:a567:: with SMTP id z36mr15867492edb.43.1556016431605;
        Tue, 23 Apr 2019 03:47:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7LuNCQaJKHa+U5+PSZdTV/dP96Js+lfMrJG75LLUib4+t8R/xIjURMbyzC2MzeLQvheNg
X-Received: by 2002:a50:a567:: with SMTP id z36mr15867439edb.43.1556016430534;
        Tue, 23 Apr 2019 03:47:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556016430; cv=none;
        d=google.com; s=arc-20160816;
        b=cbXHEmhXpeeKw1Kx5wc38qcuRycbpL56bpLvPGVnKJKPxt11G6hGDwemfSjMIy+/aE
         4rmuZsI7gDbxkIDe1HwLJ9OTtaU9novF+0ftUTt6KAK+TCPEm+HTGtgRsvYOtAbWK0g9
         smHPBq616S6Ty3elizE0oVXbvmJ1Ven2i/asCg/smRyAup3ddHGD1aaW6hxE+cBaVEhc
         G9QnPSjk0bAPNWXoaMCYaAwtZpIGLb584QPvgGtJh3tgNFg8FtO/kztyqjF73QGf+MsS
         DKQfaogsItp0ItQftfNtnHSohmb/CzM3XiFeMIsrGiY6XuOyt2FUMrLeuYr5U3/cx/Xc
         Xi0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I7wK+U4okHW9rsvcyKmYk5H6L/Mmu/w6eyeKgP3ZLYU=;
        b=CLrpdXS3p1mvZxxKSdy5hVRMOOZqAJt6eU+rB6guxcyPIsxufCZn0F14XIDCA9sKD8
         lY/QGLfAq1t1Gcq5YUnELRjEc+rOnmWOD+6JwiyYg/ePnLo5aACmyehhiO9wxAwRaqzE
         906FIqN7Nfqpsy7iliJGuu7W/oWw5spYDftugPlxbpKt3KVRuLrMNZaJnC9gIOR94jcX
         +5yLrUM0qzI829gu73JrmILN0BHMZ8QGI05ceLRgZoV1SowzdAbvNDmm7D8W1OhzZzJQ
         Gduq96thoVzW5ZeqHW7KbB4KbV0AGCQSpjgk5ywYmf8trNBPFvO7TTu2z6RoblBcx7Ew
         vkLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w56si4658403edb.133.2019.04.23.03.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 03:47:10 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5E467AF1C;
	Tue, 23 Apr 2019 10:47:09 +0000 (UTC)
Date: Tue, 23 Apr 2019 12:47:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Michel Lespinasse <walken@google.com>
Cc: Laurent Dufour <ldufour@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Andi Kleen <ak@linux.intel.com>, dave@stgolabs.net,
	Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	mpe@ellerman.id.au, Paul Mackerras <paulus@samba.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Mike Rapoport <rppt@linux.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	haren@linux.vnet.ibm.com, Nick Piggin <npiggin@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 00/31] Speculative page faults
Message-ID: <20190423104707.GK25106@dhcp22.suse.cz>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 22-04-19 14:29:16, Michel Lespinasse wrote:
[...]
> I want to add a note about mmap_sem. In the past there has been
> discussions about replacing it with an interval lock, but these never
> went anywhere because, mostly, of the fact that such mechanisms were
> too expensive to use in the page fault path. I think adding the spf
> mechanism would invite us to revisit this issue - interval locks may
> be a great way to avoid blocking between unrelated mmap_sem writers
> (for example, do not delay stack creation for new threads while a
> large mmap or munmap may be going on), and probably also to handle
> mmap_sem readers that can't easily use the spf mechanism (for example,
> gup callers which make use of the returned vmas). But again that is a
> separate topic to explore which doesn't have to get resolved before
> spf goes in.

Well, I believe we should _really_ re-evaluate the range locking sooner
rather than later. Why? Because it looks like the most straightforward
approach to the mmap_sem contention for most usecases I have heard of
(mostly a mm{unm}ap, mremap standing in the way of page faults).
On a plus side it also makes us think about the current mmap (ab)users
which should lead to an overall code improvements and maintainability.

SPF sounds like a good idea but it is a really big and intrusive surgery
to the #PF path. And more importantly without any real world usecase
numbers which would justify this. That being said I am not opposed to
this change I just think it is a large hammer while we haven't seen
attempts to tackle problems in a simpler way.

-- 
Michal Hocko
SUSE Labs

