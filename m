Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81F9AC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 18:15:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA7352089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 18:15:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="wzOucalG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA7352089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82CB48E0003; Tue, 30 Jul 2019 14:15:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DDBB8E0001; Tue, 30 Jul 2019 14:15:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CC438E0003; Tue, 30 Jul 2019 14:15:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 06F8D8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:15:26 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id l7so6762190lfc.4
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:15:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=O1f0fqsMtDtcIdVNBgmb2PMxS7uPI7/I37S9Ymo3qec=;
        b=CUX7BsXnru239L029Vvsl1scxdyxW01/wc5b8dK+3ZbIgnaeg3hshHeoPkdBximi3T
         QDZGE7zRKQRvu9Ca3O9/dd3MqWYE19aixDz56YWXSnQ+pr85Hp6dh0BhK5dUPi7BQgoj
         Sqh4ZBSxnVxLoKgk02C1r4y1PuYQau2fH4p4TYgJxjFdEe99PaWAWTU2RhZ6ZgCRnMwv
         Z30uZrOImj1WFe8NE/uC7zCoIH5LZvTHCuRXriyQ6KGvd6fWWph3nzWKNWTFDBFBvymJ
         0YHvqQ2dkeMDKztPjhykWuwfxsmow43YYExDJPWmWM+GWifBNGn+2aSaiYS3Uj/YpyM5
         rZwA==
X-Gm-Message-State: APjAAAVmAYbJ48tpSivARp9K8qMDm4uCZPd9mBDfaTegEnnsmKZy/pmu
	g8uUp4OB28STSR4KfLUP7cMvjAJ/NH7lk/oo3kMreCPkGusAtOr/XspImmzjlp5hfIlx599oAmY
	24cd/xh4kuXZRJX2EJ552YxbHcan8r8jwyl5FIxVc0ocZrnQGdp6tYot+C04cagk99A==
X-Received: by 2002:a2e:2b57:: with SMTP id q84mr61992976lje.105.1564510525166;
        Tue, 30 Jul 2019 11:15:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwT/9kB6X4HIIM3qMxR4MjmSUUAwVdBy2sUFe2WyM5+h7lrSn9LPVXh9c3SusJ5rd+rpnzS
X-Received: by 2002:a2e:2b57:: with SMTP id q84mr61992942lje.105.1564510524189;
        Tue, 30 Jul 2019 11:15:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564510524; cv=none;
        d=google.com; s=arc-20160816;
        b=jkOnsdJj7npbfWYoDpbwntc8YqmsHYXqw7SeQvo07JYKo3yXybZ4CS07OZktofqpu+
         8yT0lBap2cujAbF/e75n+jljb0sVb5uTWS1W/qutd+/0iJPlpsT/ufZTMQfmZ7e1oGcC
         6Xnf4BVXCpgqRSQ1rnvGHA70dlmp2ehNPszjsKAFbemJunqHkWCAuJQwCllff4VkMaoT
         HpJ3CEIj1POWoSP6GuiqeYchPN8Z0peYS1nKxu2qU91BM8dXxfyOJVUqadizFOlHe5zh
         nrv7PFYU8eLD+NXMh4vNyIdfSt/I87KG+jBZaqJzUU7aqduArWYeT3scgWzIMR9Q6ka7
         9xRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=O1f0fqsMtDtcIdVNBgmb2PMxS7uPI7/I37S9Ymo3qec=;
        b=IGAJHGxegnV5NJDr1OFBZPn2pNdEIzcFcbFDPPW4ptLzEUdktVays0z48USJrhzCHb
         qUgU1xHkqInhysRWYqeU/BkwnB4iFIrCSsqeXai0V3QCreWt87WtZEEfa/cL6xUNU8oz
         0LpO33i6gq6yeb1etTnU11xAfLbJ6gqt3NW0JV0Aao9vzzmBepJ2qWLCpbu81qToAPHW
         OHcV6foySBY+MWafqHJFDa9qMxKPAnv8ijgt4y0I+S8wQYZv7VvVFevEeY6JrGqT69M/
         2AQuVu8jzKePekqH63rqq4kUsyeUsOjt8cazOFZl02HtJEXdjhzUOVoKc2cLfwyIb2Se
         PFtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=wzOucalG;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [2a02:6b8:0:1472:2741:0:8b6:217])
        by mx.google.com with ESMTPS id q64si55568170ljq.31.2019.07.30.11.15.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 11:15:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) client-ip=2a02:6b8:0:1472:2741:0:8b6:217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=wzOucalG;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 71CAA2E14C1;
	Tue, 30 Jul 2019 21:15:23 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id jJUKzscTox-FMeK8IK3;
	Tue, 30 Jul 2019 21:15:23 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1564510523; bh=O1f0fqsMtDtcIdVNBgmb2PMxS7uPI7/I37S9Ymo3qec=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=wzOucalG3TJcf705DvhKCt/iJ+Gei4PRaz8KkgIcEn0/engALRpkk2bwtHmicH0wd
	 Wdq51G8qcAFjmZKdJ+gPff2LVcWzSXbg0fcQ5gV/JgIACYN9uxu3EU/N15XKLDfaEg
	 ey1FxR/2tsR0q+TK8PLmszVr4AqJxjARczpHJOi8=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:6454:ac35:2758:ad6a])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id GB79wZpAye-FMaOPmnb;
	Tue, 30 Jul 2019 21:15:22 +0300
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
 <51ba7304-06bd-a50d-cb14-6dc41b92fab5@yandex-team.ru>
 <20190730154854.GG28829@quack2.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <c28d4243-aeb9-901a-46e9-bfe2e704cd8f@yandex-team.ru>
