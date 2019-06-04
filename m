Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21B14C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:32:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0A9524A3C
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:32:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0A9524A3C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 297336B026B; Tue,  4 Jun 2019 05:32:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2477B6B026C; Tue,  4 Jun 2019 05:32:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15E4D6B0274; Tue,  4 Jun 2019 05:32:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A338B6B026B
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 05:32:57 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id c25so3034895ljb.3
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 02:32:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=6dtfLqsrTNUKAkLmSfJSEil7cGEYGcNJKGj5jtnh1iU=;
        b=dF9ld1ghfBloc6FbARBAaDsOWNTxtansWHYIde0DEGDlIVzmAdtprazTm4kiZ5u92u
         IW8I0JfwjQLmpnglnBD+deqVxPzQcSAwPeYLcaNleZm7hkW0kug3+FZS97vbOmBpCaWV
         b+6gnNttk9c9Ww2OcblseDC7KZQTG+no2ME98XMSXMqDjDkODJAmlVxDd/qbvyb6fWMa
         Pe0m+GEP1b+a/Zsg+0VrTVLWYz4b47ARXb0/H/wd+tzTj0uWm1y05eovFO5L7G5uffkq
         sPtb9X+cDGGvVtTMQAp4aiefPdU4YsDJPsIckrK7ic7JtKlBU8MF/SRrbjwZZvbpSi3L
         91ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXTFdn56M/qaFR0TQFDN1f7p2WLEe+g1+7M6/FEXRxDDoIKItoT
	zgTZq7H+/Bs1jP1NymnCtDn0q/ULSq8BAUWWOlXIsLeMf9IFAGIAkgPxdBnqJh+HTqCYXYNUDZM
	6LtreDiVjazvWaOIBEDlN8dGSbpZ13StlPTDRHdmBx7dhTFNRqLh+lLpaouOKvt0YfA==
X-Received: by 2002:a19:710b:: with SMTP id m11mr11482993lfc.135.1559640776817;
        Tue, 04 Jun 2019 02:32:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwi39asUuwN2nMco0KgRaMO52RAGv4D7I2xLdpVEaslNMIrYsiadkz+A2QcCNULDtO6CNAh
X-Received: by 2002:a19:710b:: with SMTP id m11mr11482947lfc.135.1559640775814;
        Tue, 04 Jun 2019 02:32:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559640775; cv=none;
        d=google.com; s=arc-20160816;
        b=t65da0wlDBzLKxkpzH5fPiAqqQQwQWj/n7j5g1E+iN2gFqPzOc4cBnIMCTMrhKakeq
         7pDDds5Vq8k8x2EJWj924dvzp6bJSeikM/5FJ2iIaZvLQtAZD8aVNkVDmwdzoZnly5qB
         +WVvyL0/QL4QlZScF6crVEWFtKrrtwvM/OJ6esWnHTgpCeIyPDJbZGkCZRfVUz95nZOu
         YlDCv1J0TtUGOeq/33z5H8AQ6D7lOubPEqcwRpmtf7DONqAbGO9Yt74aKGCo0Jmp/upc
         fdS0I9N2zQ5+1rr8o6gq/JTn6A7uYOYicUCc4CWw5v4wTrSanGBa6gpaxFivTEWJH9Fl
         xa2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6dtfLqsrTNUKAkLmSfJSEil7cGEYGcNJKGj5jtnh1iU=;
        b=RGPaHZm22FXbQMD0YDCclY/a7KFRurJJSmFbxywfgryrB1ijbaAxvv+JS22iQrw0Mm
         eL5Za0DxB7I5Iwjl4dJwvPm2SyP7GQrUHaoZbk6kd4pYczhuFAfhOAbXbWviu1RKMOBc
         H/X1rorAtoqL+hTuuSGuR83UDhIxTicNF/6+8qq/a8c6qpBF/n406Z1sQRkuLUvltah4
         00ohDDAtzLTDPaRG0J2EwfJLlEGx6dU445+LGkJMwJ/+aXTRMIcHi+sTirS396MkL0wC
         8yJcedqiVi5bAPJSyG1H8zh1xoY+Es0+09vVXT0oOGB8cNZlcnJk4967n50ks9IK5vSO
         XMWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id n6si14793756lji.196.2019.06.04.02.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 02:32:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hY5oE-0001dh-Oe; Tue, 04 Jun 2019 12:32:46 +0300
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
 <4228b541-d31c-b76a-2570-1924df0d4724@virtuozzo.com>
 <5ae7e3c1-3875-ea1e-54b3-ac3c493a11f0@virtuozzo.com>
 <20190603174706.t4cby7f5ni4gvvom@box>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <c250a53e-dd30-3f10-1c05-e86e4e10358a@virtuozzo.com>
