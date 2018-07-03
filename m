Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEC916B02AA
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 21:38:41 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z26-v6so451372qto.17
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 18:38:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k9-v6si4046460qvd.123.2018.07.02.18.38.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 18:38:39 -0700 (PDT)
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
 <1530570880.3179.9.camel@HansenPartnership.com>
 <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <6e86c673-af14-2111-ea30-dc6cac655414@redhat.com>
Date: Tue, 3 Jul 2018 09:38:31 +0800
MIME-Version: 1.0
In-Reply-To: <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On 07/03/2018 07:19 AM, Andrew Morton wrote:
> On Mon, 02 Jul 2018 15:34:40 -0700 James Bottomley <James.Bottomley@Han=
senPartnership.com> wrote:
>
>> On Mon, 2018-07-02 at 14:18 -0700, Andrew Morton wrote:
>>> On Mon, 2 Jul 2018 12:34:00 -0700 Linus Torvalds <torvalds@linux-foun=

>>> dation.org> wrote:
>>>
>>>> On Sun, Jul 1, 2018 at 10:52 PM Waiman Long <longman@redhat.com>
>>>> wrote:
>>>>> A rogue application can potentially create a large number of
>>>>> negative
>>>>> dentries in the system consuming most of the memory available if
>>>>> it
>>>>> is not under the direct control of a memory controller that
>>>>> enforce
>>>>> kernel memory limit.
>>>> I certainly don't mind the patch series, but I would like it to be
>>>> accompanied with some actual example numbers, just to make it all a
>>>> bit more concrete.
>>>>
>>>> Maybe even performance numbers showing "look, I've filled the
>>>> dentry
>>>> lists with nasty negative dentries, now it's all slower because we
>>>> walk those less interesting entries".
>>>>
>>> (Please cc linux-mm@kvack.org on this work)
>>>
>>> Yup.  The description of the user-visible impact of current behavior
>>> is far too vague.
>>>
>>> In the [5/6] changelog it is mentioned that a large number of -ve
>>> dentries can lead to oom-killings.  This sounds bad - -ve dentries
>>> should be trivially reclaimable and we shouldn't be oom-killing in
>>> such a situation.
>> If you're old enough, it's d=C3=A9j=C3=A0 vu; Andrea went on a negativ=
e dentry
>> rampage about 15 years ago:
>>
>> https://lkml.org/lkml/2002/5/24/71
> That's kinda funny.
>
>> I think the summary of the thread is that it's not worth it because
>> dentries are a clean cache, so they're immediately shrinkable.
> Yes, "should be".  I could understand that the presence of huge
> nunmbers of -ve dentries could result in undesirable reclaim of
> pagecache, etc.  Triggering oom-killings is very bad, and presumably
> has the same cause.
>
> Before we go and add a large amount of code to do the shrinker's job
> for it, we should get a full understanding of what's going wrong.  Is
> it because the dentry_lru had a mixture of +ve and -ve dentries?=20
> Should we have a separate LRU for -ve dentries?  Are we appropriately
> aging the various dentries?  etc.

I have actually investigated having a separate LRU for negative
dentries. That will result in a far more invasive patch that will be
more disruptive.

Another change that was suggested by a colleague is to put a newly
created -ve dentry to the tail (LRU end) of the LRU and move it to the
head only if it is accessed a second time. That will put most of the
negative dentries at the tail that will be more easily trimmed away.

Cheers,
Longman
