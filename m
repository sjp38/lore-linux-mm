Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A27DB6B0006
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 04:53:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4-v6so7489804wme.7
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 01:53:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5-v6si891960wre.145.2018.07.30.01.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 01:53:55 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm: proc/pid/smaps_rollup: convert to single value
 seq_file
References: <20180723111933.15443-1-vbabka@suse.cz>
 <20180723111933.15443-5-vbabka@suse.cz>
 <cb1d1965-9a13-e80f-dfde-a5d3bf9f510c@suse.cz> <20180726162637.GB25227@avx2>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bf4525b0-fd5b-4c4c-2cb3-adee3dd95a48@suse.cz>
Date: Mon, 30 Jul 2018 10:53:53 +0200
MIME-Version: 1.0
In-Reply-To: <20180726162637.GB25227@avx2>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Colascione <dancol@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org

On 07/26/2018 06:26 PM, Alexey Dobriyan wrote:
> On Wed, Jul 25, 2018 at 08:53:53AM +0200, Vlastimil Babka wrote:
>> I moved the reply to this thread since the "added to -mm tree"
>> notification Alexey replied to in <20180724182908.GD27053@avx2> has
>> reduced CC list and is not linked to the patch postings.
>>
>> On 07/24/2018 08:29 PM, Alexey Dobriyan wrote:
>>> On Mon, Jul 23, 2018 at 04:55:48PM -0700, akpm@linux-foundation.org wrote:
>>>> The patch titled
>>>>      Subject: mm: /proc/pid/smaps_rollup: convert to single value seq_file
>>>> has been added to the -mm tree.  Its filename is
>>>>      mm-proc-pid-smaps_rollup-convert-to-single-value-seq_file.patch
>>>
>>>> Subject: mm: /proc/pid/smaps_rollup: convert to single value seq_file
>>>>
>>>> The /proc/pid/smaps_rollup file is currently implemented via the
>>>> m_start/m_next/m_stop seq_file iterators shared with the other maps files,
>>>> that iterate over vma's.  However, the rollup file doesn't print anything
>>>> for each vma, only accumulate the stats.
>>>
>>> What I don't understand why keep seq_ops then and not do all the work in
>>> ->show hook.  Currently /proc/*/smaps_rollup is at ~500 bytes so with
>>> minimum 1 page seq buffer, no buffer resizing is possible.
>>
>> Hmm IIUC seq_file also provides the buffer and handles feeding the data
>> from there to the user process, which might have called read() with a smaller
>> buffer than that. So I would rather not avoid the seq_file infrastructure.
>> Or you're saying it could be converted to single_open()? Maybe, with more work.
> 
> Prefereably yes.

OK here it is. Sending as a new patch instead of delta, as that's easier
to review - the delta is significant. Line stats wise it's the same.
Again a bit less boilerplate thans to no special seq_ops, a bit more
copy/paste in the open and release functions. But I guess it's better
overall.

----8>----
