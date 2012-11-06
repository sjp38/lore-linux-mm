Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 1BF836B002B
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 12:41:37 -0500 (EST)
Date: Tue, 06 Nov 2012 12:41:33 -0500 (EST)
Message-Id: <20121106.124133.1287008316099748150.davem@davemloft.net>
Subject: Re: [PATCH 15/16] mm: use vm_unmapped_area() on sparc32
 architecture
From: David Miller <davem@davemloft.net>
In-Reply-To: <5098BC7F.7090702@redhat.com>
References: <1352155633-8648-16-git-send-email-walken@google.com>
	<20121105.202501.1246122770431623794.davem@davemloft.net>
	<5098BC7F.7090702@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: walken@google.com, akpm@linux-foundation.org, hughd@google.com, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, ralf@linux-mips.org, lethal@linux-sh.org, cmetcalf@tilera.com, x86@kernel.org, wli@holomorphy.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

From: Rik van Riel <riel@redhat.com>
Date: Tue, 06 Nov 2012 02:30:07 -0500

> On 11/05/2012 08:25 PM, David Miller wrote:
>> From: Michel Lespinasse <walken@google.com>
>> Date: Mon,  5 Nov 2012 14:47:12 -0800
>>
>>> Update the sparc32 arch_get_unmapped_area function to make use of
>>> vm_unmapped_area() instead of implementing a brute force search.
>>>
>>> Signed-off-by: Michel Lespinasse <walken@google.com>
>>
>> Hmmm...
>>
>>> -	if (flags & MAP_SHARED)
>>> -		addr = COLOUR_ALIGN(addr);
>>> -	else
>>> -		addr = PAGE_ALIGN(addr);
>>
>> What part of vm_unmapped_area() is going to duplicate this special
>> aligning logic we need on sparc?
>>
> 
> That would be this part:
> 
> +found:
> + /* We found a suitable gap. Clip it with the original low_limit. */
> +	if (gap_start < info->low_limit)
> +		gap_start = info->low_limit;
> +
> +	/* Adjust gap address to the desired alignment */
> + gap_start += (info->align_offset - gap_start) & info->align_mask;
> +
> +	VM_BUG_ON(gap_start + info->length > info->high_limit);
> +	VM_BUG_ON(gap_start + info->length > gap_end);
> +	return gap_start;
> +}

Ok, now I understand.  Works for me:

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
