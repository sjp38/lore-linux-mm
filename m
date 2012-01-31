Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id C9EAA6B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 07:16:39 -0500 (EST)
Message-ID: <4F27DB7B.4010103@stericsson.com>
Date: Tue, 31 Jan 2012 13:15:55 +0100
From: Maxime Coquelin <maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Subject: Re: [RFCv1 3/6] PASR: mm: Integrate PASR in Buddy allocator
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com> <1327930436-10263-4-git-send-email-maxime.coquelin@stericsson.com> <20120130152237.GS25268@csn.ul.ie> <4F26CAD1.2000209@stericsson.com>
In-Reply-To: <4F26CAD1.2000209@stericsson.com>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus WALLEIJ <linus.walleij@stericsson.com>, Andrea GALLO <andrea.gallo@stericsson.com>, Vincent GUITTOT <vincent.guittot@stericsson.com>, Philippe LANGLAIS <philippe.langlais@stericsson.com>, Loic PALLARDY <loic.pallardy@stericsson.com>

Hello Mel,
On 01/30/2012 05:52 PM, Maxime Coquelin wrote:
>
> On 01/30/2012 04:22 PM, Mel Gorman wrote:
>
>> You may be able to use the existing arch_alloc_page() hook and
>> call PASR on architectures that support it if and only if PASR is
>> present and enabled by the administrator but even this is likely to be
>> unpopular as it'll have a measurable performance impact on platforms
>> with PASR (not to mention the PASR lock will be even heavier as it'll
>> now be also used for per-cpu page allocations). To get the hook you
>> want, you'd need to show significant benefit before they were happy with
>> the hook.
> Your proposal sounds good.
> AFAIK, per-cpu allocation maximum size is 32KB. Please correct me if 
> I'm wrong.
> Since pasr_kget/kput() calls the PASR framework only on MAX_ORDER 
> allocations, we wouldn't add any locking risks nor contention compared 
> to current patch.
> I will update the patch set using  arch_alloc/free_page().
>
I just had a deeper look at when arch_alloc_page() is called. I think it 
does not fit with PASR framework needs.
pasr_kget() calls pasr_get() only for max order pages (same for 
pasr_kput()) to avoid overhead.

In current patch set, pasr_kget() is called when pages are removed from 
the free lists, and pasr_kput() when pages are inserted in the free lists.
So, pasr_get() is called in case of :
     - allocation of a max order page
     - split of a max order page into lower order pages to fulfill 
allocation of pages smaller than max order
And pasr_put() is called in case of:
     - release of a max order page
     - coalescence of two "max order -1" pages when smaller pages are 
released

If we call the PASR framework in arch_alloc_page(), we have two 
possibilities:
     1) using pasr_kget(): the PASR framework will only be notified of 
max order allocations, so the coalesce/split of free pages case will not 
be taken into account.
     2) using pasr_get(): the PASR framework will be called for every 
orders of page allocation/release. The induced overhead is not acceptable.

To avoid calling pasr_kget/kput() directly in page_alloc.c, do you think 
adding some arch specific hooks when a page is inserted or removed from 
the free lists could be acceptable?
Something like arch_insert_freepage(struct page *page, int order) and 
arch_remove_freepage(struct page *page, int order).

Regards,
Maxime

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
