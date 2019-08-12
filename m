Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56528C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:21:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08977206A2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:21:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="lDBMVyRn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08977206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC0526B0003; Mon, 12 Aug 2019 18:21:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4A3D6B0005; Mon, 12 Aug 2019 18:21:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 910516B0006; Mon, 12 Aug 2019 18:21:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0213.hostedemail.com [216.40.44.213])
	by kanga.kvack.org (Postfix) with ESMTP id 6A48E6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:21:53 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 08BDD180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:21:53 +0000 (UTC)
X-FDA: 75815199306.26.toys36_4a8e6967ca854
X-HE-Tag: toys36_4a8e6967ca854
X-Filterd-Recvd-Size: 7915
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:21:52 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d51e6800000>; Mon, 12 Aug 2019 15:21:52 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 12 Aug 2019 15:21:50 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 12 Aug 2019 15:21:50 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 12 Aug
 2019 22:21:50 +0000
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
To: Ira Weiny <ira.weiny@intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-rdma@vger.kernel.org>
References: <20190812015044.26176-1-jhubbard@nvidia.com>
 <20190812015044.26176-3-jhubbard@nvidia.com>
 <20190812220340.GA26305@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <0b66c1f8-c694-7971-b2d3-e1dd53a0f103@nvidia.com>
Date: Mon, 12 Aug 2019 15:21:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190812220340.GA26305@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565648512; bh=uQPl7D4DEl8AVSuP+2Fq2Helx9cv9AvXMSaieCMT7oA=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=lDBMVyRnFKunGUOR/0vpLpZtJOa9QH7VEGqfPR59AhGyeeukIzGUoz9b2kBImVw7H
	 y8cnr9Sd//+TBEcrXo9JyNphHRFzRQgJ85myw2lNi+kM6UpUUnytx9+GhUeXP9FKZ3
	 RgoJQNeEGGMUnduEAVPhVoM3HZX/ST0NXgedIKw8OttfofCcgaRwxUvU0yjmLHTOzG
	 m5CZ8Z7yajenjJDzRcT7W+lJF+01cDcxKn2xWig68moCWvUMubbCMJ6xnFNn5c/Kga
	 oo7WH7P6nyLqX/egqMWZyT9SX3Cawy0d9q4Ay6DRQakwmqgJWdNqonVaHWGMH2xGSU
	 8GUs/eRg3PT6Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/12/19 3:03 PM, Ira Weiny wrote:
> On Sun, Aug 11, 2019 at 06:50:44PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
...
>> +/**
>> + * vaddr_pin_pages pin pages by virtual address and return the pages to the
> 
> vaddr_pin_pages_remote
> 
> Fixed in my tree.


thanks. :)


> 
>> + * user.
>> + *
>> + * @tsk:	the task_struct to use for page fault accounting, or
>> + *		NULL if faults are not to be recorded.
>> + * @mm:		mm_struct of target mm
>> + * @addr:	start address
>> + * @nr_pages:	number of pages to pin
>> + * @gup_flags:	flags to use for the pin
>> + * @pages:	array of pages returned
>> + * @vaddr_pin:	initialized meta information this pin is to be associated
>> + * with.
>> + *
>> + * This is the "vaddr_pin_pages" corresponding variant to
>> + * get_user_pages_remote(), but with FOLL_PIN semantics: the implementation sets
>> + * FOLL_PIN. That, in turn, means that the pages must ultimately be released
>> + * by put_user_page().
>> + */
>> +long vaddr_pin_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
>> +			    unsigned long start, unsigned long nr_pages,
>> +			    unsigned int gup_flags, struct page **pages,
>> +			    struct vm_area_struct **vmas, int *locked,
>> +			    struct vaddr_pin *vaddr_pin)
>> +{
>> +	gup_flags |= FOLL_TOUCH | FOLL_REMOTE | FOLL_PIN;
>> +
>> +	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
>> +				       locked, gup_flags, vaddr_pin);
>> +}
>> +EXPORT_SYMBOL(vaddr_pin_pages_remote);
>> +
>>  /**
>>   * vaddr_unpin_pages_dirty_lock - counterpart to vaddr_pin_pages
>>   *
>> @@ -2536,3 +2568,21 @@ void vaddr_unpin_pages_dirty_lock(struct page **pages, unsigned long nr_pages,
>>  	__put_user_pages_dirty_lock(vaddr_pin, pages, nr_pages, make_dirty);
>>  }
>>  EXPORT_SYMBOL(vaddr_unpin_pages_dirty_lock);
>> +
>> +/**
>> + * vaddr_unpin_pages - simple, non-dirtying counterpart to vaddr_pin_pages
>> + *
>> + * @pages: array of pages returned
>> + * @nr_pages: number of pages in pages
>> + * @vaddr_pin: same information passed to vaddr_pin_pages
>> + *
>> + * Like vaddr_unpin_pages_dirty_lock, but for non-dirty pages. Useful in putting
>> + * back pages in an error case: they were never made dirty.
>> + */
>> +void vaddr_unpin_pages(struct page **pages, unsigned long nr_pages,
>> +		       struct vaddr_pin *vaddr_pin)
>> +{
>> +	__put_user_pages_dirty_lock(vaddr_pin, pages, nr_pages, false);
>> +}
>> +EXPORT_SYMBOL(vaddr_unpin_pages);
> 
> Rather than have another wrapping call why don't we just do this?  Would it be
> so bad to just have to specify false for make_dirty?

