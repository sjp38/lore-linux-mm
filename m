Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 405E2C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:57:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A37A206A2
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:57:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="nRcfxXoJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A37A206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F8248E0005; Tue, 30 Jul 2019 10:57:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A76D8E0001; Tue, 30 Jul 2019 10:57:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 197018E0005; Tue, 30 Jul 2019 10:57:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id A78E58E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:57:22 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id f24so6694961lfk.6
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 07:57:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=dHW6AIzVqZ+BtB7OKS/RSaqFVfjBjJYiEElqTiNSJSw=;
        b=PT3/hLofYZJSyTwGx8Ggy0t97plZk4IqHzJNLE6Tf0wjkMwyAJJ9PSUcm6NHzD4rX5
         6u4ByRhxxvK+kJW/euFOEATV7g19xDN9Zh+1fWWrltyqd8joCo2MnBW+luIFjKPFhkZK
         24XDtQXJUQMKDYWylLLUwJTounCVKeYS1iPtCVSnVWaBHOJEOkjE1nOxpPB8Y15Gh+uQ
         QEanX9TfJJprTvRpO70FNrLtffN4a5Um0wnIBVnjkuoUqNjXTJ4952yOcy8kYYD/4Gqz
         /gXdhr8LQMWcVp5xfZ/H3QnzeGDt/DAQz8LUBG4KmK/ArHlU9zdlHAitXK9C7J17zdx6
         M2Pg==
X-Gm-Message-State: APjAAAXv+7IaO5VBVUSTW23PtF9kEtA6oDiX5vX1MCldHr7laOWKndUz
	WSNKwemKEOcdZHg8dJFOm54+FjBaCKiaHK6CC+O+cVEep0eXUm4+CREaIWbxqv8n5vQLmJupua4
	pcK0QXXOZtDtvBZ/xnozBiiKRfOJA3lWl6bUJqlMJc39qHmsILqIrSrk+faTkEo7HVQ==
X-Received: by 2002:ac2:42c7:: with SMTP id n7mr54292250lfl.65.1564498641821;
        Tue, 30 Jul 2019 07:57:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyblpJtfzcc/txqGff6c1Nk5IylrQfdnejduGOhsCnrJsCub92wRWwVYQAIivQD0+yx4SYt
X-Received: by 2002:ac2:42c7:: with SMTP id n7mr54292210lfl.65.1564498641025;
        Tue, 30 Jul 2019 07:57:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564498641; cv=none;
        d=google.com; s=arc-20160816;
        b=tf9qeirYRyrpE4T2T4NAJic6XEs7zlTeGEfJWSEOo18gBMMps8cev+SvHgsrNWXhU9
         bhEf78C2KZa1jm//Atfq8t3C2Cu0oa1MvCSflway9DjrdWCC+6RT8onrEpfbzkd2Bi07
         jY1NlReHLPz46yMAy8/itgQs6JxTISpbsjXpJig7amRn93WEQH7wrWiACWnyGVz0vaJO
         1i8ZmJvLbEJyhc8R4c3qQ4b0PuXlsQLCoKzzBP5JQvMEh7gcVrQC/hlAM1Og7iDYTr/2
         Q9NNj7jH6OHt3HfEiGKzlY4QVAaO+yWEn0Z5+np1NtFFXzzCKQn9KWALNQZ5b4kAspnM
         FIww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=dHW6AIzVqZ+BtB7OKS/RSaqFVfjBjJYiEElqTiNSJSw=;
        b=0YOtklSul9CHrepz42vSKgATCs/LoglDOs2bmdlHhIS+e3qXHxMGLBIgExxxQzqm7u
         cYjyLgzslNIw7FB8h8GA0ujwl6SynMsDmN87zZJ3iiAyT1YKlC4Gk7+06TBOMKodbL9l
         YLHlU+uuMY/ZGXbqN8ZO5bW6UXjEMwUOR2WlNSghwrne5bS8s3aHkxIK8DlJSsHe4OlW
         Dk/EzL38j+RYub96TEgqT2E0KS7ZH6WVO9VIuiZqzg5LddozbjpM6SAEhDvwy5+U36SS
         A5UsOI1jALilZjpw4IyFp1CW2/6eIt88rtTT+215LrJfDuDPRoIQpid4p8oKYrWywM7G
         tw0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=nRcfxXoJ;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [2a02:6b8:0:1619::183])
        by mx.google.com with ESMTPS id d15si60005781ljj.171.2019.07.30.07.57.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 07:57:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) client-ip=2a02:6b8:0:1619::183;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=nRcfxXoJ;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 3DC5F2E149D;
	Tue, 30 Jul 2019 17:57:19 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id WNehyI4MZ5-vIm4YE3J;
	Tue, 30 Jul 2019 17:57:19 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1564498639; bh=dHW6AIzVqZ+BtB7OKS/RSaqFVfjBjJYiEElqTiNSJSw=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=nRcfxXoJOFApXtdgJwbWyzJxu18sBhC97J+b0XUkbFKbeyF+czKvEWkER4dD4PvpM
	 Kx/kWcdfC8+qhUZCnfAK7DgD6b7CRVZVU0aEanWgO1MM6GjH/xuz0fqsz9Qx261iQ4
	 tVpiYuJxxjpZMd1yQzLk/Q6wtTeCxfDCimRo8B7E=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:6454:ac35:2758:ad6a])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id 1ayIe6tgdX-vIQKqeKg;
	Tue, 30 Jul 2019 17:57:18 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH 1/2] mm/filemap: don't initiate writeback if mapping has
 no dirty pages
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
 Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>,
 linux-fsdevel@vger.kernel.org
