Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E224C6B026D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 02:56:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o60-v6so2701832edd.13
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 23:56:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c10-v6si817286edk.121.2018.07.24.23.56.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 23:56:15 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm: proc/pid/smaps_rollup: convert to single value
 seq_file
References: <20180723111933.15443-1-vbabka@suse.cz>
 <20180723111933.15443-5-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cb1d1965-9a13-e80f-dfde-a5d3bf9f510c@suse.cz>
Date: Wed, 25 Jul 2018 08:53:53 +0200
MIME-Version: 1.0
In-Reply-To: <20180723111933.15443-5-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>
Cc: Daniel Colascione <dancol@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org

I moved the reply to this thread since the "added to -mm tree"
notification Alexey replied to in <20180724182908.GD27053@avx2> has
reduced CC list and is not linked to the patch postings.

On 07/24/2018 08:29 PM, Alexey Dobriyan wrote:
> On Mon, Jul 23, 2018 at 04:55:48PM -0700, akpm@linux-foundation.org wrote:
>> The patch titled
>>      Subject: mm: /proc/pid/smaps_rollup: convert to single value seq_file
>> has been added to the -mm tree.  Its filename is
>>      mm-proc-pid-smaps_rollup-convert-to-single-value-seq_file.patch
> 
>> Subject: mm: /proc/pid/smaps_rollup: convert to single value seq_file
>>
>> The /proc/pid/smaps_rollup file is currently implemented via the
>> m_start/m_next/m_stop seq_file iterators shared with the other maps files,
>> that iterate over vma's.  However, the rollup file doesn't print anything
>> for each vma, only accumulate the stats.
> 
> What I don't understand why keep seq_ops then and not do all the work in
> ->show hook.  Currently /proc/*/smaps_rollup is at ~500 bytes so with
> minimum 1 page seq buffer, no buffer resizing is possible.

Hmm IIUC seq_file also provides the buffer and handles feeding the data
from there to the user process, which might have called read() with a smaller
buffer than that. So I would rather not avoid the seq_file infrastructure.
Or you're saying it could be converted to single_open()? Maybe, with more work.

>> +static int show_smaps_rollup(struct seq_file *m, void *v)
>> +{
>> +	struct proc_maps_private *priv = m->private;
>> +	struct mem_size_stats *mss = priv->rollup;
>> +	struct vm_area_struct *vma;
>> +
>> +	/*
>> +	 * We might be called multiple times when e.g. the seq buffer
>> +	 * overflows. Gather the stats only once.
> 
> It doesn't!

Because the buffer is 1 page and the data is ~500 bytes as you said above?
Agreed, but I wouldn't want to depend on data not growing in the future or
the initial buffer not getting smaller. I could extend the comment that this
is theoretical for now?
 
>> +	if (!mss->finished) {
>> +		for (vma = priv->mm->mmap; vma; vma = vma->vm_next) {
>> +			smap_gather_stats(vma, mss);
>> +			mss->last_vma_end = vma->vm_end;
>>  		}
>> -		last_vma = !m_next_vma(priv, vma);
>> -	} else {
>> -		rollup_mode = false;
>> -		memset(&mss_stack, 0, sizeof(mss_stack));
>> -		mss = &mss_stack;
