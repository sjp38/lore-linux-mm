Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 61FF26B02E4
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 18:33:26 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 80so76225675pfy.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 15:33:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 31si4939486plf.32.2017.01.19.15.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 15:33:25 -0800 (PST)
Date: Thu, 19 Jan 2017 15:33:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/1] mm/ksm: improve deduplication of zero pages with
 colouring
Message-Id: <20170119153324.69cd6ba29704b02040412ec6@linux-foundation.org>
In-Reply-To: <1484850953-23941-1-git-send-email-imbrenda@linux.vnet.ibm.com>
References: <1484850953-23941-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, borntraeger@de.ibm.com, hughd@google.com, aarcange@redhat.com, chrisw@sous-sol.org, linux-kernel@vger.kernel.org

On Thu, 19 Jan 2017 19:35:53 +0100 Claudio Imbrenda <imbrenda@linux.vnet.ibm.com> wrote:

> Some architectures have a set of zero pages (coloured zero pages)
> instead of only one zero page, in order to improve the cache
> performance. In those cases, the kernel samepage merger (KSM) would
> merge all the allocated pages that happen to be filled with zeroes to
> the same deduplicated page, thus losing all the advantages of coloured
> zero pages.
> 
> This behaviour is noticeable when a process accesses large arrays of
> allocated pages containing zeroes. A test I conducted on s390 shows
> that there is a speed penalty when KSM merges such pages, compared to
> not merging them or using actual zero pages from the start without
> breaking the COW.
> 
> This patch fixes this behaviour. When coloured zero pages are present,
> the checksum of a zero page is calculated during initialisation, and
> compared with the checksum of the current canditate during merging. In
> case of a match, the normal merging routine is used to merge the page
> with the correct coloured zero page, which ensures the candidate page
> is checked to be equal to the target zero page.
> 
> A sysfs entry is also added to toggle this behaviour, since it can
> potentially introduce performance regressions, especially on
> architectures without coloured zero pages. The default value is
> disabled, for backwards compatibility.
> 
> With this patch, the performance with KSM is the same as with non
> COW-broken actual zero pages, which is also the same as without KSM.
> 
> ...
>
> @@ -2233,6 +2267,28 @@ static ssize_t merge_across_nodes_store(struct kobject *kobj,
>  KSM_ATTR(merge_across_nodes);
>  #endif
>  
> +static ssize_t use_zero_pages_show(struct kobject *kobj,
> +				struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%u\n", ksm_use_zero_pages);
> +}
> +static ssize_t use_zero_pages_store(struct kobject *kobj,
> +				   struct kobj_attribute *attr,
> +				   const char *buf, size_t count)
> +{
> +	int err;
> +	bool value;
> +
> +	err = kstrtobool(buf, &value);
> +	if (err)
> +		return -EINVAL;
> +
> +	ksm_use_zero_pages = value;
> +
> +	return count;
> +}
> +KSM_ATTR(use_zero_pages);

Please send along an update for Documentation/vm/ksm.txt?  Be sure that
it fully explains "since it can potentially introduce performance
regressions", so our users are able to understand whether or not they
should use this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
