Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B57D8C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:12:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 846A8217F4
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:12:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 846A8217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 179836B027E; Mon, 27 May 2019 11:12:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12AB56B0280; Mon, 27 May 2019 11:12:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F33136B0281; Mon, 27 May 2019 11:12:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C11476B027E
	for <linux-mm@kvack.org>; Mon, 27 May 2019 11:12:07 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id 72so8908612otv.23
        for <linux-mm@kvack.org>; Mon, 27 May 2019 08:12:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+SwoNYGdL5TJTcjSuNRdZDV3y9fIFV4dZFCT9dM/VBA=;
        b=ZGGrXWkK0H4a8pSB0hpyJ5DYWenQ+f5Ga/lc+UlgwUt/ADEpvL5i+WF+RhP8OcoFSw
         MLMqpB37N5PTNK1hagufdk0q6xJixPM6Rl8SIui+hVgPRcJzXZyx2NkHb/5IFXLfTtmG
         5/cuICopmcp8E3Lq4TJcEYKYqYDwg8JwH5ZHw/kTBywRT6cq/5G5pzifjITogZNNPeZQ
         E/GZOzF/Fm8A4n3R5OyZ9Am85QPzdVqP+UKPMEMBQFyZq8hf8GbG4CCA9u6sRTJzC9SW
         zb2YqHQnW5IRva3u9nO/x1DBXQnCpLZLxXKpGRCU2NkCXfpm0E1CaF+pWk3KhkhchfT6
         0GkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXYxB7WbW/AEPxoBz35pbADi+VtRWcdRCXVBpamEAPTZrUSW0Ys
	PBny3DRxbK4btKi7Tf0ZQaCSwzS9IEGfzakViL8fhEHUrdu8DOhHpgiW2as08rFd/dzI1Lt9fOr
	l2GySpwHOVN1OJ+pjKLan3wfJBXK6/wIBHOeq+Hn5ZeZOA2BQVil6OfSN9yIZw+3G1w==
X-Received: by 2002:aca:f002:: with SMTP id o2mr14557150oih.31.1558969927450;
        Mon, 27 May 2019 08:12:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQYi6YUmusdqvglwynmydM/bPF4laIWlMcZSRZ37siPJyDS/3SZ9BGWJug3LcF9K488+3c
X-Received: by 2002:aca:f002:: with SMTP id o2mr14557116oih.31.1558969926708;
        Mon, 27 May 2019 08:12:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558969926; cv=none;
        d=google.com; s=arc-20160816;
        b=RHsDAMEtB/wxLxDhPkBtRuCk8ydpKNZ7tYN1I+gKRm4eFzVmYP1Uv+oqg4oUsH0Lmg
         h6LxN4+EPOoIlStcfpRDeKxnkKvZHQtJQLbBoir7/IjOwGb3O2+dvlQfeEtvLHgeC5ZL
         jI0XUJqtbI/VT8h2UEKA1z2TuYYK+TJ3ztvcERgU6GOS+6pibgRjIJWWxIKysuzgH5kr
         XhF7/diG0x58H5PvtkIe6LRAc1OV4I1d2k8kSN00L3l40Za4whk7edG/yYlzGfB7+XYu
         ORkmO/G5n44c5P+m8GdjJHtch07mHC4oJsJ1tRUyMQL5+81JReMTf2yC0JYRjEYtfC/2
         rsTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+SwoNYGdL5TJTcjSuNRdZDV3y9fIFV4dZFCT9dM/VBA=;
        b=wV6ALIlJwj1zYpQIsWdiCYE6QKLWfNS1dCLuY/ZncEEu84LIrhggYZTR0C4t4mA0YF
         PYqAEHrvy4dfvrxx3nJ2+s9dun42Ao/JmJ6dfGLq15gA5aOMaaAuGHMqLFJFZJanxoJf
         VtuqeV6W7tiX5ZdMeTl/UqBip46ZEGd+lNVUTqqettBcMDzb2s5bXzNm8JQiwNrXCFgZ
         zR0QiGo+fbX2+nlacVfDay7en+Y/+AiQdXX+eDvxpeHuei4C1W8AhKZ/o/GZBHeDfA8F
         EFJYOiy0QpZ4U0ewgAyHfGTVEhrDFbEWoq0ZeD1cq2tjSLI73+sYb3nXJuNgjd0kP8nl
         WUKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q23si5877282otk.310.2019.05.27.08.12.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 08:12:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ECD117FDFA;
	Mon, 27 May 2019 15:12:05 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id 2D197608A4;
	Mon, 27 May 2019 15:12:03 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Mon, 27 May 2019 17:12:05 +0200 (CEST)
Date: Mon, 27 May 2019 17:12:02 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 5/7] mm: introduce external memory hinting API
Message-ID: <20190527151201.GB8961@redhat.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
 <20190521153113.GA2235@redhat.com>
 <20190527074300.GA6879@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527074300.GA6879@google.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 27 May 2019 15:12:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/27, Minchan Kim wrote:
>
> > another problem is that pid_task(pid) can return a zombie leader, in this case
> > mm_access() will fail while it shouldn't.
>
> I'm sorry. I didn't notice that. However, I couldn't understand your point.
> Why do you think mm_access shouldn't fail even though pid_task returns
> a zombie leader?

The leader can exit (call sys_exit(), not sys_exit_group()), this won't affect
other threads. In this case the process is still alive even if the leader thread
is zombie. That is why we have find_lock_task_mm().

Oleg.

