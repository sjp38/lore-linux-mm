Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D86A36B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 20:11:07 -0400 (EDT)
Message-ID: <4BBBCD6F.3050707@redhat.com>
Date: Tue, 06 Apr 2010 20:10:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/14] mm: Share the anon_vma ref counts between KSM and
 page migration
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>	<1270224168-14775-4-git-send-email-mel@csn.ul.ie> <20100406170528.ecb30941.akpm@linux-foundation.org>
In-Reply-To: <20100406170528.ecb30941.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/06/2010 08:05 PM, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:37 +0100
> Mel Gorman<mel@csn.ul.ie>  wrote:

>> +#if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
>> +
>> +	/*
>> +	 * The external_refcount is taken by either KSM or page migration
>> +	 * to take a reference to an anon_vma when there is no
>> +	 * guarantee that the vma of page tables will exist for
>> +	 * the duration of the operation. A caller that takes
>> +	 * the reference is responsible for clearing up the
>> +	 * anon_vma if they are the last user on release
>> +	 */
>> +	atomic_t external_refcount;
>>   #endif
>
> hah.

>> +	anonvma_external_refcount_init(anon_vma);
>
> What a mouthful.  Can we do s/external_//g?

For the function, sure.

However, I believe it would be good to keep the variable
inside the anon_vma as "external_refcount", because the
VMAs attached to the anon_vma take a reference by being
on the list (and leave the refcount alone).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
