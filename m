Message-ID: <486A1AA3.203@panasas.com>
Date: Tue, 01 Jul 2008 14:53:07 +0300
From: Benny Halevy <bhalevy@panasas.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix uninitialized variables for find_vma_prepare
 callers
References: <1214844882-22560-1-git-send-email-bhalevy@panasas.com> <Pine.LNX.4.64.0806301942220.22984@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0806301942220.22984@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Jun. 30, 2008, 22:00 +0300, Hugh Dickins <hugh@veritas.com> wrote:
> On Mon, 30 Jun 2008, Benny Halevy wrote:
>> gcc 4.3.0 correctly emits the following warnings.
>> When a vma covering addr is found, find_vma_prepare indeed returns without
>> setting pprev, rb_link, and rb_parent.
> 
> That's amusing, thank you.
> 
> You may wonder how the vma rb_tree has been working all these years
> despite that.  The answer is that we only use find_vma_prepare when
> about to insert a new vma: if there's anything already there, it's
> either an error condition, or we go off and unmap the overlap without
> taking any interest in those uninitialized values for linking.
> 
> It would be nicer to initialize them, and your patch is certainly
> nice and simple.  Would it have the effect, that it returns with
> vma == *pprev when addr falls within an existing vma?
> That would be a sensible outcome, I think.

No, *pprev will be set to the last parent encountered with this
patch, but doing what you suggested is possible, though I doubt
it matters since apparently nobody is using pprev in this path
otherwise stuff would've just broken.

Benny

> 
> Hugh
> 
>> [warnings snipped]
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  mm/mmap.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 3354fdd..81b9873 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -366,7 +366,7 @@ find_vma_prepare(struct mm_struct *mm, unsigned long addr,
>>  		if (vma_tmp->vm_end > addr) {
>>  			vma = vma_tmp;
>>  			if (vma_tmp->vm_start <= addr)
>> -				return vma;
>> +				break;
>>  			__rb_link = &__rb_parent->rb_left;
>>  		} else {
>>  			rb_prev = __rb_parent;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
