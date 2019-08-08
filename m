Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34FA6C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:47:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9EE6218FD
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:47:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9EE6218FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BF896B0003; Thu,  8 Aug 2019 03:47:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9971C6B0006; Thu,  8 Aug 2019 03:47:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D4066B0007; Thu,  8 Aug 2019 03:47:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4103B6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 03:47:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n3so57680577edr.8
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 00:47:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lXHZiRyoS7AsT86hV/qvQecLB28+VUvpO74oglK2L18=;
        b=UnSjyMHTr71wBMs9RkSG7qnnEsVE6J4AFc0qOOtg7QP+vWNPytYR1Wwl1ujcijml8d
         /DQrF0D5XjpE9YYfBhxBkZzP+aHPtFtn3AJrje38OXsgN9f2MHS8fcHvUafGrMxLybxj
         RtecR3bvZHjsNkLea8+KQ7R9YSLjKrylGqKC8Q27lJtvW6YjbbLtumwAqM5vIvnpTj+Z
         CGXK0q0Ehlu24jR7SqOUYtmoqDN79ONQKz2ygc6PcRuEZHIhWe+crE9quvmh8xxb1ct+
         3jo4X3sBlyMKMXNdg/8Y3cf2tNfM/rCsyLBjKWArvPhBET8vXK0uZiUcu66VX90W01I+
         NrdA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWi9cASC+HxMRfhvtInIYBmy1HYgRPyqGzoNKrcWoOOViEjQ38F
	FHbFrX5Bjz9/YHepkucLb34+p4FGb8dwz2JBSlU8uV5/z/9lucfd7W1PUfZGpt7VQbLy+g4wrI/
	7hsTeTwDKg6KuPo1O2vR/6zhakWvy6GaQgtZhkHsskJcsJkpT2SddLcdld66EqlE=
X-Received: by 2002:a17:906:2111:: with SMTP id 17mr11818182ejt.75.1565250457836;
        Thu, 08 Aug 2019 00:47:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGFNMeHfcjsQqEcuKjs4BC9ivWDj1KWCAqStyp47FI4WDUUkEyXpasw0O4Z6XXHTEsDXhd
X-Received: by 2002:a17:906:2111:: with SMTP id 17mr11818143ejt.75.1565250457218;
        Thu, 08 Aug 2019 00:47:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565250457; cv=none;
        d=google.com; s=arc-20160816;
        b=r3y7LjZ6U4cnx+5O5RomPu3huysEkjc+xu2+io02BytbLlnOi1rztv2axnAV635+a3
         DSI9/TGh54J7EXRTof32T4x1SoHS9cRZ+MBchgHFCbHcoMjk8P8WF5nQmVHiBK/2VjxS
         42pUV4bTN39y80pr6MAVwO6gowxsGND0kpQLcTqKU7+LIsPiaDky2mJ0yuq3B+i+4qvv
         rIyOFrR0P7H8iJfNABV+bKhslCq+pWvJ8vywGSdjSJNHiKew4VMN7HQrPwY/NxlSeqWm
         F/Y9qmrs8HLwT0mPdRYL4WHbmBoo0b9w2yOEGfUcF5H3PfIf0YetHD20wj3rgMsCeR3x
         ShZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lXHZiRyoS7AsT86hV/qvQecLB28+VUvpO74oglK2L18=;
        b=bJqueDwCua7z7fimLCLTy6jf2Z1GfX1C+cep5A8O/JZR/ibhSut27Gtc0IlEMEhgyo
         sdsnlMTg4JvBLBP2X0Rn691bdSUNkQqYmYD3QBl5uNh0w++KUPShZll96K/UQcGqDf8k
         qbY7T6ssSvvk5u4nOQ5zaPk299XcisEiQgrTFPpsTTs3+XLmyU/Mpwcajf/AGbP1lt6O
         VQq58JNbsI2BolJYnWiu9wwlRojMpDN9kXgVEPEuYO0+p6nYxCU27MmEA+TC6lGsltg0
         prjmUv60Q4KFjajGM+wBjt1gnPSmcfQVnMqZEIZ/jajc1362082zYMDO89fbXFAD4qvZ
         yBZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k24si20554603ede.54.2019.08.08.00.47.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 00:47:37 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 77326B11C;
	Thu,  8 Aug 2019 07:47:36 +0000 (UTC)
Date: Thu, 8 Aug 2019 09:47:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ltp@lists.linux.it,
	Li Wang <liwang@redhat.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Cyril Hrubis <chrubis@suse.cz>, xishi.qiuxishi@alibaba-inc.com,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race causing
 SIGBUS
Message-ID: <20190808074736.GJ11812@dhcp22.suse.cz>
References: <20190808000533.7701-1-mike.kravetz@oracle.com>
 <20190808074607.GI11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808074607.GI11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 08-08-19 09:46:07, Michal Hocko wrote:
> On Wed 07-08-19 17:05:33, Mike Kravetz wrote:
> > Li Wang discovered that LTP/move_page12 V2 sometimes triggers SIGBUS
> > in the kernel-v5.2.3 testing.  This is caused by a race between hugetlb
> > page migration and page fault.
> > 
> > If a hugetlb page can not be allocated to satisfy a page fault, the task
> > is sent SIGBUS.  This is normal hugetlbfs behavior.  A hugetlb fault
> > mutex exists to prevent two tasks from trying to instantiate the same
> > page.  This protects against the situation where there is only one
> > hugetlb page, and both tasks would try to allocate.  Without the mutex,
> > one would fail and SIGBUS even though the other fault would be successful.
> > 
> > There is a similar race between hugetlb page migration and fault.
> > Migration code will allocate a page for the target of the migration.
> > It will then unmap the original page from all page tables.  It does
> > this unmap by first clearing the pte and then writing a migration
> > entry.  The page table lock is held for the duration of this clear and
> > write operation.  However, the beginnings of the hugetlb page fault
> > code optimistically checks the pte without taking the page table lock.
> > If clear (as it can be during the migration unmap operation), a hugetlb
> > page allocation is attempted to satisfy the fault.  Note that the page
> > which will eventually satisfy this fault was already allocated by the
> > migration code.  However, the allocation within the fault path could
> > fail which would result in the task incorrectly being sent SIGBUS.
> > 
> > Ideally, we could take the hugetlb fault mutex in the migration code
> > when modifying the page tables.  However, locks must be taken in the
> > order of hugetlb fault mutex, page lock, page table lock.  This would
> > require significant rework of the migration code.  Instead, the issue
> > is addressed in the hugetlb fault code.  After failing to allocate a
> > huge page, take the page table lock and check for huge_pte_none before
> > returning an error.  This is the same check that must be made further
> > in the code even if page allocation is successful.
> > 
> > Reported-by: Li Wang <liwang@redhat.com>
> > Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
> > Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> > Tested-by: Li Wang <liwang@redhat.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Btw. is this worth marking for stable? I haven't seen it triggering
anywhere but artificial tests. On the other hand the patch is quite
straightforward so it shouldn't hurt in general.
-- 
Michal Hocko
SUSE Labs

