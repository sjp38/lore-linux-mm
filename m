Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 661966B578C
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 11:03:34 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z44-v6so14323110qtg.5
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 08:03:34 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m77-v6si9000169qkl.347.2018.08.31.08.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 08:03:33 -0700 (PDT)
Subject: Re: [PATCH 1/2] fs/dcache: Track & report number of negative dentries
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-2-git-send-email-longman@redhat.com>
 <20180829001153.GD1572@dastard>
 <20180831143100.GA6379@bombadil.infradead.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <2b1fcabb-ff53-7906-c4d3-dfe19f8449e6@redhat.com>
Date: Fri, 31 Aug 2018 11:03:31 -0400
MIME-Version: 1.0
In-Reply-To: <20180831143100.GA6379@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 08/31/2018 10:31 AM, Matthew Wilcox wrote:
> On Wed, Aug 29, 2018 at 10:11:53AM +1000, Dave Chinner wrote:
>>> +++ b/Documentation/sysctl/fs.txt
>>> @@ -63,19 +63,26 @@ struct {
>>>          int nr_unused;
>>>          int age_limit;         /* age in seconds */
>>>          int want_pages;        /* pages requested by system */
>>> -        int dummy[2];
>>> +        int nr_negative;       /* # of unused negative dentries */
>>> +        int dummy;
>>>  } dentry_stat = {0, 0, 45, 0,};
>> That's not a backwards compatible ABI change. Those dummy fields
>> used to represent some metric we no longer calculate, and there are
>> probably still monitoring apps out there that think they still have
>> the old meaning. i.e. they are still visible to userspace:
> I believe you are incorrect.  dentry_stat was introduced in 2.1.60 with
> this hunk:
>
> +struct {
> +       int nr_dentry;
> +       int nr_unused;
> +       int age_limit;          /* age in seconds */
> +       int want_pages;         /* pages requested by system */
> +       int dummy[2];
> +} dentry_stat = {0, 0, 45, 0,};
> +
>
> Looking through the rest of the dentry_stat changes in the 2.1.60 release,
> it's not replacing anything, it's adding new information.

Thanks for looking up earlier non-git source tree. If that is the case,
the dummy[2] was there just for future extension purpose. It should be
perfectly fine to reuse one of the dummy entry for negative dentry count
then as no sane application would have checked the last 2 entries of
dentry-state and do dummy things if they are non-zero.

Cheers,
Longman
