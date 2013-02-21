Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 6B3046B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 15:48:57 -0500 (EST)
Message-ID: <512687F9.8090000@synopsys.com>
Date: Fri, 22 Feb 2013 02:17:53 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/2] memblock: add assertion for zero allocation alignment
References: <20130221193639.GN3570@htj.dyndns.org> <1361477421-3964-1-git-send-email-vgupta@synopsys.com> <CAE9FiQV20uj_kOViCOd4gdPFuAf28fEbjhGCrzNogQWx5T3+zg@mail.gmail.com>
In-Reply-To: <CAE9FiQV20uj_kOViCOd4gdPFuAf28fEbjhGCrzNogQWx5T3+zg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Friday 22 February 2013 02:01 AM, Yinghai Lu wrote:
> On Thu, Feb 21, 2013 at 12:10 PM, Vineet Gupta
> <Vineet.Gupta1@synopsys.com> wrote:
>> This came to light when calling memblock allocator from arc port (for
>> copying flattended DT). If a "0" alignment is passed, the allocator
>> round_up() call incorrectly rounds up the size to 0.
>>
>> round_up(num, alignto) => ((num - 1) | (alignto -1)) + 1
>>
>> While the obvious allocation failure causes kernel to panic, it is
>> better to warn the caller to fix the code.
>>
>> Tejun suggested that instead of BUG_ON(!align) - which might be
>> ineffective due to pending console init and such, it is better to
>> WARN_ON, and continue the boot with a reasonable default align.
>>
>> Caller passing @size need not be handled similarly as the subsequent
>> panic will indicate that anyhow.
>>
>> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Yinghai Lu <yinghai@kernel.org>
>> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>  mm/memblock.c |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 1bcd9b9..f3804bd 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -824,6 +824,9 @@ static phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
>>         /* align @size to avoid excessive fragmentation on reserved array */
>>         size = round_up(size, align);
>>
>> +       if (WARN_ON(!align))
>> +               align = __alignof__(long long);
>> +
> the checking should be put before round_up?

Oops my bad.

Interestingly however, I did test this exact patch on ARC before sending out -
passing @align = 0 to make it hit the WARN. It prints the warning, and uses
@size=0, @align=8 for memblock_find_in_range_node() and successfully allocates
memory as opposed to failure for @size=0, @align=0 scenario. This is kind of weird.

Anyhow I'll send the updated patch to fix the gotcha !

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
