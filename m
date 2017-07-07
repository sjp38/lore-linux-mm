Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC7E16B02C3
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 04:44:10 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id l38so9345837uaf.1
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 01:44:10 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i6si8640vkg.260.2017.07.07.01.44.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 01:44:09 -0700 (PDT)
Subject: Re: [PATCH 1/3] Protectable memory support
References: <20170705134628.3803-1-igor.stoppa@huawei.com>
 <20170705134628.3803-2-igor.stoppa@huawei.com>
 <20170706162742.GA2919@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <1665fd00-5908-2399-577d-1972c7d1c63b@huawei.com>
Date: Fri, 7 Jul 2017 11:42:09 +0300
MIME-Version: 1.0
In-Reply-To: <20170706162742.GA2919@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, keescook@chromium.org
Cc: mhocko@kernel.org, jmorris@namei.org, labbott@redhat.com, hch@infradead.org, penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 06/07/17 19:27, Jerome Glisse wrote:
> On Wed, Jul 05, 2017 at 04:46:26PM +0300, Igor Stoppa wrote:

[...]

>> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
>> index 6b5818d..acc0723 100644
>> --- a/include/linux/page-flags.h
>> +++ b/include/linux/page-flags.h
>> @@ -81,6 +81,7 @@ enum pageflags {
>>  	PG_active,
>>  	PG_waiters,		/* Page has waiters, check its waitqueue. Must be bit #7 and in the same byte as "PG_locked" */
>>  	PG_slab,
>> +	PG_pmalloc,
>>  	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
>>  	PG_arch_1,
>>  	PG_reserved,
>> @@ -274,6 +275,7 @@ PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
>>  	TESTCLEARFLAG(Active, active, PF_HEAD)
>>  __PAGEFLAG(Slab, slab, PF_NO_TAIL)
>>  __PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
>> +__PAGEFLAG(Pmalloc, pmalloc, PF_NO_TAIL)
>>  PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
>>  
>>  /* Xen */
> 
> 
> So i don't think we want to waste a page flag on this. The struct 
> page flags field is already full AFAIK (see page-flags-layout.h)

okay, I do not have any specific need to have a page flag, if there is
an equally effective way to identify pages that are served by pmalloc.
I just replicated what seemed to be the typical way.

> Moreover there is easier way to tag such page. So my understanding
> is that pmalloc() is always suppose to be in vmalloc area. 

At least for now, yes.
I need to have some sort of memory-provider backend.
I tried to use a dedicated memory zone and kmalloc [1] but it was
explained to me that it would have been a bad idea.
So I defaulted to vmalloc and so far it didn't rise any objection.

> From
> the look of it all you do is check that there is a valid page behind
> the vmalloc vaddr and you check for the PG_malloc flag of that page.
> 
> Why do you need to check the PG_malloc flag for the page ? Isn't the
> fact that there is a page behind the vmalloc vaddr enough ? If not
> enough wouldn't checking the pte flags of the page enough ? ie if
> the page is read only inside vmalloc than it would be for sure some
> pmalloc area.

I had similar discussion with Kees Cook [2].
The reason why he asked me to differentiate between pmalloc and vmalloc
is that, from security perspective, there is a certain amount of
information associated to the fact that a page was obtained through
pmalloc. Checking only for pmalloc, would discard such information and
relax the constraint enforced from hardened user copy.

> Other way to distinguish between regular vmalloc and pmalloc can be
> to carveout a region of vmalloc for pmalloc purpose. Issue is that
> it might be hard to find right size for such carveout.

Yes, I considered that, but I'd prefer to avoid it, because then I
either have to fix the maximum size of such region or start managing the
creation of pools of pools. I'm not a big fan of such idea.

> Yet another way is to use some of the free struct page fields ie
> when a page is allocated for vmalloc i think most of struct page
> fields are unuse (mapping, index, lru, ...). It would be better
> to use those rather than adding a page flag.

Like introducing an unnamed union? Some sort of vmalloc_page_subtype?
If that is what you are proposing, I agree that it would work in a
similar fashion as what I have now, but without introducing the overhead
of the extra page flag.

@Kees: would this be ok from a hardened usercopy perspective?

> Everything else looks good to me, thought i am unsure on how much
> useful such feature is but i am not familiar too much with security
> side of thing.

The other 2 patches from the patchset give an example of how to turn a
compile time decision (locking down after init or not the lsm hooks)
into a boot time option.

I also want to move the SE Linux policy db to use pmalloc as allocator,
once pmalloc is merged.

But it seemed better to first get pmalloc merged and only after start
the policy db rework.

thanks, igor

[1] https://lkml.org/lkml/2017/5/4/517
[2] https://lkml.org/lkml/2017/5/23/1406

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