References: <156378816804.1087.8607636317907921438.stgit@buzz>
 <20190722175230.d357d52c3e86dc87efbd4243@linux-foundation.org>
 <bdc6c53d-a7bb-dcc4-20ba-6c7fa5c57dbd@yandex-team.ru>
 <20190730141457.GE28829@quack2.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <51ba7304-06bd-a50d-cb14-6dc41b92fab5@yandex-team.ru>
Date: Tue, 30 Jul 2019 17:57:18 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190730141457.GE28829@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.07.2019 17:14, Jan Kara wrote:
> On Tue 23-07-19 11:16:51, Konstantin Khlebnikov wrote:
>> On 23.07.2019 3:52, Andrew Morton wrote:
>>>
>>> (cc linux-fsdevel and Jan)
> 
> Thanks for CC Andrew.
> 
>>> On Mon, 22 Jul 2019 12:36:08 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
>>>
>>>> Functions like filemap_write_and_wait_range() should do nothing if inode
>>>> has no dirty pages or pages currently under writeback. But they anyway
>>>> construct struct writeback_control and this does some atomic operations
>>>> if CONFIG_CGROUP_WRITEBACK=y - on fast path it locks inode->i_lock and
>>>> updates state of writeback ownership, on slow path might be more work.
>>>> Current this path is safely avoided only when inode mapping has no pages.
>>>>
>>>> For example generic_file_read_iter() calls filemap_write_and_wait_range()
>>>> at each O_DIRECT read - pretty hot path.
> 
> Yes, but in common case mapping_needs_writeback() is false for files you do
> direct IO to (exactly the case with no pages in the mapping). So you
> shouldn't see the overhead at all. So which case you really care about?
> 
>>>> This patch skips starting new writeback if mapping has no dirty tags set.
>>>> If writeback is already in progress filemap_write_and_wait_range() will
>>>> wait for it.
>>>>
>>>> ...
>>>>
>>>> --- a/mm/filemap.c
>>>> +++ b/mm/filemap.c
>>>> @@ -408,7 +408,8 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
>>>>    		.range_end = end,
>>>>    	};
>>>> -	if (!mapping_cap_writeback_dirty(mapping))
>>>> +	if (!mapping_cap_writeback_dirty(mapping) ||
>>>> +	    !mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
>>>>    		return 0;
>>>>    	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
>>>
>>> How does this play with tagged_writepages?  We assume that no tagging
>>> has been performed by any __filemap_fdatawrite_range() caller?
>>>
>>
>> Checking also PAGECACHE_TAG_TOWRITE is cheap but seems redundant.
>>
>> To-write tags are supposed to be a subset of dirty tags:
>> to-write is set only when dirty is set and cleared after starting writeback.
>>
>> Special case set_page_writeback_keepwrite() which does not clear to-write
>> should be for dirty page thus dirty tag is not going to be cleared either.
>> Ext4 calls it after redirty_page_for_writepage()
>> XFS even without clear_page_dirty_for_io()
>>
>> Anyway to-write tag without dirty tag or at clear page is confusing.
> 
> Yeah, TOWRITE tag is intended to be internal to writepages logic so your
> patch is fine in that regard. Overall the patch looks good to me so I'm
> just wondering a bit about the motivation...

In our case file mixes cached pages and O_DIRECT read. Kind of database
were index header is memory mapped while the rest data read via O_DIRECT.
I suppose for sharing index between multiple instances.

On this path we also hit this bug:
https://lore.kernel.org/lkml/156355839560.2063.5265687291430814589.stgit@buzz/
so that's why I've started looking into this code.

