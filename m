Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B28316B007E
	for <linux-mm@kvack.org>; Wed, 11 May 2016 05:14:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y84so31393537lfc.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 02:14:56 -0700 (PDT)
Received: from 1.mo2.mail-out.ovh.net (1.mo2.mail-out.ovh.net. [46.105.63.121])
        by mx.google.com with ESMTPS id fl6si8053254wjb.189.2016.05.11.02.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 02:14:55 -0700 (PDT)
Received: from player771.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo2.mail-out.ovh.net (Postfix) with ESMTP id DDEA51000958
	for <linux-mm@kvack.org>; Wed, 11 May 2016 11:14:54 +0200 (CEST)
Subject: Re: [Question] Missing data after DMA read transfer - mm issue with
 transparent huge page?
References: <15edf085-c21b-aa1c-9f1f-057d17b8a1a3@morey-chaisemartin.com>
 <alpine.LSU.2.11.1605022020560.5004@eggly.anvils>
 <20160503101153.GA7241@gmail.com>
 <07619be9-e812-5459-26dd-ceb8c6490520@morey-chaisemartin.com>
 <20160510100104.GA18820@gmail.com>
 <80f878a0-f71b-2969-f2eb-05f4509ff58a@morey-chaisemartin.com>
 <20160510133401.GB18820@gmail.com>
From: Nicolas Morey Chaisemartin <devel@morey-chaisemartin.com>
Message-ID: <b141c0e6-b69d-7b66-34c6-ea22e0f65d97@morey-chaisemartin.com>
Date: Wed, 11 May 2016 11:14:40 +0200
MIME-Version: 1.0
In-Reply-To: <20160510133401.GB18820@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Williamson <alex.williamson@redhat.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



Le 05/10/2016 a 03:34 PM, Jerome Glisse a ecrit :
> On Tue, May 10, 2016 at 01:15:02PM +0200, Nicolas Morey Chaisemartin wrote:
>> Le 05/10/2016 a 12:01 PM, Jerome Glisse a ecrit :
>>> On Tue, May 10, 2016 at 09:04:36AM +0200, Nicolas Morey Chaisemartin wrote:
>>>> Le 05/03/2016 a 12:11 PM, Jerome Glisse a ecrit :
>>>>> On Mon, May 02, 2016 at 09:04:02PM -0700, Hugh Dickins wrote:
>>>>>> On Fri, 29 Apr 2016, Nicolas Morey Chaisemartin wrote:
> [...]
>
>>>> Hi,
>>>>
>>>> I backported the patch to 3.10 (had to copy paste pmd_protnone defitinition from 4.5) and it's working !
>>>> I'll open a ticket in Redhat tracker to try and get this fixed in RHEL7.
>>>>
>>>> I have a dumb question though: how can we end up in numa/misplaced memory code on a single socket system?
>>>>
>>> This patch is not a fix, do you see bug message in kernel log ? Because if
>>> you do that it means we have a bigger issue.
>> I don't see any on my 3.10. I have DMA_API_DEBUG enabled but I don't think it has an impact.
> My patch can't be backported to 3.10 as is, you most likely need to replace
> pmd_protnone() by pmd_numa()
>
>>> You did not answer one of my previous question, do you set get_user_pages
>>> with write = 1 as a paremeter ?
>> For the read from the device, yes:
>>         down_read(&current->mm->mmap_sem);
>>         res = get_user_pages(
>>                 current,
>>                 current->mm,
>>                 (unsigned long) iov->host_addr,
>>                 page_count,
>>                 (write_mode == 0) ? 1 : 0,      /* write */
>>                 0,      /* force */
>>                 &trans->pages[sg_o],
>>                 NULL);
>>         up_read(&current->mm->mmap_sem);
> As i don't have context to infer how write_mode is set above, do you mind
> retesting your driver and always asking for write no matter what ?
write_mode is 0 for car2host transfers so yes, write_mode is 1.
During debug I tried with write_mode=1 and force=1 in all cases and it failed too.
>>> Also it would be a lot easier if you were testing with lastest 4.6 or 4.5
>>> not RHEL kernel as they are far appart and what might looks like same issue
>>> on both might be totaly different bugs.
>> Is a RPM from elrepo ok?
>> http://elrepo.org/linux/kernel/el7/SRPMS/
> Yes should be ok for testing.
>
I tried the elrpo 4.5.2 package without your patch and my test fails, sadly the src rpm from elrepo does not contaisn the kernel sources and I haven't looked how to get the proper tarball.
I tried to rebuild a src rpm for a fedora 24 (kernel 4.5.3) and it works without your patch. I'm not sure what differs in their config. I'll keep digging.

Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
