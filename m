Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 2458C6B0087
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 06:37:29 -0400 (EDT)
Message-ID: <51ADC365.4010307@redhat.com>
Date: Tue, 04 Jun 2013 06:37:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] Re: Repeated fork() causes SLAB to grow without bound
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu> <502D42E5.7090403@redhat.com> <20120818000312.GA4262@evergreen.ssec.wisc.edu> <502F100A.1080401@redhat.com> <alpine.LSU.2.00.1208200032450.24855@eggly.anvils> <CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com> <20120822032057.GA30871@google.com> <50345232.4090002@redhat.com> <20130603195003.GA31275@evergreen.ssec.wisc.edu>
In-Reply-To: <20130603195003.GA31275@evergreen.ssec.wisc.edu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/03/2013 03:50 PM, Daniel Forrest wrote:
> On Tue, Aug 21, 2012 at 11:29:54PM -0400, Rik van Riel wrote:
>> On 08/21/2012 11:20 PM, Michel Lespinasse wrote:
>>> On Mon, Aug 20, 2012 at 02:39:26AM -0700, Michel Lespinasse wrote:
>>>> Instead of adding an atomic count for page references, we could limit
>>>> the anon_vma stacking depth. In fork, we would only clone anon_vmas
>>>> that have a low enough generation count. I think that's not great
>>>> (adds a special case for the deep-fork-without-exec behavior), but
>>>> still better than the atomic page reference counter.
>>>
>>> Here is an attached patch to demonstrate the idea.
>>>
>>> anon_vma_clone() is modified to return the length of the existing same_vma
>>> anon vma chain, and we create a new anon_vma in the child only on the first
>>> fork (this could be tweaked to allow up to a set number of forks, but
>>> I think the first fork would cover all the common forking server cases).
>>
>> I suspect we need 2 or 3.
>>
>> Some forking servers first fork off one child, and have
>> the original parent exit, in order to "background the server".
>> That first child then becomes the parent to the real child
>> processes that do the work.
>>
>> It is conceivable that we might need an extra level for
>> processes that do something special with privilege dropping,
>> namespace changing, etc...
>>
>> Even setting the threshold to 5 should be totally harmless,
>> since the problem does not kick in until we have really
>> long chains, like in Dan's bug report.
>
> I have been running with Michel's patch (with the threshold set to 5)
> for quite a few months now and can confirm that it does indeed solve
> my problem.  I am not a kernel developer, so I would appreciate if one
> of you could push this into the kernel tree.
>
> NOTE: I have attached Michel's patch with "(length > 1)" modified to
> "(length > 5)" and added a "Tested-by:".

Thank you for testing this.

I believe this code should go into the Linux kernel,
since it closes up what could be a denial of service
attack (albeit a local one) with the anonvma code.

> On Mon, Aug 20, 2012 at 02:39:26AM -0700, Michel Lespinasse wrote:
>> Instead of adding an atomic count for page references, we could limit
>> the anon_vma stacking depth. In fork, we would only clone anon_vmas
>> that have a low enough generation count. I think that's not great
>> (adds a special case for the deep-fork-without-exec behavior), but
>> still better than the atomic page reference counter.
>
> Here is an attached patch to demonstrate the idea.
>
> anon_vma_clone() is modified to return the length of the existing same_vma
> anon vma chain, and we create a new anon_vma in the child only on the first
> fork (this could be tweaked to allow up to a set number of forks, but
> I think the first fork would cover all the common forking server cases).
>
> Signed-off-by: Michel Lespinasse <walken@google.com>
> Tested-by: Daniel Forrest <dan.forrest@ssec.wisc.edu>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
