Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD652C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 02:21:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F13B2064A
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 02:21:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Z0cwZYY6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F13B2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEF4A8E0003; Tue, 30 Jul 2019 22:21:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9FBE8E0001; Tue, 30 Jul 2019 22:21:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB5EE8E0003; Tue, 30 Jul 2019 22:21:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 943708E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 22:21:24 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a21so34947855pgv.0
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 19:21:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=wfO9r2YHzfXnuX5Kr+rPkjXbDXK210fTn6hrztawxZ0=;
        b=CLwMXmYPWP/36zcrLmNTPd86BbEZI+caH9do/zsgWC+O4Jva+0fjINHldCCYNR+AtK
         Eil53TXXS2sFkA08M3pIN114Vo0RocnDWk4s6fFNXx5iD0UZUayTV63sGR/nVeSpZ/b6
         b6/pNR0Xe6uEFrzxFQg/jQ1rby3F9xQzOb5iq3dwKXE9KBd7CS7pDeF0YV5v5APaCZ8Y
         eOOrSD/+neDYR+TZdWhrMu/VDoeWy1mv4nqlLUmg3lEMo1Wog/kviBQwzVbjQdX8xO8C
         mIwAkZXNQ+S1a2V9b9lwK67fAP2ewRfmI73bMxMwVSt7uLJ8JAgXXeSLuf3o250hhrsM
         uzzg==
X-Gm-Message-State: APjAAAWNq7as9Z3N7g91R+3q36Js/M0pYDlF3YuqD+rmb/oidmE8Epzr
	lreuqTDGr6FW/IzE4e5zzFnXwHcuve649zJRq55sAGJOYyMfYDuN4R9u3v+fse92wdnBLp0rTCm
	2elbzQnY2n5D+X5NvITLhLqnzRhIIMj81XxT6IqDCzfoMYGhoLXSWsUKYmwpwFoGNZQ==
X-Received: by 2002:a62:87c8:: with SMTP id i191mr44968500pfe.133.1564539684236;
        Tue, 30 Jul 2019 19:21:24 -0700 (PDT)
X-Received: by 2002:a62:87c8:: with SMTP id i191mr44968455pfe.133.1564539683434;
        Tue, 30 Jul 2019 19:21:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564539683; cv=none;
        d=google.com; s=arc-20160816;
        b=hy5K5tIMWWl0o4PZLjdbHF1mBbf4H1GxzmQaIeYq/yMHXhxcYPH40t0XFjrsQx3h6H
         OrvTGKQjwjSxwHqHUy/EAt8nBRISuMzWrSM8kkdeQcEGtuWEgtF+Ay+JxgXwORuEntP2
         aVB9YtkQpRB6KrMM/esWzCigPgm2Ye9Vh4LXq3UiA+ybTJPtNoctd6yG1sL0kI17E6eH
         PRODyiHzCIOV2kMzprfavA9a6ZDjzUHy3NSspF6zLsr68OI/q5Y2AYJ8aVdBHMxVrFwb
         mQHGjh9PiG6DpqirMe9SiQRbyqrg/17VU2iLXz6y+zDqn5HKy5nLT2LPkHWlU0OqNcBt
         MpHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=wfO9r2YHzfXnuX5Kr+rPkjXbDXK210fTn6hrztawxZ0=;
        b=fksn4UZAlnf2SsNCbQcRPv3kYt7FqDlIKlyxi4L9Oxqx1kpbeOtKGy4rp8AVvGc76f
         vuT9+Ifri/zGsHdnmjwqsSwnCyWBKQ/ruVI12cWUbiuIN2PGX/Ogqq8G69DP0OA0Z6d4
         XECEX5/02n+otQlOHiuHBPbL9KuEvfh7pdm+NArUajZbVE8bY5asZvXap7kgIQApggnO
         5Ellc015Y6c5Dzzkz/4/dglWDBQNbPwGS/gFwkeqQWpdEC9qz/8cZQpLxCyzltBSjNze
         Fr+BlVCJLlWoXS0pLEgiGK1YwEykL/+/4i7qC3W+zhrsZ4wpOGrjloIhwefonDX+JuP5
         kIlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Z0cwZYY6;
       spf=pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmica.g@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h6sor16558047pfe.41.2019.07.30.19.21.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 19:21:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Z0cwZYY6;
       spf=pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmica.g@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=wfO9r2YHzfXnuX5Kr+rPkjXbDXK210fTn6hrztawxZ0=;
        b=Z0cwZYY6NB9z3AeRFZ5F9ivrbekqwqA754MYg0lxZjoYmmBYsJ/Bl5wHSjCKN2LKBb
         RiVb5ZqBigEi4yXwuIOEc+nJm9XYTqh9pkF3ES4VOLOnLst2nENuMZ5bG6Gbp4kPWl+X
         o4vpIC701znWr7RpZaoEqbr+/iYRHbkWllXL4o2GCx4fis/KCQhsrL0vYoZ88J5Amasj
         iNC5H8rZr6XTCcyOtcWZGOYJ5RxHa4DpWz9b98qFzLk7iUJODCPdexNE2tz+I6fQfbhv
         ZQ7hTkO3HvNNx1onQLjN+IFoG63qcYI0uegXN2aKkbVSDUnES9G0m5qhEHNx+/x5H/1A
         Rntw==
