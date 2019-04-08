Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55C83C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:40:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 031D620833
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:40:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 031D620833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C5FB6B0277; Mon,  8 Apr 2019 14:40:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84E016B0278; Mon,  8 Apr 2019 14:40:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C5C06B0279; Mon,  8 Apr 2019 14:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 460216B0277
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 14:40:24 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d131so12346090qkc.18
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 11:40:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ftwBKUAD4Z+GK4KmwYOBuH9fg/gP9BISIIkbd2+xBM8=;
        b=CdDd0Z/27M4iFFf5VFai5ryz+HITiNVuHMW9oPpBiVM2Qs9jtF0iMoQHrDcws95HP5
         N42sL8IKPm6YsH/4oIjLz+GvZfZI2vX6VuFfozIc3yO/Zi51A+P9Wdna5iKWIjzz6SW+
         fotXj8WDJcB3fzXLSg8Fnq1xVzJUqKdZxQBjxs4RksqshXFxCv/JDvO5v4bu/LUB+/RF
         it3iLpkYU7I/btAfZPV4tHS3zoZXypkt/W5v+NKEClcM+aT5za6FhVDU3EBaM3AOS34Y
         uH2SNYW3QUKToMClLmKN/Dc4K7lPN7J76UgkyGeGF/CqBeP/lf+pODtYY2kc2vut7uZs
         b/SQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVt+Xh1uUiT+dd79Z7lAjx7+wDD++mv+spvUNEhYOG+arDAYEbR
	/rcZYuKJzOcXlHNsT5yPjs8/jODfK8rMdIcV83yTl+y+Z7CNgpKrnOEjfRVnchn1z/40S2NtI8e
	I1qTp8bBSgSTuv4qzD+13Ld9mk/yUuMzV4CFV+v/HjmUiuONnBpBHJ07AlLu1ZkobrA==
X-Received: by 2002:ae9:dc01:: with SMTP id q1mr22930203qkf.98.1554748823968;
        Mon, 08 Apr 2019 11:40:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRrZLFeuYPrreMs3/i7heHBx0HU0fEUdK5Az5cOriZSSSAGfSAJTLSDJHDfb4C0hA7Xg14
X-Received: by 2002:ae9:dc01:: with SMTP id q1mr22930170qkf.98.1554748823352;
        Mon, 08 Apr 2019 11:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554748823; cv=none;
        d=google.com; s=arc-20160816;
        b=DadPbTDI4cAasnd5LS6B/XhfXkpFVSCzXDNAYgEo0ekoG1PhJWdsWh36Wdg3cRwF7h
         kvSUK1a4kgI6ovsktkVL6NNsS/JnCJCnozPk48BF3oHkH8NsnrAs76KbKBHbW9/0pigD
         evaxm/WjTUShd14FjhV7QZnTuruES7HIhXAXXgHiI0G9wmspPkpJI2yD9Kuo/4WJilCR
         WHOflnPnva1SP3GO3QsorpdpDEyVMev0cv0D0eRO/9UR30rPjMRe3T/uWQ35WmH1rgMA
         4WmGkFsX+NgRzPZGJTt3LrzaZjejJmaJrLv/1jlvacuVx9i+74oT2uw1COrhYD8wQ0rE
         Bw5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=ftwBKUAD4Z+GK4KmwYOBuH9fg/gP9BISIIkbd2+xBM8=;
        b=QxmwXwx+Lo0p+zDkBBVPxg187uqy3JihWBuoYcY5tVIN0p7HHCKE0qFswCg1LyYoKe
         J2StmKgWw5agrcq9FtstADMXAAARqsOo0pbAhZDct8MGD2a2JiN59oiLhlV0K6TJUyGt
         8/hT0qY63N2kXB/bUqU41Se3ixEzJQtRNWq7YLnm9qLtkxNTXI0DVNHltg8yB57ZZN7z
         vZzcn1neRSxXeMKToeCVPWxCq2rtrzrG2fO803FAJIqbXaqxsbtkckBTV094IpO/awy2
         DjGL93ClGcriKS6Wx2o0Wi/i/9hSGZv8ZzxaqI9CM8LeOjcpWqpe0gSMTAaj8SpQ+zHU
         Nb2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x30si100585qvf.161.2019.04.08.11.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 11:40:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 465C6307D91F;
	Mon,  8 Apr 2019 18:40:22 +0000 (UTC)
Received: from [10.36.116.113] (ovpn-116-113.ams2.redhat.com [10.36.116.113])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A596F6402B;
	Mon,  8 Apr 2019 18:40:12 +0000 (UTC)
