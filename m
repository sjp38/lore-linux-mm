Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81ACBC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 14:33:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3957C23A57
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 14:33:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3957C23A57
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 978666B000E; Wed, 29 May 2019 10:33:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 928A16B0010; Wed, 29 May 2019 10:33:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 817DC6B0266; Wed, 29 May 2019 10:33:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 13B116B000E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 10:33:18 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id d18so755102lfn.11
        for <linux-mm@kvack.org>; Wed, 29 May 2019 07:33:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ai/tZzHsucrZ/HLP0HEiPJV0lYzFFYTLQhHIn3KF/u8=;
        b=ErOoUHbp4fNQgqbmIpjetw8+qCQV1TwAKin5NaX0OaDEFRa64ndq3XcQ5JVCJJteYn
         clLpqVyoghowHBXh/VOM8W74qwGQSH2hasSTGMX0I0lVaYDCGVQ1GCYiRUfAczhry2rJ
         F+AJST4pFsA/Zq6gv3t2JKf78dRPHz0k3Xs3lZCUY48ZYylM2VnBEiiLqKVOSo19ZA+i
         ZdQDgF0NasgMOZznLladiCKH/S5oZBpk5yNUYEx+2aJ5MGX9ZQIhGCzH5eDum71SBp8L
         yoeoTbT7b6fm1CZDrEJXUTemWz3vLLGlkRXdvBraE9o2PTf2ePOLd1lNWm+eeDF2RFoF
         Zoxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWv82m/mPGRWf8ndK16PeZEThPOqds2RGbFfxFDXB/DpTTmJpvx
	yg7oW1cDKkoexDt5Y/iHYV5a7pcuxUiWQZDpt4O3CrQUe7W/nFtLvG+/1XnnNsUXdFPepmZdKi1
	Q9ROVGkyAB/vkkm9MNLWGycNsfTPNPMNewCZ6tpyfhIqpDo3ifYa+bouLyi+uXXMMww==
X-Received: by 2002:ac2:419a:: with SMTP id z26mr29507866lfh.122.1559140397403;
        Wed, 29 May 2019 07:33:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwy9CICVaAh8ZJnf/QhZhf/z4DRLx+CUPyGNIW4svmnq1pcthQiFd44U2doSyyUz/Z/LQgo
X-Received: by 2002:ac2:419a:: with SMTP id z26mr29507812lfh.122.1559140396055;
        Wed, 29 May 2019 07:33:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559140396; cv=none;
        d=google.com; s=arc-20160816;
        b=BHuT17vTthVLFmnrieiIGJTUUbOiRtohufnKKyQKXhzPaOYraO/ju0erl1AeiHFT1O
         z0IufyeU7EOQtz6OLqdK7QNo6qIKrzD+HxsmIZ6bdryLZaU8SrP4ty+rJSsuu/+akdlj
         7pMiJazZCm+KGSxYxU4rroK05TC/5s16nEFMGdZdl0sjvsFF664UTc+RuTYsJfx5b3OG
         WfzxhUCS4utt9y/7gYaCVvNXMZLbjpGKAcj5xpHuXVRdrdSu8jlJ9IAwQoISrUvXAgMK
         oqt7ctxnKFhHJL9hfipWIF1qC9MuhxSInQImu6MRvnCpo6yaNt9Kf1whD8/EVxqIw9GH
         HcuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ai/tZzHsucrZ/HLP0HEiPJV0lYzFFYTLQhHIn3KF/u8=;
        b=HJO7QuDXFsVVxCp4RMboAKkZIMSUkcQ00cuy3nrLlYrUSo55T00VY3myR9T5rxPDnF
         dRH7ViDYwBhGG9W86bdWo5akNjzvpZwJqkAV6cJDd5wELfQaCE4yAvKnVgFCfxR8wTrN
         Z6VHwTe1edcBQPIZ3F+xOc/s7rqHmhn3mP1YEzCcscQMkqpiaMa0hdVqSIBro//a1jt+
         c3iFUyEHwCo5Wh1q5Wv0QKK69YI8FOPkyU5P7JC51yTvss1+evHoxsByJdDFMyUF8hTw
         aIBssh8Z2ShPPqParKA2bVe23Egsb/RehZVA/+X0CMEVn6AT9u6It5ipY6VqO9oHDKtH
         OC/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id d13si14786498lfi.8.2019.05.29.07.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 07:33:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hVzdY-00049P-4C; Wed, 29 May 2019 17:33:04 +0300
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
 keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com,
 andreyknvl@google.com, arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com,
 riel@surriel.com, keescook@chromium.org, hannes@cmpxchg.org,
 npiggin@gmail.com, mathieu.desnoyers@efficios.com, shakeelb@google.com,
 guro@fb.com, aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <20190522152254.5cyxhjizuwuojlix@box>
 <358bb95e-0dca-6a82-db39-83c0cf09a06c@virtuozzo.com>
 <20190524115239.ugxv766doolc6nsc@box>
 <c3cd3719-0a5e-befe-89f2-328526bb714d@virtuozzo.com>
 <20190527233030.hpnnbi4aqnu34ova@box>
 <de6e4e89-66ac-da2f-48a6-4d98a728687a@virtuozzo.com>
 <20190528161524.tn5sqzhmhgyuwrmy@box>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <4b9a6b90-4d82-9d4d-466d-653f9024849f@virtuozzo.com>