Date: Tue, 30 Jul 2019 21:15:22 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190730154854.GG28829@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 30.07.2019 18:48, Jan Kara wrote:
> On Tue 30-07-19 17:57:18, Konstantin Khlebnikov wrote:
>> On 30.07.2019 17:14, Jan Kara wrote:
>>> On Tue 23-07-19 11:16:51, Konstantin Khlebnikov wrote:
>>>> On 23.07.2019 3:52, Andrew Morton wrote:
>>>>>
>>>>> (cc linux-fsdevel and Jan)
>>>
>>> Thanks for CC Andrew.
>>>
>>>>> On Mon, 22 Jul 2019 12:36:08 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
>>>>>
>>>>>> Functions like filemap_write_and_wait_range() should do nothing if inode
>>>>>> has no dirty pages or pages currently under writeback. But they anyway
>>>>>> construct struct writeback_control and this does some atomic operations
>>>>>> if CONFIG_CGROUP_WRITEBACK=y - on fast path it locks inode->i_lock and
>>>>>> updates state of writeback ownership, on slow path might be more work.
>>>>>> Current this path is safely avoided only when inode mapping has no pages.
>>>>>>
>>>>>> For example generic_file_read_iter() calls filemap_write_and_wait_range()
>>>>>> at each O_DIRECT read - pretty hot path.
>>>
>>> Yes, but in common case mapping_needs_writeback() is false for files you do
>>> direct IO to (exactly the case with no pages in the mapping). So you
>>> shouldn't see the overhead at all. So which case you really care about?
>>>
>>>>>> This patch skips starting new writeback if mapping has no dirty tags set.
>>>>>> If writeback is already in progress filemap_write_and_wait_range() will
>>>>>> wait for it.
>>>>>>
>>>>>> ...
>>>>>>
>>>>>> --- a/mm/filemap.c
>>>>>> +++ b/mm/filemap.c
>>>>>> @@ -408,7 +408,8 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
>>>>>>     		.range_end = end,
>>>>>>     	};
>>>>>> -	if (!mapping_cap_writeback_dirty(mapping))
>>>>>> +	if (!mapping_cap_writeback_dirty(mapping) ||
>>>>>> +	    !mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
>>>>>>     		return 0;
>>>>>>     	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
>>>>>
>>>>> How does this play with tagged_writepages?  We assume that no tagging
>>>>> has been performed by any __filemap_fdatawrite_range() caller?
>>>>>
>>>>
>>>> Checking also PAGECACHE_TAG_TOWRITE is cheap but seems redundant.
>>>>
>>>> To-write tags are supposed to be a subset of dirty tags:
>>>> to-write is set only when dirty is set and cleared after starting writeback.
>>>>
>>>> Special case set_page_writeback_keepwrite() which does not clear to-write
>>>> should be for dirty page thus dirty tag is not going to be cleared either.
>>>> Ext4 calls it after redirty_page_for_writepage()
>>>> XFS even without clear_page_dirty_for_io()
>>>>
>>>> Anyway to-write tag without dirty tag or at clear page is confusing.
>>>
>>> Yeah, TOWRITE tag is intended to be internal to writepages logic so your
>>> patch is fine in that regard. Overall the patch looks good to me so I'm
>>> just wondering a bit about the motivation...
>>
>> In our case file mixes cached pages and O_DIRECT read. Kind of database
>> were index header is memory mapped while the rest data read via O_DIRECT.
>> I suppose for sharing index between multiple instances.
> 
> OK, that has always been a bit problematic but you're not the first one to
> have such design ;). So feel free to add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> to your patch.

Thanks.

O_DIRECT has long history of misunderstandings =)
It looks some cases are still not documented.
My favourite: O_DIRECT write into hole goes into cache, at least for ext4.

> 
>> On this path we also hit this bug:
>> https://lore.kernel.org/lkml/156355839560.2063.5265687291430814589.stgit@buzz/
>> so that's why I've started looking into this code.
> 
> I see. OK.
> 
> 								Honza
> 

