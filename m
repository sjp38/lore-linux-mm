Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id E1EA36B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 16:39:56 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id x3so1737859qcv.16
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 13:39:56 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id d67si1199389qgf.175.2014.02.19.13.39.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 13:39:54 -0800 (PST)
Message-ID: <530524A3.6090700@surriel.com>
Date: Wed, 19 Feb 2014 16:39:47 -0500
From: Rik van Riel <riel@surriel.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm:prototype for the updated swapoff implementation
References: <20140219003522.GA8887@kelleynnn-virtual-machine> <20140219132757.58b61f07bad914b3848275e9@linux-foundation.org>
In-Reply-To: <20140219132757.58b61f07bad914b3848275e9@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kelley Nielsen <kelleynnn@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, opw-kernel@googlegroups.com, jamieliu@google.com, sjenning@linux.vnet.ibm.com, Hugh Dickins <hughd@google.com>

On 02/19/2014 04:27 PM, Andrew Morton wrote:
> On Tue, 18 Feb 2014 16:35:22 -0800 Kelley Nielsen <kelleynnn@gmail.com> wrote:
> 
>> The function try_to_unuse() is of quadratic complexity, with a lot of
>> wasted effort. It unuses swap entries one by one, potentially iterating
>> over all the page tables for all the processes in the system for each
>> one.
>>
>> This new proposed implementation of try_to_unuse simplifies its
>> complexity to linear. It iterates over the system's mms once, unusing
>> all the affected entries as it walks each set of page tables. It also
>> makes similar changes to shmem_unuse.
>>
>> Improvement
>>
>> swapoff was called on a swap partition containing about 50M of data,
>> and calls to the function unuse_pte_range were counted.
>>
>> Present implementation....about 22.5M calls.
>> Prototype.................about  7.0K   calls.
> 
> Do you have situations in which swapoff is taking an unacceptable
> amount of time?  If so, please update the changelog to provide full
> details on this, with before-and-after timing measurements.

I have seen plenty of that.  With just a few GB in swap space in
use, on a system with 24GB of RAM, and about a dozen GB in use
by various processes, I have seen swapoff take several hours of
CPU time.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
