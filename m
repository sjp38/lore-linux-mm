Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8C93C76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 17:00:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA66C20838
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 17:00:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA66C20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 463E36B0006; Mon, 15 Jul 2019 13:00:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4151C6B000A; Mon, 15 Jul 2019 13:00:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3039B6B000C; Mon, 15 Jul 2019 13:00:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBF4E6B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 13:00:43 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u1so10822890pgr.13
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 10:00:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=fnmOM86QVifGTF/kFu3dVJQXgDGj1CuabsUs3lLdtXg=;
        b=qIyebAYINOKdpwXjoFH1pehgvwABx70tcAPwvOYNLba6c6Mug5OnKB8rx0DpBrLh3M
         +P1/J9U2oVvVN650FbS4IY1Cka0qjLve4b1t3K6BTKPF7D6JT2gqYQWfFS7ELxgWn65l
         62ikF+as/x1Jz3ZnJMEhog+/mSkfkO5NP/nDxXFE5P2eLPPkC1LAD5fz+T7MtRdBFIlv
         kxOb1r920eCMf7FwzCJLPJQJ3DN72o7TgBPcjw6Rsx5MbCXatnlPFjZXnkIyBogR+iC+
         w7lI3h8ISBnCWh5ctn+MBQ59UP1WoHgHVn0+aSP4KmKwTHgrXON/Q/R2qqKC7hDS40HL
         uw+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAULpnkHA8IkTGuj1wEZYIcmHAO03QcVw/jpkPuRLpYpmhrKRpUY
	ZbfBF8MsPCHdvtektPk/oofTuM3hemAQxg9e5Mg/BRlpbTMo42ZW0mpU/DXCVOqpWnC04+w4YH0
	EIkbga6rs1oSWGYyNzxpDtZMiEslSRu6lQ6Fn9h0dXz+UyHlGB2QpM6a0BVZ+JDEPqg==
X-Received: by 2002:a63:4d05:: with SMTP id a5mr26106085pgb.19.1563210043519;
        Mon, 15 Jul 2019 10:00:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyUQhUxEHMFeTSxtUE36sAVkJPOfxfSa1iJMZBRUfl9iaN/BH7cSh0Ndron7x+/SfgDE6F
X-Received: by 2002:a63:4d05:: with SMTP id a5mr26106022pgb.19.1563210042840;
        Mon, 15 Jul 2019 10:00:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563210042; cv=none;
        d=google.com; s=arc-20160816;
        b=FTd+8PFPZt5WvJpemdPK8ZeRYrle95QFjuFInDsQ8bJR3Uk+ZEwmeL2AVGcV5Xv9OD
         Rl9iM0vywqejXIp8gc5Q5SZgr+UYo2BjRabvjgDr1BX58XOkKGro6t7GQUDOUnL4lmD+
         N6J/TE8WYTYxoEvQ8pR5lB+L6Bnphpw+GaueOdZ8dtCM4/ioP6NxopbmPdmFGy90nUYG
         GTyctfgQq5lHrjDde9oJwzJ2hys8O0K5H5mLxqAmLa3IkRU44gOl2Fn/gTbwttqvMzh4
         RT/GnJ6Aleg1DEylOaBWPZatP9LVlxIV5+dDBOm+PnKJZzMGKJK0qncJdJow5OJT2tV3
         TaFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=fnmOM86QVifGTF/kFu3dVJQXgDGj1CuabsUs3lLdtXg=;
        b=QyJi4xtb3mpQaGUelFTJOt885xNkgxxO8hYCIvL9CUo+iH8f8az8r+N9vUntrllOuj
         D3FDI4Ip9rQopSwMkrW8L6r9Y/Q8c9fwlv/I10ZseUngJTGus8ZLLC3INm5vhxgabxxx
         JJ8x7q56iIsfZj3D3/I+5kLn2ASLsp+1PliEcbjro8wPLJRf/dgxr8jCoF68lUsisIp3
         we3wyBDtJadknsCJwNnQo4QbCb7h2HLUjHW9x76Jqfl+qjTUY/QwvgEyJ52ps/Ul+UGn
         0eZmLWuFSM8WoI1Xp8AEDyUaaUn4MsY927n/gxnC1F6cGFN/g3QJJEkjhOynwRzNOTRu
         nfBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id l186si16923399pgd.455.2019.07.15.10.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 10:00:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TX.KuoP_1563210037;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX.KuoP_1563210037)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Jul 2019 01:00:40 +0800
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
To: Matthew Wilcox <willy@infradead.org>
Cc: mhocko@suse.com, dvyukov@google.com, catalin.marinas@arm.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190713212548.GZ32320@bombadil.infradead.org>
 <4b4eb1f9-440c-f4cd-942c-2c11b566c4c0@linux.alibaba.com>
 <20190715130648.GA32320@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <a991ac12-3610-f993-e44c-b12adab17fe1@linux.alibaba.com>
Date: Mon, 15 Jul 2019 10:00:34 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190715130648.GA32320@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/15/19 6:06 AM, Matthew Wilcox wrote:
> On Sun, Jul 14, 2019 at 08:47:07PM -0700, Yang Shi wrote:
>>
>> On 7/13/19 2:25 PM, Matthew Wilcox wrote:
>>> On Sat, Jul 13, 2019 at 04:49:04AM +0800, Yang Shi wrote:
>>>> When running ltp's oom test with kmemleak enabled, the below warning was
>>>> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
>>>> passed in:
>>> There are lots of places where kmemleak will call kmalloc with
>>> __GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM (including the XArray code, which
>>> is how I know about it).  It needs to be fixed to allow its internal
>>> allocations to fail and return failure of the original allocation as
>>> a consequence.
>> Do you mean kmemleak internal allocation? It would fail even though
>> __GFP_NOFAIL is passed in if GFP_NOWAIT is specified. Currently buddy
>> allocator will not retry if the allocation is non-blockable.
> Actually it sets off a warning.  Which is the right response from the
> core mm code because specifying __GFP_NOFAIL and __GFP_NOWAIT makes no
> sense.

Yes, this is what I meant. Kmemleak did a trick to fool fault-injection 
by passing in __GFP_NOFAIL, but it doesn't make sense for non-blockable 
allocation.


