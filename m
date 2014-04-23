Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id DDAEC6B0038
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 14:20:43 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id uy17so4679058igb.15
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 11:20:43 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id h20si17069341igq.11.2014.04.23.11.20.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Apr 2014 11:20:42 -0700 (PDT)
Message-ID: <53580476.6040801@infradead.org>
Date: Wed, 23 Apr 2014 11:20:38 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: mmotm 2014-04-22-15-20 uploaded (uml 32- and 64-bit defconfigs)
References: <20140422222121.2FAB45A431E@corp2gmr1-2.hot.corp.google.com>	<5357F405.20205@infradead.org>	<20140423134131.778f0d0a@redhat.com>	<5357FCEB.2060507@infradead.org> <20140423141600.4a303d95@redhat.com>
In-Reply-To: <20140423141600.4a303d95@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, nacc@linux.vnet.ibm.com, Richard Weinberger <richard@nod.at>

On 04/23/14 11:16, Luiz Capitulino wrote:
> On Wed, 23 Apr 2014 10:48:27 -0700
> Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>> On 04/23/14 10:41, Luiz Capitulino wrote:
>>> On Wed, 23 Apr 2014 10:10:29 -0700
>>> Randy Dunlap <rdunlap@infradead.org> wrote:
>>>
>>>> On 04/22/14 15:21, akpm@linux-foundation.org wrote:
>>>>> The mm-of-the-moment snapshot 2014-04-22-15-20 has been uploaded to
>>>>>
>>>>>    http://www.ozlabs.org/~akpm/mmotm/
>>>>>
>>>>> mmotm-readme.txt says
>>>>>
>>>>> README for mm-of-the-moment:
>>>>>
>>>>> http://www.ozlabs.org/~akpm/mmotm/
>>>>>
>>>>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>>>>> more than once a week.
>>>>>
>>>>> You will need quilt to apply these patches to the latest Linus release (3.x
>>>>> or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
>>>>> http://ozlabs.org/~akpm/mmotm/series
>>>>>
>>>>
>>>> include/linux/hugetlb.h:468:9: error: 'HPAGE_SHIFT' undeclared (first use in this function)
>>>
>>> The patch adding HPAGE_SHIFT usage to hugetlb.h in current mmotm is this:
>>>
>>> http://www.ozlabs.org/~akpm/mmotm/broken-out/hugetlb-ensure-hugepage-access-is-denied-if-hugepages-are-not-supported.patch
>>>
>>> But I can't reproduce the issue to be sure what the problem is. Are you
>>> building the kernel on 32bits? Can you provide the output of
>>> "grep -i huge .config" or send your .config in private?
>>>
>>
>> [adding Richard to cc:]
>>
>>
>> As in $subject, if I build uml x86 32-bit or 64-bit defconfig, the build fails with
>> this error.
> 
> Oh, I missed the subject info completely. Sorry about that.
> 
> So, the issue really seems to be introduced by patch:
> 
>  hugetlb-ensure-hugepage-access-is-denied-if-hugepages-are-not-supported.patch
> 
> And the problem is that UML doesn't define HPAGE_SHIFT. The following patch
> fixes it, but I'll let Nishanth decide what to do here.

Thanks for tracking it down.


> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 4eace5e..3aab7df 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -458,6 +458,10 @@ static inline spinlock_t *huge_pte_lock(struct hstate *h,
>  	return ptl;
>  }
>  
> +#ifndef HPAGE_SHIFT
> +#define HPAGE_SHIFT 0
> +#endif
> +
>  static inline bool hugepages_supported(void)
>  {
>  	/*
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
