Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2406B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 21:57:15 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 140-v6so10209315itg.4
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:57:15 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e2-v6si288645itb.58.2018.03.26.18.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 18:57:14 -0700 (PDT)
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
 <20180102222341.GB20405@bombadil.infradead.org>
 <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
 <20180104013807.GA31392@tardis>
 <be1abd24-56c8-45bc-fecc-3f0c5b978678@oracle.com>
 <64ca3929-4044-9393-a6ca-70c0a2589a35@oracle.com>
 <20180104214658.GA20740@bombadil.infradead.org>
 <3e4ea0b9-686f-7e36-d80c-8577401517e2@oracle.com>
 <20180104231307.GA794@bombadil.infradead.org>
 <20180104234732.GM9671@linux.vnet.ibm.com>
 <20180105000707.GA22237@bombadil.infradead.org>
 <1515134773.21222.13.camel@perches.com>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <1e8c4382-b97f-659a-59fa-07c71efad970@oracle.com>
Date: Mon, 26 Mar 2018 18:56:51 -0700
MIME-Version: 1.0
In-Reply-To: <1515134773.21222.13.camel@perches.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Boqun Feng <boqun.feng@gmail.com>, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org

Folks,

Is anyone working on resolving the check patch issue as I am waiting to 
resubmit my patch. Will it be fine if I submitted the patch with the 
original macro as the check is in-correct.

I do not speak perl but I can do the process work. If folks think Joe's 
fix is fine I can submit it and perhaps someone can review it ?

Regards,

Shoaib


On 01/04/2018 10:46 PM, Joe Perches wrote:
> On Thu, 2018-01-04 at 16:07 -0800, Matthew Wilcox wrote:
>> On Thu, Jan 04, 2018 at 03:47:32PM -0800, Paul E. McKenney wrote:
>>> I was under the impression that typeof did not actually evaluate its
>>> argument, but rather only returned its type.  And there are a few macros
>>> with this pattern in mainline.
>>>
>>> Or am I confused about what typeof does?
>> I think checkpatch is confused by the '*' in the typeof argument:
>>
>> $ git diff |./scripts/checkpatch.pl --strict
>> CHECK: Macro argument reuse 'ptr' - possible side-effects?
>> #29: FILE: include/linux/rcupdate.h:896:
>> +#define kfree_rcu(ptr, rcu_head)                                        \
>> +	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
>>
>> If one removes the '*', the warning goes away.
>>
>> I'm no perlista, but Joe, would this regexp modification make sense?
>>
>> +++ b/scripts/checkpatch.pl
>> @@ -4957,7 +4957,7 @@ sub process {
>>                                  next if ($arg =~ /\.\.\./);
>>                                  next if ($arg =~ /^type$/i);
>>                                  my $tmp_stmt = $define_stmt;
>> -                               $tmp_stmt =~ s/\b(typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*\s*$arg\s*\)*\b//g;
>> +                               $tmp_stmt =~ s/\b(typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*\**\(*\s*$arg\s*\)*\b//g;
> I supposed ideally it'd be more like
>
> $tmp_stmt =~ s/\b(?:typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*(?:\s*\*\s*)*\s*\(*\s*$arg\s*\)*\b//g;
>
> Adding ?: at the start to not capture and
> (?:\s*\*\s*)* for any number of * with any
> surrounding spacings.