Date: Wed, 29 May 2019 17:33:02 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190528161524.tn5sqzhmhgyuwrmy@box>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.05.2019 19:15, Kirill A. Shutemov wrote:
> On Tue, May 28, 2019 at 12:15:16PM +0300, Kirill Tkhai wrote:
>> On 28.05.2019 02:30, Kirill A. Shutemov wrote:
>>> On Fri, May 24, 2019 at 05:00:32PM +0300, Kirill Tkhai wrote:
>>>> On 24.05.2019 14:52, Kirill A. Shutemov wrote:
>>>>> On Fri, May 24, 2019 at 01:45:50PM +0300, Kirill Tkhai wrote:
>>>>>> On 22.05.2019 18:22, Kirill A. Shutemov wrote:
>>>>>>> On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
>>>>>>>> This patchset adds a new syscall, which makes possible
>>>>>>>> to clone a VMA from a process to current process.
>>>>>>>> The syscall supplements the functionality provided
>>>>>>>> by process_vm_writev() and process_vm_readv() syscalls,
>>>>>>>> and it may be useful in many situation.
>>>>>>>
>>>>>>> Kirill, could you explain how the change affects rmap and how it is safe.
>>>>>>>
>>>>>>> My concern is that the patchset allows to map the same page multiple times
>>>>>>> within one process or even map page allocated by child to the parrent.
>>>>>>>
>>>>>>> It was not allowed before.
>>>>>>>
>>>>>>> In the best case it makes reasoning about rmap substantially more difficult.
>>>>>>>
>>>>>>> But I'm worry it will introduce hard-to-debug bugs, like described in
>>>>>>> https://lwn.net/Articles/383162/.
>>>>>>
>>>>>> Andy suggested to unmap PTEs from source page table, and this make the single
>>>>>> page never be mapped in the same process twice. This is OK for my use case,
>>>>>> and here we will just do a small step "allow to inherit VMA by a child process",
>>>>>> which we didn't have before this. If someone still needs to continue the work
>>>>>> to allow the same page be mapped twice in a single process in the future, this
>>>>>> person will have a supported basis we do in this small step. I believe, someone
>>>>>> like debugger may want to have this to make a fast snapshot of a process private
>>>>>> memory (when the task is stopped for a small time to get its memory). But for
>>>>>> me remapping is enough at the moment.
>>>>>>
>>>>>> What do you think about this?
>>>>>
>>>>> I don't think that unmapping alone will do. Consider the following
>>>>> scenario:
>>>>>
>>>>> 1. Task A creates and populates the mapping.
>>>>> 2. Task A forks. We have now Task B mapping the same pages, but
>>>>> write-protected.
>>>>> 3. Task B calls process_vm_mmap() and passes the mapping to the parent.
>>>>>
>>>>> After this Task A will have the same anon pages mapped twice.
>>>>
>>>> Ah, sure.
>>>>
>>>>> One possible way out would be to force CoW on all pages in the mapping,
>>>>> before passing the mapping to the new process.
>>>>
>>>> This will pop all swapped pages up, which is the thing the patchset aims
>>>> to prevent.
>>>>
>>>> Hm, what about allow remapping only VMA, which anon_vma::rb_root contain
>>>> only chain and which vma->anon_vma_chain contains single entry? This is
>>>> a vma, which were faulted, but its mm never were duplicated (or which
>>>> forks already died).
>>>
>>> The requirement for the VMA to be faulted (have any pages mapped) looks
>>> excessive to me, but the general idea may work.
>>>
>>> One issue I see is that userspace may not have full control to create such
>>> VMA. vma_merge() can merge the VMA to the next one without any consent
>>> from userspace and you'll get anon_vma inherited from the VMA you've
>>> justed merged with.
>>>
>>> I don't have any valid idea on how to get around this.
>>
>> Technically it is possible by creating boundary 1-page VMAs with another protection:
>> one above and one below the desired region, then map the desired mapping. But this
>> is not comfortable.
>>
>> I don't think it's difficult to find a natural limitation, which prevents mapping
>> a single page twice if we want to avoid this at least on start. Another suggestion:
>>
>> prohibit to map a remote process's VMA only in case of its vm_area_struct::anon_vma::root
>> is the same as root of one of local process's VMA.
>>
>> What about this?
> 
> I don't see anything immediately wrong with this, but it's still going to
> produce puzzling errors for a user. How would you document such limitation
> in the way it makes sense for userspace developer?

It's difficult, since the limitation is artificial.

I just may to suggest more strict limitation.

Something like "VMA may be remapped only as a whole region,
and only in the case of there were not fork() after VMA
appeared in a process (by mmap or remapping from another
remote process). In case of VMA were merged with a neighbouring
VMA, the same rules are applied to the neighbours.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..0bcd6f598e73 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -287,13 +287,17 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_5	37	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
 #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+#define VM_HIGH_ARCH_5	BIT(VM_HIGH_ARCH_BIT_5)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
+#define VM_MAY_REMOTE_REMAP	VM_HIGH_ARCH_5
+
 #ifdef CONFIG_ARCH_HAS_PKEYS
 # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
 # define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit value */
diff --git a/kernel/fork.c b/kernel/fork.c
index ff4efd16fd82..a3c758c8cd54 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -584,8 +584,10 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		if (!(tmp->vm_flags & VM_WIPEONFORK))
+		if (!(tmp->vm_flags & VM_WIPEONFORK)) {
 			retval = copy_page_range(mm, oldmm, mpnt);
+			mpnt->vm_flags &= ~VM_MAY_REMOTE_REMAP;
+		}
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);

