Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id E74946B0075
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 10:51:47 -0400 (EDT)
Received: by qkx62 with SMTP id 62so150786866qkx.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 07:51:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g140si11804734qhc.92.2015.04.17.07.51.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 07:51:46 -0700 (PDT)
Message-ID: <55311DE2.9000901@redhat.com>
Date: Fri, 17 Apr 2015 15:51:14 +0100
From: John Spray <john.spray@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com> <1429082147-4151-2-git-send-email-b.michalska@samsung.com> <20150417113110.GD3116@quack.suse.cz> <553104E5.2040704@samsung.com> <55310957.3070101@gmail.com>
In-Reply-To: <55310957.3070101@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>, Beata Michalska <b.michalska@samsung.com>, Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org

On 17/04/2015 14:23, Austin S Hemmelgarn wrote:
> On 2015-04-17 09:04, Beata Michalska wrote:
>> On 04/17/2015 01:31 PM, Jan Kara wrote:
>>> On Wed 15-04-15 09:15:44, Beata Michalska wrote:
>>> ...
>>>> +static const match_table_t fs_etypes = {
>>>> +    { FS_EVENT_INFO,    "info"  },
>>>> +    { FS_EVENT_WARN,    "warn"  },
>>>> +    { FS_EVENT_THRESH,  "thr"   },
>>>> +    { FS_EVENT_ERR,     "err"   },
>>>> +    { 0, NULL },
>>>> +};
>>>    Why are there these generic message types? Threshold messages 
>>> make good
>>> sense to me. But not so much the rest. If they don't have a clear 
>>> meaning,
>>> it will be a mess. So I also agree with a message like - "filesystem 
>>> has
>>> trouble, you should probably unmount and run fsck" - that's fine. But
>>> generic "info" or "warning" doesn't really carry any meaning on its 
>>> own and
>>> thus seems pretty useless to me. To explain a bit more, AFAIU this
>>> shouldn't be a generic logging interface where something like severity
>>> makes sense but rather a relatively specific interface notifying about
>>> events in filesystem userspace should know about so I expect 
>>> relatively low
>>> number of types of events, not tens or even hundreds...
>>>
>>>                                 Honza
>>
>> Getting rid of those would simplify the configuration part, indeed.
>> So we would be left with 'generic' and threshold events.
>> I guess I've overdone this part.
>
> For some filesystems, it may make sense to differentiate between a 
> generic warning and an error.  For BTRFS and ZFS for example, if there 
> is a csum error on a block, this will get automatically corrected in 
> many configurations, and won't require anything like fsck to be run, 
> but monitoring applications will still probably want to be notified.

Another key differentiation IMHO is between transient errors (like 
server is unavailable in a distributed filesystem) that will block the 
filesystem but might clear on their own, vs. permanent errors like 
unreadable drives that definitely will not clear until the administrator 
takes some action.  It's usually a reasonable approximation to call 
transient issues warnings, and permanent issues errors.

John




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
