Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC02DC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:10:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A28420818
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:10:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A28420818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 161AC6B0005; Thu, 16 May 2019 09:10:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EBAB6B0006; Thu, 16 May 2019 09:10:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF5E36B0007; Thu, 16 May 2019 09:10:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 862466B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 09:10:18 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id q29so674747lfb.11
        for <linux-mm@kvack.org>; Thu, 16 May 2019 06:10:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cDxEmRuq9y/Yiy+CCL7APOCUH/M8H7RoJf2yk7nAVmc=;
        b=FbmbXmBRBocMvXZIE3VIHALf14+1aUsYRGSdm05M4BeJF9mVltXT1uM/y18/nA12/P
         J2ESFkJlt5Fspcib0D6vf/qmsR60UJX3Fje5Dye9JHqIFrFvdfFc/Ft4A8kEz3QgC+nV
         5gJWefDAqT7CDniOe70B/riKK/L+Bj8OUmvQR5ekpe+rwyXRC9GbGBYCzZgwOqVFs+qF
         jQXYZO0Woc+UUhq8jIUSr2IvBXN8uIUJcyf/pDR8vXZfREwHbmS56tfuWZ9bgGWyU1Hl
         Ar/vE72AT9np7I6YOuE4LVpNGrNaXZMbr6NDmQN0ee1vogXaZZ8bPsMJM1bUDQ0v03V3
         vtWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUBUBPNxOQfGQZdgRslCLWq/UhoeSu1vfwiXu/0dpKkArY+oEMC
	obZZHnj8xB8dZ2fSDAVqhT3kv9KijOh8+lojoLBFXbdUDWTCJaP+Un6HwRKnaMD7VPxJfRXxbiF
	1nHgjbLxhM06wYdN7UTrxGtVXvetjWLleRAkMc0uXzhHQgxEFeFbrL31gOsh76/jGZA==
X-Received: by 2002:a2e:380c:: with SMTP id f12mr7840177lja.53.1558012217960;
        Thu, 16 May 2019 06:10:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7oyF+iDWpZXfcnVuL8iG/K2tpd/etVD6qupaU1xfLiT56TWN+CM4PELZZ7GPss8V6kzxa
X-Received: by 2002:a2e:380c:: with SMTP id f12mr7840123lja.53.1558012217080;
        Thu, 16 May 2019 06:10:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558012217; cv=none;
        d=google.com; s=arc-20160816;
        b=R5Usv3fihsn2E4JkRhxvu7+Oip1W63QZrJ1K3QJPFlbiyBVcZFmgU/rPDOJeN8zrFb
         G5hg/CojJ2HNkh2E1L/Y/vFo/L215ud5e05rm1I7r5+jW1+EQ1bqXwrIu/Zk4//4Pkv6
         IzQ1zbBYEmVDvdKxD96zcy3nfo16q6RpG66oSzULvDmPKI58z4tGYvchXIzuOHJHexO5
         hPrzOjdjOIYbCSPKGlzOV3grNivDQGIhts0EJvVSZLBipZFzmH28f89YwACUQtC0KKvY
         YSVT7LBl6GnS+ifzqC1suZi2SyV5vcDTwwTxzQ39LXdJIoUFx+YojIyyOSm9/y1mnikL
         qAPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cDxEmRuq9y/Yiy+CCL7APOCUH/M8H7RoJf2yk7nAVmc=;
        b=Khwv3YaqYTw3QbidDEYxri0UzVWX9caLeATyHZEFaxNg2VLBUk50mQTX8s7erV8YoC
         wA2z8Iea+PCmXd6Y64cPimubexLnKsvWId2WjDC5IRxV1TQ4AcAGSzqGd0QoPSmz8eQT
         jk5e09mGy+2OsMqVf2N7hwW4ueg4+VTkjqoEoRth4wV8LQLQqYSgvNDIu0qU8bU1llHP
         Xnsqe5uul/N7YHjXDDgf8YpGtnWwMHP5w2BjpQfyk7G1gwa6GAGHEpc6npNh3VlNBk1G
         EyG2Wvk8ZEdd0glG23u7zif6PEbiyrnS5BiTJWiJVEu+PDtGA0J1dC6Azb3504BIRe6P
         XC7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id x10si4274646lfc.110.2019.05.16.06.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 06:10:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hRG9B-0006kf-Km; Thu, 16 May 2019 16:10:09 +0300
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
To: Adam Borowski <kilobyte@angband.pl>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
 keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
 ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
 vbabka@suse.cz, cl@linux.com, riel@surriel.com, keescook@chromium.org,
 hannes@cmpxchg.org, npiggin@gmail.com, mathieu.desnoyers@efficios.com,
 shakeelb@google.com, guro@fb.com, aarcange@redhat.com, hughd@google.com,
 jglisse@redhat.com, mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
 <20190515193841.GA29728@angband.pl>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <7136aa47-3ce5-243d-6c92-5893b7b1379d@virtuozzo.com>
Date: Thu, 16 May 2019 16:10:07 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190515193841.GA29728@angband.pl>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Adam,

On 15.05.2019 22:38, Adam Borowski wrote:
> On Wed, May 15, 2019 at 06:11:15PM +0300, Kirill Tkhai wrote:
>> This patchset adds a new syscall, which makes possible
>> to clone a mapping from a process to another process.
>> The syscall supplements the functionality provided
>> by process_vm_writev() and process_vm_readv() syscalls,
>> and it may be useful in many situation.
>>
>> For example, it allows to make a zero copy of data,
>> when process_vm_writev() was previously used:
> 
> I wonder, why not optimize the existing interfaces to do zero copy if
> properly aligned?  No need for a new syscall, and old code would immediately
> benefit.

Because, this is just not possible. You can't zero copy anonymous pages
of a process to pages of a remote process, when they are different pages.

>> There are several problems with process_vm_writev() in this example:
>>
>> 1)it causes pagefault on remote process memory, and it forces
>>   allocation of a new page (if was not preallocated);
>>
>> 2)amount of memory for this example is doubled in a moment --
>>   n pages in current and n pages in remote tasks are occupied
>>   at the same time;
>>
>> 3)received data has no a chance to be properly swapped for
>>   a long time.
> 
> That'll handle all of your above problems, except for making pages
> subject to CoW if written to.  But if making pages writeably shared is
> desired, the old functions have a "flags" argument that doesn't yet have a
> single bit defined.

Kirill