Sure, passing in false for make_dirty is fine, and in fact, there may even be
error cases I've forgotten about that *want* to dirty the page. 

I thought about these variants, and realized that we don't generally need to 
say "lock" anymore, because we're going to forcibly use set_page_dirty_lock 
(rather than set_page_dirty) in this part of the code. And a shorter name 
is nice. Since you've dropped both "_dirty" and "_lock" from the function 
name, it's still nice and short even though we pass in make_dirty as an arg.

So that's a long-winded, "the API below looks good to me". :)

> 
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index e77b250c1307..ca660a5e8206 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2540,7 +2540,7 @@ long vaddr_pin_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
>  EXPORT_SYMBOL(vaddr_pin_pages_remote);
>  
>  /**
> - * vaddr_unpin_pages_dirty_lock - counterpart to vaddr_pin_pages
> + * vaddr_unpin_pages - counterpart to vaddr_pin_pages
>   *
>   * @pages: array of pages returned
>   * @nr_pages: number of pages in pages
> @@ -2551,26 +2551,9 @@ EXPORT_SYMBOL(vaddr_pin_pages_remote);
>   * in vaddr_pin_pages should be passed back into this call for proper
>   * tracking.
>   */
> -void vaddr_unpin_pages_dirty_lock(struct page **pages, unsigned long nr_pages,
> -                                 struct vaddr_pin *vaddr_pin, bool make_dirty)
> +void vaddr_unpin_pages(struct page **pages, unsigned long nr_pages,
> +                      struct vaddr_pin *vaddr_pin, bool make_dirty)
>  {
>         __put_user_pages_dirty_lock(vaddr_pin, pages, nr_pages, make_dirty);
>  }
>  EXPORT_SYMBOL(vaddr_unpin_pages_dirty_lock);
> -
> -/**
> - * vaddr_unpin_pages - simple, non-dirtying counterpart to vaddr_pin_pages
> - *
> - * @pages: array of pages returned
> - * @nr_pages: number of pages in pages
> - * @vaddr_pin: same information passed to vaddr_pin_pages
> - *
> - * Like vaddr_unpin_pages_dirty_lock, but for non-dirty pages. Useful in putting
> - * back pages in an error case: they were never made dirty.
> - */
> -void vaddr_unpin_pages(struct page **pages, unsigned long nr_pages,
> -                      struct vaddr_pin *vaddr_pin)
> -{
> -       __put_user_pages_dirty_lock(vaddr_pin, pages, nr_pages, false);
> -}
> -EXPORT_SYMBOL(vaddr_unpin_pages);
> 

thanks,
-- 
John Hubbard
NVIDIA

