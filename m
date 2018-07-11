Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 412696B0271
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 11:14:04 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v65-v6so11527061qka.23
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:14:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t34-v6si5865668qth.151.2018.07.11.08.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 08:13:59 -0700 (PDT)
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
References: <1530905572-817-1-git-send-email-longman@redhat.com>
 <20180709081920.GD22049@dhcp22.suse.cz>
 <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
 <20180710142740.GQ14284@dhcp22.suse.cz>
 <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
 <20180711102139.GG20050@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Message-ID: <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
Date: Wed, 11 Jul 2018 11:13:58 -0400
MIME-Version: 1.0
In-Reply-To: <20180711102139.GG20050@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On 07/11/2018 06:21 AM, Michal Hocko wrote:
> On Tue 10-07-18 12:09:17, Waiman Long wrote:
>> On 07/10/2018 10:27 AM, Michal Hocko wrote:
>>> On Mon 09-07-18 12:01:04, Waiman Long wrote:
>>>> On 07/09/2018 04:19 AM, Michal Hocko wrote:
> [...]
>>>>> percentage has turned out to be a really wrong unit for many tunabl=
es
>>>>> over time. Even 1% can be just too much on really large machines.
>>>> Yes, that is true. Do you have any suggestion of what kind of unit
>>>> should be used? I can scale down the unit to 0.1% of the system memo=
ry.
>>>> Alternatively, one unit can be 10k/cpu thread, so a 20-thread system=

>>>> corresponds to 200k, etc.
>>> I simply think this is a strange user interface. How much is a
>>> reasonable number? How can any admin figure that out?
>> Without the optional enforcement, the limit is essentially just a
>> notification mechanism where the system signals that there is somethin=
g
>> wrong going on and the system administrator need to take a look. So it=

>> is perfectly OK if the limit is sufficiently high that normally we won=
't
>> need to use that many negative dentries. The goal is to prevent negati=
ve
>> dentries from consuming a significant portion of the system memory.
> So again. How do you tell the right number?

I guess it will be more a trial and error kind of adjustment as the
right figure will depend on the kind of workloads being run on the
system. So unless the enforcement option is turned on, setting a limit
that is too small won't have too much impact over than a slight
performance drop because of the invocation of the slowpaths and the
warning messages in the console. Whenever a non-zero value is written
into "neg-dentry-limit", an informational message will be printed about
what the actual negative dentry limits
will be. It can be compared against the current negative dentry number
(5th number) from "dentry-state" to see if there is enough safe margin
to avoid false positive warning.

>
>> I am going to reduce the granularity of each unit to 1/1000 of the tot=
al
>> system memory so that for large system with TB of memory, a smaller
>> amount of memory can be specified.
> It is just a matter of time for this to be too coarse as well.

The goal is to not have too much memory being consumed by negative
dentries and also the limit won't be reached by regular daily
activities. So a limit of 1/1000 of the total system memory will be good
enough on large memory system even if the absolute number is really big.

Cheers,
Longman
