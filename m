Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EA22C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 18:49:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CD13204FD
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 18:49:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CD13204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F86D8E0004; Fri,  1 Mar 2019 13:49:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A7B88E0001; Fri,  1 Mar 2019 13:49:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 449CF8E0004; Fri,  1 Mar 2019 13:49:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DBC8B8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 13:49:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u25so10503843edd.15
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 10:49:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yT1o5MX6eOQPohVNnv59ywBZtM90ajDwX9lBtJ3oZig=;
        b=M98EJE3+4Cx+nepqAdeGLJHbNszFnLD82KZVBf50xkLNRUj5LcfxXijQRQVbxsaz5d
         X2BgGxj44zWT/sUL5ZSscxnJ/rqpp0q62bpTfnwPTcbg32bNIp1VruPoVuT9sfKR5up4
         S1uowoNbJkB2KFaoxKFAdJkHh4fxgb024b3jA6wWgDVKiWI/h0YgFupYCCMWpbba4ZHu
         +t0KGp2iYxSFD1vaFjv0A1DBbxwY+2aHMzAqyBOg9WLmugP1BDfjW6wip+KkfBfM79l2
         RQaUXmEFyMtKbln8RCYXN0dkaN8MxrQc6oz3gDvz9Wnn7n/Io0tRrTI5nyRUzD9Jgg7o
         R2zg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAXb7tnLiQwAlBMhVV7qh06T0jzdkZWVQJctayLzp5KhCKfYW6Gl
	BKyVNaWOFvqnp0ukX2vjPO+/+I6HQemxxMPONlPWlwFcntkN33lyOBAykfbtO9xUcW7cYI/D11N
	tvcBWhvdMOPCZADXtdKeg6Wm1/NicLWcEJvLOVz+RqZWMDs+AziCss9bo4Efw8Mk=
X-Received: by 2002:aa7:d396:: with SMTP id x22mr5319893edq.182.1551466179365;
        Fri, 01 Mar 2019 10:49:39 -0800 (PST)
X-Google-Smtp-Source: APXvYqw2y1lG99swetyE4dHQjsbgAbMQaLbGCMX29c7UiO3xo1cjfHN18rBThGP+OAt15GJFdD0x
X-Received: by 2002:aa7:d396:: with SMTP id x22mr5319844edq.182.1551466178144;
        Fri, 01 Mar 2019 10:49:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551466178; cv=none;
        d=google.com; s=arc-20160816;
        b=gef0cr3SupIqHKh+PNQg6w/3RBcZY9fOLbSs9rySt3bN+jT6W58qFTA0YkKyGxOCgn
         VKXveZZCnScUkz4ZovYZ/eB39KwBcqrUaMGtBKRKu6c23zLEEF0norzZLgxoy5zUezQo
         SY5ee5nPeVvnqwLTGuFrB00paoecEO28R3nqmYTaNvY9BFUMlEih/O3/kqGa5GFgbhbr
         zQ7xAJz498dGd6SaocBFD6MKp/0/g98ix6qFKXxyK7WtMUBkG91Oqm6R8DqvXn9o1xTP
         aO/clXh9Ws7fSf5RCwMANU5n9OVsarIX84Cx9sVZI8eZ/Yb9+LmYoR1wUn0smkJRzjkD
         kAVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=yT1o5MX6eOQPohVNnv59ywBZtM90ajDwX9lBtJ3oZig=;
        b=ZYO8gl2S7m8hVEViZ7MQVJqFdSviQL9iUFPk3jrUKg2FGYvhHjV6rB7bu0bPhRKF55
         VUo8aqVitNqur6BG4D4AYtSO+eePv1XzJIxdExOjCru1fMamMX7ucG6cCX6QAP0j2rs8
         aM+A07ROiP7uxFFMrNjHrZMS5doEtG+RqdrASw062sTnuOfhKk2WH4l1Ih2se+3Xxfzm
         wPMF8JMwan7nSCMjdTETvnXQvR/V7CN0KlnPQjiLQxQV17FeHmWeaV9nFSFI7tEbOQzf
         ccRDgzXycOvTJ/GPmjV2aAIhwJS+rSiF+oItL7XLTvcPMU1fdYPBpUu7+PRJyHse61Z2
         r5Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w20si3057213eda.362.2019.03.01.10.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 10:49:37 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 45E12AEC7;
	Fri,  1 Mar 2019 18:49:37 +0000 (UTC)
Date: Fri, 1 Mar 2019 10:49:29 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 0/2] RFC: READ/WRITE_ONCE vma/mm cleanups
Message-ID: <20190301184929.76v4w4plreobjim3@linux-r8p5>
Mail-Followup-To: Andrea Arcangeli <aarcange@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>
References: <20190301035550.1124-1-aarcange@redhat.com>
 <20190301093729.wa4phctbvplt5pg3@kshutemo-mobl1>
 <3e8b2ff0-d188-5259-b488-e31355e1e8ad@suse.cz>
 <20190301165452.GP14294@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190301165452.GP14294@redhat.com>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 01 Mar 2019, Andrea Arcangeli wrote:

>
>On Fri, Mar 01, 2019 at 02:04:38PM +0100, Vlastimil Babka wrote:
>> On 3/1/19 10:37 AM, Kirill A. Shutemov wrote:
>> > On Thu, Feb 28, 2019 at 10:55:48PM -0500, Andrea Arcangeli wrote:
>> >> Hello,
>> >>
>> >> This was a well known issue for more than a decade, but until a few
>> >> months ago we relied on the compiler to stick to atomic accesses and
>> >> updates while walking and updating pagetables.
>> >>
>> >> However now the 64bit native_set_pte finally uses WRITE_ONCE and
>> >> gup_pmd_range uses READ_ONCE as well.
>> >>
>> >> This convert more racy VM places to avoid depending on the expected
>> >> compiler behavior to achieve kernel runtime correctness.
>> >>
>> >> It mostly guarantees gcc to do atomic updates at 64bit granularity
>> >> (practically not needed) and it also prevents gcc to emit code that
>> >> risks getting confused if the memory unexpectedly changes under it
>> >> (unlikely to ever be needed).
>> >>
>> >> The list of vm_start/end/pgoff to update isn't complete, I covered the
>> >> most obvious places, but before wasting too much time at doing a full
>> >> audit I thought it was safer to post it and get some comment. More
>> >> updates can be posted incrementally anyway.
>> >
>> > The intention is described well to my eyes.
>> >
>> > Do I understand correctly, that it's attempt to get away with modifying
>> > vma's fields under down_read(mmap_sem)?
>
>The issue is that we already get away with it, but we do it without
>READ/WRITE_ONCE. The patch should changes nothing, it should only
>reduce the dependency on the compiler to do what we expect.
>
>> If that's the intention, then IMHO it's not that well described. It
>> talks about "racy VM places" but e.g. the __mm_populate() changes are
>> for code protected by down_read(). So what's going on here?
>
>expand_stack can move anonymous vma vm_end up or vm_start/pgoff down,
>while we hold the mmap_sem for writing. See the location of the three
>WRITE_ONCE in the patch.

You mean for reading, right? Yes, with expand_stack being held for read
such members were never really serialized by the mmap_sem and thus we
should not be computing stale values.

Acked-by: Davidlohr Bueso <dbueso@suse.de>

Thanks.