X-Google-Smtp-Source: APXvYqxyqpyYZY8qY7B1CMLxmEvGtOzFCCg6NIwd49Af1HowMQkaHr7BFniHgWBtLUGq47Ht38tPyw==
X-Received: by 2002:a62:14c4:: with SMTP id 187mr43672529pfu.241.1564539683105;
        Tue, 30 Jul 2019 19:21:23 -0700 (PDT)
Received: from rashmica.ozlabs.ibm.com ([122.99.82.10])
        by smtp.googlemail.com with ESMTPSA id e11sm79504488pfm.35.2019.07.30.19.21.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 19:21:22 -0700 (PDT)
Message-ID: <7c49e493510ce04371d8d6cd6c436c347b1f8469.camel@gmail.com>
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
From: Rashmica Gupta <rashmica.g@gmail.com>
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, 
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com, 
	anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Wed, 31 Jul 2019 12:21:16 +1000
In-Reply-To: <b3fd1177-45ef-fd9e-78c8-d05138c647da@redhat.com>
References: <20190625075227.15193-1-osalvador@suse.de>
	 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
	 <20190626080249.GA30863@linux>
	 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
	 <20190626081516.GC30863@linux>
	 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
	 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
	 <0cd2c142-66ba-5b6d-bc9d-fe68c1c65c77@redhat.com>
	 <b7de7d9d84e9dd47358a254d36f6a24dd48da963.camel@gmail.com>
	 <b3fd1177-45ef-fd9e-78c8-d05138c647da@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-07-29 at 10:06 +0200, David Hildenbrand wrote:
> > > Of course, other interfaces might make sense.
> > > 
> > > You can then start using these memory blocks and hinder them from
> > > getting onlined (as a safety net) via memory notifiers.
> > > 
> > > That would at least avoid you having to call
> > > add_memory/remove_memory/offline_pages/device_online/modifying
> > > memblock
> > > states manually.
> > 
> > I see what you're saying and that definitely sounds safer.
> > 
> > We would still need to call remove_memory and add_memory from
> > memtrace
> > as
> > just offlining memory doesn't remove it from the linear page tables
> > (if 
> > it's still in the page tables then hardware can prefetch it and if
> > hardware tracing is using it then the box checkstops).
> 
> That prefetching part is interesting (and nasty as well). If we could
> at
> least get rid of the manual onlining/offlining, I would be able to
> sleep
> better at night ;) One step at a time.
> 

What are your thoughts on adding remove to state_store in
drivers/base/memory.c? And an accompanying add? So then userspace could
do "echo remove > memory34/state"? 

Then most of the memtrace code could be moved to a userspace tool. The
only bit that we would need to keep in the kernel is setting up debugfs
files in memtrace_init_debugfs.