Subject: Re: Thoughts on simple scanner approach for free page hinting
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <01d5f4e8-742b-33f5-6d91-0c7c396d1cfc@redhat.com>
 <CAKgT0UfbVS2iupbf4Dfp91PAdgHNHwZ-RNyL=mcPsS_68Ly_9Q@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <ef4c219f-6686-f5f6-fd22-d1da0b1720f3@redhat.com>
Date: Mon, 8 Apr 2019 20:40:11 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UfbVS2iupbf4Dfp91PAdgHNHwZ-RNyL=mcPsS_68Ly_9Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 08 Apr 2019 18:40:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>>>
>>> In addition we will need some way to identify which pages have been
>>> hinted on and which have not. The way I believe easiest to do this
>>> would be to overload the PageType value so that we could essentially
>>> have two values for "Buddy" pages. We would have our standard "Buddy"
>>> pages, and "Buddy" pages that also have the "Offline" value set in the
>>> PageType field. Tracking the Online vs Offline pages this way would
>>> actually allow us to do this with almost no overhead as the mapcount
>>> value is already being reset to clear the "Buddy" flag so adding a
>>> "Offline" flag to this clearing should come at no additional cost.
>>
>> Just nothing here that this will require modifications to kdump
>> (makedumpfile to be precise and the vmcore information exposed from the
>> kernel), as kdump only checks for the the actual mapcount value to
>> detect buddy and offline pages (to exclude them from dumps), they are
>> not treated as flags.
>>
>> For now, any mapcount values are really only separate values, meaning
>> not the separate bits are of interest, like flags would be. Reusing
>> other flags would make our life a lot easier. E.g. PG_young or so. But
>> clearing of these is then the problematic part.
>>
>> Of course we could use in the kernel two values, Buddy and BuddyOffline.
>> But then we have to check for two different values whenever we want to
>> identify a buddy page in the kernel.
> 
> Actually this may not be working the way you think it is working.

Trust me, I know how it works. That's why I was giving you the notice.

Read the first paragraph again and ignore the others. I am only
concerned about makedumpfile that has to be changed.

PAGE_OFFLINE_MAPCOUNT_VALUE
PAGE_BUDDY_MAPCOUNT_VALUE

Once you find out how these values are used, you should understand what
has to be changed and where.

>>>
>>> Lastly we would need to create a specialized function for allocating
>>> the non-"Offline" pages, and to tweak __free_one_page to tail enqueue
>>> "Offline" pages. I'm thinking the alloc function it would look
>>> something like __rmqueue_smallest but without the "expand" and needing
>>> to modify the !page check to also include a check to verify the page
>>> is not "Offline". As far as the changes to __free_one_page it would be
>>> a 2 line change to test for the PageType being offline, and if it is
>>> to call add_to_free_area_tail instead of add_to_free_area.
>>
>> As already mentioned, there might be scenarios where the additional
>> hinting thread might consume too much CPU cycles, especially if there is
>> little guest activity any you mostly spend time scanning a handful of
>> free pages and reporting them. I wonder if we can somehow limit the
>> amount of wakeups/scans for a given period to mitigate this issue.
> 
> That is why I was talking about breaking nr_free into nr_freed and
> nr_bound. By doing that I can record the nr_free value to a
> virtio-balloon specific location at the start of any walk and should
> know exactly now many pages were freed between that call and the next
> one. By ordering things such that we place the "Offline" pages on the
> tail of the list it should make the search quite fast since we would
> just be always allocating off of the head of the queue until we have
> hinted everything int he queue. So when we hit the last call to alloc
> the non-"Offline" pages and shut down our thread we can use the
> nr_freed value that we recorded to know exactly how many pages have
> been added that haven't been hinted.
> 
>> One main issue I see with your approach is that we need quite a lot of
>> core memory management changes. This is a problem. I wonder if we can
>> factor out most parts into callbacks.
> 
> I think that is something we can't get away from. However if we make
> this generic enough there would likely be others beyond just the
> virtualization drivers that could make use of the infrastructure. For
> example being able to track the rate at which the free areas are
> cycling in and out pages seems like something that would be useful
> outside of just the virtualization areas.

Might be, but might be the other extreme, people not wanting such
special cases in core mm. I assume the latter until I see a very clear
design where such stuff has been properly factored out.

> 
>> E.g. in order to detect where to queue a certain page (front/tail), call
>> a callback if one is registered, mark/check pages in a core-mm unknown
>> way as offline etc.
>>
>> I still wonder if there could be an easier way to combine recording of
>> hints and one hinting thread, essentially avoiding scanning and some of
>> the required core-mm changes.
> 
> The concern I have with trying to avoid the scanning by tracking is
> that if you fall behind it becomes something where just tracking the
> metadata for the page hints would start to become expensive.

Depends, if it is mostly only marking a bit in a bitmap, it should in
general not be too much of an issue. As usual, the datastructure used is
the important bit.

-- 

Thanks,

David / dhildenb

