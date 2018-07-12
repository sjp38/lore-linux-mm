Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB7F6B000D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:12:31 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m6-v6so35045250qkd.20
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:12:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u20-v6si7110550qtc.86.2018.07.12.09.12.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 09:12:30 -0700 (PDT)
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
References: <1530905572-817-1-git-send-email-longman@redhat.com>
 <20180709081920.GD22049@dhcp22.suse.cz>
 <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
 <20180710142740.GQ14284@dhcp22.suse.cz>
 <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
 <20180711102139.GG20050@dhcp22.suse.cz>
 <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
 <20180712084807.GF32648@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Message-ID: <c68aa6ad-9e35-f828-6373-39938fd6e2a7@redhat.com>
Date: Thu, 12 Jul 2018 12:12:28 -0400
MIME-Version: 1.0
In-Reply-To: <20180712084807.GF32648@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On 07/12/2018 04:48 AM, Michal Hocko wrote:
> On Wed 11-07-18 11:13:58, Waiman Long wrote:
>> On 07/11/2018 06:21 AM, Michal Hocko wrote:
>>> On Tue 10-07-18 12:09:17, Waiman Long wrote:
>>>> On 07/10/2018 10:27 AM, Michal Hocko wrote:
>>>>> On Mon 09-07-18 12:01:04, Waiman Long wrote:
>>>>>> On 07/09/2018 04:19 AM, Michal Hocko wrote:
>>> [...]
>>>>>>> percentage has turned out to be a really wrong unit for many tuna=
bles
>>>>>>> over time. Even 1% can be just too much on really large machines.=

>>>>>> Yes, that is true. Do you have any suggestion of what kind of unit=

>>>>>> should be used? I can scale down the unit to 0.1% of the system me=
mory.
>>>>>> Alternatively, one unit can be 10k/cpu thread, so a 20-thread syst=
em
>>>>>> corresponds to 200k, etc.
>>>>> I simply think this is a strange user interface. How much is a
>>>>> reasonable number? How can any admin figure that out?
>>>> Without the optional enforcement, the limit is essentially just a
>>>> notification mechanism where the system signals that there is someth=
ing
>>>> wrong going on and the system administrator need to take a look. So =
it
>>>> is perfectly OK if the limit is sufficiently high that normally we w=
on't
>>>> need to use that many negative dentries. The goal is to prevent nega=
tive
>>>> dentries from consuming a significant portion of the system memory.
>>> So again. How do you tell the right number?
>> I guess it will be more a trial and error kind of adjustment as the
>> right figure will depend on the kind of workloads being run on the
>> system. So unless the enforcement option is turned on, setting a limit=

>> that is too small won't have too much impact over than a slight
>> performance drop because of the invocation of the slowpaths and the
>> warning messages in the console. Whenever a non-zero value is written
>> into "neg-dentry-limit", an informational message will be printed abou=
t
>> what the actual negative dentry limits
>> will be. It can be compared against the current negative dentry number=

>> (5th number) from "dentry-state" to see if there is enough safe margin=

>> to avoid false positive warning.
> What you wrote above is exactly the reason why I do not like yet anothe=
r
> tunable. If you cannot give a reasonable cook book on how to tune this
> properly then nobody will really use it and we will eventually find
> out that we have a user visible API which might simply make further
> development harder and which will be hard to get rid of because you
> never know who is going to use it for strange purposes.
>
> Really, negative entries are a cache and if we do not shrink that cache=

> properly then this should be fixed rather than giving up and pretending=

> that the admin is the one to control that.

The rationale beside this patchset comes from a customer request to have
the ability to track and limit negative dentries. The goal is to not
have a disproportionate amount of memory being consumed by negative
dentries. Setting the limit and reaching it does nothing other than
gives out a warning about the limit being breached unless the enforce
option is turned on which is for the paranoids.

There is no one right value for the limit. It all depends on what the
users think is a disproportionate amount of memory.

Cheers,
Longman
