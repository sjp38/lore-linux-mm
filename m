Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE08EC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 16:36:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C7F820883
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 16:36:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C7F820883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6AA46B0003; Mon,  8 Apr 2019 12:36:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B19946B0006; Mon,  8 Apr 2019 12:36:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0B856B0007; Mon,  8 Apr 2019 12:36:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9436B0003
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 12:36:23 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x58so13241820qtc.1
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 09:36:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=yy6znOe2GQuSillon4ncISVLmdWa3NZ4uTwkSEarw/E=;
        b=KBMFGRHWGWU9ui4tYHSoMpcKhMG7ZAMOjhSPu/hlZY26t7fAdBQT9v/dx5ESoW+jBX
         ARGA0K+8GEZK7N8J2JK1UNxV51Tr6nBO+BzjnTK/O4e7/aSDsATGDUZrNJjpk3bnlzez
         R3RmwFPhh8kHMgEj141RS9Fzu5f4BmqCSrY7g5zlzjO7S2vQ+5i/+ASEzfcgvnKGM5fb
         20tic0ty1bciGg6XRPLHhBK2ixIfzfJvnueYc6V6LoXU9q2jwbZkhdhgOYOWgL9XtI0m
         ROY8vKUupkW2XfS/22eavWFY5xkdGcPRmfxcUrlqXbfgsDfTBEPV6/d6STXOf40KMSWR
         CY/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVeWl/7ToO62LIQcflQuKE472ZoCow4DDZju1mmc1zhvhWFXZkv
	+gJrNAxN5uCc4G7LPujcLm3UAhAP2NWuruhVi8x9fmwSiL41LlrR9VsXkKLgv+5e973yEaQ3Bgt
	szVRQ6WvC4i0hn//Npd0zJitzELHDbSBcJW3E3j4Y+58mMtTNWS8/672dPP6y+JekIA==
X-Received: by 2002:a37:a5d8:: with SMTP id o207mr23925233qke.0.1554741383138;
        Mon, 08 Apr 2019 09:36:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRYG92ES5Uxg5nemz9KOT1NY/EA0iq9tMOB6RzjzuaUYvzzCZG1BTr2xPwosKeOxb97qzo
X-Received: by 2002:a37:a5d8:: with SMTP id o207mr23925115qke.0.1554741381595;
        Mon, 08 Apr 2019 09:36:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554741381; cv=none;
        d=google.com; s=arc-20160816;
        b=gY2SCn7q7g3bHvFZlZ9jMhlFF1b+IKgrY5v3nCa3lF7nEdtggNvUHHNZBKyZYYEZQ0
         gwot8Cvay0GelmGG/li4cPUr0dc+vUmzO2xVh75AlRNxTrzzoZFgngaWjAhLgZSKgU0W
         0CtJ5u92L74UHNx5A6jSEWVwydmhksJ4V1OYwDkfh2iKvGjm+HpjZ0gUDq5w4W+HEp/c
         u/nT8adOz/Y+mhINw7Hg5fzUWVVBti3zDNVkkLpvNKkzGcj8XEAcHc0+GPrQ+5Ey77YV
         b+CHKwDZOq23Ud/zXMpmDa4RlQLSrdzF+RSJenwoJuToAXkHOkXrSOxoNA8QI7NTL2EM
         vxCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=yy6znOe2GQuSillon4ncISVLmdWa3NZ4uTwkSEarw/E=;
        b=QsEtpCEwcu11y347HaQShpkC0uGZwHx6afRSZgqaI0waMTYYxUO4S/we+FzXDjhTDj
         7WP+kN790fzC1x80jrtGku52ObpFV3HcSP4RZfY1ipob78it6RZ6dQkbrmZy6dmkQxik
         QCx8dajKFFQUvhZKJ4m9Oaw+0zxUIUIwIDGgSTy/mBRLjiTDZ0GGS5EZSGA7ovS2Vgtv
         5ONLQEvxicvUdkiQJ/zPDjWvSXXvHcBtkuANa3RLVHHz8AiDYB6soQ+g5hgx53inWBBl
         3U7HYdLBJu2Dcg1pUGQ7iNdB8cfw1T3MMbbMmXi8LMrdTBuEMCS2i/7plVO/sxBxYaeB
         PiNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m50si3206075qtm.179.2019.04.08.09.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 09:36:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 812F13001A68;
	Mon,  8 Apr 2019 16:36:19 +0000 (UTC)
Received: from [10.36.116.77] (ovpn-116-77.ams2.redhat.com [10.36.116.77])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 13E495D719;
	Mon,  8 Apr 2019 16:36:08 +0000 (UTC)
Subject: Re: Thoughts on simple scanner approach for free page hinting
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <01d5f4e8-742b-33f5-6d91-0c7c396d1cfc@redhat.com>
Date: Mon, 8 Apr 2019 18:36:08 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 08 Apr 2019 16:36:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06.04.19 02:09, Alexander Duyck wrote:
> So I am starting this thread as a spot to collect my thoughts on the
> current guest free page hinting design as well as point out a few
> possible things we could do to improve upon it.
> 
> 1. The current design isn't likely going to scale well to multiple
> VCPUs. The issue specifically is that the zone lock must be held to
> pull pages off of the free list and to place them back there once they
> have been hinted upon. As a result it would likely make sense to try
> to limit ourselves to only having one thread performing the actual
> hinting so that we can avoid running into issues with lock contention
> between threads.

Makes sense.

> 
> 2. There are currently concerns about the hinting triggering false OOM
> situations if too much memory is isolated while it is being hinted. My
> thought on this is to simply avoid the issue by only hint on a limited
> amount of memory at a time. Something like 64MB should be a workable
> limit without introducing much in the way of regressions. However as a
> result of this we can easily be overrun while waiting on the host to
> process the hinting request. As such we will probably need a way to
> walk the free list and free pages after they have been freed instead
> of trying to do it as they are freed.

