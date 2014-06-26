Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5086E6B008A
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 11:52:08 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id c1so912858igq.2
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 08:52:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y5si3199236igl.3.2014.06.26.08.52.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jun 2014 08:52:07 -0700 (PDT)
Message-ID: <53AC4182.3020504@redhat.com>
Date: Thu, 26 Jun 2014 11:51:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: numa: setup_node_data(): drop dead code and rename
 function
References: <20140619222019.3db6ad7e@redhat.com>	<53AC335F.4010308@redhat.com> <20140626110501.78bb611d@redhat.com>
In-Reply-To: <20140626110501.78bb611d@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, andi@firstfloor.org, akpm@linux-foundation.org, rientjes@google.com

On 06/26/2014 11:05 AM, Luiz Capitulino wrote:
> On Thu, 26 Jun 2014 10:51:11 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> On 06/19/2014 10:20 PM, Luiz Capitulino wrote:
> 
>>>> @@ -523,8 +508,17 @@ static int __init numa_register_memblks(struct
>>>> numa_meminfo *mi) end = max(mi->blk[i].end, end); }
>>>>
>>>> -		if (start < end) -			setup_node_data(nid, start, end); +		if
>>>> (start >= end) +			continue; + +		/* +		 * Don't confuse VM with a
>>>> node that doesn't have the +		 * minimum amount of memory: +		 */ +
>>>> if (end && (end - start) < NODE_MIN_SIZE) +			continue; + +
>>>> alloc_node_data(nid); }
> 
> Minor nit.  If we skip a too-small node, should we remember that we
> did so, and add its memory to another node, assuming it is physically
> contiguous memory?
> 
>> Interesting point. Honest question, please disregard if this doesn't
>> make sense: but won't this affect automatic numa performance? Because
>> the kernel won't know that that extra memory actually pertains to another
>> node and hence that extra memory will have a difference distance of the
>> node that's making use it of it.

If there is so little memory the kernel is unwilling to turn
it into its own zone or node, it should not be enough to
affect placement policy at all.

Whether or not we use that last little bit of memory is probably
not very important, either :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