Date: Tue, 4 Jun 2019 12:32:46 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190603174706.t4cby7f5ni4gvvom@box>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.06.2019 20:47, Kirill A. Shutemov wrote:> On Mon, Jun 03, 2019 at 05:56:32PM +0300, Kirill Tkhai wrote:
>> On 03.06.2019 17:38, Kirill Tkhai wrote:
>>> On 22.05.2019 18:22, Kirill A. Shutemov wrote:
>>>> On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
>>>>> This patchset adds a new syscall, which makes possible
>>>>> to clone a VMA from a process to current process.
>>>>> The syscall supplements the functionality provided
>>>>> by process_vm_writev() and process_vm_readv() syscalls,
>>>>> and it may be useful in many situation.
>>>>
>>>> Kirill, could you explain how the change affects rmap and how it is safe.
>>>>
>>>> My concern is that the patchset allows to map the same page multiple times
>>>> within one process or even map page allocated by child to the parrent.
>>>
>>> Speaking honestly, we already support this model, since ZERO_PAGE() may
>>> be mapped multiply times in any number of mappings.
>>
>> Picking of huge_zero_page and mremapping its VMA to unaligned address also gives
>> the case, when the same huge page is mapped as huge page and as set of ordinary
>> pages in the same process.
>>
>> Summing up two above cases, is there really a fundamental problem with
>> the functionality the patch set introduces? It looks like we already have
>> these cases in stable kernel supported.
> 
> It *might* work. But it requires a lot of audit to prove that it actually
> *does* work.

Please, give the represent of the way the audit results should look like
for you. In case of I hadn't done some audit before patchset preparing,
I wouldn't have sent it. So, give an idea that you expect from this.

> For instance, are you sure it will not break KSM?

Yes, it does not break KSM. The main point is that in case of KSM we already
may have not just only a page mapped twice in a single process, but even
a page mapped twice in a single VMA. And this is just a particular case of
generic supported set. (Ordinary page still can't be mapped twice in a single
VMA, since pgoff differences won't allow to merge such two hunks together).

The generic rule of ksm is "everything may happen with a page in a real time,
and all of this will be reflected in stable and unstable trees and rmap_items
some time later". Pages of a duplicated VMA will be interpreted as KSM fork,
and the corresponding checks in unstable_tree_search_insert() and
stable_tree_search() provide this.

When both of source and destination VMAs are mergeable,
1)if page was added to stable tree before the duplication of related VMA,
  then during scanning destination VMA in cmp_and_merge_page() it will be
  detected as a duplicate, and we will just add related rmap_item
  to stable node chain;
2)if page was added to unstable tree before the duplication of related VMA,
  and it is remaining there, then the page will be detected as a duplicate
  in destination VMA, and the scan of page will be skipped till next turn;
3)if page was not added to any tree before the duplication, it may be added
  to one of the trees and it will be handled by one of two rules above.

When one of source or destination VMAs is not mergeable, while a page become
PageKsm() during scanning other of them, the unmergeable VMA becomes to refer
to PageKsm(), which does not have rmap_item. But it still possible to unmap
that page from unmergeable VMA, since rmap_walk_ksm() goes over all anon_vma
under rb_root. Just the same as what happens, when process forks, and its
child makes VMA unmergeable.

> What does it mean for memory accounting? memcg?

Once assigned memcg remains the same after VMA duplication. Mapped page range
advances counters in vm_stat_account(). Since we keep fork() semantics,
the same thing occurs as after fork()+mremap().

> My point is that you breaking long standing invariant in Linux MM and it
> has to be properly justified.

I'm not against that. Please, say, which form of the justification you expect.
I assume you do not mean retelling of every string of existing code, because
this way the words will take 10 times more, than the code, and just not human
possible.

Please, give the specific request what you expect, and how this should look like.

> I would expect to see some strange deadlocks or permanent trylock failure
> as result of such change.

Do you hint some specific area? Do you expect I run some specific test cases?
Do you want we add some debugging engine on top of page locking to detect such
the trylock failures?

Thanks,
Kirill