We will need such a way in case we care about dropped hinting requests, yes.

> 
> 3. Even with the current buffering which is still on the larger side
> it is possible to overrun the hinting limits if something causes the
> host to stall and a large swath of memory is released. As such we are
> still going to need some sort of scanning mechanism or will have to
> live with not providing accurate hints.

Yes, usually if there is a lot of guest activity, you could however
assume that free pages might get reused either way soon. Of course,
special cases are "freeing XGB and being idle afterwards".

> 
> 4. In my opinion, the code overall is likely more complex then it
> needs to be. We currently have 2 allocations that have to occur every
> time we provide a hint all the way to the host, ideally we should not
> need to allocate more memory to provide hints. We should be able to
> hold the memory use for a memory hint device constant and simply map
> the page address and size to the descriptors of the virtio-ring.

I don't think the two allocations are that complex. The only thing I
consider complex is isolation a lot of pages from different zones etc.
Two allocations, nobody really cares about that. Of course, the fact
that we have to allocate memory from the VCPUs where we currently freed
a page is not optimal. I consider that rather a problem/complex.

Especially you have a point regarding scalability and multiple VCPUs.

> 
> With that said I have a few ideas that may help to address the 4
> issues called out above. The basic idea is simple. We use a high water
> mark based on zone->free_area[order].nr_free to determine when to wake
> up a thread to start hinting memory out of a given free area. From
> there we allocate non-"Offline" pages from the free area and assign
> them to the hinting queue up to 64MB at a time. Once the hinting is
> completed we mark them "Offline" and add them to the tail of the
> free_area. Doing this we should cycle the non-"Offline" pages slowly
> out of the free_area. In addition the search cost should be minimal
> since all of the "Offline" pages should be aggregated to the tail of
> the free_area so all pages allocated off of the free_area will be the
> non-"Offline" pages until we shift over to them all being "Offline".
> This should be effective for MAX_ORDER - 1 and MAX_ORDER - 2 pages
> since the only real consumer of add_to_free_area_tail is
> __free_one_page which uses it to place a page with an order less than
> MAX_ORDER - 2 on the tail of a free_area assuming that it should be
> freeing the buddy of that page shortly. The only other issue with
> adding to tail would be the memory shuffling which was recently added,
> but I don't see that as being something that will be enabled in most
> cases so we could probably just make the features mutually exclusive,
> at least for now.
> 
> So if I am not mistaken this would essentially require a couple
> changes to the mm infrastructure in order for this to work.
> 
> First we would need to split nr_free into two counters, something like
> nr_freed and nr_bound. You could use nr_freed - nr_bound to get the
> value currently used for nr_free. When we pulled the pages for hinting
> we would reduce the nr_freed value and then add back to it when the
> pages are returned. When pages are allocated they would increment the
> nr_bound value. The idea behind this is that we can record nr_free
> when we collect the pages and save it to some local value. This value
> could then tell us how many new pages have been added that have not
> been hinted upon.

I can imagine that quite some people will have problems with such
"virtualization specific changes" splattered around core memory
management. Would there be a way to manage this data at a different
place, out of core-mm and somehow work on it via callbacks?

> 
> In addition we will need some way to identify which pages have been
> hinted on and which have not. The way I believe easiest to do this
> would be to overload the PageType value so that we could essentially
> have two values for "Buddy" pages. We would have our standard "Buddy"
> pages, and "Buddy" pages that also have the "Offline" value set in the
> PageType field. Tracking the Online vs Offline pages this way would
> actually allow us to do this with almost no overhead as the mapcount
> value is already being reset to clear the "Buddy" flag so adding a
> "Offline" flag to this clearing should come at no additional cost.

Just nothing here that this will require modifications to kdump
(makedumpfile to be precise and the vmcore information exposed from the
kernel), as kdump only checks for the the actual mapcount value to
detect buddy and offline pages (to exclude them from dumps), they are
not treated as flags.

For now, any mapcount values are really only separate values, meaning
not the separate bits are of interest, like flags would be. Reusing
other flags would make our life a lot easier. E.g. PG_young or so. But
clearing of these is then the problematic part.

Of course we could use in the kernel two values, Buddy and BuddyOffline.
But then we have to check for two different values whenever we want to
identify a buddy page in the kernel.

> 
> Lastly we would need to create a specialized function for allocating
> the non-"Offline" pages, and to tweak __free_one_page to tail enqueue
> "Offline" pages. I'm thinking the alloc function it would look
> something like __rmqueue_smallest but without the "expand" and needing
> to modify the !page check to also include a check to verify the page
> is not "Offline". As far as the changes to __free_one_page it would be
> a 2 line change to test for the PageType being offline, and if it is
> to call add_to_free_area_tail instead of add_to_free_area.

As already mentioned, there might be scenarios where the additional
hinting thread might consume too much CPU cycles, especially if there is
little guest activity any you mostly spend time scanning a handful of
free pages and reporting them. I wonder if we can somehow limit the
amount of wakeups/scans for a given period to mitigate this issue.

One main issue I see with your approach is that we need quite a lot of
core memory management changes. This is a problem. I wonder if we can
factor out most parts into callbacks.

E.g. in order to detect where to queue a certain page (front/tail), call
a callback if one is registered, mark/check pages in a core-mm unknown
way as offline etc.

I still wonder if there could be an easier way to combine recording of
hints and one hinting thread, essentially avoiding scanning and some of
the required core-mm changes.

-- 

Thanks,

David / dhildenb

