Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 38E756B0255
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 18:59:02 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so226539151wic.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 15:59:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ez6si6552528wid.72.2015.09.23.15.59.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Sep 2015 15:59:00 -0700 (PDT)
Date: Wed, 23 Sep 2015 15:58:52 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: Multiple potential races on vma->vm_flags
Message-ID: <20150923225852.GA10657@linux-uzut.site>
References: <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com>
 <20150911103959.GA7976@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1509111734480.7660@eggly.anvils>
 <55F8572D.8010409@oracle.com>
 <20150915190143.GA18670@node.dhcp.inet.fi>
 <CAAeHK+wABeppPQCsTmUk6cMswJosgkaXkHO5QTFBh=1ZTi+-3w@mail.gmail.com>
 <alpine.LSU.2.11.1509221151370.11653@eggly.anvils>
 <CAAeHK+zkG4L7TJ3M8fus8F5KExHRMhcyjgEQop=wqOpBcrKzYQ@mail.gmail.com>
 <alpine.LSU.2.11.1509221831570.19790@eggly.anvils>
 <20150923114636.GB25020@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20150923114636.GB25020@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Andrey Konovalov <andreyknvl@google.com>, Sasha Levin <sasha.levin@oracle.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, 23 Sep 2015, Kirill A. Shutemov wrote:

>On Tue, Sep 22, 2015 at 06:39:52PM -0700, Hugh Dickins wrote:
>>[...]
>> I'd rather wait to hear whether this appears to work in practice,
>> and whether you agree that it should work in theory, before writing
>> the proper description.  I'd love to lose that down_read_trylock.
>>
>> You mention how Sasha hit the "Bad page state (mlocked)" back in
>> November: that was one of the reasons we reverted Davidlohr's
>> i_mmap_lock_read to i_mmap_lock_write in unmap_mapping_range(),
>> without understanding why it was needed.  Yes, it would lock out
>> a concurrent try_to_unmap(), whose setting of PageMlocked was not
>> sufficiently serialized by the down_read_trylock of mmap_sem.
>>
>> But I don't remember the other reasons for that revert (and
>> haven't looked very hard as yet): anyone else remember?

Yeah, I don't think this was ever resolved, but ultimately the patch
got reverted[1] because it exposed issues in the form of bad pages
(shmem, vmsplice) and corrupted vm_flags while in untrack_pfn() causing,
for example, vm_file to dissapear.

>I hoped Davidlohr will come back with something after the revert, but it
>never happend. I think the reverted patch was responsible for most of
>scalability boost from rwsem for i_mmap_lock...

Actually no, the change that got reverted was something we got in very
last minute, just because it made sense and had the blessing of some
key people. The main winner of the series was migration (rmap), which
later Hugh addressed more specifically for unmapped pages:

https://lkml.org/lkml/2014/11/30/349

So I really didn't care about the reverted patch, and therefore was never
on my radar.

[1] https://lkml.org/lkml/2014/12/22/375

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
