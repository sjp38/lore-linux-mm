Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07D47C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 22:20:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92E4721874
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 22:20:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="wHVCvNK3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92E4721874
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FE916B0008; Thu, 29 Aug 2019 18:20:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 098306B000C; Thu, 29 Aug 2019 18:20:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E90C16B000D; Thu, 29 Aug 2019 18:20:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id C25126B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 18:20:19 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 73B1A1E06C
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 22:20:19 +0000 (UTC)
X-FDA: 75876884958.27.fifth41_1fe13e13ded32
X-HE-Tag: fifth41_1fe13e13ded32
X-Filterd-Recvd-Size: 4011
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 22:20:18 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id 26so702740pfp.9
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:20:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=GVOqYmM2Y9fBLs59pkcO9sFEhdR0n+gm/H+kyKc15XE=;
        b=wHVCvNK39KHNNY4HF3wY3NkJLZfOQdCUJiXGoeP3T/UDxPop1ECLnAFxcV0rEx8o+V
         JII5v6i7ZKHZbB05yBaZWYkEkvtpXIxCOQ9/Ngr78cCBrGPq2H9YRnlZLgd1JgeB7TzQ
         Mg/ABGmKuMRLYkfv48QYdY2hw5qmbwl+S0vr1J9xwOT8koG0uEqPixqdHtw13NjbG5BJ
         DaUulH0se+pqYeKc75oa4Nn2nZUfEypOub+1sR5ZzZAf8fLFoJFDE8gDt8ujD6W9+ucV
         6UbeWaISsva/vvH4dDm5VeQ30cP4V3iK4XVKpqdzdjq89ujQQl02u4rinAEi2ei8MXW5
         e5iQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=GVOqYmM2Y9fBLs59pkcO9sFEhdR0n+gm/H+kyKc15XE=;
        b=ZEhfa0BWSwUE9hXylwHOQnmOLOj0jTn8/A40uWgLuBofcY93LewVGKEi/0u/WmqSvo
         wBGSA+W/09iIM9ae5BUrqrIjCLxQNrimZpS8qVtqwqH9m6yNRjtJNvSZC7FxGRUtfabQ
         pAEmPsHZCFj8cVy2cbypvQFbPlvKcu3wSZLG5KEuY4AniqXPtKrYaPQPFK74u8wtxohJ
         UgVjG6zizCajTH+KMNWrYttbDhtUqjcD1qywcrKEbsjchsicXBaa6tmdrLtHZc+JgwZX
         AQwX6kJefAZ7dJeWkRteqXhh1THHCE3HhQ1OlvlyzRUvg1+NrD8lKDz804WMiiBed+af
         oOPw==
X-Gm-Message-State: APjAAAUhGyzWtHAty3qHO0OCaQSa8dJgvIrdljnoWw20nlRwci4gyNsq
	3jPeFZZKe8CX7Jc6BsIL4jpDVg==
X-Google-Smtp-Source: APXvYqxgGNtSETr5KkzHixZs4r45yt16y5jHxbUeBtQDByzuSiKUcb6Zwakv3bXp3jdYqS+grlvf1Q==
X-Received: by 2002:a17:90a:22c9:: with SMTP id s67mr12304024pjc.22.1567117217328;
        Thu, 29 Aug 2019 15:20:17 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id e189sm3157869pgc.15.2019.08.29.15.20.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Aug 2019 15:20:16 -0700 (PDT)
Date: Thu, 29 Aug 2019 15:20:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Michal Hocko <mhocko@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, 
    LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, oom: consider present pages for the node size
In-Reply-To: <20190829163443.899-1-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.21.1908291519580.54347@chino.kir.corp.google.com>
References: <20190829163443.899-1-mhocko@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Aug 2019, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> constrained_alloc calculates the size of the oom domain by using
> node_spanned_pages which is incorrect because this is the full range of
> the physical memory range that the numa node occupies rather than the
> memory that backs that range which is represented by node_present_pages.
> 
> Sparsely populated nodes (e.g. after memory hot remove or simply sparse
> due to memory layout) can have really a large difference between the
> two. This shouldn't really cause any real user observable problems
> because the oom calculates a ratio against totalpages and used memory
> cannot exceed present pages but it is confusing and wrong from code
> point of view.
> 
> Noticed-by: David Hildenbrand <david@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

