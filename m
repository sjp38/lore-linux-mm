Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id B9C096B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 11:49:41 -0500 (EST)
Message-ID: <4EF8A59C.9050601@parallels.com>
Date: Mon, 26 Dec 2011 20:49:32 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mincore: Introduce the MINCORE_ANON bit
References: <4EF78B6A.8020904@parallels.com> <4EF78B99.1020109@parallels.com> <CAHGf_=r5mmUJUaQLKgrY1rf9Qx0gO0hEJaHFehm5Zz7ZKMYUkQ@mail.gmail.com> <4EF89BCB.8070306@parallels.com> <CAHGf_=rJhpQyhWiVk_BALM7SG=rgbVLscLMqdmmC4OLBR70mOA@mail.gmail.com>
In-Reply-To: <CAHGf_=rJhpQyhWiVk_BALM7SG=rgbVLscLMqdmmC4OLBR70mOA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On 12/26/2011 08:35 PM, KOSAKI Motohiro wrote:
> 2011/12/26 Pavel Emelyanov <xemul@parallels.com>:
>> On 12/26/2011 04:05 AM, KOSAKI Motohiro wrote:
>>>> +static unsigned char mincore_pte(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
>>>> +{
>>>> +       struct page *pg;
>>>> +
>>>> +       pg = vm_normal_page(vma, addr, pte);
>>>> +       if (!pg)
>>>> +               return 0;
>>>> +       else
>>>> +               return PageAnon(pg) ? MINCORE_ANON : 0;
>>>> +}
>>>> +
>>>
>>> How do your program handle tmpfs pages (and/or ram device pages)?
>>
>> Do you mean mapped files from tmpfs? Currently just any other file.
>> Do you see problems with this patch wrt tmpfs?
> 
> If you don't save mapped file on tmpfs or other volatile devices, the process
> might not restored. The data might already destroyed. 

Yes I know this, thanks :\

> The common strategy are two,
> 
> 1) save all opened file by different ways.
> 2) save all mapped file even though clean file cache.
> 
> In both case, we don't reduce freezed data size. So, I'm interesting
> you strategy.

The tmpfs contents itself is supposed to be preserved, it's not a problem. The problem I'm trying
to solve here is which page from task mappings (i.e. vm_area_struct-s) to save and which not to.

Do the proposed MINCORE_RESIDENT and MINCORE_ANON bits have problems with this from
your POV?

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
