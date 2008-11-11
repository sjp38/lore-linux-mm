Message-ID: <491A08D0.9030502@redhat.com>
Date: Wed, 12 Nov 2008 00:36:00 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <1226409701-14831-3-git-send-email-ieidus@redhat.com> <20081111114555.eb808843.akpm@linux-foundation.org> <20081111210655.GG10818@random.random> <Pine.LNX.4.64.0811111522150.27767@quilx.com> <4919FB95.4060105@redhat.com> <Pine.LNX.4.64.0811111544350.28346@quilx.com>
In-Reply-To: <Pine.LNX.4.64.0811111544350.28346@quilx.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 11 Nov 2008, Avi Kivity wrote:
>
>   
>> Christoph Lameter wrote:
>>     
>>> page migration requires the page to be on the LRU. That could be changed
>>> if you have a different means of isolating a page from its page tables.
>>>
>>>       
>> Isn't rmap the means of isolating a page from its page tables?  I guess I'm
>> misunderstanding something.
>>     
>
> In order to migrate a page one first has to make sure that userspace and
> the kernel cannot access the page in any way. User space must be made to
> generate page faults and all kernel references must be accounted for and
> not be in use.
>
> The user space portion involves changing the page tables so that faults
> are generated.
>
> The kernel portion isolates the page from the LRU (to exempt it from
> kernel reclaim handling etc).
>
>   

Thanks.

> Only then can the page and its metadata be copied to a new location.
>
> Guess you already have the LRU portion done. So you just need the user
> space isolation portion?
>   

We don't want to limit all faults, just writes.  So we write protect the 
page before merging.

What do you mean by page metadata?  obviously the dirty bit (Izik?), 
accessed bit and position in the LRU are desirable (the last is quite 
difficult for ksm -- the page occupied *two* positions in the LRU).

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
