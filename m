Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8556B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 21:31:03 -0400 (EDT)
Received: by obbop1 with SMTP id op1so58227910obb.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:31:03 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id zc1si16094091obc.95.2015.06.25.18.31.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 18:31:02 -0700 (PDT)
Received: by oiyy130 with SMTP id y130so65465958oiy.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:31:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150626005808.GA5704@swordfish>
References: <CAA25o9SCnDYZ6vXWQWEWGDiwpV9rf+S_3Np8nJrWqHJ1x6-kMg@mail.gmail.com>
	<20150624152518.d3a5408f2bde405df1e6e5c4@linux-foundation.org>
	<CAA25o9RNLr4Gk_4m56bAf7_RBsObrccFWPtd-9jwuHg1NLdRTA@mail.gmail.com>
	<CAA25o9ShiKyPTBYbVooA=azb+XO9PWFtididoyPa4s-v56mvBg@mail.gmail.com>
	<20150626005808.GA5704@swordfish>
Date: Thu, 25 Jun 2015 18:31:02 -0700
Message-ID: <CAA25o9TCj0YSw1JhuPVsu9PzEMwnC2pLHNvNdMa+0OpJd1X64Q@mail.gmail.com>
Subject: Re: extremely long blockages when doing random writes to SSD
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

We're using CFQ.

CONFIG_DEFAULT_IOSCHED="cfq"
...
CONFIG_IOSCHED_CFQ=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_NOOP=y

On Thu, Jun 25, 2015 at 5:58 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> Hello,
>
> On (06/25/15 11:24), Luigi Semenzato wrote:
>> I looked at this some more and I am not sure that there is any bug, or
>> other possible tuning.
>>
>> While the random-write process runs, iostat -x -k 1 reports these numbers:
>>
>> average queue size: around 300
>> average write wait: typically 200 to 400 ms, but can be over 1000 ms
>> average read wait: typically 50 to 100 ms
>>
>> (more info at crbug.com/414709)
>>
>> The read latency may be enough to explain the jank.  In addition, the
>> browser can do fsyncs, and I think that those will block for a long
>> time.
>>
>> Ionice doesn't seem to make a difference.  I suspect that once the
>> blocks are in the output queue, it's first-come/first-serve.  Is this
>> correct or am I confused?
>>
>> We can fix this on the application side but only partially.  The OS
>> version updater can use O_SYNC.  The problem is that his can happen in
>> a number of situations, such as when simply downloading a large file,
>> and in other code we don't control.
>>
>
> do you use CONFIG_IOSCHED_DEADLINE or CONFIG_IOSCHED_CFQ?
>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
